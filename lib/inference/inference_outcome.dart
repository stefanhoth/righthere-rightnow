import 'package:meta/meta.dart';
import 'package:righthere_rightnow/inference/inference_engine.dart';

/// Why a piece of inference produced nothing usable.
///
/// Every one of these used to be a bare `null`, which made a device where
/// the model had never downloaded indistinguishable from one where it ran
/// and returned nonsense. Milestone 4 depends on telling them apart.
enum InferenceFailure {
  /// The engine did not respond inside its timeout.
  timedOut,

  /// The engine threw. The prompt reached it and something went wrong.
  engineThrew,

  /// The engine answered, and the answer could not be used -- unparseable,
  /// or too little of it recognised to trust (ADR-0003).
  unusableOutput,

  /// The engine answered with nothing at all.
  emptyOutput,
}

/// The result of asking the Inference Engine for something, carrying *why*
/// when the answer is nothing.
///
/// Callers that only want the happy path read [valueOrNull] and are no worse
/// off than they were with a nullable return. Callers that need to explain
/// themselves to a human switch on the variant.
@immutable
sealed class InferenceOutcome<T> {
  const InferenceOutcome();

  /// The value if inference succeeded, otherwise null.
  T? get valueOrNull => switch (this) {
    InferenceSucceeded<T>(:final value) => value,
    _ => null,
  };
}

/// Inference ran and produced a usable result.
@immutable
final class InferenceSucceeded<T> extends InferenceOutcome<T> {
  const InferenceSucceeded(this.value);

  final T value;
}

/// Inference was never attempted, because the engine was not ready.
/// [availability] is never [EngineAvailability.ready].
@immutable
final class InferenceSkipped<T> extends InferenceOutcome<T> {
  const InferenceSkipped(this.availability);

  final EngineAvailability availability;
}

/// Inference was attempted and did not produce anything usable.
@immutable
final class InferenceFailed<T> extends InferenceOutcome<T> {
  const InferenceFailed(this.failure);

  final InferenceFailure failure;
}
