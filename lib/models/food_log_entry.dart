class FoodLogEntry {
  final int? id;
  final String date;
  final String? time;
  final String? mealType;
  final int? recipeId;
  final int? productId;
  final double portion;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  const FoodLogEntry({
    this.id,
    required this.date,
    this.time,
    this.mealType,
    this.recipeId,
    this.productId,
    required this.portion,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });
}