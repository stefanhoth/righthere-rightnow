import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:righthere_rightnow/scheduling/briefing_alarm.dart';
import 'package:righthere_rightnow/scheduling/briefing_foreground_service.dart';
import 'package:righthere_rightnow/ui/agenda/daily_agenda_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeBriefingService();
  await initializeBriefingAlarm();
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
