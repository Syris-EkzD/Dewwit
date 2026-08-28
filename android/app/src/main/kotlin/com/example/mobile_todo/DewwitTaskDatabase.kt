package com.example.mobile_todo

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

data class WidgetTask(
    val id: Long,
    val title: String,
    val isCompleted: Boolean,
)

object DewwitTaskDatabase {
    fun readTasks(context: Context): List<WidgetTask> =
        Helper(context).use { helper ->
            helper.readableDatabase.query(
                TASKS_TABLE,
                arrayOf("id", "title", "is_completed"),
                null,
                null,
                null,
                null,
                "created_at ASC, id ASC",
            ).use { cursor ->
                buildList {
                    val idIndex = cursor.getColumnIndexOrThrow("id")
                    val titleIndex = cursor.getColumnIndexOrThrow("title")
                    val completedIndex = cursor.getColumnIndexOrThrow("is_completed")
                    while (cursor.moveToNext()) {
                        add(
                            WidgetTask(
                                id = cursor.getLong(idIndex),
                                title = cursor.getString(titleIndex),
                                isCompleted = cursor.getInt(completedIndex) == 1,
                            ),
                        )
                    }
                }
            }
        }

    fun toggleTask(context: Context, taskId: Long) {
        Helper(context).use { helper ->
            helper.writableDatabase.execSQL(
                """
                UPDATE $TASKS_TABLE
                SET is_completed = CASE is_completed WHEN 0 THEN 1 ELSE 0 END
                WHERE id = ?
                """.trimIndent(),
                arrayOf(taskId),
            )
        }
    }

    private class Helper(context: Context) :
        SQLiteOpenHelper(context.applicationContext, DATABASE_NAME, null, DATABASE_VERSION) {
        override fun onCreate(database: SQLiteDatabase) {
            database.execSQL(
                """
                CREATE TABLE $TASKS_TABLE (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL CHECK(length(trim(title)) > 0),
                    is_completed INTEGER NOT NULL DEFAULT 0
                        CHECK(is_completed IN (0, 1)),
                    created_at INTEGER NOT NULL
                )
                """.trimIndent(),
            )
        }

        override fun onUpgrade(database: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit
    }

    private const val DATABASE_NAME = "dewwit.db"
    private const val DATABASE_VERSION = 1
    private const val TASKS_TABLE = "tasks"
}
