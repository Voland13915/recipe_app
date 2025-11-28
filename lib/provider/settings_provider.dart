import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
  bool _personalizedAds = false;
  bool _dataSharingEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get personalizedAds => _personalizedAds;
  bool get dataSharingEnabled => _dataSharingEnabled;

  void toggleNotifications(bool value) {
    if (_notificationsEnabled == value) {
      return;
    }
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    final newThemeMode = value ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == newThemeMode) {
      return;
    }
    _themeMode = newThemeMode;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }

  void togglePersonalizedAds(bool value) {
    if (_personalizedAds == value) {
      return;
    }
    _personalizedAds = value;
    notifyListeners();
  }

  void toggleDataSharing(bool value) {
    if (_dataSharingEnabled == value) {
      return;
    }
    _dataSharingEnabled = value;
    notifyListeners();
  }
}
