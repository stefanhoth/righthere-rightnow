package com.stefanhoth.righthere_rightnow

import android.content.ActivityNotFoundException
import android.content.ContentUris
import android.content.Intent
import android.provider.CalendarContract
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the app's platform channels, all of them things the calendar plugin
 * cannot do:
 *
 *  - `calendar_rsvp`: device_calendar_plus does not project
 *    SELF_ATTENDEE_STATUS, IS_ORGANIZER or ORGANIZER, and it drops the
 *    organiser attendee row entirely (see docs/adr/0001). The Instances
 *    projection map is a copy of Events', so all three columns are queryable
 *    on the Instances URI; this channel supplies them, keyed by
 *    (eventId, begin) for the Dart side to join on.
 *  - `alarm_rearm`: stores the Dart callback handle the boot receiver needs.
 *  - `calendar_view`: opens one Event occurrence in the calendar app.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                if (call.method != METHOD_QUERY_RSVP_AND_ORGANISER) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                handleQueryRsvpAndOrganiser(call, result)
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_REARM_CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                if (call.method != "storeRearmCallbackHandle") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val handle = (call.arguments as? Number)?.toLong()
                if (handle == null) {
                    result.error("invalid_arguments", "a callback handle is required", null)
                    return@setMethodCallHandler
                }
                AlarmRearmPrefs.storeCallbackHandle(applicationContext, handle)
                result.success(null)
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CALENDAR_VIEW_CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                if (call.method != METHOD_VIEW_EVENT) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                handleViewEvent(call, result)
            }
    }

    /**
     * Hands one Event occurrence to the device's calendar app.
     *
     * The begin time is what selects the occurrence: on a `content://` URI
     * alone the calendar shows the series, so a recurring Commitment tapped
     * today would open its first instance instead.
     */
    private fun handleViewEvent(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val eventId = call.argument<String>("eventId")?.toLongOrNull()
        val beginMillis = call.argument<Long>("beginMillis")
        if (eventId == null || beginMillis == null) {
            result.error(
                "invalid_arguments",
                "a numeric eventId and beginMillis are required",
                null,
            )
            return
        }

        val intent = Intent(Intent.ACTION_VIEW)
            .setData(ContentUris.withAppendedId(CalendarContract.Events.CONTENT_URI, eventId))
            .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, beginMillis)

        try {
            startActivity(intent)
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            // No calendar app installed, or none that will show this Event.
            // The Dart side tells the user; it is not a channel failure.
            Log.i(TAG, "no activity to view calendar event $eventId", e)
            result.success(false)
        }
    }

    private fun handleQueryRsvpAndOrganiser(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        val startMillis = call.argument<Long>("startMillis")
        val endMillis = call.argument<Long>("endMillis")
        if (startMillis == null || endMillis == null) {
            result.error(
                "invalid_arguments",
                "startMillis and endMillis are required",
                null,
            )
            return
        }

        val uriBuilder = CalendarContract.Instances.CONTENT_URI.buildUpon()
        ContentUris.appendId(uriBuilder, startMillis)
        ContentUris.appendId(uriBuilder, endMillis)

        val projection = arrayOf(
            CalendarContract.Instances.EVENT_ID,
            CalendarContract.Instances.BEGIN,
            CalendarContract.Events.SELF_ATTENDEE_STATUS,
            CalendarContract.Events.IS_ORGANIZER,
        )

        val rows = mutableListOf<Map<String, Any?>>()
        contentResolver.query(uriBuilder.build(), projection, null, null, null)?.use { cursor ->
            val eventIdIndex = cursor.getColumnIndex(CalendarContract.Instances.EVENT_ID)
            val beginIndex = cursor.getColumnIndex(CalendarContract.Instances.BEGIN)
            val selfAttendeeStatusIndex =
                cursor.getColumnIndex(CalendarContract.Events.SELF_ATTENDEE_STATUS)
            val isOrganizerIndex = cursor.getColumnIndex(CalendarContract.Events.IS_ORGANIZER)

            while (cursor.moveToNext()) {
                rows.add(
                    mapOf(
                        "eventId" to cursor.getString(eventIdIndex),
                        "begin" to cursor.getLong(beginIndex),
                        "selfAttendeeStatus" to cursor.getInt(selfAttendeeStatusIndex),
                        "isOrganizer" to (cursor.getString(isOrganizerIndex) == "1"),
                    ),
                )
            }
        }

        result.success(rows)
    }

    companion object {
        private const val CHANNEL_NAME = "com.stefanhoth.righthere_rightnow/calendar_rsvp"
        private const val METHOD_QUERY_RSVP_AND_ORGANISER = "queryRsvpAndOrganiser"
        private const val ALARM_REARM_CHANNEL_NAME =
            "com.stefanhoth.righthere_rightnow/alarm_rearm"
        private const val CALENDAR_VIEW_CHANNEL_NAME =
            "com.stefanhoth.righthere_rightnow/calendar_view"
        private const val METHOD_VIEW_EVENT = "viewEvent"
        private const val TAG = "RightHereRightNow"
    }
}
