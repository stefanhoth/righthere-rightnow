import 'package:meta/meta.dart';

/// The time of day the Briefing Run fires, deliberately simple: a fixed
/// clock time rather than reading the device's own wake alarm. See
/// docs/DECISIONS.md.
@immutable
class RunTime {
  const RunTime({required this.hour, required this.minute});

  static const defaultValue = RunTime(hour: 5, minute: 30);

  final int hour;
  final int minute;

  @override
  bool operator ==(Object other) =>
      other is RunTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}
