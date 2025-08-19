import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  bool? _isDarkMode;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool? get isDarkMode => _isDarkMode;
  set isDarkMode(bool? value) => _isDarkMode = value;
  Locale? get locale => _locale;

  String? _languagePreference;
  String? get languagePreference => _languagePreference;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('selected_language');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
  }

  Future<void> setLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
  }

  Future<String?> getLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _languagePreference = prefs.getString('selected_language');
    return _languagePreference;
  }

  Future<bool?> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('dark_mode') == null) {
      _themeMode = ThemeMode.system;

      return null;
    }
    _isDarkMode = int.parse(prefs.getString('dark_mode') ?? "0") == 1;
    _themeMode = (_isDarkMode ?? false) ? ThemeMode.dark : ThemeMode.light;
    return _isDarkMode;
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !(_isDarkMode ?? false);
    _themeMode = (_isDarkMode ?? false) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'dark_mode', ((_isDarkMode ?? false) ? 1 : 0).toString());
  }
}
