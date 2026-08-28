package com.example.mobile_todo

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService

class DewwitWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory =
        TaskViewsFactory(applicationContext)
}

private class TaskViewsFactory(
    private val context: Context,
) : RemoteViewsService.RemoteViewsFactory {
    private var tasks: List<WidgetTask> = emptyList()

    override fun onCreate() = Unit

    override fun onDataSetChanged() {
        tasks = DewwitTaskDatabase.readTasks(context)
    }

    override fun onDestroy() {
        tasks = emptyList()
    }

    override fun getCount(): Int = tasks.size

    override fun getViewAt(position: Int): RemoteViews? {
        val task = tasks.getOrNull(position) ?: return null
        return RemoteViews(context.packageName, R.layout.dewwit_widget_task).apply {
            setTextViewText(R.id.widget_task_status, if (task.isCompleted) "☑" else "☐")
            setTextViewText(R.id.widget_task_title, task.title)
            setOnClickFillInIntent(
                R.id.widget_task_row,
                Intent().putExtra(DewwitWidgetProvider.EXTRA_TASK_ID, task.id),
            )
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = tasks.getOrNull(position)?.id ?: position.toLong()

    override fun hasStableIds(): Boolean = true
}
