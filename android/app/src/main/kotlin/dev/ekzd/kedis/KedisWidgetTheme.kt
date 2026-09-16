package dev.ekzd.kedis

import android.content.Context
import android.content.res.Configuration
import androidx.annotation.ColorInt
import androidx.annotation.DrawableRes

internal enum class KedisThemeMode(val storedValue: String) {
    SYSTEM("system"),
    LIGHT("light"),
    DARK("dark");

    companion object {
        fun fromStoredValue(value: String?): KedisThemeMode =
            entries.firstOrNull { it.storedValue == value } ?: SYSTEM
    }
}

internal object KedisWidgetThemePreferences {
    // Retained so an internal product rename does not create a second preference store.
    private const val PREFERENCES_NAME = "dewwit_widget_preferences"
    private const val THEME_MODE_KEY = "theme_mode"

    fun getThemeMode(context: Context): KedisThemeMode = KedisThemeMode.fromStoredValue(
        context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .getString(THEME_MODE_KEY, null),
    )

    fun setThemeMode(context: Context, value: String?) {
        val mode = KedisThemeMode.fromStoredValue(value)
        context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(THEME_MODE_KEY, mode.storedValue)
            .apply()
    }
}

internal data class KedisWidgetPalette(
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

internal object KedisWidgetTheme {
    fun resolve(context: Context): KedisWidgetPalette {
        val useDarkPalette = when (KedisWidgetThemePreferences.getThemeMode(context)) {
            KedisThemeMode.LIGHT -> false
            KedisThemeMode.DARK -> true
            KedisThemeMode.SYSTEM -> {
                val nightMode = context.resources.configuration.uiMode and
                    Configuration.UI_MODE_NIGHT_MASK
                nightMode == Configuration.UI_MODE_NIGHT_YES
            }
        }

        return if (useDarkPalette) dark(context) else light(context)
    }

    private fun light(context: Context) = KedisWidgetPalette(
        backgroundDrawable = R.drawable.kedis_widget_background_light,
        taskBackgroundDrawable = R.drawable.kedis_widget_task_background_light,
        actionBackgroundDrawable = R.drawable.kedis_widget_action_background_light,
        taskText = context.getColor(R.color.kedis_widget_light_on_surface),
        secondaryText = context.getColor(R.color.kedis_widget_light_on_surface_variant),
        completedText = context.getColor(R.color.kedis_widget_light_completed),
        checkbox = context.getColor(R.color.kedis_widget_light_on_surface_variant),
        completedCheckbox = context.getColor(R.color.kedis_widget_light_primary),
        actionIcon = context.getColor(R.color.kedis_widget_light_on_primary_container),
    )

    private fun dark(context: Context) = KedisWidgetPalette(
        backgroundDrawable = R.drawable.kedis_widget_background_dark,
        taskBackgroundDrawable = R.drawable.kedis_widget_task_background_dark,
        actionBackgroundDrawable = R.drawable.kedis_widget_action_background_dark,
        taskText = context.getColor(R.color.kedis_widget_dark_on_surface),
        secondaryText = context.getColor(R.color.kedis_widget_dark_on_surface_variant),
        completedText = context.getColor(R.color.kedis_widget_dark_completed),
        checkbox = context.getColor(R.color.kedis_widget_dark_on_surface_variant),
        completedCheckbox = context.getColor(R.color.kedis_widget_dark_primary),
        actionIcon = context.getColor(R.color.kedis_widget_dark_on_primary_container),
    )
}
