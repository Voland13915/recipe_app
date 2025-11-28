class Product {
  final int? id;
  final String name;
  final double caloriesPer100;
  final double proteinsPer100;
  final double fatsPer100;
  final double carbsPer100;

  const Product({
    this.id,
    required this.name,
    required this.caloriesPer100,
    required this.proteinsPer100,
    required this.fatsPer100,
    required this.carbsPer100,
  });
}