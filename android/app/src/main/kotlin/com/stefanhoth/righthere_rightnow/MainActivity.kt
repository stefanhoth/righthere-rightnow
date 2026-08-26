package com.stefanhoth.righthere_rightnow

import android.content.ContentUris
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * device_calendar_plus does not project SELF_ATTENDEE_STATUS, IS_ORGANIZER or
 * ORGANIZER, and it drops the organiser attendee row entirely (see
 * docs/adr/0001). The Instances projection map is a copy of Events', so all
 * three columns are queryable on the Instances URI; this channel supplies
 * them, keyed by (eventId, begin) for the Dart side to join on.
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
    }
}
