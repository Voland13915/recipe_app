import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/models/models.dart';
import 'package:nutrition_app/provider/dish_provider.dart';
import 'package:nutrition_app/utils/food_api_client.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

class DishBuilderScreen extends StatelessWidget {
  const DishBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DishProvider>(
      create: (_) => DishProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Создать блюдо', style: Theme.of(context).textTheme.headlineLarge),
          actions: [
            IconButton(
              icon: const Icon(UniconsLine.save),
              onPressed: () {
                // Placeholder: Сохранить блюдо (позже реализуем)
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Блюдо сохранено!')));
              },
            ),
          ],
        ),
        body: Consumer<DishProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Раздел: Добавление ингредиентов
                  Text('Ингредиенты', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 2.h),
                  _buildIngredientList(provider),
                  SizedBox(height: 2.h),
                  ElevatedButton.icon(
                    icon: const Icon(UniconsLine.plus),
                    label: const Text('Добавить ингредиент'),
                    onPressed: () => _showAddIngredientDialog(context, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: Size(double.infinity, 5.h),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Раздел: Текущие макросы (фактические)
                  Text('Фактические макросы', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 1.h),
                  _buildMacroDisplay(provider.calculateTotalCalories(), 'Калории', Colors.blue, provider),
                  _buildMacroDisplay(provider.calculateTotalProteins(), 'Белки (г)', Colors.green, provider),
                  _buildMacroDisplay(provider.calculateTotalFats(), 'Жиры (г)', Colors.orange, provider),
                  _buildMacroDisplay(provider.calculateTotalCarbs(), 'Углеводы (г)', Colors.purple, provider),
                  SizedBox(height: 4.h),

                  // Раздел: Целевые макросы (интерактивная настройка)
                  Text('Целевые макросы', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 1.h),
                  _buildTargetSlider(provider, 'Калории', provider.targetCalories, (value) => provider.setTargetCalories(value)),
                  _buildTargetSlider(provider, 'Белки (г)', provider.targetProteins, (value) => provider.setTargetProteins(value)),
                  _buildTargetSlider(provider, 'Жиры (г)', provider.targetFats, (value) => provider.setTargetFats(value)),
                  _buildTargetSlider(provider, 'Углеводы (г)', provider.targetCarbs, (value) => provider.setTargetCarbs(value)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Список ингредиентов с регулировкой порций
  Widget _buildIngredientList(DishProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = provider.ingredients[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(ingredient.name),
            subtitle: Row(
              children: [
                const Text('Кол-во: '),
                SizedBox(
                  width: 30.w,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final qty = double.tryParse(value) ?? 100.0;
                      provider.updateQuantity(index, qty);
                    },
                    decoration: InputDecoration(
                      hintText: '${ingredient.quantity} г',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(UniconsLine.trash),
              onPressed: () => provider.removeIngredient(index),
            ),
          ),
        );
      },
    );
  }

  // Дисплей для макросов (progress bar для сравнения с целью)
  Widget _buildMacroDisplay(double value, String label, Color color, DishProvider provider) {
    double target = 0;
    switch (label) {
      case 'Калории': target = provider.targetCalories; break;
      case 'Белки (г)': target = provider.targetProteins; break;
      case 'Жиры (г)': target = provider.targetFats; break;
      case 'Углеводы (г)': target = provider.targetCarbs; break;
    }
    final progress = target > 0 ? value / target : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}'),
        LinearProgressIndicator(value: progress.clamp(0, 1), color: color, backgroundColor: Colors.grey[300]),
        SizedBox(height: 1.h),
      ],
    );
  }

  // Слайдер для целевых макросов
  Widget _buildTargetSlider(DishProvider provider, String label, double value, Function(double) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}'),
        Slider(
          value: value,
          min: 0,
          max: label == 'Калории' ? 5000 : 500,  // Arbitrary max
          onChanged: onChange,
        ),
      ],
    );
  }

  // Диалог для добавления ингредиента через поиск по базе
  void _showAddIngredientDialog(BuildContext context, DishProvider provider) {
    final TextEditingController searchController = TextEditingController();
    final FoodApiClient apiClient = FoodApiClient();
    List<Ingredient> results = <Ingredient>[];
    bool isLoading = false;
    String? errorMessage;

    Future<void> search(String query, void Function(void Function()) setState) async {
      if (query.trim().isEmpty) {
        setState(() {
          errorMessage = 'Введите название продукта';
          results = <Ingredient>[];
        });
        return;
      }

      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      try {
        final List<Ingredient> fetchedResults = await apiClient.searchIngredients(query);
        setState(() {
          results = fetchedResults;
          errorMessage = fetchedResults.isEmpty ? 'Ничего не найдено' : null;
        });
      } catch (e) {
        setState(() {
          errorMessage = 'Не удалось загрузить продукты. Проверьте подключение.';
          results = <Ingredient>[];
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Найти ингредиент'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Название продукта',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => search(searchController.text, setState),
                      ),
                    ),
                    onSubmitted: (value) => search(value, setState),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading) const LinearProgressIndicator(),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 300,
                    child: results.isEmpty && !isLoading && errorMessage == null
                        ? const Center(child: Text('Начните поиск продукта'))
                        : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final ingredient = results[index];
                        return ListTile(
                          title: Text(ingredient.name),
                          subtitle: Text(
                            'Ккал: ${ingredient.caloriesPer100g.toStringAsFixed(0)}, Б: ${ingredient.proteinsPer100g.toStringAsFixed(1)}, Ж: ${ingredient.fatsPer100g.toStringAsFixed(1)}, У: ${ingredient.carbsPer100g.toStringAsFixed(1)} (на 100г)',
                          ),
                          onTap: () {
                            provider.addIngredient(
                              Ingredient(
                                name: ingredient.name,
                                caloriesPer100g: ingredient.caloriesPer100g,
                                proteinsPer100g: ingredient.proteinsPer100g,
                                fatsPer100g: ingredient.fatsPer100g,
                                carbsPer100g: ingredient.carbsPer100g,
                              ),
                            );
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}