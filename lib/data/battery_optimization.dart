import 'package:permission_handler/permission_handler.dart';

/// Whether this app is currently exempt from Doze and App Standby. Backed by
/// `PowerManager.isIgnoringBatteryOptimizations()` on Android.
Future<PermissionStatus> batteryOptimizationStatus() {
  return Permission.ignoreBatteryOptimizations.status;
}

/// Shows the system's "ignore battery optimizations" dialog. A no-op if
/// already granted, or if the user has permanently denied it before.
Future<void> requestBatteryOptimizationExemption() async {
  await Permission.ignoreBatteryOptimizations.request();
}
