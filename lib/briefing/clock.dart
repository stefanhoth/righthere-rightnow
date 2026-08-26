/// Injectable source of "now", so briefing logic never calls
/// `DateTime.now()` inline and stays deterministically testable.
///
/// Pass `DateTime.now` for real use, or `() => fixedInstant` in tests.
typedef Clock = DateTime Function();
