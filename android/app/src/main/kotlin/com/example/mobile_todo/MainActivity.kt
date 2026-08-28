package com.example.mobile_todo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "refresh") {
                    DewwitWidgetProvider.refreshWidgets(this)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private companion object {
        const val WIDGET_CHANNEL = "dewwit/widget"
    }
}
