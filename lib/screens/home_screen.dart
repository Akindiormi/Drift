import 'package:flutter/material.dart';
import '../services/sleep_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_cards.dart';
import '../widgets/common/screen_scaffold.dart';
import '../widgets/buttons/app_buttons.dart';
import '../widgets/animations/celebration_overlay.dart';
import '../widgets/illustrations/moon_orb.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _logging = false;

  Future<void> _logTonight() async {
    setState(() => _logging = true);
    final newStreak = await SleepService.instance.logTonight();
    if (!mounted) return;
    setState(() => _logging = false);

    if (newStreak == null) return; // already logged today, no-op

    final milestone = newStreak == 1
        ? 'Night 1 🌙'
        : newStreak % 7 == 0
            ? '$newStreak nights straight ✨'
            : '$newStreak-night streak';

    await showCelebration(
      context,
      title: milestone,
      message: newStreak == 1
          ? "You've started your streak. Come back tomorrow."
          : 'Keep it going tomorrow night.',
      icon: Icons.nightlight_round,
      color: newStreak >= 7 ? AppColors.gold : AppColors.accentEmerald,
    );
  }

  Future<void> _pickBedtime() async {
    final service = SleepService.instance;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: service.bedtimeHour, minute: service.bedtimeMinute),
    );
    if (picked == null) return;
    await service.setBedtime(picked.hour, picked.minute);
    await NotificationService.instance
        .scheduleBedtimeReminder(picked.hour, picked.minute);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for ${picked.format(context)}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SleepService.instance,
      builder: (context, _) {
        final service = SleepService.instance;
        final loggedToday = service.hasLoggedToday;

        return GradientScaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Drift', style: AppText.display(context, size: 28)),
                  Text('fall asleep, keep the streak',
                      style: AppText.body(context, size: 14)),
                  const SizedBox(height: 28),
                  Center(
                    child: Column(
                      children: [
                        MoonOrb(streak: service.currentStreak, size: 160),
                        const SizedBox(height: 20),
                        Text(
                          '${service.currentStreak}',
                          style: AppText.display(context, size: 56),
                        ),
                        Text(
                          service.currentStreak == 1 ? 'night streak' : 'night streak',
                          style: AppText.label(context, size: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: StatChip(
                          icon: Icons.emoji_events_rounded,
                          iconColor: AppColors.gold,
                          value: '${service.longestStreak}',
                          label: 'BEST STREAK',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatChip(
                          icon: Icons.bedtime_rounded,
                          iconColor: AppColors.accentEmerald,
                          value: '${service.totalLogs}',
                          label: 'NIGHTS LOGGED',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GlassCard(
                    onTap: _pickBedtime,
                    child: Row(
                      children: [
                        const Icon(Icons.alarm_rounded, color: AppColors.accentEmerald),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bedtime reminder · ${TimeOfDay(hour: service.bedtimeHour, minute: service.bedtimeMinute).format(context)}',
                            style: AppText.body(context, size: 14),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: AppPalette.of(context).textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: loggedToday ? 'Logged for tonight ✓' : 'Log tonight\'s sleep',
                    icon: loggedToday ? null : Icons.nightlight_round,
                    loading: _logging,
                    onPressed: loggedToday ? null : _logTonight,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
