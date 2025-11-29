import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/screens.dart';  // Изменён путь
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/provider/provider.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});  // Исправлено

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  static const List<Widget> pages = [
    HomeScreen(),
    CategoryScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final languageCode = settings.locale.languageCode;
    final labels = _navLabels[languageCode] ?? _navLabels['en']!;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
        Theme.of(context).bottomNavigationBarTheme.backgroundColor,        elevation: 4.0,
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        selectedFontSize: 10.0.sp,
        iconSize: 18.sp,
        showUnselectedLabels: true,
        selectedItemColor:
        Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
        Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.home),
            label: labels[0],
          ),
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.apps),
            label: labels[1],
          ),
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.bookmark),
            label: labels[2],
          ),
          BottomNavigationBarItem(
            icon: const Icon(UniconsLine.user),
            label: labels[3],
          ),
        ],
      ),
      body: pages.elementAt(selectedIndex),
    );
  }

  static const Map<String, List<String>> _navLabels = {
    'en': ['Home', 'Category', 'Saved', 'Profile'],
    'ru': ['Главная', 'Категории', 'Сохранено', 'Профиль'],
  };
}