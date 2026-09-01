import 'package:dewwit/settings/theme_preference_store.dart';
import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(
    this._preferenceStore, {
    ThemeMode initialThemeMode = ThemeMode.system,
  }) : _themeMode = initialThemeMode;

  final ThemePreferenceStore _preferenceStore;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();
    await _preferenceStore.save(themeMode);
  }
}
