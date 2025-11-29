import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:nutrition_app/models/ingredient.dart';

class FoodApiClient {
  FoodApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  static const Map<String, String> _headers = <String, String>{
    'Accept': 'application/json',
    // Open Food Facts blocks generic or missing User-Agent headers, so keep this descriptive
    // and include a contact URL/email as recommended in their API guidelines.
    'User-Agent': 'RecipeApp/1.0 (https://github.com/openai/recipe_app; support@recipeapp.local)',
  };

  /// Fetches a list of ingredients from Open Food Facts based on a text query.
  ///
  /// Returns an empty list if no results found. Throws an [Exception] when
  /// network fails or responds with a non-200 status code.
  Future<List<Ingredient>> searchIngredients(String query) async {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = _normalize(query);

    final uri = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl').replace(
      queryParameters: <String, String>{
        'search_terms': query,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '8',
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
    final products = (data['products'] as List<dynamic>?) ?? <dynamic>[];

    final ingredients = products.map((dynamic product) {
      final Map<String, dynamic> nutriments =
          (product is Map<String, dynamic> ? product['nutriments'] : null) as Map<String, dynamic>? ?? {};
      double getNum(String key) {
        final value = nutriments[key];
        if (value is num) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value.replaceAll(',', '.'));
          if (parsed != null) return parsed;
        }
        return 0.0;
      }

      return Ingredient(
        name: (product['product_name'] as String?)?.trim().isNotEmpty == true
            ? product['product_name'] as String
            : 'Неизвестный продукт',
        caloriesPer100g: getNum('energy-kcal_100g'),
        proteinsPer100g: getNum('proteins_100g'),
        fatsPer100g: getNum('fat_100g'),
        carbsPer100g: getNum('carbohydrates_100g'),
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