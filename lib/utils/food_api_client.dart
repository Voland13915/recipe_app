import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nutrition_app/models/ingredient.dart';

class FoodApiClient {
  FoodApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  /// Fetches a list of ingredients from Open Food Facts based on a text query.
  ///
  /// Returns an empty list if no results found. Throws an [Exception] when
  /// network fails or responds with a non-200 status code.
  Future<List<Ingredient>> searchIngredients(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl').replace(
      queryParameters: <String, String>{
        'search_terms': query,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '8',
      },
    );

    final response = await _httpClient.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products (${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    final products = (data['products'] as List<dynamic>?) ?? <dynamic>[];

    return products.map((dynamic product) {
      final Map<String, dynamic> nutriments =
          (product is Map<String, dynamic> ? product['nutriments'] : null) as Map<String, dynamic>? ?? {};
      double getNum(String key) => (nutriments[key] as num?)?.toDouble() ?? 0.0;

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
  }
}