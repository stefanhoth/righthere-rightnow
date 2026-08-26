package com.stefanhoth.righthere_rightnow

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation

/**
 * Recomputes and re-arms the Briefing Run alarm on boot, app update, or a
 * system clock/timezone change -- any of which can leave the previously
 * scheduled alarm stale or gone.
 *
 * Runs the Dart side (`scheduling/briefing_alarm.dart`'s `rearmDispatcher`)
 * in a headless Flutter engine, since no engine is already running when a
 * plain BroadcastReceiver fires. Holds the broadcast open (`goAsync`) until
 * Dart confirms it re-armed, or a safety timeout elapses -- the OS can kill
 * the process the moment `onReceive` returns otherwise, before the async
 * engine startup finishes.
 */
class RearmBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val handle = AlarmRearmPrefs.readCallbackHandle(context) ?: return
        val callbackInfo =
            FlutterCallbackInformation.lookupCallbackInformation(handle) ?: return

        val appContext = context.applicationContext
        val pendingResult = goAsync()
        val mainHandler = Handler(Looper.getMainLooper())
        var finished = false

        fun finishOnce() {
            if (!finished) {
                finished = true
                pendingResult.finish()
            }
        }

        mainHandler.post {
            val loader = FlutterLoader()
            loader.startInitialization(appContext)
            loader.ensureInitializationComplete(appContext, null)

            val engine = FlutterEngine(appContext)
            val dartCallback = DartCallback(
                appContext.assets,
                loader.findAppBundlePath(),
                callbackInfo,
            )

            MethodChannel(engine.dartExecutor.binaryMessenger, COMPLETION_CHANNEL_NAME)
                .setMethodCallHandler { call, result ->
                    if (call.method == "rearmComplete") {
                        result.success(null)
                        finishOnce()
                        engine.destroy()
                    } else {
                        result.notImplemented()
                    }
                }

            engine.dartExecutor.executeDartCallback(dartCallback)
        }

        // Safety net: never leave the broadcast pending indefinitely if the
        // Dart side doesn't call back for any reason.
        mainHandler.postDelayed({ finishOnce() }, 10_000)
    }

    companion object {
        const val COMPLETION_CHANNEL_NAME =
            "com.stefanhoth.righthere_rightnow/alarm_rearm_complete"
    }
}
