import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:righthere_rightnow/briefing/briefing_run_orchestrator.dart';
import 'package:righthere_rightnow/briefing/ranking_explanation.dart';
import 'package:righthere_rightnow/briefing/staleness.dart';
import 'package:righthere_rightnow/domain/agenda_item.dart';
import 'package:righthere_rightnow/ui/agenda/agenda_controller.dart';
import 'package:righthere_rightnow/ui/agenda/agenda_pill.dart';
import 'package:righthere_rightnow/ui/agenda/task_title.dart';
import 'package:righthere_rightnow/ui/settings/settings_screen.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyAgendaScreen extends ConsumerWidget {
  const DailyAgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaState = ref.watch(dailyAgendaControllerProvider);
    // Watched here, not inside the AsyncData branch below: the live run
    // `dailyAgendaControllerProvider` triggers on every open invalidates
    // this as soon as it completes, so reading it only alongside the
    // finished agenda would always see the just-refreshed, non-stale value.
    final lastRunCompletedAt = ref
        .watch(lastBriefingRunCompletedAtProvider)
        .value;
    final showStaleBanner = isStale(
      lastRunCompletedAt: lastRunCompletedAt,
      clock: DateTime.now,
    );

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
      body: Column(
        children: [
          if (showStaleBanner)
            _StaleBanner(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(dailyAgendaControllerProvider.notifier).refresh(),
              child: switch (agendaState) {
                AsyncData(:final value) => _AgendaBody(result: value),
                AsyncError(:final error) => _ErrorView(message: '$error'),
                _ => const _LoadingView(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('staleBanner'),
      color: Theme.of(context).colorScheme.errorContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No Daily Agenda has run in over a day. Check battery '
                  'settings so your morning briefing can run in the '
                  'background.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final launchRunId = ref.watch(notificationLaunchRunIdProvider).value;

    final header = Column(
      children: [
        if (result.framingLine != null) _FramingLine(text: result.framingLine!),
        _LastRunBanner(result: result),
        const _RatingButtons(),
        if (launchRunId != null) const _OpenedFromNotificationBanner(),
        if (result.isPartial) _PartialDataBanner(message: result.error!),
        if (result.allDayCommitments.isNotEmpty)
          _AllDayHeader(commitments: result.allDayCommitments),
      ],
    );

    if (isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          header,
          const Padding(
            key: Key('agendaEmpty'),
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Nothing on your plate today.')),
          ),
        ],
      );
    }

    return ReorderableListView(
      physics: const AlwaysScrollableScrollPhysics(),
      header: header,
      onReorderItem: (oldIndex, newIndex) => ref
          .read(dailyAgendaControllerProvider.notifier)
          .reorder(oldIndex, newIndex),
      children: [
        for (final item in rankedItems)
          _AgendaTile(key: ValueKey(item.id), item: item),
      ],
    );
  }
}

class _RatingButtons extends ConsumerWidget {
  const _RatingButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Spacer(),
        IconButton(
          key: const Key('thumbsUpButton'),
          icon: const Icon(Icons.thumb_up_outlined),
          tooltip: 'Good ranking',
          onPressed: () => _rate(context, ref, 1),
        ),
        IconButton(
          key: const Key('thumbsDownButton'),
          icon: const Icon(Icons.thumb_down_outlined),
          tooltip: "Not worth reordering, but wasn't great",
          onPressed: () => _rate(context, ref, -1),
        ),
      ],
    );
  }

  Future<void> _rate(BuildContext context, WidgetRef ref, int rating) async {
    await ref.read(dailyAgendaControllerProvider.notifier).rate(rating);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Noted.')));
    }
  }
}

class _FramingLine extends StatelessWidget {
  const _FramingLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('framingLine'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        text,
        key: const Key('framingLineText'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
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

class _OpenedFromNotificationBanner extends StatelessWidget {
  const _OpenedFromNotificationBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('openedFromNotificationBanner'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        'Opened from your Focus Pull notification.',
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

/// Calendar Commitments carry a purple source mark, Todoist Tasks a teal one,
/// so the two systems stay distinguishable at a glance and red is left to
/// mean "overdue". The tint is the lightest step of each ramp, the mark the
/// mid step.
const _calendarTint = Color(0xFFEEEDFE);
const _calendarMark = Color(0xFF534AB7);
const _todoistTint = Color(0xFFE1F5EE);
const _todoistMark = Color(0xFF0F6E56);

class _AgendaTile extends StatelessWidget {
  const _AgendaTile({required super.key, required this.item});

  final AgendaItem item;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final pill = agendaPillFor(item, now);
    final parsedTitle = switch (item) {
      Commitment() => null,
      final Task task => parseTaskTitle(task.title),
    };
    final (tint, mark, icon) = switch (item) {
      Commitment() => (
        _calendarTint,
        _calendarMark,
        SimpleIcons.googlecalendar,
      ),
      Task() => (_todoistTint, _todoistMark, SimpleIcons.todoist),
    };
    final secondary = _secondaryText(pill != null);
    final link = parsedTitle?.link;

    return ListTile(
      key: ValueKey(item.id),
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: mark),
      ),
      title: _title(context, parsedTitle),
      subtitle: (pill == null && secondary == null)
          ? null
          : _Subtitle(pill: pill, text: secondary),
      trailing: _trailing(),
      onTap: link == null ? null : () => launchUrl(link),
    );
  }

  Widget _title(BuildContext context, ParsedTaskTitle? parsedTitle) {
    if (parsedTitle == null) {
      return Text(item.title);
    }
    if (parsedTitle.link == null) {
      return Text(parsedTitle.text);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: Text(parsedTitle.text)),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.open_in_new,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String? _secondaryText(bool hasPill) {
    final reason = rankingExplanation(item, DateTime.now);
    return switch (item) {
      final Commitment commitment => '${_durationLabel(commitment)} · $reason',
      final Task task => _taskDueText(task) ?? (hasPill ? null : reason),
    };
  }

  Widget? _trailing() {
    final current = item;
    if (current is Commitment && current.conferenceUrl != null) {
      return IconButton(
        key: const Key('joinConferenceButton'),
        icon: const Icon(Icons.videocam),
        tooltip: 'Join',
        onPressed: () => launchUrl(Uri.parse(current.conferenceUrl!)),
      );
    }
    return null;
  }

  String _durationLabel(Commitment commitment) {
    final minutes = commitment.end.difference(commitment.start).inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes / 60;
    return hours == hours.roundToDouble()
        ? '${hours.toInt()} hr'
        : '${hours.toStringAsFixed(1)} hr';
  }

  String? _taskDueText(Task task) {
    final due = task.due;
    if (due == null) {
      return null;
    }
    return due.hasTime
        ? DateFormat.MMMd().add_jm().format(due.date)
        : DateFormat.MMMd().format(due.date);
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.pill, required this.text});

  final AgendaPill? pill;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final currentPill = pill;
    final currentText = text;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          if (currentPill != null) _StatusPill(currentPill),
          if (currentPill != null && currentText != null)
            const SizedBox(width: 6),
          if (currentText != null)
            Expanded(
              child: Text(
                currentText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.pill);

  final AgendaPill pill;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Material's ColorScheme has no "warning" role, so the amber pair is
    // spelled out rather than pulled from the theme.
    final (background, foreground) = switch (pill.tone) {
      PillTone.urgent => (scheme.errorContainer, scheme.onErrorContainer),
      PillTone.warning => (const Color(0xFFFAEEDA), const Color(0xFF633806)),
      PillTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      PillTone.info => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        pill.label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w500),
      ),
    );
  }
}
