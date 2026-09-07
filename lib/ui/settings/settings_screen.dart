import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:righthere_rightnow/data/battery_optimization.dart'
    as battery_optimization;
import 'package:righthere_rightnow/inference/gemma_lite_rt_engine.dart';
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
  final _wmBaseUrlController = TextEditingController();
  final _wmPathController = TextEditingController();
  final _wmUsernameController = TextEditingController();
  final _wmPasswordController = TextEditingController();

  /// True once the user asks to replace a token that is already saved. A
  /// fresh setup (no token yet) shows the editor without this.
  bool _editingToken = false;

  /// The same, for the What Matters connection.
  bool _editingWhatMatters = false;

  void _clearWhatMattersFields() {
    _wmBaseUrlController.clear();
    _wmPathController.clear();
    _wmUsernameController.clear();
    _wmPasswordController.clear();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _wmBaseUrlController.dispose();
    _wmPathController.dispose();
    _wmUsernameController.dispose();
    _wmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryStatus = ref.watch(tokenEntryControllerProvider);
    final storedToken = ref.watch(storedTodoistTokenProvider);
    final wmEntryStatus = ref.watch(whatMattersEntryControllerProvider);
    final wmConnection = ref.watch(storedWhatMattersConnectionProvider);
    final wmCached = ref.watch(cachedWhatMattersProvider);
    final modelStatus = ref.watch(gemmaModelStatusProvider);
    final calendarPermission = ref.watch(calendarPermissionStatusProvider);
    final storedRunTime = ref.watch(storedRunTimeProvider);
    final nextScheduledRun = ref.watch(nextScheduledRunProvider);
    final batteryOptimizationStatus = ref.watch(
      batteryOptimizationStatusProvider,
    );

    // A successful save collapses the editor back to the one-line summary.
    // The confirmation moves to a SnackBar so it survives the collapse.
    ref.listen(tokenEntryControllerProvider, (_, next) {
      if (next != TokenEntryStatus.saved) {
        return;
      }
      if (_editingToken) {
        setState(() => _editingToken = false);
      }
      _tokenController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved.')));
    });

    ref.listen(whatMattersEntryControllerProvider, (_, next) {
      if (next != WhatMattersEntryStatus.saved) {
        return;
      }
      if (_editingWhatMatters) {
        setState(() => _editingWhatMatters = false);
      }
      _clearWhatMattersFields();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved.')));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Todoist', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          storedToken.when(
            data: (token) => token != null && !_editingToken
                ? Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'A token is saved.',
                          key: Key('storedTokenStatus'),
                        ),
                      ),
                      TextButton(
                        key: const Key('editTokenButton'),
                        onPressed: () => setState(() => _editingToken = true),
                        child: const Text('Replace'),
                      ),
                    ],
                  )
                : _TokenEditor(
                    controller: _tokenController,
                    entryStatus: entryStatus,
                    showCancel: token != null,
                    onVerifyAndSave: () => ref
                        .read(tokenEntryControllerProvider.notifier)
                        .verifyAndSave(_tokenController.text),
                    onCancel: () => setState(() {
                      _editingToken = false;
                      _tokenController.clear();
                    }),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('Could not read the saved token.'),
          ),
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
          Text('What Matters', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          wmConnection.when(
            data: (connection) => connection != null && !_editingWhatMatters
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reading ${connection.path}',
                          key: const Key('whatMattersConnectionStatus'),
                        ),
                      ),
                      TextButton(
                        key: const Key('editWhatMattersButton'),
                        onPressed: () =>
                            setState(() => _editingWhatMatters = true),
                        child: const Text('Replace'),
                      ),
                    ],
                  )
                : _WhatMattersEditor(
                    baseUrlController: _wmBaseUrlController,
                    pathController: _wmPathController,
                    usernameController: _wmUsernameController,
                    passwordController: _wmPasswordController,
                    entryStatus: wmEntryStatus,
                    showCancel: connection != null,
                    onVerifyAndSave: () => ref
                        .read(whatMattersEntryControllerProvider.notifier)
                        .verifyAndSave(
                          baseUrl: _wmBaseUrlController.text,
                          path: _wmPathController.text,
                          username: _wmUsernameController.text,
                          appPassword: _wmPasswordController.text,
                        ),
                    onCancel: () => setState(() {
                      _editingWhatMatters = false;
                      _clearWhatMattersFields();
                    }),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('Could not read the saved connection.'),
          ),
          wmCached.when(
            data: (document) => document == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Last fetched ${_ageLabel(document.fetchedAt)}.',
                      key: const Key('whatMattersCacheAge'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          Text('Model', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          modelStatus.when(
            data: (status) => _ModelStatusView(
              status: status,
              onRecheck: () => ref.invalidate(gemmaModelStatusProvider),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const Text('Could not check for the model file.'),
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

  /// A rough "how old is the cached copy" phrase. Precision past the hour
  /// does not matter here -- the question is "is this stale", not "when
  /// exactly".
  String _ageLabel(DateTime fetchedAt) {
    final age = DateTime.now().difference(fetchedAt);
    if (age.inMinutes < 1) {
      return 'just now';
    }
    if (age.inHours < 1) {
      return '${age.inMinutes} min ago';
    }
    if (age.inDays < 1) {
      return '${age.inHours} h ago';
    }
    return '${age.inDays} d ago';
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

/// The on-demand token editor: an obscured field plus a verify-and-save
/// button. A fresh setup shows it inline with a "no token" line; replacing an
/// existing token shows it with a Cancel button to collapse again.
class _TokenEditor extends StatelessWidget {
  const _TokenEditor({
    required this.controller,
    required this.entryStatus,
    required this.showCancel,
    required this.onVerifyAndSave,
    required this.onCancel,
  });

  final TextEditingController controller;
  final TokenEntryStatus entryStatus;
  final bool showCancel;
  final VoidCallback onVerifyAndSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final verifying = entryStatus == TokenEntryStatus.verifying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!showCancel) ...[
          const Text('No token saved yet.', key: Key('storedTokenStatus')),
          const SizedBox(height: 8),
        ],
        TextField(
          key: const Key('tokenField'),
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Personal API token',
            helperText: 'Todoist -> Settings -> Integrations -> Developer',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton(
              key: const Key('verifyAndSaveButton'),
              onPressed: verifying ? null : onVerifyAndSave,
              child: verifying
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify and save'),
            ),
            if (showCancel) ...[
              const SizedBox(width: 8),
              TextButton(
                key: const Key('cancelTokenEditButton'),
                onPressed: verifying ? null : onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ],
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
          TokenEntryStatus.idle ||
          TokenEntryStatus.verifying ||
          TokenEntryStatus.saved => const SizedBox.shrink(),
        },
      ],
    );
  }
}

/// The on-demand What Matters editor: server URL, path, username and app
/// password, plus a verify-and-save button. Same shape as [_TokenEditor] --
/// a fresh setup shows it with the explanatory line; replacing an existing
/// connection shows it with a Cancel button. A successful save is confirmed
/// by a SnackBar from the screen, not an inline message, so it survives the
/// editor collapsing.
class _WhatMattersEditor extends StatelessWidget {
  const _WhatMattersEditor({
    required this.baseUrlController,
    required this.pathController,
    required this.usernameController,
    required this.passwordController,
    required this.entryStatus,
    required this.showCancel,
    required this.onVerifyAndSave,
    required this.onCancel,
  });

  final TextEditingController baseUrlController;
  final TextEditingController pathController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final WhatMattersEntryStatus entryStatus;
  final bool showCancel;
  final VoidCallback onVerifyAndSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final verifying = entryStatus == WhatMattersEntryStatus.verifying;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!showCancel) ...[
          Text(
            'A markdown file in your Nextcloud describing what you are '
            'working toward. Read over WebDAV with a Nextcloud app password.',
            key: const Key('whatMattersConnectionStatus'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          key: const Key('whatMattersBaseUrlField'),
          controller: baseUrlController,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'WebDAV base URL',
            helperText:
                'https://cloud.example.com/remote.php/dav/files/username',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('whatMattersPathField'),
          controller: pathController,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'File path',
            helperText: '/Notes/What Matters.md',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('whatMattersUsernameField'),
          controller: usernameController,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'Nextcloud username'),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('whatMattersPasswordField'),
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'App password',
            helperText:
                'Nextcloud -> Settings -> Security -> Create app password',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton(
              key: const Key('whatMattersVerifyButton'),
              onPressed: verifying ? null : onVerifyAndSave,
              child: verifying
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify and save'),
            ),
            if (showCancel) ...[
              const SizedBox(width: 8),
              TextButton(
                key: const Key('cancelWhatMattersEditButton'),
                onPressed: verifying ? null : onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
        switch (entryStatus) {
          WhatMattersEntryStatus.invalid => const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Nextcloud rejected that username or app password.',
              key: Key('whatMattersStatusMessage'),
            ),
          ),
          WhatMattersEntryStatus.error => const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Could not read the file. Check the URL and path.',
              key: Key('whatMattersStatusMessage'),
            ),
          ),
          WhatMattersEntryStatus.idle ||
          WhatMattersEntryStatus.verifying ||
          WhatMattersEntryStatus.saved => const SizedBox.shrink(),
        },
      ],
    );
  }
}

/// One checkbox per calendar. A box is ticked when the calendar is in the
/// stored selection, or when the selection is empty -- an empty selection
/// means every calendar.
/// Whether the hand-delivered Gemma `.litertlm` file is in place, and the
/// `adb push` target if not. There is no in-app download yet -- see
/// DECISIONS.md (2026-08-31).
class _ModelStatusView extends StatelessWidget {
  const _ModelStatusView({required this.status, required this.onRecheck});

  final GemmaModelStatus status;
  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    if (status.expectedPath == null) {
      return const Text(
        'This platform cannot run a local model.',
        key: Key('modelStatus'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status.isPresent
              ? 'Gemma 4 model in place (${_gib(status.sizeBytes!)}).'
              : 'No model file. Ranking and framing fall back to rules until '
                    'one is pushed here:',
          key: const Key('modelStatus'),
        ),
        if (!status.isPresent) ...[
          const SizedBox(height: 4),
          SelectableText(
            status.expectedPath!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 4),
        TextButton(
          key: const Key('recheckModelButton'),
          onPressed: onRecheck,
          child: const Text('Recheck'),
        ),
      ],
    );
  }

  static String _gib(int bytes) =>
      '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

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
