package com.example.mobile_todo

import android.content.Context
import android.content.res.Configuration
import androidx.annotation.ColorInt
import androidx.annotation.DrawableRes

internal enum class DewwitThemeMode(val storedValue: String) {
    SYSTEM("system"),
    LIGHT("light"),
    DARK("dark");

    companion object {
        fun fromStoredValue(value: String?): DewwitThemeMode =
            entries.firstOrNull { it.storedValue == value } ?: SYSTEM
    }
}

internal object DewwitWidgetThemePreferences {
    private const val PREFERENCES_NAME = "dewwit_widget_preferences"
    private const val THEME_MODE_KEY = "theme_mode"

    fun getThemeMode(context: Context): DewwitThemeMode = DewwitThemeMode.fromStoredValue(
        context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .getString(THEME_MODE_KEY, null),
    )

    fun setThemeMode(context: Context, value: String?) {
        val mode = DewwitThemeMode.fromStoredValue(value)
        context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(THEME_MODE_KEY, mode.storedValue)
            .apply()
    }
}

internal data class DewwitWidgetPalette(
    @DrawableRes val backgroundDrawable: Int,
    @DrawableRes val taskBackgroundDrawable: Int,
    @DrawableRes val actionBackgroundDrawable: Int,
    @ColorInt val taskText: Int,
    @ColorInt val secondaryText: Int,
    @ColorInt val completedText: Int,
    @ColorInt val checkbox: Int,
    @ColorInt val completedCheckbox: Int,
    @ColorInt val actionIcon: Int,
)

internal object DewwitWidgetTheme {
    fun resolve(context: Context): DewwitWidgetPalette {
        val useDarkPalette = when (DewwitWidgetThemePreferences.getThemeMode(context)) {
            DewwitThemeMode.LIGHT -> false
            DewwitThemeMode.DARK -> true
            DewwitThemeMode.SYSTEM -> {
                val nightMode = context.resources.configuration.uiMode and
                    Configuration.UI_MODE_NIGHT_MASK
                nightMode == Configuration.UI_MODE_NIGHT_YES
            }
        }

        return if (useDarkPalette) dark(context) else light(context)
    }

    private fun light(context: Context) = DewwitWidgetPalette(
        backgroundDrawable = R.drawable.dewwit_widget_background_light,
        taskBackgroundDrawable = R.drawable.dewwit_widget_task_background_light,
        actionBackgroundDrawable = R.drawable.dewwit_widget_action_background_light,
        taskText = context.getColor(R.color.dewwit_widget_light_on_surface),
        secondaryText = context.getColor(R.color.dewwit_widget_light_on_surface_variant),
        completedText = context.getColor(R.color.dewwit_widget_light_completed),
        checkbox = context.getColor(R.color.dewwit_widget_light_on_surface_variant),
        completedCheckbox = context.getColor(R.color.dewwit_widget_light_primary),
        actionIcon = context.getColor(R.color.dewwit_widget_light_on_primary_container),
    )

    private fun dark(context: Context) = DewwitWidgetPalette(
        backgroundDrawable = R.drawable.dewwit_widget_background_dark,
        taskBackgroundDrawable = R.drawable.dewwit_widget_task_background_dark,
        actionBackgroundDrawable = R.drawable.dewwit_widget_action_background_dark,
        taskText = context.getColor(R.color.dewwit_widget_dark_on_surface),
        secondaryText = context.getColor(R.color.dewwit_widget_dark_on_surface_variant),
        completedText = context.getColor(R.color.dewwit_widget_dark_completed),
        checkbox = context.getColor(R.color.dewwit_widget_dark_on_surface_variant),
        completedCheckbox = context.getColor(R.color.dewwit_widget_dark_primary),
        actionIcon = context.getColor(R.color.dewwit_widget_dark_on_primary_container),
    )
}
