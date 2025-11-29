import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:nutrition_app/models/ingredient.dart';

class FoodApiClient {
  FoodApiClient({http.Client? httpClient, String? apiKey})
      : _httpClient = httpClient ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('FDC_API_KEY', defaultValue: 'DEMO_KEY');

  final http.Client _httpClient;
  final String _apiKey;

  static const Map<String, String> _headers = <String, String>{
    'Accept': 'application/json',
    // Open Food Facts blocks generic or missing User-Agent headers, so keep this descriptive
    // and include a contact URL/email as recommended in their API guidelines.
    'User-Agent': 'RecipeApp/1.0 (https://github.com/openai/recipe_app; support@recipeapp.local)',
  };

  /// Fetches a list of ingredients from USDA FoodData Central based on a text query.
  ///
  /// Returns an empty list if no results found. Throws an [Exception] when
  /// network fails or responds with a non-200 status code.
  Future<List<Ingredient>> searchIngredients(String query) async {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = _normalize(query);

    final uri = Uri.parse('https://api.nal.usda.gov/fdc/v1/foods/search').replace(
      queryParameters: <String, String>{
        'query': query,
        'pageSize': '8',
        'dataType': 'Foundation,SR Legacy,Survey (FNDDS)',
        'requireAllWords': 'true',
        'api_key': _apiKey,
      },
    );

    print('REQUEST: $uri');

    http.Response response;
    try {
      response = await _httpClient.get(uri, headers: _headers);
      print('RESPONSE: ${response.statusCode}');
    } catch (e, st) {
      print('HTTP ERROR: $e');
      print(st);
      rethrow; // чтобы увидеть ошибку и в логах, и в UI
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products (${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    final foods = (data['foods'] as List<dynamic>?) ?? <dynamic>[];

    final ingredients = foods.map((dynamic food) {
      final List<dynamic> nutrients = (food is Map<String, dynamic> ? food['foodNutrients'] : null) as List<dynamic>? ?? [];

      double getNutrient(Set<String> numbers, Set<String> names) {
        for (final nutrient in nutrients) {
          if (nutrient is! Map<String, dynamic>) continue;
          final number = nutrient['nutrientNumber'] as String? ?? nutrient['number'] as String?;
          final name = nutrient['nutrientName'] as String? ?? nutrient['name'] as String?;
          if ((number != null && numbers.contains(number)) || (name != null && names.contains(name))) {
            final value = nutrient['value'];
            if (value is num) return value.toDouble();
          }
        }
        return 0.0;
      }

      final description = (food is Map<String, dynamic> ? food['description'] as String? : null)?.trim() ?? '';
      final brandOwner = (food is Map<String, dynamic> ? food['brandOwner'] as String? : null)?.trim() ?? '';
      final dataType = (food is Map<String, dynamic> ? food['dataType'] as String? : null)?.trim();
      final displayName = [description, if (brandOwner.isNotEmpty) brandOwner, if (dataType?.isNotEmpty == true) '[${dataType!}]']
          .where((part) => part != null && part.toString().isNotEmpty)
          .join(' ')
          .trim();

      return Ingredient(
        name: displayName.isNotEmpty ? displayName : 'Неизвестный продукт',
        caloriesPer100g: getNutrient({'208'}, {'Energy'}),
        proteinsPer100g: getNutrient({'203'}, {'Protein'}),
        fatsPer100g: getNutrient({'204'}, {'Total lipid (fat)', 'Total Fat'}),
        carbsPer100g: getNutrient({'205'}, {'Carbohydrate, by difference', 'Carbohydrate'}),
      );
    }).where((ingredient) => ingredient.name.trim().isNotEmpty).toList();

    ingredients.sort((a, b) => _scoreMatch(a.name, normalizedQuery).compareTo(_scoreMatch(b.name, normalizedQuery)));
    return ingredients;
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-zа-яё0-9]+', caseSensitive: false), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  int _scoreMatch(String name, String normalizedQuery) {
    final normalizedName = _normalize(name);
    if (normalizedName == normalizedQuery) return 0; // exact match
    if (normalizedName.startsWith(normalizedQuery)) return 1; // starts with query
    if (normalizedQuery.isNotEmpty && normalizedName.split(' ').contains(normalizedQuery)) return 2; // full word match
    return 3 + normalizedName.length; // fallback: keep deterministic ordering
  }
}