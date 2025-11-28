import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nutrition_app/models/models.dart';  // Изменён путь
import 'package:sqflite/sqflite.dart';  // Для будущей БД
import 'package:nutrition_app/utils/database_schema.dart';

class ListOfRecipes with ChangeNotifier {
  Database? _database;  // Для SQLite
  bool _isLoading = false;
  bool _isInitialized = false;
  List<Recipe> _recipes = [];

  bool get isLoading => _isLoading;

  void _updateLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _updateLoading(true);
    try {
      // Заглушка под будущую асинхронную загрузку
      await initDatabase();
      _isInitialized = true;
    } finally {
      _updateLoading(false);
    }
  }

  // Инициализация БД (вызовите в init)
  Future<void> initDatabase() async {
        if (_database != null) return;

    _database = await DatabaseSchema.open();

    await _seedDatabaseIfNeeded();
    await _loadRecipesFromDb();
  }

  Map<String, dynamic> _recipeToDbMap(Recipe recipe) {
    return {
      'id': recipe.recipeId,
      'category': recipe.recipeCategory,
      'name': recipe.recipeName,
      'description': recipe.recipeDescription,
      'image': recipe.recipeImage,
      'prepTime': recipe.prepTime,
      'cookTime': recipe.cookTime,
      'serving': recipe.recipeServing,
      'ingredients': jsonEncode(recipe.recipeIngredients),
      'method': recipe.recipeMethod,
      'review': recipe.recipeReview,
      'isPopular': recipe.isPopular ? 1 : 0,
      'caloriesPerServing': recipe.caloriesPerServing,
      'proteinsPerServing': recipe.proteinsPerServing,
      'fatsPerServing': recipe.fatsPerServing,
      'carbsPerServing': recipe.carbsPerServing,
      'gramsPerServing': recipe.gramsPerServing,
    };
  }

  Recipe _recipeFromDbMap(Map<String, dynamic> map) {
    final ingredients = map['ingredients'];
    final parsedIngredients = ingredients is String
        ? (jsonDecode(ingredients) as List<dynamic>).cast<String>()
        : <String>[];

    return Recipe(
      recipeId: map['id'] as int,
      recipeCategory: map['category'] as String,
      recipeName: map['name'] as String,
      recipeImage: map['image'] as String,
      recipeDescription: map['description'] as String? ?? '',
      prepTime: (map['prepTime'] as num).toDouble(),
      cookTime: (map['cookTime'] as num).toDouble(),
      recipeServing: map['serving'] as int,
      recipeIngredients: parsedIngredients,
      recipeMethod: map['method'] as String,
      recipeReview: (map['review'] as num).toDouble(),
      isPopular: (map['isPopular'] as int) == 1,
      caloriesPerServing: (map['caloriesPerServing'] as num).toDouble(),
      proteinsPerServing: (map['proteinsPerServing'] as num).toDouble(),
      fatsPerServing: (map['fatsPerServing'] as num).toDouble(),
      carbsPerServing: (map['carbsPerServing'] as num).toDouble(),
      gramsPerServing: (map['gramsPerServing'] as num?)?.toDouble(),
    );
  }

  Future<void> _seedDatabaseIfNeeded() async {
    if (_database == null) return;

    final count = Sqflite.firstIntValue(
      await _database!.rawQuery('SELECT COUNT(*) FROM recipes'),
    );

    if (count != null && count > 0) return;

    final batch = _database!.batch();
    for (final recipe in _seedRecipes) {
      batch.insert('recipes', _recipeToDbMap(recipe));
    }
    await batch.commit(noResult: true);
  }

  Future<void> _loadRecipesFromDb() async {
    if (_database == null) return;

    final results = await _database!.query('recipes');
    _recipes = results.map(_recipeFromDbMap).toList();
    notifyListeners();
  }

  // Нормализация категорий: поддерживаем и русские, и английские
  static const Map<String, String> _categoryCanonical = {
    // Завтрак
    'завтрак': 'Breakfast',
    'breakfast': 'Breakfast',
    // Обед
    'обед': 'Lunch',
    'lunch': 'Lunch',
    // Ужин
    'ужин': 'Dinner',
    'dinner': 'Dinner',
    // Перекус
    'перекус': 'Snack',
    'snack': 'Snack',
    // Десерт (в исходных данных использовалось именно "Desert")
    'десерт': 'Desert',
    'dessert': 'Desert',
    'desert': 'Desert',
    // Напиток
    'напиток': 'Beverage',
    'напитки': 'Beverage',
    'beverage': 'Beverage',
    'drink': 'Beverage',
    'drinks': 'Beverage',
  };

  static String _toCanonicalCategory(String input) {
    final key = input.trim().toLowerCase();
    return _categoryCanonical[key] ?? input; // если не нашли — оставим как есть
  }


  // Рецепты: категории — в КАНОНИЧЕСКОМ (английском) виде, тексты — на русском
  static final List<Recipe> _seedRecipes = [
    // Breakfast
    Recipe(
      recipeId: 1,
      recipeCategory: 'Breakfast',
      recipeName: 'Тост с авокадо',
      recipeImage:
      'https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      recipeDescription:
      'Хрустящий цельнозерновой тост с нежным авокадо, лимоном и каплей оливкового масла.',
      prepTime: 10.0,
      cookTime: 5.0,
      recipeServing: 1,
      recipeIngredients: [
        '1 ломтик цельнозернового хлеба',
        '1/2 спелого авокадо',
        '1 ч. л. лимонного сока',
        'Соль и перец по вкусу',
        '1 ч. л. оливкового масла'
      ],
      recipeMethod:
      'Поджарьте хлеб до золотистого цвета. Разомните авокадо с лимонным соком, солью и перцем. Нанесите на тост и сбрызните маслом.',
      recipeReview: 45,
      isPopular: true,
      caloriesPerServing: 220.0,
      proteinsPerServing: 5.0,
      fatsPerServing: 14.0,
      carbsPerServing: 20.0,
    ),
    Recipe(
      recipeId: 2,
      recipeCategory: 'Breakfast',
      recipeName: 'Йогурт-парфе с ягодами',
      recipeImage:
      'https://plus.unsplash.com/premium_photo-1713719216015-00a348bc4526?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1170',
      recipeDescription:
      'Слои греческого йогурта, свежих ягод и хрустящей гранолы с каплей мёда.',
      prepTime: 8.0,
      cookTime: 1.0,
      recipeServing: 1,
      recipeIngredients: [
        '1 стакан греческого йогурта',
        '1/2 стакана смеси ягод',
        '2 ст. л. гранолы',
        '1 ч. л. мёда',
        '1 ст. л. рубленого миндаля'
      ],
      recipeMethod:
      'В бокал слоями выложите йогурт, ягоды и гранолу. Полейте мёдом и посыпьте миндалём.',
      recipeReview: 60,
      isPopular: false,
      caloriesPerServing: 260.0,
      proteinsPerServing: 15.0,
      fatsPerServing: 9.0,
      carbsPerServing: 32.0,
    ),
    Recipe(
      recipeId: 3,
      recipeCategory: 'Breakfast',
      recipeName: 'Овсянка с бананом и орехами',
      recipeImage:
      'https://media.istockphoto.com/id/1352896570/photo/oatmeal-bowl-oat-porridge-with-banana-blueberry-walnut-chia-seeds-and-almond-milk-for-healthy.jpg?s=1024x1024&w=is&k=20&c=r8W5vdoCr-_vh6hYNP47kxNOQ_B3aiHtWtR7Lz9U0bY=',
      recipeDescription:
      'Тёплые овсяные хлопья на миндальном молоке с бананом, грецкими орехами и кленовым сиропом.',
      prepTime: 5.0,
      cookTime: 10.0,
      recipeServing: 1,
      recipeIngredients: [
        '1/2 стакана овсяных хлопьев',
        '1 стакан миндального молока',
        '1 спелый банан, ломтиками',
        '1 ст. л. рубленых грецких орехов',
        '1 ч. л. кленового сиропа'
      ],
      recipeMethod:
      'Сварите овсянку на миндальном молоке до кремовой консистенции. Вмешайте половину банана и сироп. Сверху выложите оставшийся банан и орехи.',
      recipeReview: 38,
      isPopular: false,
      caloriesPerServing: 280.0,
      proteinsPerServing: 7.0,
      fatsPerServing: 9.0,
      carbsPerServing: 45.0,
    ),
    Recipe(
      recipeId: 4,
      recipeCategory: 'Breakfast',
      recipeName: 'Омлет с овощами',
      recipeImage:
      'https://plus.unsplash.com/premium_photo-1689596510437-aed4adfd125e?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8VmVnZ2llJTIwT21lbGV0dGV8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600',
      recipeDescription:
      'Пышный омлет с перцем, шпинатом и луком, под сырной посыпкой.',
      prepTime: 10.0,
      cookTime: 7.0,
      recipeServing: 1,
      recipeIngredients: [
        '2 крупных яйца',
        '1/4 стакана сладкого перца, кубиками',
        '1/4 стакана шпината, рубленого',
        '1 ст. л. лука, мелко нарезанного',
        '1 ст. л. тёртого чеддера'
      ],
      recipeMethod:
      'Взбейте яйца и вылейте на разогретую сковороду. Добавьте овощи и готовьте до схватывания. Посыпьте сыром и сложите пополам.',
      recipeReview: 52,
      isPopular: true,
      caloriesPerServing: 210.0,
      proteinsPerServing: 16.0,
      fatsPerServing: 15.0,
      carbsPerServing: 4.0,
    ),
    Recipe(
      recipeId: 5,
      recipeCategory: 'Breakfast',
      recipeName: 'Смуди-боул с арахисовой пастой',
      recipeImage:
      'https://i.pinimg.com/736x/09/5b/8d/095b8d3487c57d9158f1ed2c48b1525d.jpg',
      recipeDescription:
      'Густой шоколадно-арахисовый смузи в тарелке с хрустящей гранолой.',
      prepTime: 7.0,
      cookTime: 1.0,
      recipeServing: 1,
      recipeIngredients: [
        '1 замороженный банан',
        '1/2 стакана миндального молока',
        '2 ст. л. арахисовой пасты',
        '1 ст. л. какао',
        '1/4 стакана гранолы (для подачи)'
      ],
      recipeMethod:
      'Взбейте банан, молоко, арахисовую пасту и какао до однородности. Перелейте в миску и посыпьте гранолой.',
      recipeReview: 33,
      isPopular: false,
      caloriesPerServing: 320.0,
      proteinsPerServing: 12.0,
      fatsPerServing: 18.0,
      carbsPerServing: 34.0,
    ),

    // Lunch
    Recipe(
      recipeId: 6,
      recipeCategory: 'Lunch',
      recipeName: 'Салат с курицей-гриль',
      recipeImage:
      'https://images.unsplash.com/photo-1604909052743-94e838986d24?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=880',
      recipeDescription:
      'Курица-гриль на миксе салатной зелени с томатами, огурцом и бальзамической заправкой.',
      prepTime: 15.0,
      cookTime: 12.0,
      recipeServing: 2,
      recipeIngredients: [
        '200 г куриной грудки-гриль',
        '2 стакана салатной смеси',
        '1/2 стакана черри',
        '1/4 стакана огурца, ломтиками',
        '2 ст. л. бальзамической заправки'
      ],
      recipeMethod:
      'Нарежьте курицу. Смешайте зелень с томатами и огурцом, заправьте. Сверху выложите курицу.',
      recipeReview: 75,
      isPopular: true,
      caloriesPerServing: 280.0,
      proteinsPerServing: 26.0,
      fatsPerServing: 12.0,
      carbsPerServing: 16.0,
    ),
    Recipe(
      recipeId: 7,
      recipeCategory: 'Lunch',
      recipeName: 'Боул с киноа и овощами',
      recipeImage:
      'https://i.pinimg.com/originals/e2/3a/e8/e23ae80b8ad212a310fd84c2a0233870.png',
      recipeDescription:
      'Сытная киноа с запечённым нутом, овощами и ореховым тахини-соусом.',
      prepTime: 10.0,
      cookTime: 20.0,
      recipeServing: 2,
      recipeIngredients: [
        '1 стакан отваренной киноа',
        '1/2 стакана запечённого нута',
        '1/2 стакана брокколи, на пару',
        '1/2 стакана сладкого перца, кубиками',
        '2 ст. л. соуса тахини'
      ],
      recipeMethod:
      'Разложите киноа по тарелкам. Сверху выложите нут, брокколи и перец. Полейте тахини.',
      recipeReview: 41,
      isPopular: false,
      caloriesPerServing: 340.0,
      proteinsPerServing: 12.0,
      fatsPerServing: 11.0,
      carbsPerServing: 48.0,
    ),
    Recipe(
      recipeId: 8,
      recipeCategory: 'Lunch',
      recipeName: 'Сэндвич с индейкой и авокадо',
      recipeImage:
      'https://plus.unsplash.com/premium_photo-1738431707788-3960bf6fddc3?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=880',
      recipeDescription:
      'Цельнозерновой хлеб с ломтиками индейки, авокадо, томатом и листьями салата.',
      prepTime: 8.0,
      cookTime: 1.0,
      recipeServing: 1,
      recipeIngredients: [
        '2 ломтика цельнозернового хлеба',
        '90 г индейки, ломтиками',
        '1/4 авокадо, ломтиками',
        '2 ломтика томата',
        '1 лист салата'
      ],
      recipeMethod:
      'Соберите сэндвич слоями: индейка, авокадо, томат, салат. Разрежьте пополам и подавайте.',
      recipeReview: 58,
      isPopular: false,
      caloriesPerServing: 330.0,
      proteinsPerServing: 24.0,
      fatsPerServing: 12.0,
      carbsPerServing: 32.0,
    ),
    Recipe(
      recipeId: 9,
      recipeCategory: 'Lunch',
      recipeName: 'Овощной ролл по-средиземноморски',
      recipeImage:
      'https://i.pinimg.com/736x/16/e8/14/16e8146ec18254ea5998bb0d8ad64fe7.jpg',
      recipeDescription:
      'Пшеничная тортилья с хумусом, огурцом, морковью и солёной фетой.',
      prepTime: 12.0,
      cookTime: 1.0,
      recipeServing: 1,
      recipeIngredients: [
        '1 пшеничная тортилья (ц/з)',
        '1/4 стакана хумуса',
        '1/4 стакана огурца, ломтиками',
        '1/4 стакана моркови, тёртой',
        '2 ст. л. сыра фета, крошкой'
      ],
      recipeMethod:
      'Смажьте тортилью хумусом. Выложите огурец, морковь и фету. Плотно сверните и разрежьте пополам.',
      recipeReview: 29,
      isPopular: false,
      caloriesPerServing: 290.0,
      proteinsPerServing: 10.0,
      fatsPerServing: 9.0,
      carbsPerServing: 44.0,
    ),
    Recipe(
      recipeId: 10,
      recipeCategory: 'Lunch',
      recipeName: 'Томатный суп с базиликом',
      recipeImage:
      'https://images.unsplash.com/photo-1695960682129-d35477676196?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1170',
      recipeDescription:
      'Томаты, томлённые с чесноком и луком, пробитые до шелковистой текстуры с листьями базилика.',
      prepTime: 15.0,
      cookTime: 30.0,
      recipeServing: 3,
      recipeIngredients: [
        '1 ст. л. оливкового масла',
        '1/2 стакана лука, кубиками',
        '2 зубчика чеснока, измельчить',
        '3 стакана томатов дроблёных',
        '1/2 стакана свежего базилика'
      ],
      recipeMethod:
      'Обжарьте лук и чеснок в масле до аромата. Добавьте томаты и томите 20 минут. Пробейте с базиликом до гладкости и подайте тёплым.',
      recipeReview: 47,
      isPopular: true,
      caloriesPerServing: 180.0,
      proteinsPerServing: 5.0,
      fatsPerServing: 8.0,
      carbsPerServing: 24.0,
    ),

    // Dinner
    Recipe(
      recipeId: 11,
      recipeCategory: 'Dinner',
      recipeName: 'Запечённый лосось с травами',
      recipeImage:
      'https://images.unsplash.com/photo-1601314212732-047d4bdffd22?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=736',
      recipeDescription:
      'Лосось в духовке с лимоном, укропом и оливковым маслом до нежной сочности.',
      prepTime: 10.0,
      cookTime: 18.0,
      recipeServing: 2,
      recipeIngredients: [
        '2 филе лосося',
        '1 ст. л. оливкового масла',
        '1 ст. л. лимонного сока',
        '1 ч. л. сушёного укропа',
        'Соль и перец по вкусу'
      ],
      recipeMethod:
      'Смажьте лосось маслом и лимонным соком. Приправьте укропом, солью и перцем. Выпекайте при 200°C 15–18 минут до расслоения.',
      recipeReview: 68,
      isPopular: true,
      caloriesPerServing: 360.0,
      proteinsPerServing: 34.0,
      fatsPerServing: 22.0,
      carbsPerServing: 2.0,
    ),
    Recipe(
      recipeId: 12,
      recipeCategory: 'Dinner',
      recipeName: 'Курица в воке с овощами',
      recipeImage:
      'https://images.unsplash.com/photo-1758979690131-11e2aa0b142b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Q2hpY2tlbiUyMFN0aXItRnJ5fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
      recipeDescription:
      'Быстрый стир-фрай из курицы и овощей в соево-имбирном соусе.',
      prepTime: 12.0,
      cookTime: 15.0,
      recipeServing: 2,
      recipeIngredients: [
        '250 г куриного филе, полосками',
        '2 стакана смеси овощей для стир-фрая',
        '2 ст. л. соевого соуса',
        '1 ст. л. кунжутного масла',
        '1 ч. л. тёртого имбиря'
      ],
      recipeMethod:
      'Разогрейте кунжутное масло в воке. Обжарьте курицу до румяности, добавьте овощи, соус и имбирь. Готовьте до мягкости овощей.',
      recipeReview: 54,
      isPopular: false,
      caloriesPerServing: 320.0,
      proteinsPerServing: 30.0,
      fatsPerServing: 12.0,
      carbsPerServing: 20.0,
    ),
    Recipe(
      recipeId: 13,
      recipeCategory: 'Dinner',
      recipeName: 'Такос с говядиной',
      recipeImage:
      'https://plus.unsplash.com/premium_photo-1661730314652-911662c0d86e?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1170',
      recipeDescription:
      'Пряный фарш в тёплых кукурузных тортильях с салатом и сальсой.',
      prepTime: 15.0,
      cookTime: 12.0,
      recipeServing: 3,
      recipeIngredients: [
        '300 г постного говяжьего фарша',
        '1 пакет приправы для тако',
        '6 маленьких кукурузных тортиль',
        '1/2 стакана салата айсберг, шинкованного',
        '1/4 стакана сальсы'
      ],
      recipeMethod:
      'Обжарьте фарш, добавьте приправу и немного воды. Разложите по тортильям, сверху салат и сальса.',
      recipeReview: 59,
      isPopular: true,
      caloriesPerServing: 400.0,
      proteinsPerServing: 24.0,
      fatsPerServing: 18.0,
      carbsPerServing: 36.0,
    ),
    Recipe(
      recipeId: 14,
      recipeCategory: 'Dinner',
      recipeName: 'Овощное карри в кокосовом молоке',
      recipeImage:
      'https://www.tastingtable.com/img/gallery/vegetable-coconut-curry-recipe/l-intro-1662563071.jpg',
      recipeDescription:
      'Кремовое карри с овощами и ароматными специями. Подаётся с басмати.',
      prepTime: 15.0,
      cookTime: 25.0,
      recipeServing: 3,
      recipeIngredients: [
        '1 ст. л. кокосового масла',
        '2 стакана овощей (микс)',
        '1 стакан кокосового молока',
        '2 ст. л. пасты красного карри',
        '1 стакан варёного риса басмати (для подачи)'
      ],
      recipeMethod:
      'Обжарьте овощи 5 минут в кокосовом масле. Добавьте пасту карри и кокосовое молоко, томите до мягкости. Подавайте с рисом.',
      recipeReview: 48,
      isPopular: false,
      caloriesPerServing: 420.0,
      proteinsPerServing: 8.0,
      fatsPerServing: 24.0,
      carbsPerServing: 46.0,
    ),
    Recipe(
      recipeId: 15,
      recipeCategory: 'Dinner',
      recipeName: 'Паста «Примавера»',
      recipeImage:
      'https://i2.wp.com/www.thespruceeats.com/thmb/IKjgrJs1Wg5cWXwbFT3ecbwBbsU=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/SES-pasta-primavera-recipe-7503609-hero-01-242226d2fd334ccebcfac98e91b74f08.jpg',
      recipeDescription:
      'Цельнозерновая паста с сезонными овощами и пармезаном.',
      prepTime: 12.0,
      cookTime: 18.0,
      recipeServing: 2,
      recipeIngredients: [
        '180 г цельнозерновой пасты',
        '1 стакан черри',
        '1 стакан цукини, кружочками',
        '1/2 стакана зелёного горошка',
        '2 ст. л. тёртого пармезана'
      ],
      recipeMethod:
      'Сварите пасту по инструкции. Обжарьте овощи в оливковом масле, затем соедините с пастой и пармезаном.',
      recipeReview: 36,
      isPopular: false,
      caloriesPerServing: 380.0,
      proteinsPerServing: 15.0,
      fatsPerServing: 10.0,
      carbsPerServing: 58.0,
    ),

    // Snack
    Recipe(
      recipeId: 16,
      recipeCategory: 'Snack',
      recipeName: 'Овощные палочки с хумусом',
      recipeImage:
      'https://fb.ru/media/i/3/0/1/0/1/3/2/i/3010132.jpg',
      recipeDescription:
      'Хрустящие морковь, огурец и сельдерей с кремовым хумусом.',
      prepTime: 10.0,
      cookTime: 1.0,
      recipeServing: 2,
      recipeIngredients: [
        '1/2 стакана хумуса',
        '1 морковь, палочками',
        '1 огурец, палочками',
        '1 стебель сельдерея, ломтиками',
        '1 ст. л. оливкового масла (по желанию)'
      ],
      recipeMethod:
      'Разложите палочки овощей на тарелке. Подавайте с хумусом, при желании сбрызните маслом.',
      recipeReview: 22,
      isPopular: false,
      caloriesPerServing: 180.0,
      proteinsPerServing: 6.0,
      fatsPerServing: 10.0,
      carbsPerServing: 18.0,
    ),
    Recipe(
      recipeId: 17,
      recipeCategory: 'Snack',
      recipeName: 'Домашняя смесь «Трейл-микс»',
      recipeImage:
      'https://media.istockphoto.com/id/1188912041/photo/beef-jerky-trail-mix.jpg?s=612x612&w=0&k=20&c=C3qvx_ZUm1kQfP_PntOW6ShRddoAiEjhA_-CObsmHw8=',
      recipeDescription:
      'Сладко-солёная смесь орехов, сухофруктов, шоколада и семечек для быстрого перекуса.',
      prepTime: 5.0,
      cookTime: 1.0,
      recipeServing: 4,
      recipeIngredients: [
        '1/2 стакана миндаля',
        '1/2 стакана кешью',
        '1/4 стакана сушёной клюквы',
        '1/4 стакана тёмного шоколада, капли',
        '1/4 стакана семян тыквы'
      ],
      recipeMethod:
      'Смешайте все ингредиенты в миске до равномерного распределения. Разложите по пакетикам.',
      recipeReview: 31,
      isPopular: true,
      caloriesPerServing: 220.0,
      proteinsPerServing: 6.0,
      fatsPerServing: 14.0,
      carbsPerServing: 18.0,
    ),
    Recipe(
      recipeId: 18,
      recipeCategory: 'Snack',
      recipeName: 'Йогуртовый фруктовый дип',
      recipeImage:
      'https://i.pinimg.com/originals/bf/12/bf/bf12bf71c5a18d835fa34877128718a2.jpg',
      recipeDescription:
      'Подслащённый греческий йогурт с ванилью и чиа для макания фруктов.',
      prepTime: 6.0,
      cookTime: 1.0,
      recipeServing: 4,
      recipeIngredients: [
        '1 стакан греческого йогурта',
        '2 ст. л. мёда',
        '1 ч. л. ванильного экстракта',
        'Нарезанные фрукты для подачи',
        '1 ст. л. семян чиа'
      ],
      recipeMethod:
      'Взбейте йогурт с мёдом и ванилью. Посыпьте чиа и подавайте с фруктами.',
      recipeReview: 18,
      isPopular: false,
      caloriesPerServing: 120.0,
      proteinsPerServing: 9.0,
      fatsPerServing: 3.0,
      carbsPerServing: 16.0,
    ),
    Recipe(
      recipeId: 19,
      recipeCategory: 'Snack',
      recipeName: 'Яблоко с миндальным маслом',
      recipeImage:
      'https://i.pinimg.com/originals/0e/e9/6a/0ee96a43293f40488a187000c3f9a1b1.jpg',
      recipeDescription:
      'Хрустящие ломтики яблока с бархатистым миндальным маслом и тёплыми специями.',
      prepTime: 5.0,
      cookTime: 1.0,
      recipeServing: 1,
      recipeIngredients: [
        '1 среднее яблоко, ломтиками',
        '2 ст. л. миндального масла',
        '1 ч. л. корицы',
        '1 ч. л. семян чиа',
        '1 ч. л. мёда (по желанию)'
      ],
      recipeMethod:
      'Разложите яблоко на тарелке. Подавайте с миндальным маслом, посыпьте корицей и чиа, при желании добавьте мёд.',
      recipeReview: 25,
      isPopular: false,
      caloriesPerServing: 210.0,
      proteinsPerServing: 5.0,
      fatsPerServing: 12.0,
      carbsPerServing: 26.0,
    ),
    Recipe(
      recipeId: 20,
      recipeCategory: 'Snack',
      recipeName: 'Энергетические шарики без выпечки',
      recipeImage:
      'https://i.pinimg.com/736x/b6/dd/0d/b6dd0d0155caf4e8b53388d0dcbad9eb.jpg',
      recipeDescription:
      'Жевательные шарики из овсянки и арахисовой пасты с льном и шоколадными каплями — без духовки.',
      prepTime: 15.0,
      cookTime: 1.0,
      recipeServing: 4,
      recipeIngredients: [
        '1 стакан овсяных хлопьев',
        '1/2 стакана арахисовой пасты',
        '1/3 стакана мёда',
        '1/4 стакана льняной муки',
        '1/4 стакана мини-капель шоколада'
      ],
      recipeMethod:
      'Смешайте все ингредиенты до однородности. Скатайте шарики и охладите 30 минут.',
      recipeReview: 40,
      isPopular: true,
      caloriesPerServing: 190.0,
      proteinsPerServing: 6.0,
      fatsPerServing: 10.0,
      carbsPerServing: 22.0,
    ),

    // Desert (каноническое имя как в исходнике)
    Recipe(
      recipeId: 21,
      recipeCategory: 'Desert',
      recipeName: 'Брауни «Фаджи»',
      recipeImage:
      'https://plus.unsplash.com/premium_photo-1716152295684-21731e330e36?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8RnVkZ3klMjBCcm93bmllc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=600',
      recipeDescription:
      'Насыщенные шоколадные брауни с мягкой тягучей серединкой и хрустящей корочкой.',
      prepTime: 20.0,
      cookTime: 25.0,
      recipeServing: 8,
      recipeIngredients: [
        '1/2 стакана растопленного сливочного масла',
        '1 стакан сахара',
        '2 крупных яйца',
        '1/3 стакана какао-порошка',
        '1/2 стакана муки'
      ],
      recipeMethod:
      'Смешайте масло с сахаром, введите яйца, затем какао и муку. Выложите в форму и выпекайте при 175°C 25 минут.',
      recipeReview: 85,
      isPopular: true,
      caloriesPerServing: 240.0,
      proteinsPerServing: 3.0,
      fatsPerServing: 12.0,
      carbsPerServing: 32.0,
    ),
    Recipe(
      recipeId: 22,
      recipeCategory: 'Desert',
      recipeName: 'Лимонный тарт',
      recipeImage:
      'https://images.unsplash.com/photo-1543508185-225c92847541?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8TGVtb24lMjBUYXJ0fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
      recipeDescription:
      'Песочная основа, наполненная шёлковистым лимонным курдом и охлаждённая до идеала.',
      prepTime: 25.0,
      cookTime: 30.0,
      recipeServing: 6,
      recipeIngredients: [
        '1 готовая тарталетка (основа)',
        '3 крупных яйца',
        '1/2 стакана сахара',
        '1/3 стакана лимонного сока',
        '2 ст. л. сливочного масла'
      ],
      recipeMethod:
      'Взбейте яйца с сахаром и лимонным соком в сотейнике. Готовьте до загустения, вмешайте масло, вылейте в основу и охладите.',
      recipeReview: 44,
      isPopular: false,
      caloriesPerServing: 280.0,
      proteinsPerServing: 5.0,
      fatsPerServing: 14.0,
      carbsPerServing: 34.0,
    ),
    Recipe(
      recipeId: 23,
      recipeCategory: 'Desert',
      recipeName: 'Мини-чизкейки',
      recipeImage:
      'https://i.pinimg.com/736x/1d/bd/83/1dbd83b85b6604e7caa890b340800f80.jpg',
      recipeDescription:
      'Индивидуальные чизкейки на крекерной основе, нежные и кремовые.',
      prepTime: 15.0,
      cookTime: 18.0,
      recipeServing: 6,
      recipeIngredients: [
        '6 мини-корзинок из крекерной крошки',
        '225 г сливочного сыра',
        '1/4 стакана сахара',
        '1 яйцо',
        '1 ч. л. ванильного экстракта'
      ],
      recipeMethod:
      'Взбейте сливочный сыр с сахаром, яйцом и ванилью. Наполните основы и выпекайте при 160°C 18 минут. Остудите.',
      recipeReview: 39,
      isPopular: false,
      caloriesPerServing: 260.0,
      proteinsPerServing: 5.0,
      fatsPerServing: 16.0,
      carbsPerServing: 22.0,
    ),
    Recipe(
      recipeId: 24,
      recipeCategory: 'Desert',
      recipeName: 'Тропический фруктовый салат',
      recipeImage:
      'https://i.pinimg.com/736x/4b/ad/27/4bad27da3088e0bff4c0a3ee0e7b8af3.jpg',
      recipeDescription:
      'Освежающая смесь ананаса, манго и ягод в лаймово-медовой заправке.',
      prepTime: 15.0,
      cookTime: 1.0,
      recipeServing: 4,
      recipeIngredients: [
        '1 стакан ананаса, кубиками',
        '1 стакан манго, кубиками',
        '1 стакан клубники, ломтиками',
        '1 ст. л. сока лайма',
        '1 ст. л. мёда'
      ],
      recipeMethod:
      'Смешайте фрукты в миске. Заправьте соком лайма и мёдом. Охладите 20 минут.',
      recipeReview: 27,
      isPopular: false,
      caloriesPerServing: 150.0,
      proteinsPerServing: 2.0,
      fatsPerServing: 1.0,
      carbsPerServing: 38.0,
    ),
    Recipe(
      recipeId: 25,
      recipeCategory: 'Desert',
      recipeName: 'Санди с ванильным мороженым',
      recipeImage:
      'https://images.unsplash.com/photo-1633881613747-e98695066141?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1170',
      recipeDescription:
      'Классические шарики ванильного мороженого с шоколадным соусом, орехами, взбитыми сливками и вишней.',
      prepTime: 5.0,
      cookTime: 1.0,
      recipeServing: 2,
      recipeIngredients: [
        '2 шарика ванильного мороженого',
        '2 ст. л. шоколадного соуса',
        '2 ст. л. рубленых орехов',
        'Взбитые сливки',
        'Вишня мараскино'
      ],
      recipeMethod:
      'Выложите мороженое в пиалы. Полейте соусом, посыпьте орехами, добавьте сливки и вишню.',
      recipeReview: 51,
      isPopular: true,
      caloriesPerServing: 310.0,
      proteinsPerServing: 5.0,
      fatsPerServing: 16.0,
      carbsPerServing: 38.0,
    ),

    // Beverage
    Recipe(
      recipeId: 26,
      recipeCategory: 'Beverage',
      recipeName: 'Зелёный детокс-смузи',
      recipeImage:
      'https://avatars.mds.yandex.net/i?id=5f5251ad6270d95b309c21c8a5dbacebbeb17232-4401365-images-thumbs&n=13',
      recipeDescription:
      'Ярко-зелёный смузи из шпината, банана, ананаса и кокосовой воды.',
      prepTime: 5.0,
      cookTime: 1.0,
      recipeServing: 1,
      recipeIngredients: [
        '1 стакан шпината',
        '1/2 банана',
        '1/2 стакана ананаса, кубиками',
        '1 стакан кокосовой воды',
        'Сок 1/2 лайма'
      ],
      recipeMethod:
      'Пробейте шпинат, банан, ананас, кокосовую воду и лайм до однородности. Подавайте сразу, при желании со льдом.',
      recipeReview: 35,
      isPopular: false,
      caloriesPerServing: 160.0,
      proteinsPerServing: 3.0,
      fatsPerServing: 1.0,
      carbsPerServing: 38.0,
    ),
    Recipe(
      recipeId: 27,
      recipeCategory: 'Beverage',
      recipeName: 'Шоколадный протеиновый шейк',
      recipeImage:
      'https://thebigmansworld.com/wp-content/uploads/2024/05/chocolate-protein-shake-recipe1.jpg',
      recipeDescription:
      'Кремовый послетренировочный шейк с шоколадным протеином, бананом, арахисовой пастой и молоком.',
      prepTime: 5.0,
      cookTime: 1.0,
      recipeServing: 1,
      recipeIngredients: [
        '1 мерная ложка шоколадного протеина',
        '1 стакан обезжиренного молока',
        '1 ст. л. арахисовой пасты',
        '1/2 банана',
        '1/2 стакана льда'
      ],
      recipeMethod:
      'Смешайте все ингредиенты в блендере до кремовой текстуры. Подавайте охлаждённым.',
      recipeReview: 42,
      isPopular: true,
      caloriesPerServing: 280.0,
      proteinsPerServing: 28.0,
      fatsPerServing: 9.0,
      carbsPerServing: 28.0,
    ),
    Recipe(
      recipeId: 28,
      recipeCategory: 'Beverage',
      recipeName: 'Успокаивающий травяной чай',
      recipeImage:
      'https://images.pexels.com/photos/1417945/pexels-photo-1417945.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      recipeDescription:
      'Расслабляющий настой из ромашки и лаванды с мёдом и лимоном.',
      prepTime: 2.0,
      cookTime: 5.0,
      recipeServing: 2,
      recipeIngredients: [
        '2 стакана воды',
        '1 ст. л. сушёной ромашки',
        '1 ч. л. сушёной лаванды',
        '1 ч. л. мёда',
        'Ломтики лимона для подачи'
      ],
      recipeMethod:
      'Доведите воду до лёгкого кипения. Заварите ромашку и лаванду 5 минут, процедите в кружки и подсластите мёдом, добавьте лимон.',
      recipeReview: 21,
      isPopular: false,
      caloriesPerServing: 35.0,
      proteinsPerServing: 0.0,
      fatsPerServing: 0.0,
      carbsPerServing: 9.0,
    ),
    Recipe(
      recipeId: 29,
      recipeCategory: 'Beverage',
      recipeName: 'Классический лимонад',
      recipeImage:
      'https://images.pexels.com/photos/96974/pexels-photo-96974.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      recipeDescription:
      'Свежевыжатый лимонный сок с сахаром и водой — идеально охлаждающий.',
      prepTime: 10.0,
      cookTime: 1.0,
      recipeServing: 4,
      recipeIngredients: [
        '1 стакан свежего лимонного сока',
        '1/2 стакана сахара',
        '4 стакана холодной воды',
        'Ломтики лимона для украшения',
        'Кубики льда'
      ],
      recipeMethod:
      'Размешайте сахар в лимонном соке до растворения. Добавьте воду и охладите. Подавайте со льдом и ломтиками лимона.',
      recipeReview: 49,
      isPopular: true,
      caloriesPerServing: 110.0,
      proteinsPerServing: 0.0,
      fatsPerServing: 0.0,
      carbsPerServing: 28.0,
    ),
    Recipe(
      recipeId: 30,
      recipeCategory: 'Beverage',
      recipeName: 'Тайский айс-ти',
      recipeImage:
      'https://images.pexels.com/photos/40594/lemon-tea-cold-beverages-summer-offerings-40594.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
      recipeDescription:
      'Пряный тайский чай, охлаждённый и поданный со сгущённым молоком поверх льда.',
      prepTime: 5.0,
      cookTime: 180.0,
      recipeServing: 4,
      recipeIngredients: [
        '4 стакана воды',
        '1/2 стакана смеси для тайского чая',
        '1/2 стакана сахара',
        '1 стакан льда',
        '1/2 стакана сгущённого молока'
      ],
      recipeMethod:
      'Доведите воду до кипения и всыпьте смесь для чая. Настаивайте 15 минут, процедите, вмешайте сахар. Полностью охладите и подавайте со льдом и сгущённым молоком.',
      recipeReview: 147,
      isPopular: false,
      caloriesPerServing: 180.0,
      proteinsPerServing: 4.0,
      fatsPerServing: 5.0,
      carbsPerServing: 32.0,
    ),
  ];

  List<Recipe> get getRecipes {
    return _recipes;
  }

  Recipe findById(double id) {
    return _recipes.firstWhere((i) => i.recipeId == id);
  }

  List<dynamic> findByCategory(String categoryName) {
    // нормализуем вход и сравниваем по канонической категории
    final canonical = _toCanonicalCategory(categoryName);
    final list = _recipes.where((e) => e.recipeCategory == canonical).toList();
    return list;
  }

  List<Recipe> get popularRecipes {
    return _recipes.where((element) => element.isPopular).toList();
  }

  List<dynamic> searchRecipe(String searchText) {
    final q = searchText.toLowerCase();
    final list = _recipes
        .where((e) =>
    e.recipeName.toLowerCase().contains(q) ||
        e.recipeDescription.toLowerCase().contains(q))
        .toList();
    return list;
  }
}
