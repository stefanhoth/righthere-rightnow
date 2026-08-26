import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/ranking_explanation.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/ui/agenda/agenda_controller.dart';
import 'package:righthere_rightnow/ui/settings/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyAgendaScreen extends ConsumerWidget {
  const DailyAgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaState = ref.watch(dailyAgendaControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(dailyAgendaControllerProvider.notifier).refresh(),
        child: switch (agendaState) {
          AsyncData(:final value) => _AgendaBody(result: value),
          AsyncError(:final error) => _ErrorView(message: '$error'),
          _ => const _LoadingView(),
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 400,
          child: Center(
            key: Key('agendaLoading'),
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 400,
          child: Center(
            child: Text(
              'Could not load the Daily Agenda.\n$message',
              key: const Key('agendaError'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _AgendaBody extends ConsumerWidget {
  const _AgendaBody({required this.result});

  final BriefingRunResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (result.calendarPermissionDenied) {
      return _PermissionDeniedView(
        onGrantPermission: () async {
          await DeviceCalendar().requestPermissions();
          await ref.read(dailyAgendaControllerProvider.notifier).refresh();
        },
      );
    }

    final rankedItems = result.agenda.items;
    final isEmpty = rankedItems.isEmpty && result.allDayCommitments.isEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _LastRunBanner(result: result),
        if (result.isPartial) _PartialDataBanner(message: result.error!),
        if (result.allDayCommitments.isNotEmpty)
          _AllDayHeader(commitments: result.allDayCommitments),
        if (isEmpty)
          const Padding(
            key: Key('agendaEmpty'),
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Nothing on your plate today.')),
          )
        else
          for (final item in rankedItems) _AgendaTile(item: item),
      ],
    );
  }
}

class _LastRunBanner extends StatelessWidget {
  const _LastRunBanner({required this.result});

  final BriefingRunResult result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        'Last updated ${DateFormat.jm().format(result.completedAt)}',
        key: const Key('lastRunTime'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _PartialDataBanner extends StatelessWidget {
  const _PartialDataBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('partialDataBanner'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Some data could not be loaded: $message',
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onGrantPermission});

  final Future<void> Function() onGrantPermission;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Calendar access is needed to build your agenda.',
                  key: Key('calendarPermissionDeniedMessage'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onGrantPermission,
                  child: const Text('Grant calendar access'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AllDayHeader extends StatelessWidget {
  const _AllDayHeader({required this.commitments});

  final List<Commitment> commitments;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('allDayHeader'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final commitment in commitments)
            Chip(label: Text(commitment.title)),
        ],
      ),
    );
  }
}

class _AgendaTile extends StatelessWidget {
  const _AgendaTile({required this.item});

  final AgendaItem item;

  @override
  Widget build(BuildContext context) {
    final agendaItem = item;
    final reason = rankingExplanation(agendaItem, DateTime.now);

    return switch (agendaItem) {
      Commitment() => ListTile(
        key: ValueKey(agendaItem.id),
        leading: const Icon(Icons.event),
        title: Text(agendaItem.title),
        subtitle: Text(
          '${DateFormat.jm().format(agendaItem.start)} - '
          '${DateFormat.jm().format(agendaItem.end)} · $reason',
        ),
        trailing: agendaItem.conferenceUrl == null
            ? null
            : IconButton(
                key: const Key('joinConferenceButton'),
                icon: const Icon(Icons.videocam),
                tooltip: 'Join',
                onPressed: () =>
                    launchUrl(Uri.parse(agendaItem.conferenceUrl!)),
              ),
      ),
      Task() => ListTile(
        key: ValueKey(agendaItem.id),
        leading: const Icon(Icons.check_box_outlined),
        title: Text(agendaItem.title),
        subtitle: Text(
          _taskDueText(agendaItem) == null
              ? reason
              : '${_taskDueText(agendaItem)} · $reason',
        ),
      ),
    };
  }

  String? _taskDueText(Task task) {
    final due = task.due;
    if (due == null) {
      return null;
    }
    return due.hasTime
        ? DateFormat.yMMMd().add_jm().format(due.date)
        : DateFormat.yMMMd().format(due.date);
  }
}
