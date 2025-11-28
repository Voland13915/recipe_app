import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/provider/provider.dart';  // Изменён путь
import 'package:nutrition_app/custom_theme.dart';  // Изменён путь
import 'package:sizer/sizer.dart';

import 'custom_navbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ListOfRecipes()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => SavedProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // Исправлено для Dart 3+

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      final settings = context.watch<SettingsProvider>();

      return MaterialApp(
        title: 'Nutrition App',  // Изменено имя
        debugShowCheckedModeBanner: false,
        theme: CustomTheme.lightTheme,
        darkTheme: CustomTheme.darkTheme,
        themeMode: settings.themeMode,
        locale: settings.locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ru'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const CustomNavBar(),
      );
    });
  }
}