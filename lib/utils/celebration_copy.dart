import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Everything the celebration overlay needs for a given streak: title,
/// message, icon, color and how big the moment should feel.
class CelebrationMoment {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final int confettiCount;
  final bool heavyHaptic;

  const CelebrationMoment({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.confettiCount,
    required this.heavyHaptic,
  });
}

final _rand = Random();

/// A few interchangeable lines for an "ordinary" night so the same overlay
/// doesn't repeat verbatim every day of a multi-day test.
const _ordinaryLines = [
  'Logged. Sleep well.',
  'Streak alive 🌙',
  'Tonight\'s in the books.',
  'Another night down.',
  'Keeping it going.',
];

CelebrationMoment celebrationFor(int streak) {
  if (streak == 1) {
    return const CelebrationMoment(
      title: 'Night 1 🌙',
      message: "You've started your streak. Come back tomorrow.",
      icon: Icons.nightlight_round,
      color: AppColors.accentEmerald,
      confettiCount: 60,
      heavyHaptic: false,
    );
  }
  if (streak == 7) {
    return const CelebrationMoment(
      title: 'One week strong 🔥',
      message: 'Seven nights in a row. The moon\'s glowing for it.',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.gold,
      confettiCount: 130,
      heavyHaptic: true,
    );
  }
  if (streak == 30) {
    return const CelebrationMoment(
      title: 'A full month 🏆',
      message: "30 nights. That's not a habit anymore — that's who you are.",
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFF3D48A),
      confettiCount: 220,
      heavyHaptic: true,
    );
  }
  if (streak == 100) {
    return const CelebrationMoment(
      title: '100 nights ✨',
      message: 'Triple digits. Legendary streak territory.',
      icon: Icons.auto_awesome_rounded,
      color: Colors.white,
      confettiCount: 260,
      heavyHaptic: true,
    );
  }
  if (streak % 7 == 0) {
    return CelebrationMoment(
      title: '$streak nights straight',
      message: 'Another week banked.',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.gold,
      confettiCount: 150,
      heavyHaptic: true,
    );
  }
  // Ordinary night — small, quick, randomized so it doesn't feel copy-pasted.
  return CelebrationMoment(
    title: _ordinaryLines[_rand.nextInt(_ordinaryLines.length)],
    message: '$streak-night streak',
    icon: Icons.nightlight_round,
    color: AppColors.accentEmerald,
    confettiCount: 50,
    heavyHaptic: false,
  );
}
