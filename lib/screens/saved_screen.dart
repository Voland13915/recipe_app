// saved_screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/custom_navbar.dart';  // Изменён путь
import 'package:nutrition_app/models/models.dart';
import 'package:nutrition_app/utils/category_list.dart';
import 'package:nutrition_app/models/saved_recipes.dart' as saved_model;
import 'package:nutrition_app/provider/provider.dart';  // Изменён путь
import 'package:nutrition_app/widgets/widgets.dart';  // Изменён путь
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:nutrition_app/screens/recipe_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: savedProvider.getSaved.isEmpty
              ? const EmptyRecipe()
              : const SavedRecipes(),
        ),
      ),
    );
  }
}

class SavedRecipes extends StatefulWidget {
  const SavedRecipes({
    Key? key,
  }) : super(key: key);

  @override
  State<SavedRecipes> createState() => _SavedRecipesState();
}

class _SavedRecipesState extends State<SavedRecipes> {
  Set<String> _selectedCategories = {};
  double? _prepTimeMax;
  double? _cookTimeMax;
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();

  @override
  void dispose() {
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }

  List<saved_model.SavedRecipes> _filterRecipes(
      List<saved_model.SavedRecipes> recipes,
      {double? prepMax, double? cookMax}) {
    return recipes.where((recipe) {
      final matchesCategory = _selectedCategories.isEmpty ||
          _selectedCategories.contains(recipe.recipeCategory);

      final matchesPrep = prepMax == null || recipe.prepTime <= prepMax;

      final matchesCook = cookMax == null || recipe.cookTime <= cookMax;

      return matchesCategory && matchesPrep && matchesCook;
    }).toList();
  }

  void _openFilterSheet(
      BuildContext context,
      List<saved_model.SavedRecipes> savedRecipes,
      ) {
    final availableCategories = items
        .map((category) => category.category)
        .toSet()
        .toList()
      ..sort();

    _prepTimeController.text =
    _prepTimeMax != null ? _prepTimeMax!.toStringAsFixed(0) : '';
    _cookTimeController.text =
    _cookTimeMax != null ? _cookTimeMax!.toStringAsFixed(0) : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        var tempCategories = {..._selectedCategories};

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filter recipes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      )
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'Category',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8.0),
                  if (availableCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Нет категорий для фильтрации.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: availableCategories
                          .map(
                            (category) => FilterChip(
                          label: Text(category),
                          selected: tempCategories.contains(category),
                          onSelected: (isSelected) {
                            setModalState(() {
                              if (isSelected) {
                                tempCategories.add(category);
                              } else {
                                tempCategories.remove(category);
                              }
                            });
                          },
                        ),
                      )
                          .toList(),
                    ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Prep time up to (min)',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Например, 30',
                    ),
                    onChanged: (value) {
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Cook time up to (min)',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _cookTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Например, 45',
                    ),
                    onChanged: (value) {
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedCategories = {};
                            _prepTimeMax = null;
                            _cookTimeMax = null;
                            _prepTimeController.clear();
                            _cookTimeController.clear();
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          final parsedPrep = double.tryParse(
                              _prepTimeController.text.trim().isEmpty
                                  ? ''
                                  : _prepTimeController.text.trim());
                          final parsedCook = double.tryParse(
                              _cookTimeController.text.trim().isEmpty
                                  ? ''
                                  : _cookTimeController.text.trim());
                          setState(() {
                            _selectedCategories = tempCategories;
                            _prepTimeMax = parsedPrep;
                            _cookTimeMax = parsedCook;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openRecipe(saved_model.SavedRecipes recipe) {
    final recipesProvider =
        Provider.of<ListOfRecipes>(context, listen: false).getRecipes;

    Recipe? recipeDetails;
    try {
      recipeDetails = recipesProvider.firstWhere(
            (entry) => entry.recipeId.toString() == recipe.recipeId,
      );
    } catch (_) {
      recipeDetails = null;
    }

    if (recipeDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть рецепт.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecipeScreen(),
        settings: RouteSettings(arguments: recipeDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedProvider = Provider.of<SavedProvider>(context);
    final savedRecipes = savedProvider.getSaved.values.toList();

    final filteredRecipes = _filterRecipes(
      savedRecipes,
      prepMax: _prepTimeMax,
      cookMax: _cookTimeMax,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 6.0.h,
        ),
        Text(
          'Saved',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        SizedBox(
          height: 4.0.h,
        ),
        TabRow(
          onFilterTap: () => _openFilterSheet(context, savedRecipes),
        ),
        if (_selectedCategories.isNotEmpty ||
            _prepTimeMax != null ||
            _cookTimeMax != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ..._selectedCategories.map(
                      (category) => Chip(
                    label: Text(category),
                    onDeleted: () => setState(() {
                      _selectedCategories.remove(category);
                    }),
                  ),
                ),
                if (_prepTimeMax != null)
                  Chip(
                    label: Text('Prep: ≤${_prepTimeMax?.toStringAsFixed(0)}m'),
                    onDeleted: () => setState(() {
                      _prepTimeMax = null;
                    }),
                  ),
                if (_cookTimeMax != null)
                  Chip(
                    label: Text('Cook: ≤${_cookTimeMax?.toStringAsFixed(0)}m'),
                    onDeleted: () => setState(() {
                      _cookTimeMax = null;
                    }),
                  ),
              ],
            ),
          ),
        if (filteredRecipes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Нет рецептов, подходящих под фильтры.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey.shade700),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 15.0,
              );
            },
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              var recipe = filteredRecipes[index];
              return Dismissible(
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  color: Colors.red,
                  height: 20.0,
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    child: Icon(
                      UniconsLine.trash,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
                key: ValueKey(recipe.recipeId),
                onDismissed: (direction) {
                  setState(() {
                    savedProvider.removeRecipe(recipe.recipeId);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${recipe.recipeName} deleted'),
                    ),
                  );
                },
                child: InkWell(
                  onTap: () => _openRecipe(recipe),
                  child: SizedBox(
                    height: 20.0.h,
                    child: Material(
                      color: Colors.white,
                      elevation: 2.0,
                      child: Row(
                        children: [
                          ReusableNetworkImage(
                            imageUrl: recipe.recipeImage,
                            height: 20.0.h,
                            width: 20.0.h,
                          ),
                          SizedBox(
                            width: 2.0.h,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.recipeName,
                                style:
                                Theme.of(context).textTheme.headlineLarge,
                              ),
                              SizedBox(
                                height: 1.5.h,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    UniconsLine.clock,
                                    size: 16.0,
                                    color: Colors.grey.shade500,
                                  ),
                                  SizedBox(
                                    width: 1.5.w,
                                  ),
                                  Text(
                                    '${recipe.prepTime.toStringAsFixed(0)} M Prep',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 1.0.h,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    UniconsLine.clock,
                                    size: 16.0,
                                    color: Colors.grey.shade500,
                                  ),
                                  SizedBox(
                                    width: 1.5.w,
                                  ),
                                  Text(
                                    '${recipe.cookTime.toStringAsFixed(0)} M Cook',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class EmptyRecipe extends StatelessWidget {
  const EmptyRecipe({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Ath á minni skjá
            SizedBox(height: 10.h,),
            Image.asset('assets/recipebook.gif'),
            Text(
              'You haven\'t saved any recipes yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontSize: 14.sp),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Want to take a look?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 2.5.h),
            InkWell(
              child: Container(
                width: double.infinity,
                height: 45.0,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Explore',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomNavBar(),
                  ),
                );
              },
            ),
          ]),
    );
  }
}