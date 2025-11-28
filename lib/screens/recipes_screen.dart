// recipes_screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/models/models.dart';
import 'package:nutrition_app/provider/provider.dart';
import 'package:nutrition_app/screens/screens.dart';
import 'package:nutrition_app/widgets/widgets.dart';
import 'package:unicons/unicons.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryName =
        ModalRoute.of(context)?.settings.arguments as String?;
    if (categoryName == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('Категория не найдена.')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer2<ListOfRecipes, SavedProvider>(
          builder: (context, recipesProvider, savedProvider, _) {
            if (recipesProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final recipeList =
                recipesProvider.findByCategory(categoryName);
            if (recipeList.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Пока для категории "$categoryName" нет рецептов. '
                    'Попробуйте выбрать другую категорию.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: recipeList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final recipe = recipeList[index];
                final recipeKey = recipe.recipeId.toString();
                final isSaved =
                    savedProvider.getSaved.containsKey(recipeKey);

                return _RecipeCard(
                  recipe: recipe,
                  isSaved: isSaved,
                  onToggleSave: () {
                    savedProvider.addAndRemoveFromSaved(
                      recipeKey,
                      recipe.recipeCategory,
                      recipe.cookTime,
                      recipe.prepTime,
                      recipe.recipeImage,
                      recipe.recipeName,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.isSaved,
    required this.onToggleSave,
  });

  final Recipe recipe;
  final bool isSaved;
  final VoidCallback onToggleSave;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RecipeScreen(),
          settings: RouteSettings(arguments: recipe),
        ),
      ),
      borderRadius: BorderRadius.circular(16.0),
      child: Material(
        elevation: 2.0,
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  height: 100.0,
                  width: 100.0,
                  child: ReusableNetworkImage(
                    imageUrl: recipe.recipeImage,
                    height: 100.0,
                    width: 100.0,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.recipeName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 8.0,
                      children: [
                        _InfoChip(
                          icon: UniconsLine.clock,
                          label:
                              '${recipe.prepTime.toStringAsFixed(0)} м. подготовка',
                        ),
                        _InfoChip(
                          icon: UniconsLine.stopwatch,
                          label:
                              '${recipe.cookTime.toStringAsFixed(0)} м. готовка',
                        ),
                        _InfoChip(
                          icon: UniconsLine.users_alt,
                          label: 'Порций: ${recipe.recipeServing}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        _MacroPill(
                          label: '${recipe.caloriesPerServing.toStringAsFixed(0)} ккал',
                        ),
                        _MacroPill(
                          label:
                              'Б: ${recipe.proteinsPerServing.toStringAsFixed(1)} г',
                        ),
                        _MacroPill(
                          label:
                              'Ж: ${recipe.fatsPerServing.toStringAsFixed(1)} г',
                        ),
                        _MacroPill(
                          label:
                              'У: ${recipe.carbsPerServing.toStringAsFixed(1)} г',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleSave,
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
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

class _MacroPill extends StatelessWidget {
  const _MacroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
