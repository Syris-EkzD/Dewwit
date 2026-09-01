package com.example.mobile_todo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews
import java.util.concurrent.Executors

class DewwitWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle,
    ) {
        updateWidget(context, appWidgetManager, appWidgetId)
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_task_list)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == Intent.ACTION_CONFIGURATION_CHANGED) {
            refreshWidgets(context)
            return
        }
        if (intent.action != ACTION_TOGGLE_TASK) return

        val taskId = intent.getLongExtra(EXTRA_TASK_ID, -1L)
        if (taskId < 0) return

        val pendingResult = goAsync()
        executor.execute {
            try {
                DewwitTaskDatabase.toggleTask(context, taskId)
                refreshWidgets(context)
            } finally {
                pendingResult.finish()
            }
        }
    }

    companion object {
        const val ACTION_TOGGLE_TASK = "com.example.mobile_todo.TOGGLE_TASK"
        const val EXTRA_TASK_ID = "task_id"

        private val executor = Executors.newSingleThreadExecutor()

        fun refreshWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, DewwitWidgetProvider::class.java)
            val widgetIds = manager.getAppWidgetIds(component)
            widgetIds.forEach { appWidgetId ->
                updateWidget(context, manager, appWidgetId)
            }
            manager.notifyAppWidgetViewDataChanged(widgetIds, R.id.widget_task_list)
        }

        private fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val serviceIntent = Intent(context, DewwitWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            val toggleIntent = Intent(context, DewwitWidgetProvider::class.java).apply {
                action = ACTION_TOGGLE_TASK
            }
            val toggleFlags = PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_MUTABLE
                } else {
                    0
                }
            val openAppIntent = Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            val palette = DewwitWidgetTheme.resolve(context)

            val views = RemoteViews(context.packageName, R.layout.dewwit_widget).apply {
                setInt(R.id.widget_root, "setBackgroundResource", palette.backgroundDrawable)
                setRemoteAdapter(R.id.widget_task_list, serviceIntent)
                setEmptyView(R.id.widget_task_list, R.id.widget_empty_view)
                setTextColor(R.id.widget_empty_view, palette.secondaryText)
                setPendingIntentTemplate(
                    R.id.widget_task_list,
                    PendingIntent.getBroadcast(context, appWidgetId, toggleIntent, toggleFlags),
                )
                setInt(
                    R.id.widget_open_app,
                    "setBackgroundResource",
                    palette.actionBackgroundDrawable,
                )
                setInt(R.id.widget_open_app, "setColorFilter", palette.actionIcon)
                setOnClickPendingIntent(
                    R.id.widget_open_app,
                    PendingIntent.getActivity(
                        context,
                        appWidgetId,
                        openAppIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                    ),
                )
            }
            manager.updateAppWidget(appWidgetId, views)
        }
    }
}
