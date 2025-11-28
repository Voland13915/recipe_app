class RecipeIngredientRecord {
  final int? id;
  final int recipeId;
  final int productId;
  final double grams;

  const RecipeIngredientRecord({
    this.id,
    required this.recipeId,
    required this.productId,
    required this.grams,
  });
}