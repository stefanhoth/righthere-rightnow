package com.stefanhoth.righthere_rightnow

import android.content.Context

/**
 * The Dart-registered callback handle for `scheduling/briefing_alarm.dart`'s
 * `rearmDispatcher`, shared between MainActivity (writer, whenever the app
 * runs in the foreground) and RearmBroadcastReceiver (reader, which may run
 * with no Flutter engine already alive).
 */
object AlarmRearmPrefs {
    private const val PREFS_NAME = "righthere_rightnow.alarm_rearm"
    private const val KEY_CALLBACK_HANDLE = "rearm_callback_handle"

    fun storeCallbackHandle(context: Context, handle: Long) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putLong(KEY_CALLBACK_HANDLE, handle)
            .apply()
    }

    fun readCallbackHandle(context: Context): Long? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        if (!prefs.contains(KEY_CALLBACK_HANDLE)) {
            return null
        }
        return prefs.getLong(KEY_CALLBACK_HANDLE, 0L)
    }
}
