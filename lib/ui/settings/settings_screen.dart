import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:righthere_rightnow/scheduling/run_time.dart';
import 'package:righthere_rightnow/ui/settings/run_time_controller.dart';
import 'package:righthere_rightnow/ui/settings/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryStatus = ref.watch(tokenEntryControllerProvider);
    final storedToken = ref.watch(storedTodoistTokenProvider);
    final calendarPermission = ref.watch(calendarPermissionStatusProvider);
    final storedRunTime = ref.watch(storedRunTimeProvider);
    final nextScheduledRun = ref.watch(nextScheduledRunProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Todoist', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          storedToken.when(
            data: (token) => Text(
              token == null ? 'No token saved yet.' : 'A token is saved.',
              key: const Key('storedTokenStatus'),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('Could not read the saved token.'),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('tokenField'),
            controller: _tokenController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Personal API token',
              helperText: 'Todoist -> Settings -> Integrations -> Developer',
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('verifyAndSaveButton'),
            onPressed: entryStatus == TokenEntryStatus.verifying
                ? null
                : () => ref
                      .read(tokenEntryControllerProvider.notifier)
                      .verifyAndSave(_tokenController.text),
            child: entryStatus == TokenEntryStatus.verifying
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify and save'),
          ),
          switch (entryStatus) {
            TokenEntryStatus.invalid => const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'That token was rejected by Todoist.',
                key: Key('tokenStatusMessage'),
              ),
            ),
            TokenEntryStatus.error => const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Could not reach Todoist. Try again.',
                key: Key('tokenStatusMessage'),
              ),
            ),
            TokenEntryStatus.saved => const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Saved.', key: Key('tokenStatusMessage')),
            ),
            TokenEntryStatus.idle ||
            TokenEntryStatus.verifying => const SizedBox.shrink(),
          },
          const SizedBox(height: 24),
          Text('Calendar', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          calendarPermission.when(
            data: (status) => Text(
              _describeCalendarPermission(status),
              key: const Key('calendarPermissionStatus'),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('Could not read calendar permission.'),
          ),
          const SizedBox(height: 24),
          Text('Briefing time', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          storedRunTime.when(
            data: (runTime) => Row(
              children: [
                Expanded(
                  child: Text(
                    _describeTimeOfDay(runTime.hour, runTime.minute),
                    key: const Key('storedRunTime'),
                  ),
                ),
                TextButton(
                  onPressed: () => _pickRunTime(context, runTime),
                  child: const Text('Change'),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('Could not read the briefing time.'),
          ),
          nextScheduledRun.when(
            data: (next) => Text(
              'Next run: ${DateFormat.yMMMd().add_jm().format(next)}',
              key: const Key('nextScheduledRun'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickRunTime(BuildContext context, RunTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null || !context.mounted) {
      return;
    }
    await ref
        .read(runTimeControllerProvider.notifier)
        .updateRunTime(RunTime(hour: picked.hour, minute: picked.minute));
  }

  String _describeTimeOfDay(int hour, int minute) {
    final formatted = TimeOfDay(hour: hour, minute: minute).format(context);
    return 'Runs daily at $formatted';
  }

  String _describeCalendarPermission(CalendarPermissionStatus status) {
    return switch (status) {
      CalendarPermissionStatus.granted => 'Calendar access granted.',
      CalendarPermissionStatus.writeOnly => 'Write-only calendar access.',
      CalendarPermissionStatus.denied => 'Calendar access denied.',
      CalendarPermissionStatus.restricted =>
        'Calendar access restricted by device policy.',
      CalendarPermissionStatus.notDetermined =>
        'Calendar access not yet requested.',
    };
  }
}
