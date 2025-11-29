// search_field
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/provider/recipe_provider.dart';
import 'package:nutrition_app/screens/recipe_screen.dart';
import 'package:nutrition_app/models/models.dart';
import 'package:unicons/unicons.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Implement a dropdown logic to the SearchField
    final recipeData = Provider.of<ListOfRecipes>(context);
    return Material(
      elevation: 2.0,
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
              Theme.of(context).cardColor,
          isDense: true,
          prefixIcon:
          Icon(UniconsLine.search, color: Theme.of(context).primaryColor),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(UniconsLine.multiply),
                  color: Theme.of(context).primaryColor,
                  onPressed: _controller.clear,
                ),
              IconButton(
                icon: const Icon(UniconsLine.search),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  showSearch<Recipe?>(
                    context: context,
                    query: _controller.text,
                    delegate: RecipeSearchDelegate(recipeData: recipeData),
                  );
                },
              ),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
          hintText: 'Search recipe here...',
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.0,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        onSubmitted: (value) {
          showSearch<Recipe?>(
            context: context,
            query: value,
            delegate: RecipeSearchDelegate(recipeData: recipeData),
          );
        },
      ),
    );
  }
}

class RecipeSearchDelegate extends SearchDelegate<Recipe?> {
  RecipeSearchDelegate({required this.recipeData})
      : super(searchFieldLabel: 'Найдите блюдо...');

  final ListOfRecipes recipeData;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        fillColor: theme.cardColor,
      ),
      textTheme: theme.textTheme.apply(bodyColor: theme.textTheme.bodyLarge?.color),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
    IconButton(
      icon: const Icon(UniconsLine.multiply),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = '';
          showSuggestions(context);
        }// Исправлено: value.toLowerCase() внутри
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = recipeData.searchRecipe(query);
    if (results.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }

    return _SearchResultList(results: results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = query.isEmpty ? recipeData.getRecipes : recipeData.searchRecipe(query);
    return _SearchResultList(results: results.take(10).toList());
  }
}

class _SearchResultList extends StatelessWidget {
  const _SearchResultList({required this.results});

  final List<Recipe> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(child: Text('Начните вводить название блюда'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final recipe = results[index];
        final imageUrl = recipe.recipeImage.isNotEmpty
            ? recipe.recipeImage
            : 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200';
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 56,
              width: 56,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(UniconsLine.exclamation_circle),
              ),
            ),
          ),
          title: Text(recipe.recipeName),
          subtitle: Text(recipe.recipeCategory),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const RecipeScreen(),
                settings: RouteSettings(arguments: recipe),
              ),
            );
          },
        );
      },
    );
  }
}