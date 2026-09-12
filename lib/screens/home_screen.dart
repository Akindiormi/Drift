import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/sleep_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/celebration_copy.dart';
import '../widgets/common/app_cards.dart';
import '../widgets/common/screen_scaffold.dart';
import '../widgets/common/streak_dots.dart';
import '../widgets/buttons/app_buttons.dart';
import '../widgets/animations/celebration_overlay.dart';
import '../widgets/illustrations/moon_orb.dart';
import '../widgets/share/share_streak_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _logging = false;
  bool _sharing = false;
  final GlobalKey _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Show the "your streak was reset" toast at most once, the next time
    // they open the app after a missed day — not silent, not shaming.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = SleepService.instance;
      if (service.justReset) {
        service.acknowledgeReset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Your streak was reset — start again tonight 🌙'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryDark,
          ),
        );
      }
    });
  }

  Future<void> _logTonight() async {
    setState(() => _logging = true);
    final newStreak = await SleepService.instance.logTonight();
    if (!mounted) return;
    setState(() => _logging = false);

    if (newStreak == null) return; // already logged today, no-op

    final moment = celebrationFor(newStreak);
    SystemSound.play(SystemSoundType.click);
    if (moment.heavyHaptic) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }

    await showCelebration(
      context,
      title: moment.title,
      message: moment.message,
      icon: moment.icon,
      color: moment.color,
      confettiCount: moment.confettiCount,
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

  Future<void> _share(int streak) async {
    setState(() => _sharing = true);
    try {
      await captureAndShare(
        _shareCardKey,
        text: "$streak-night sleep streak on Drift 🌙",
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SleepService.instance,
      builder: (context, _) {
        final service = SleepService.instance;
        final loggedToday = service.hasLoggedToday;
        final streak = service.currentStreak;

        return GradientScaffold(
          body: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Drift', style: AppText.display(context, size: 28)),
                                Text('fall asleep, keep the streak',
                                    style: AppText.body(context, size: 14)),
                              ],
                            ),
                          ),
                          _sharing
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  onPressed: () => _share(streak),
                                  icon: const Icon(Icons.ios_share_rounded),
                                  color: AppPalette.of(context).textSecondary,
                                  tooltip: 'Share your streak',
                                ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            MoonOrb(streak: streak, size: 160),
                            const SizedBox(height: 20),
                            Text(
                              '$streak',
                              style: AppText.display(context, size: 56),
                            ),
                            Text(
                              'night streak',
                              style: AppText.label(context, size: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GlassCard(
                        child: StreakDotsRow(last7Days: service.last7Days),
                      ),
                      const SizedBox(height: 16),
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
                      loggedToday
                          ? _LoggedBadge()
                          : PrimaryButton(
                              label: "Log tonight's sleep",
                              icon: Icons.nightlight_round,
                              loading: _logging,
                              onPressed: _logTonight,
                            ),
                    ],
                  ),
                ),
              ),
              // Off-screen render target for the share card — always in the
              // tree (so RepaintBoundary has a painted layer to capture),
              // positioned off-canvas so it's never visible.
              Positioned(
                left: -9999,
                top: 0,
                child: RepaintBoundary(
                  key: _shareCardKey,
                  child: ShareableStreakCard(streak: streak),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Distinct "done" state — not just a disabled button. Muted fill, check
/// icon, slightly scaled down so it visibly reads as complete at a glance.
class _LoggedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              'Logged for tonight',
              style: AppText.heading(context, size: 15, color: AppColors.success),
            ),
          ],
        ),
      ),
    );
  }
}
