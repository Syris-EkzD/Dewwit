package dev.ekzd.kedis

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "refresh" -> {
                        KedisWidgetProvider.refreshWidgets(this)
                        result.success(null)
                    }
                    "syncThemeMode" -> {
                        KedisWidgetThemePreferences.setThemeMode(this, call.arguments as? String)
                        KedisWidgetProvider.refreshWidgets(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private companion object {
        // Retained as the existing Flutter/native protocol identifier.
        const val WIDGET_CHANNEL = "dewwit/widget"
    }
}
