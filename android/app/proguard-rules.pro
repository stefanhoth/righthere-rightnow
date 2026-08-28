# The calendar RSVP/organiser MethodChannel is wired up by class name via the
# Flutter engine; keep it and its callback so R8 can't rename or strip it.
-keep class com.stefanhoth.righthere_rightnow.MainActivity { *; }

# ML Kit finds its component registrars by reflection, from a ContentProvider
# in its manifest, so R8 sees no caller for their no-arg constructors and
# deletes them. R8's own usage.txt listed
# `com.google.mlkit.common.internal.CommonComponentRegistrar: public void
# <init>()` as removed, and the app logged
# `NoSuchMethodException: CommonComponentRegistrar.<init> []` at startup.
#
# ML Kit then never initialises, GenAI's checkStatus() throws with a null
# message, and flutter_gemma_builtin_ai maps that to UNAVAILABLE_OTHER. The
# Inference Engine therefore reports itself unavailable and the Daily Agenda
# is ranked by the fallback -- silently, and only in release builds.
-keep class * implements com.google.firebase.components.ComponentRegistrar {
    <init>();
}
