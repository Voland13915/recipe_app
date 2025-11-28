import 'package:flutter/material.dart';
import 'package:nutrition_app/models/models.dart';
import 'package:nutrition_app/provider/provider.dart';
import 'package:nutrition_app/utils/nutrition_engine.dart';
import 'package:provider/provider.dart';

class DatabaseManagerScreen extends StatefulWidget {
  const DatabaseManagerScreen({super.key});

  @override
  State<DatabaseManagerScreen> createState() => _DatabaseManagerScreenState();
}

class _DatabaseManagerScreenState extends State<DatabaseManagerScreen> {
  bool _loading = true;
  String? _error;
  List<Product> _products = [];
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final recipeProvider = context.read<ListOfRecipes>();

    try {
      await recipeProvider.initialize();
      final products = await recipeProvider.fetchProducts();
      await recipeProvider.reloadRecipes();

      setState(() {
        _products = products;
        _recipes = List.of(recipeProvider.getRecipes);
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _refreshProducts() async {
    final provider = context.read<ListOfRecipes>();
    final products = await provider.fetchProducts();
    setState(() => _products = products);
  }

  Future<void> _refreshRecipes() async {
    final provider = context.read<ListOfRecipes>();
    await provider.reloadRecipes();
    setState(() => _recipes = List.of(provider.getRecipes));
  }

  void _openProductForm({Product? product}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ProductFormSheet(
          initialProduct: product,
          onSaved: (saved) async {
            await context.read<ListOfRecipes>().upsertProduct(saved);
            await _refreshProducts();
          },
        ),
      ),
    );
  }

  Future<void> _openRecipeForm({Recipe? recipe}) async {
    final recipeProvider = context.read<ListOfRecipes>();
    final ingredients =
    recipe == null ? <RecipeIngredientRecord>[] : await recipeProvider.fetchRecipeIngredients(recipe.recipeId);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: RecipeFormSheet(
          products: _products,
          initialRecipe: recipe,
          initialIngredients: ingredients,
          onSaved: (payload, ingredientRecords) async {
            await recipeProvider.upsertRecipe(payload, ingredients: ingredientRecords);
            await _refreshRecipes();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final provider = context.read<ListOfRecipes>();
    await provider.deleteRecipe(recipe.recipeId);
    await _refreshRecipes();
  }

  Future<void> _deleteProduct(Product product) async {
    final provider = context.read<ListOfRecipes>();
    await provider.deleteProduct(product.id!);
    await _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('База блюд и ингредиентов'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Блюда'),
              Tab(text: 'Ингредиенты'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Повторить'),
              ),
            ],
          ),
        )
            : TabBarView(
          children: [
            RecipesTab(
              recipes: _recipes,
              onAdd: () => _openRecipeForm(),
              onEdit: (recipe) => _openRecipeForm(recipe: recipe),
              onDelete: _deleteRecipe,
            ),
            IngredientsTab(
              products: _products,
              onAdd: () => _openProductForm(),
              onEdit: (product) => _openProductForm(product: product),
              onDelete: _deleteProduct,
            ),
          ],
        ),
      ),
    );
  }
}

class RecipesTab extends StatelessWidget {
  final List<Recipe> recipes;
  final VoidCallback onAdd;
  final ValueChanged<Recipe> onEdit;
  final ValueChanged<Recipe> onDelete;

  const RecipesTab({
    super.key,
    required this.recipes,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Добавить блюдо'),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Создавайте и редактируйте рецепты, привязывая их к базе ингредиентов.'),
              ),
            ],
          ),
        ),
        Expanded(
          child: recipes.isEmpty
              ? const Center(child: Text('Нет блюд. Добавьте первое!'))
              : ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(recipe.recipeName),
                  subtitle: Text('${recipe.recipeCategory} • ${recipe.caloriesPerServing.toStringAsFixed(0)} ккал на порцию'),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit(recipe),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onDelete(recipe),
                      ),
                    ],
                  ),
                  onTap: () => onEdit(recipe),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class IngredientsTab extends StatelessWidget {
  final List<Product> products;
  final VoidCallback onAdd;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;

  const IngredientsTab({
    super.key,
    required this.products,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Добавить ингредиент'),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Ведите питательные значения продуктов, чтобы строить рецепты на их основе.'),
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? const Center(child: Text('Список ингредиентов пуст.'))
              : ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    'ккал ${product.caloriesPer100.toStringAsFixed(0)} • Б ${product.proteinsPer100.toStringAsFixed(1)} • Ж ${product.fatsPer100.toStringAsFixed(1)} • У ${product.carbsPer100.toStringAsFixed(1)} (на 100г)',
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit(product),
                      ),
                      if (product.id != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onDelete(product),
                        ),
                    ],
                  ),
                  onTap: () => onEdit(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProductFormSheet extends StatefulWidget {
  final Product? initialProduct;
  final ValueChanged<Product> onSaved;

  const ProductFormSheet({super.key, this.initialProduct, required this.onSaved});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinsController;
  late final TextEditingController _fatsController;
  late final TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProduct?.name ?? '');
    _caloriesController =
        TextEditingController(text: widget.initialProduct?.caloriesPer100.toString() ?? '0');
    _proteinsController =
        TextEditingController(text: widget.initialProduct?.proteinsPer100.toString() ?? '0');
    _fatsController = TextEditingController(text: widget.initialProduct?.fatsPer100.toString() ?? '0');
    _carbsController = TextEditingController(text: widget.initialProduct?.carbsPer100.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatsController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final product = Product(
      id: widget.initialProduct?.id,
      name: _nameController.text.trim(),
      caloriesPer100: double.tryParse(_caloriesController.text.replaceAll(',', '.')) ?? 0,
      proteinsPer100: double.tryParse(_proteinsController.text.replaceAll(',', '.')) ?? 0,
      fatsPer100: double.tryParse(_fatsController.text.replaceAll(',', '.')) ?? 0,
      carbsPer100: double.tryParse(_carbsController.text.replaceAll(',', '.')) ?? 0,
    );

    widget.onSaved(product);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.initialProduct == null ? 'Новый ингредиент' : 'Редактировать ингредиент',
                style: Theme.of(context).textTheme.headlineSmall),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название'),
              validator: (value) => (value == null || value.isEmpty) ? 'Введите название' : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(labelText: 'Ккал на 100г'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _proteinsController,
                    decoration: const InputDecoration(labelText: 'Белки на 100г'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fatsController,
                    decoration: const InputDecoration(labelText: 'Жиры на 100г'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(labelText: 'Углеводы на 100г'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class RecipeFormSheet extends StatefulWidget {
  final List<Product> products;
  final Recipe? initialRecipe;
  final List<RecipeIngredientRecord> initialIngredients;
  final void Function(Recipe recipe, List<RecipeIngredientRecord> ingredients) onSaved;

  const RecipeFormSheet({
    super.key,
    required this.products,
    required this.initialRecipe,
    required this.initialIngredients,
    required this.onSaved,
  });

  @override
  State<RecipeFormSheet> createState() => _RecipeFormSheetState();
}

class _RecipeFormSheetState extends State<RecipeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;
  late final TextEditingController _methodController;
  late final TextEditingController _reviewController;
  late final TextEditingController _imageController;
  late final TextEditingController _gramsController;
  bool _isPopular = false;
  final List<_IngredientRow> _rows = [];

  @override
  void initState() {
    super.initState();
    final recipe = widget.initialRecipe;
    _nameController = TextEditingController(text: recipe?.recipeName ?? '');
    _categoryController = TextEditingController(text: recipe?.recipeCategory ?? '');
    _descriptionController = TextEditingController(text: recipe?.recipeDescription ?? '');
    _prepTimeController = TextEditingController(text: recipe?.prepTime.toString() ?? '0');
    _cookTimeController = TextEditingController(text: recipe?.cookTime.toString() ?? '0');
    _servingsController = TextEditingController(text: recipe?.recipeServing.toString() ?? '1');
    _methodController = TextEditingController(text: recipe?.recipeMethod ?? '');
    _reviewController = TextEditingController(text: recipe?.recipeReview.toString() ?? '0');
    _imageController = TextEditingController(text: recipe?.recipeImage ?? '');
    _gramsController = TextEditingController(text: recipe?.gramsPerServing?.toString() ?? '');
    _isPopular = recipe?.isPopular ?? false;

    if (widget.initialIngredients.isEmpty) {
      _addIngredientRow();
    } else {
      for (final ingredient in widget.initialIngredients) {
        final product = widget.products.firstWhere(
              (p) => p.id == ingredient.productId,
          orElse: () => widget.products.isEmpty ? const Product(name: '', caloriesPer100: 0, proteinsPer100: 0, fatsPer100: 0, carbsPer100: 0) : widget.products.first,
        );
        _rows.add(_IngredientRow(product: product.id != null ? product : null, grams: ingredient.grams, id: ingredient.id));
      }
    }
  }

  void _addIngredientRow() {
    if (widget.products.isEmpty) return;
    _rows.add(_IngredientRow(product: widget.products.first, grams: 100));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _methodController.dispose();
    _reviewController.dispose();
    _imageController.dispose();
    _gramsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    if (_rows.isEmpty) return;

    final servings = int.tryParse(_servingsController.text) ?? 1;
    final productMap = {
      for (final product in widget.products)
        if (product.id != null) product.id!: product,
    };

    final ingredientRecords = _rows
        .where((row) => row.product?.id != null)
        .map(
          (row) => RecipeIngredientRecord(
        id: row.id,
        recipeId: widget.initialRecipe?.recipeId ?? 0,
        productId: row.product!.id!,
        grams: row.grams,
      ),
    )
        .toList();

    final totals = PortionNutrients.fromIngredients(ingredientRecords, productMap);
    final totalGrams = ingredientRecords.fold<double>(0, (sum, item) => sum + item.grams);
    final gramsPerServing = double.tryParse(_gramsController.text.replaceAll(',', '.')) ??
        (servings > 0 ? totalGrams / servings : totalGrams);

    final methodText = _methodController.text.trim();
    final recipe = Recipe(
      recipeId: widget.initialRecipe?.recipeId ?? 0,
      recipeCategory: _categoryController.text.trim().isEmpty
          ? 'Uncategorized'
          : _categoryController.text.trim(),
      recipeName: _nameController.text.trim(),
      recipeImage: _imageController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200'
          : _imageController.text.trim(),
      recipeDescription: _descriptionController.text.trim(),
      prepTime: double.tryParse(_prepTimeController.text.replaceAll(',', '.')) ?? 0,
      cookTime: double.tryParse(_cookTimeController.text.replaceAll(',', '.')) ?? 0,
      recipeServing: servings,
      recipeIngredients: ingredientRecords
          .map((record) => '${productMap[record.productId]?.name ?? 'Ингредиент'} - ${record.grams.toStringAsFixed(0)} г')
          .toList(),
      recipeMethod: methodText.isEmpty ? 'Нет описания приготовления' : methodText,
      recipeReview: double.tryParse(_reviewController.text.replaceAll(',', '.')) ?? 0,
      isPopular: _isPopular,
      caloriesPerServing: servings > 0 ? totals.calories / servings : totals.calories,
      proteinsPerServing: servings > 0 ? totals.proteins / servings : totals.proteins,
      fatsPerServing: servings > 0 ? totals.fats / servings : totals.fats,
      carbsPerServing: servings > 0 ? totals.carbs / servings : totals.carbs,
      gramsPerServing: gramsPerServing,
    );

    widget.onSaved(recipe, ingredientRecords);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.initialRecipe == null ? 'Новое блюдо' : 'Редактировать блюдо',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (value) => (value == null || value.isEmpty) ? 'Введите название' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Категория'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
                maxLines: 3,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(labelText: 'Время подготовки (мин)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cookTimeController,
                      decoration: const InputDecoration(labelText: 'Время готовки (мин)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(labelText: 'Порций'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _reviewController,
                      decoration: const InputDecoration(labelText: 'Рейтинг/очки'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Ссылка на изображение'),
              ),
              TextFormField(
                controller: _gramsController,
                decoration: const InputDecoration(labelText: 'Грамм на порцию (опционально)'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text('Отмечать как популярное'),
                value: _isPopular,
                onChanged: (value) => setState(() => _isPopular = value),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ингредиенты', style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: widget.products.isEmpty
                        ? null
                        : () => setState(() {
                      _addIngredientRow();
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
              if (widget.products.isEmpty)
                const Text('Нет продуктов в базе. Добавьте ингредиенты прежде чем создавать блюдо.')
              else
                Column(
                  children: _rows
                      .asMap()
                      .entries
                      .map(
                        (entry) => _IngredientRowWidget(
                      key: ValueKey(entry.key),
                      availableProducts: widget.products,
                      row: entry.value,
                      onChanged: (row) => setState(() => _rows[entry.key] = row),
                      onRemove: () => setState(() => _rows.removeAt(entry.key)),
                    ),
                  )
                      .toList(),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить блюдо'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredientRow {
  final Product? product;
  final double grams;
  final int? id;

  _IngredientRow({this.product, required this.grams, this.id});

  _IngredientRow copyWith({Product? product, double? grams}) =>
      _IngredientRow(product: product ?? this.product, grams: grams ?? this.grams, id: id);
}

class _IngredientRowWidget extends StatelessWidget {
  final List<Product> availableProducts;
  final _IngredientRow row;
  final ValueChanged<_IngredientRow> onChanged;
  final VoidCallback onRemove;

  const _IngredientRowWidget({
    super.key,
    required this.availableProducts,
    required this.row,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<Product>(
              isExpanded: true,
              value: _findSelectedProduct(row.product, availableProducts),
              items: availableProducts
                  .map(
                    (p) => DropdownMenuItem(
                  value: p,
                  child: Text(
                    p.name,
                    overflow: TextOverflow.ellipsis,
                  ),),
              )
                  .toList(),
              onChanged: (value) => onChanged(row.copyWith(product: value)),
              decoration: const InputDecoration(labelText: 'Ингредиент'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: row.grams.toStringAsFixed(0),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Грамм'),
              onChanged: (value) {
                final grams = double.tryParse(value.replaceAll(',', '.')) ?? row.grams;
                onChanged(row.copyWith(grams: grams));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
  Product? _findSelectedProduct(Product? product, List<Product> products) {
    if (products.isEmpty) return null;
    if (product == null) return products.first;
    for (final item in products) {
      if (item.id == product.id) {
        return item;
      }
    }
    return products.first;
  }
}