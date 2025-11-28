import 'package:flutter/material.dart';
import 'package:nutrition_app/models/models.dart';
import 'package:nutrition_app/provider/provider.dart';
import 'package:nutrition_app/screens/dish_builder_screen.dart';
import 'package:nutrition_app/screens/screens.dart';
import 'package:nutrition_app/utils/nutrition_engine.dart';
import 'package:nutrition_app/utils/utils.dart';
import 'package:nutrition_app/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _defaultGramsPerServing = 250.0;

  Recipe? _selectedRecipe;
  double _portionMultiplier = 1.0;
  double _gramsConsumed = 150.0;
  final TextEditingController _gramsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gramsController.text = _gramsConsumed.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = context.watch<ListOfRecipes>();
    final recipes = recipeProvider.getRecipes;
    final recipe = _selectedRecipe ?? (recipes.isNotEmpty ? recipes.first : null);

    return Scaffold(
      body: recipeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40.0),
              const HomeLogoText(),
              const SizedBox(height: 10.0),
              const HomeHeaderRow(),
              const SizedBox(height: 20.0),
              const SearchField(),
              const SizedBox(height: 40.0),
              const HomeGrid(),
              const SizedBox(height: 30.0),
              _NutritionTester(
                recipes: recipes,
                selectedRecipe: recipe,
                gramsController: _gramsController,
                portionMultiplier: _portionMultiplier,
                gramsConsumed: _gramsConsumed,
                defaultGramsPerServing: _defaultGramsPerServing,
                onRecipeChanged: (value) => setState(() => _selectedRecipe = value),
                onPortionChanged: (value) => setState(() => _portionMultiplier = value),
                onGramsChanged: (value) => setState(() => _gramsConsumed = value),
              ),
              SizedBox(height: 2.0.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DishBuilderScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: Size(double.infinity, 5.0.h),
                ),
                child: Text(
                  'Создать блюдо',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                'Popular Recipes',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20.0),
              const HomePopularGrid(),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionTester extends StatelessWidget {
  final List<Recipe> recipes;
  final Recipe? selectedRecipe;
  final TextEditingController gramsController;
  final double portionMultiplier;
  final double gramsConsumed;
  final double defaultGramsPerServing;
  final ValueChanged<Recipe?> onRecipeChanged;
  final ValueChanged<double> onPortionChanged;
  final ValueChanged<double> onGramsChanged;

  const _NutritionTester({
    required this.recipes,
    required this.selectedRecipe,
    required this.gramsController,
    required this.portionMultiplier,
    required this.gramsConsumed,
    required this.defaultGramsPerServing,
    required this.onRecipeChanged,
    required this.onPortionChanged,
    required this.onGramsChanged,
  });

  PortionNutrients _calculatePortion(Recipe recipe) {
    return PortionNutrients.fromRecipe(recipe, portionMultiplier);
  }

  PortionNutrients _calculateByGrams(Recipe recipe) {
    final servingMass = recipe.gramsPerServing ?? defaultGramsPerServing;
    final safeMass = servingMass <= 0 ? defaultGramsPerServing : servingMass;
    return PortionNutrients(
      calories: recipe.caloriesPerServing / safeMass * gramsConsumed,
      proteins: recipe.proteinsPerServing / safeMass * gramsConsumed,
      fats: recipe.fatsPerServing / safeMass * gramsConsumed,
      carbs: recipe.carbsPerServing / safeMass * gramsConsumed,
    );
  }

  Widget _macroRow(String label, double value, BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const Spacer(),
        Text(value.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = selectedRecipe;

    if (recipes.isEmpty) {
      return const SizedBox.shrink();
    }

    final portionNutrients = recipe == null ? PortionNutrients.zero : _calculatePortion(recipe);
    final gramsNutrients = recipe == null ? PortionNutrients.zero : _calculateByGrams(recipe);
    final gramsPerServing = recipe?.gramsPerServing ?? defaultGramsPerServing;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Проверка нутриентов', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Выберите рецепт и сравните БЖУ для множителя порций и для произвольного количества граммов.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Recipe>(
              value: recipe,
              items: recipes
                  .map(
                    (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.recipeName),
                ),
              )
                  .toList(),
              onChanged: onRecipeChanged,
              decoration: const InputDecoration(labelText: 'Рецепт'),
            ),
            const SizedBox(height: 16),
            Text('Множитель порции: ${portionMultiplier.toStringAsFixed(2)}'),
            Slider(
              value: portionMultiplier,
              min: 0.5,
              max: 3,
              divisions: 10,
              label: portionMultiplier.toStringAsFixed(2),
              onChanged: onPortionChanged,
            ),
            TextFormField(
              controller: gramsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Сколько граммов съедено',
                helperText: 'Масса порции: ${gramsPerServing.toStringAsFixed(0)} г',
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed != null) {
                  onGramsChanged(parsed);
                }
              },
            ),
            const SizedBox(height: 16),
            Text('БЖУ по множителю порций', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            _macroRow('Калории', portionNutrients.calories, context),
            _macroRow('Белки (г)', portionNutrients.proteins, context),
            _macroRow('Жиры (г)', portionNutrients.fats, context),
            _macroRow('Углеводы (г)', portionNutrients.carbs, context),
            const SizedBox(height: 16),
            Text('БЖУ по граммам', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            _macroRow('Калории', gramsNutrients.calories, context),
            _macroRow('Белки (г)', gramsNutrients.proteins, context),
            _macroRow('Жиры (г)', gramsNutrients.fats, context),
            _macroRow('Углеводы (г)', gramsNutrients.carbs, context),
          ],
        ),
      ),
    );
  }
}

class HomeHeaderRow extends StatelessWidget {
  const HomeHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Good Morning, Devina',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const Spacer(flex: 3),
        const Expanded(
          child: ProfileImage(
            height: 50.0,
            image:
            'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1740&q=80',
          ),
        ),
      ],
    );
  }
}

class HomePopularGrid extends StatelessWidget {
  const HomePopularGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = Provider.of<ListOfRecipes>(context);
    final popularRecipes = recipes.popularRecipes;
    return SizedBox(
      height: 350.0,
      child: ListView.builder(
        itemCount: popularRecipes.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: HomeStack(
                image: popularRecipes[index].recipeImage,
                text: popularRecipes[index].recipeName,
                prepTime: popularRecipes[index].prepTime,
                cookTime: popularRecipes[index].cookTime,
                recipeReview: popularRecipes[index].recipeReview,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipeScreen(),
                  settings: RouteSettings(
                    arguments: popularRecipes[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HomeStack extends StatelessWidget {
  final String image;
  final String text;
  final double prepTime;
  final double cookTime;
  final double recipeReview;

  const HomeStack({
    super.key,
    required this.image,
    required this.text,
    required this.prepTime,
    required this.cookTime,
    required this.recipeReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ReusableNetworkImage(
            imageUrl: image,
            height: 350.0,
            width: 200.0,
          ),
          Positioned(
            bottom: 10.0,
            right: 12.0,
            child: Container(
              width: 180.0,
              height: 110.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 5.0),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(UniconsLine.clock),
                        const SizedBox(width: 5.0),
                        Text(
                          '${prepTime + cookTime} M Total',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(color: Colors.black38),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(UniconsLine.star),
                        const SizedBox(width: 5.0),
                        Text(
                          recipeReview.toStringAsFixed(0),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(color: Colors.black38),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        itemCount: iconList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return InkWell(
            child: Container(
              width: 120.0,
              padding: const EdgeInsets.all(5.0),
              child: Material(
                color: Colors.white,
                elevation: 2.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(iconList[index].icon),
                    const SizedBox(height: 5.0),
                    Text(
                      iconList[index].text,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecipesScreen(),
                  settings: RouteSettings(arguments: items[index].category),
                ),
              );
            },
          );
        },
      ),
    );
  }
}