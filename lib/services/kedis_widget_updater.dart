import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KedisWidgetUpdater {
  // Retained as an internal compatibility key so the Flutter/native boundary
  // does not change just because the public product name changed.
  static const _channel = MethodChannel('dewwit/widget');

  static Future<void> refresh() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _channel.invokeMethod<void>('refresh');
    } on PlatformException catch (error) {
      debugPrint('Could not refresh the Kedis widget: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Kedis widget integration is unavailable: $error');
    }
  }

  static Future<void> syncThemeMode(ThemeMode themeMode) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await _channel.invokeMethod<void>('syncThemeMode', themeMode.name);
    } on PlatformException catch (error) {
      debugPrint('Could not update the Kedis widget theme: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Kedis widget integration is unavailable: $error');
    }
  }
}
