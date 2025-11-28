// recipe_screen
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

import 'package:nutrition_app/models/models.dart';
import 'package:nutrition_app/provider/provider.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipe =
        ModalRoute.of(context)?.settings.arguments as Recipe?;

    if (recipe == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Рецепт не найден.'),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _RecipeHero(recipe: recipe),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _RecipeSummary(recipe: recipe),
                  const SizedBox(height: 16.0),
                  _RecipeIngredients(recipe: recipe),
                  const SizedBox(height: 16.0),
                  _RecipeMethod(recipe: recipe),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeHero extends StatelessWidget {
  const _RecipeHero({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          recipe.recipeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: recipe.recipeImage,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeSummary extends StatelessWidget {
  const _RecipeSummary({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    final isSaved =
        savedProvider.getSaved.containsKey(recipe.recipeId.toString());

    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.recipeCategory,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        recipe.recipeName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isSaved
                      ? 'Убрать из сохранённых'
                      : 'Сохранить рецепт',
                  onPressed: () {
                    savedProvider.addAndRemoveFromSaved(
                      recipe.recipeId.toString(),
                      recipe.recipeCategory,
                      recipe.cookTime,
                      recipe.prepTime,
                      recipe.recipeImage,
                      recipe.recipeName,
                    );
                  },
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
            if (recipe.recipeDescription.isNotEmpty) ...[
              const SizedBox(height: 12.0),
              Text(
                recipe.recipeDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 12.0,
              runSpacing: 8.0,
              children: [
                _SummaryChip(
                  icon: UniconsLine.clock,
                  label:
                      'Подготовка: ${recipe.prepTime.toStringAsFixed(0)} мин',
                ),
                _SummaryChip(
                  icon: UniconsLine.stopwatch,
                  label: 'Готовка: ${recipe.cookTime.toStringAsFixed(0)} мин',
                ),
                _SummaryChip(
                  icon: UniconsLine.users_alt,
                  label: 'Порций: ${recipe.recipeServing}',
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _MacroBadge(
                  label: 'Калории',
                  value: '${recipe.caloriesPerServing.toStringAsFixed(0)} ккал',
                ),
                _MacroBadge(
                  label: 'Белки',
                  value: '${recipe.proteinsPerServing.toStringAsFixed(1)} г',
                ),
                _MacroBadge(
                  label: 'Жиры',
                  value: '${recipe.fatsPerServing.toStringAsFixed(1)} г',
                ),
                _MacroBadge(
                  label: 'Углеводы',
                  value: '${recipe.carbsPerServing.toStringAsFixed(1)} г',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeIngredients extends StatelessWidget {
  const _RecipeIngredients({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final ingredients = recipe.recipeIngredients;
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ингредиенты',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12.0),
            if (ingredients.isEmpty)
              Text(
                'Ингредиенты будут добавлены позже.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...ingredients.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        UniconsLine.check,
                        size: 18.0,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          ingredient,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecipeMethod extends StatelessWidget {
  const _RecipeMethod({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final steps = recipe.recipeMethod
        .split('\n')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList(growable: false);

    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Приготовление',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12.0),
            if (steps.isEmpty)
              Text(
                'Метод приготовления будет добавлен позже.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...List.generate(steps.length, (index) {
                final step = steps[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14.0,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.15),
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.0, color: Theme.of(context).primaryColor),
          const SizedBox(width: 6.0),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  const _MacroBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
