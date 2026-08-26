import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:righthere_rightnow/ui/settings/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: RightHereRightNowApp()));
}

class RightHereRightNowApp extends StatelessWidget {
  const RightHereRightNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Right Here, Right Now',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DailyAgendaScreen(),
    );
  }
}

class DailyAgendaScreen extends StatelessWidget {
  const DailyAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: const Center(child: Text('No Briefing Run yet.')),
    );
  }
}
