class MealTemplate {
  final int? id;
  final String name;

  const MealTemplate({
    this.id,
    required this.name,
  });
}

class MealTemplateItem {
  final int? id;
  final int templateId;
  final int? recipeId;
  final int? productId;
  final double portion;

  const MealTemplateItem({
    this.id,
    required this.templateId,
    this.recipeId,
    this.productId,
    required this.portion,
  });
}