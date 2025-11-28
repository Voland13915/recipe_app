import 'package:nutrition_app/models/models.dart';
import 'package:nutrition_app/utils/database_schema.dart';
import 'package:nutrition_app/utils/nutrition_engine.dart';
import 'package:sqflite/sqflite.dart';

class NutritionRepository {
  Future<Database> get _db async => DatabaseSchema.open();

  Future<int> upsertProduct(Product product) async {
    final db = await _db;
    if (product.id != null) {
      await db.update(
        'products',
        {
          'name': product.name,
          'caloriesPer100': product.caloriesPer100,
          'proteinsPer100': product.proteinsPer100,
          'fatsPer100': product.fatsPer100,
          'carbsPer100': product.carbsPer100,
        },
        where: 'id = ?',
        whereArgs: [product.id],
      );
      return product.id!;
    }

    return db.insert('products', {
      'name': product.name,
      'caloriesPer100': product.caloriesPer100,
      'proteinsPer100': product.proteinsPer100,
      'fatsPer100': product.fatsPer100,
      'carbsPer100': product.carbsPer100,
    });
  }

  Future<void> replaceRecipeIngredients(
      int recipeId,
      List<RecipeIngredientRecord> ingredients,
      ) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('recipe_ingredients', where: 'recipeId = ?', whereArgs: [recipeId]);
      for (final ingredient in ingredients) {
        await txn.insert('recipe_ingredients', {
          'recipeId': recipeId,
          'productId': ingredient.productId,
          'grams': ingredient.grams,
        });
      }
    });
  }

  Future<List<RecipeIngredientRecord>> getRecipeIngredients(int recipeId) async {
    final db = await _db;
    final rows = await db.query(
      'recipe_ingredients',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
    );

    return rows
        .map(
          (row) => RecipeIngredientRecord(
        id: row['id'] as int?,
        recipeId: row['recipeId'] as int,
        productId: row['productId'] as int,
        grams: (row['grams'] as num).toDouble(),
      ),
    )
        .toList();
  }

  Future<int> createTemplate(MealTemplate template) async {
    final db = await _db;
    return db.insert('meal_templates', {'name': template.name});
  }

  Future<void> saveTemplateItems(int templateId, List<MealTemplateItem> items) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('meal_template_items', where: 'templateId = ?', whereArgs: [templateId]);
      for (final item in items) {
        await txn.insert('meal_template_items', {
          'templateId': templateId,
          'recipeId': item.recipeId,
          'productId': item.productId,
          'portion': item.portion,
        });
      }
    });
  }

  Future<List<MealTemplateItem>> getTemplateItems(int templateId) async {
    final db = await _db;
    final rows = await db.query(
      'meal_template_items',
      where: 'templateId = ?',
      whereArgs: [templateId],
    );

    return rows
        .map(
          (row) => MealTemplateItem(
        id: row['id'] as int?,
        templateId: row['templateId'] as int,
        recipeId: row['recipeId'] as int?,
        productId: row['productId'] as int?,
        portion: (row['portion'] as num).toDouble(),
      ),
    )
        .toList();
  }

  Future<int> insertFoodLogEntry(FoodLogEntry entry) async {
    final db = await _db;
    return db.insert('food_log', {
      'date': entry.date,
      'time': entry.time,
      'mealType': entry.mealType,
      'recipeId': entry.recipeId,
      'productId': entry.productId,
      'portion': entry.portion,
      'calories': entry.calories,
      'proteins': entry.proteins,
      'fats': entry.fats,
      'carbs': entry.carbs,
    });
  }

  Future<List<FoodLogEntry>> getFoodLogByDate(String date) async {
    final db = await _db;
    final rows = await db.query('food_log', where: 'date = ?', whereArgs: [date]);

    return rows
        .map(
          (row) => FoodLogEntry(
        id: row['id'] as int?,
        date: row['date'] as String,
        time: row['time'] as String?,
        mealType: row['mealType'] as String?,
        recipeId: row['recipeId'] as int?,
        productId: row['productId'] as int?,
        portion: (row['portion'] as num).toDouble(),
        calories: (row['calories'] as num).toDouble(),
        proteins: (row['proteins'] as num).toDouble(),
        fats: (row['fats'] as num).toDouble(),
        carbs: (row['carbs'] as num).toDouble(),
      ),
    )
        .toList();
  }

  Future<PortionNutrients> getFoodLogTotals(String date) async {
    final entries = await getFoodLogByDate(date);
    return PortionNutrients.sumFoodLog(entries);
  }

  Future<PortionNutrients> calculateTemplateNutrients(
      int templateId,
      Recipe? Function(int recipeId) recipeResolver,
      ) async {
    final items = await getTemplateItems(templateId);
    return PortionNutrients.sumTemplate(items, recipeResolver);
  }
}