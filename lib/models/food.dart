class Recipe {
  final int recipeId;
  final String recipeCategory;
  final String recipeName;
  final String recipeImage;
  final String recipeDescription;
  final double prepTime;
  final double cookTime;
  final double recipeReview;
  final int recipeServing;
  final List<String> recipeIngredients;
  final String recipeMethod;
  final bool isPopular;
  final double caloriesPerServing;
  final double proteinsPerServing;
  final double fatsPerServing;
  final double carbsPerServing;
  final double? gramsPerServing;

  Recipe({
    required this.recipeId,
    required this.recipeCategory,
    required this.recipeName,
    required this.recipeImage,
    required this.recipeDescription,
    required this.prepTime,
    required this.cookTime,
    required this.recipeServing,
    required this.recipeIngredients,
    required this.recipeMethod,
    required this.recipeReview,
    required this.isPopular,
    required this.caloriesPerServing,
    required this.proteinsPerServing,
    required this.fatsPerServing,
    required this.carbsPerServing,
    this.gramsPerServing,
  });
}