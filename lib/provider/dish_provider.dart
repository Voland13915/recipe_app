import 'package:flutter/material.dart';
import 'package:nutrition_app/models/models.dart';

class DishProvider with ChangeNotifier {
  List<Ingredient> ingredients = <Ingredient>[];  // Явный non-nullable list

  double targetCalories = 2000;
  double targetProteins = 150;
  double targetFats = 70;
  double targetCarbs = 250;

  void addIngredient(Ingredient ingredient) {
    ingredients.add(ingredient);
    notifyListeners();
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, double qty) {
    ingredients[index].quantity = qty;
    notifyListeners();
  }

  double calculateTotalCalories() {
    return ingredients.fold(0.0, (sum, ing) => sum + (ing.caloriesPer100g * ing.quantity / 100));  }

  double calculateTotalProteins() {
    return ingredients.fold(0.0, (sum, ing) => sum + (ing.proteinsPer100g * ing.quantity / 100));  }

  double calculateTotalFats() {
    return ingredients.fold(0.0, (sum, ing) => sum + (ing.fatsPer100g * ing.quantity / 100));  }

  double calculateTotalCarbs() {
    return ingredients.fold(0.0, (sum, ing) => sum + (ing.carbsPer100g * ing.quantity / 100));
  }

  void setTargetCalories(double value) {
    targetCalories = value;
    notifyListeners();
  }

  void setTargetProteins(double value) {
    targetProteins = value;
    notifyListeners();
  }

  void setTargetFats(double value) {
    targetFats = value;
    notifyListeners();
  }

  void setTargetCarbs(double value) {
    targetCarbs = value;
    notifyListeners();
  }
}