import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/app_theme.dart';
import 'services/sleep_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SleepService.instance.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  // Show the home screen first — don't make the tester's first sight of the
  // app be an OS permission popup. Ask afterwards, and actually schedule the
  // default bedtime reminder once we know the answer, so the card on the
  // home screen isn't showing a time that was never really scheduled.
  runApp(const DriftApp());
  NotificationService.instance.init().then((_) {
    final service = SleepService.instance;
    NotificationService.instance
        .scheduleBedtimeReminder(service.bedtimeHour, service.bedtimeMinute);
  });
}

class DriftApp extends StatelessWidget {
  const DriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
