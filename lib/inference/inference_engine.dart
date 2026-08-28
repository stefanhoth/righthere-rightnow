/// Whether an [InferenceEngine] can be asked to complete a prompt, and if
/// not, whether that is permanent.
///
/// The distinction is load-bearing: "the model has not downloaded yet" and
/// "this device will never run it" look identical to a caller that only
/// knows a bool, and they call for completely different responses.
enum EngineAvailability {
  /// Ready to complete a prompt now.
  ready,

  /// Supported here, but not usable yet -- the model is not on the device,
  /// or is still downloading. May become [ready] later with nothing changed
  /// but time.
  notReady,

  /// This device or OS will never run this engine. Waiting does not help.
  unsupported,
}

/// The narrow contract every caller depends on -- see ADR-0004. No type from
/// a concrete engine package may appear on this interface, so swapping the
/// engine (Gemini Nano today, a downloaded Gemma later) is a change to one
/// implementation file, not to every call site.
abstract class InferenceEngine {
  /// Whether this engine can currently be asked to complete a prompt.
  ///
  /// Never throws -- an unsupported device, a disabled OS feature, or any
  /// other reason inference cannot run is reported as a value, not an
  /// exception. Every call site must have a working path for every value
  /// other than [EngineAvailability.ready].
  Future<EngineAvailability> availability();

  /// Completes [prompt], raising if the engine does not respond within
  /// [timeout]. Callers decide what "unavailable" or "too slow" means for
  /// them -- this interface only reports outcomes, it never falls back on
  /// its own.
  Future<String> complete(String prompt, {Duration timeout});
}
