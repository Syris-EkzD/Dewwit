import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferenceStore {
  static const _preferenceKey = 'theme_mode';

  Future<ThemeMode> load() async {
    final preferences = await SharedPreferences.getInstance();
    return _decode(preferences.getString(_preferenceKey));
  }

  Future<void> save(ThemeMode themeMode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, themeMode.name);
  }

  ThemeMode _decode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
