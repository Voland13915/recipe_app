import 'package:nutrition_app/models/models.dart';

class DishScoreConfig {
  final double targetCalories;
  final double targetProteins;
  final double targetFats;
  final double targetCarbs;

  final double wCalories;
  final double wProteins;
  final double wFats;
  final double wCarbs;

  const DishScoreConfig({
    this.targetCalories = 600,
    this.targetProteins = 26,
    this.targetFats = 17,
    this.targetCarbs = 80,
    this.wCalories = 2,
    this.wProteins = 3,
    this.wFats = 2,
    this.wCarbs = 1,
  });
}

class PortionNutrients {
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  const PortionNutrients({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });

  static const zero = PortionNutrients(
    calories: 0,
    proteins: 0,
    fats: 0,
    carbs: 0,
  );

  PortionNutrients operator +(PortionNutrients other) {
    return PortionNutrients(
      calories: calories + other.calories,
      proteins: proteins + other.proteins,
      fats: fats + other.fats,
      carbs: carbs + other.carbs,
    );
  }

  PortionNutrients operator -(PortionNutrients other) {
    return PortionNutrients(
      calories: calories - other.calories,
      proteins: proteins - other.proteins,
      fats: fats - other.fats,
      carbs: carbs - other.carbs,
    );
  }

  PortionNutrients scale(double multiplier) {
    return PortionNutrients(
      calories: calories * multiplier,
      proteins: proteins * multiplier,
      fats: fats * multiplier,
      carbs: carbs * multiplier,
    );
  }

  factory PortionNutrients.fromRecipe(Recipe recipe, double portionMultiplier) {
    return PortionNutrients(
      calories: recipe.caloriesPerServing * portionMultiplier,
      proteins: recipe.proteinsPerServing * portionMultiplier,
      fats: recipe.fatsPerServing * portionMultiplier,
      carbs: recipe.carbsPerServing * portionMultiplier,
    );
  }

  factory PortionNutrients.fromRecipeGrams(Recipe recipe, double gramsConsumed) {
    final gramsPerServing = recipe.gramsPerServing;
    if (gramsPerServing == null || gramsPerServing == 0) {
      return PortionNutrients.fromRecipe(recipe, gramsConsumed);
    }

    final caloriesPerGram = recipe.caloriesPerServing / gramsPerServing;
    final proteinsPerGram = recipe.proteinsPerServing / gramsPerServing;
    final fatsPerGram = recipe.fatsPerServing / gramsPerServing;
    final carbsPerGram = recipe.carbsPerServing / gramsPerServing;

    return PortionNutrients(
      calories: caloriesPerGram * gramsConsumed,
      proteins: proteinsPerGram * gramsConsumed,
      fats: fatsPerGram * gramsConsumed,
      carbs: carbsPerGram * gramsConsumed,
    );
  }

  static PortionNutrients fromIngredients(
      Iterable<RecipeIngredientRecord> ingredients,
      Map<int, Product> products,
      ) {
    PortionNutrients total = PortionNutrients.zero;

    for (final ingredient in ingredients) {
      final product = products[ingredient.productId];
      if (product == null) {
        continue;
      }

      final multiplier = ingredient.grams / 100;
      total = total + PortionNutrients(
        calories: product.caloriesPer100 * multiplier,
        proteins: product.proteinsPer100 * multiplier,
        fats: product.fatsPer100 * multiplier,
        carbs: product.carbsPer100 * multiplier,
      );
    }

    return total;
  }

  static PortionNutrients replaceIngredient({
    required PortionNutrients dishTotals,
    required Product oldProduct,
    required double oldGrams,
    required Product newProduct,
    required double newGrams,
  }) {
    final oldContribution = PortionNutrients(
      calories: oldProduct.caloriesPer100 * oldGrams / 100,
      proteins: oldProduct.proteinsPer100 * oldGrams / 100,
      fats: oldProduct.fatsPer100 * oldGrams / 100,
      carbs: oldProduct.carbsPer100 * oldGrams / 100,
    );

    final newContribution = PortionNutrients(
      calories: newProduct.caloriesPer100 * newGrams / 100,
      proteins: newProduct.proteinsPer100 * newGrams / 100,
      fats: newProduct.fatsPer100 * newGrams / 100,
      carbs: newProduct.carbsPer100 * newGrams / 100,
    );

    return dishTotals - oldContribution + newContribution;
  }

  static PortionNutrients sumTemplate(
      Iterable<MealTemplateItem> items,
      Recipe? Function(int recipeId) recipeResolver,
      ) {
    PortionNutrients total = PortionNutrients.zero;

    for (final item in items) {
      if (item.recipeId == null) {
        continue;
      }
      final recipe = recipeResolver(item.recipeId!);
      if (recipe == null) {
        continue;
      }
      total = total + PortionNutrients.fromRecipe(recipe, item.portion);
    }

    return total;
  }

  static PortionNutrients sumFoodLog(Iterable<FoodLogEntry> entries) {
    PortionNutrients total = PortionNutrients.zero;
    for (final entry in entries) {
      total = total + PortionNutrients(
        calories: entry.calories,
        proteins: entry.proteins,
        fats: entry.fats,
        carbs: entry.carbs,
      );
    }
    return total;
  }
}

class NutritionEngine {
  static double computeDishScore(
      Recipe r, {
        DishScoreConfig config = const DishScoreConfig(),
      }) {
    final k = r.caloriesPerServing;
    final p = r.proteinsPerServing;
    final f = r.fatsPerServing;
    final c = r.carbsPerServing;

    double sq(double x) => x * x;

    final eCalories =
        sq((k - config.targetCalories) / config.targetCalories) * config.wCalories;
    final eProteins =
        sq((p - config.targetProteins) / config.targetProteins) * config.wProteins;
    final eFats = sq((f - config.targetFats) / config.targetFats) * config.wFats;
    final eCarbs = sq((c - config.targetCarbs) / config.targetCarbs) * config.wCarbs;

    final error = eCalories + eProteins + eFats + eCarbs;

    return 1.0 / (1.0 + error);
  }

  static Recipe? findOptimalRecipe(
      List<Recipe> recipes, {
        DishScoreConfig config = const DishScoreConfig(),
      }) {
    final filtered = recipes.where((r) {
      final k = r.caloriesPerServing;
      final p = r.proteinsPerServing;
      return k >= 400 && k <= 800 && p >= 20;
    }).toList();

    if (filtered.isEmpty) {
      return null;
    }

    Recipe best = filtered.first;
    double bestScore = computeDishScore(best, config: config);

    for (final r in filtered.skip(1)) {
      final score = computeDishScore(r, config: config);
      if (score > bestScore) {
        bestScore = score;
        best = r;
      }
    }

    return best;
  }
}