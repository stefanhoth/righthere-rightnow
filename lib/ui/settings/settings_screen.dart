import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:righthere_rightnow/data/battery_optimization.dart'
    as battery_optimization;
import 'package:righthere_rightnow/scheduling/run_time.dart';
import 'package:righthere_rightnow/ui/dev/prompt_screen.dart';
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
    final batteryOptimizationStatus = ref.watch(
      batteryOptimizationStatusProvider,
    );

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
            data: (status) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _describeCalendarPermission(status),
                  key: const Key('calendarPermissionStatus'),
                ),
                if (status == CalendarPermissionStatus.granted) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Include these calendars in your Daily Agenda:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const _CalendarChecklist(),
                ],
              ],
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
          const SizedBox(height: 24),
          Text(
            'Battery optimisation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          batteryOptimizationStatus.when(
            data: (status) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _describeBatteryOptimizationStatus(status),
                  key: const Key('batteryOptimizationStatus'),
                ),
                if (status != PermissionStatus.granted) ...[
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const Key('requestBatteryExemptionButton'),
                    onPressed: () async {
                      await battery_optimization
                          .requestBatteryOptimizationExemption();
                      ref.invalidate(batteryOptimizationStatusProvider);
                    },
                    child: const Text('Exempt from battery optimisation'),
                  ),
                ],
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) =>
                const Text('Could not read battery optimisation status.'),
          ),
          const SizedBox(height: 24),
          Text('Developer', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('editPromptButton'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PromptScreen()),
            ),
            child: const Text('Edit ranking prompt'),
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

  String _describeBatteryOptimizationStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted =>
        'Exempt from battery optimisation -- the morning briefing can run '
            'in the background.',
      _ =>
        'Not exempt. The morning briefing may be delayed or skipped by '
            'the device.',
    };
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

/// One checkbox per calendar. A box is ticked when the calendar is in the
/// stored selection, or when the selection is empty -- an empty selection
/// means every calendar.
class _CalendarChecklist extends ConsumerWidget {
  const _CalendarChecklist();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendars = ref.watch(availableCalendarsProvider);
    final selected =
        ref.watch(selectedCalendarIdsProvider).value ?? const <String>{};

    return calendars.when(
      data: (list) {
        final allIds = {for (final calendar in list) calendar.id};
        return Column(
          children: [
            for (final calendar in list)
              CheckboxListTile(
                key: Key('calendarCheckbox:${calendar.id}'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(calendar.name),
                subtitle: calendar.accountName == null
                    ? null
                    : Text(calendar.accountName!),
                value: selected.isEmpty || selected.contains(calendar.id),
                onChanged: (value) => ref
                    .read(selectedCalendarsControllerProvider.notifier)
                    .setSelected(
                      calendar.id,
                      selected: value ?? false,
                      allCalendarIds: allIds,
                    ),
              ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => const Text('Could not list your calendars.'),
    );
  }
}
