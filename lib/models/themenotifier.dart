import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode;

  ThemeNotifier(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;

  ThemeMode get currentThemeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}
