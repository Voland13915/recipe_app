import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseSchema {
  static const _databaseName = 'recipes.db';
  static const _databaseVersion = 2;

  static Future<Database> open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createRecipesTable(db);
        await _createSupplementaryTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE recipes ADD COLUMN gramsPerServing REAL');
          await _createSupplementaryTables(db);
        }
      },
    );
  }

  static Future<void> _createRecipesTable(Database db) async {
    await db.execute(
      'CREATE TABLE recipes('
          'id INTEGER PRIMARY KEY, '
          'category TEXT, '
          'name TEXT, '
          'description TEXT, '
          'image TEXT, '
          'prepTime REAL, '
          'cookTime REAL, '
          'serving INTEGER, '
          'ingredients TEXT, '
          'method TEXT, '
          'review REAL, '
          'isPopular INTEGER, '
          'caloriesPerServing REAL, '
          'proteinsPerServing REAL, '
          'fatsPerServing REAL, '
          'carbsPerServing REAL, '
          'gramsPerServing REAL'
          ')',
    );
  }

  static Future<void> _createSupplementaryTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS products('
          'id INTEGER PRIMARY KEY, '
          'name TEXT, '
          'caloriesPer100 REAL, '
          'proteinsPer100 REAL, '
          'fatsPer100 REAL, '
          'carbsPer100 REAL'
          ')',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS recipe_ingredients('
          'id INTEGER PRIMARY KEY, '
          'recipeId INTEGER, '
          'productId INTEGER, '
          'grams REAL, '
          'FOREIGN KEY(recipeId) REFERENCES recipes(id), '
          'FOREIGN KEY(productId) REFERENCES products(id)'
          ')',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS meal_templates('
          'id INTEGER PRIMARY KEY, '
          'name TEXT'
          ')',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS meal_template_items('
          'id INTEGER PRIMARY KEY, '
          'templateId INTEGER, '
          'recipeId INTEGER, '
          'productId INTEGER, '
          'portion REAL, '
          'FOREIGN KEY(templateId) REFERENCES meal_templates(id), '
          'FOREIGN KEY(recipeId) REFERENCES recipes(id), '
          'FOREIGN KEY(productId) REFERENCES products(id)'
          ')',
    );

    await db.execute(
      'CREATE TABLE IF NOT EXISTS food_log('
          'id INTEGER PRIMARY KEY, '
          'date TEXT, '
          'time TEXT, '
          'mealType TEXT, '
          'recipeId INTEGER, '
          'productId INTEGER, '
          'portion REAL, '
          'calories REAL, '
          'proteins REAL, '
          'fats REAL, '
          'carbs REAL, '
          'FOREIGN KEY(recipeId) REFERENCES recipes(id), '
          'FOREIGN KEY(productId) REFERENCES products(id)'
          ')',
    );
  }
}