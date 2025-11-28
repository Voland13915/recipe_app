class Ingredient {
  final String name;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatsPer100g;
  final double carbsPer100g;
  double quantity;  // В граммах, регулируется пользователем

  Ingredient({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.fatsPer100g,
    required this.carbsPer100g,
    this.quantity = 100.0,  // По умолчанию 100г
  });
}