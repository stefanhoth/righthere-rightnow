# The calendar RSVP/organiser MethodChannel is wired up by class name via the
# Flutter engine; keep it and its callback so R8 can't rename or strip it.
-keep class com.stefanhoth.righthere_rightnow.MainActivity { *; }
