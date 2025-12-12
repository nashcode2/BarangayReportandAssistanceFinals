import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app language
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  static const String _languageKey = 'app_language';

  Locale get locale => _locale;
  bool get isFilipino => _locale.languageCode == 'fil';

  LanguageProvider() {
    _loadLanguage();
  }

  /// Load saved language preference
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      // Use default language if loading fails
      _locale = const Locale('en');
    }
  }

  /// Change app language
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle between English and Filipino
  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'en'
        ? const Locale('fil')
        : const Locale('en');
    await setLocale(newLocale);
  }
}

