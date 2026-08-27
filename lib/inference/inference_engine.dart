/// The narrow contract every caller depends on -- see ADR-0004. No type from
/// a concrete engine package may appear on this interface, so swapping the
/// engine (Gemini Nano today, a downloaded Gemma later) is a change to one
/// implementation file, not to every call site.
abstract class InferenceEngine {
  /// Whether this engine can currently be asked to complete a prompt.
  ///
  /// Never throws -- an unsupported device, a disabled OS feature, or any
  /// other reason inference cannot run is reported as `false`, not an
  /// exception. Every call site must have a working path for that case.
  Future<bool> isAvailable();

  /// Completes [prompt], raising if the engine does not respond within
  /// [timeout]. Callers decide what "unavailable" or "too slow" means for
  /// them -- this interface only reports outcomes, it never falls back on
  /// its own.
  Future<String> complete(String prompt, {Duration timeout});
}
