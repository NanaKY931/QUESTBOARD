import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _firstRunKey = 'is_first_run';
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isFirstRun = true;

  ThemeProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isFirstRun => _isFirstRun;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 1; // Default to Dark (1)
    _themeMode = ThemeMode.values[themeIndex];
    _isFirstRun = prefs.getBool(_firstRunKey) ?? true;
    notifyListeners();
  }

  Future<void> setFirstRunComplete() async {
    _isFirstRun = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstRunKey, false);
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
  }
}
