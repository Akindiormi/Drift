import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StreakDotsRow extends StatelessWidget {
  final List<bool> last7Days; // oldest first, 7 entries

  const StreakDotsRow({super.key, required this.last7Days});

  @override
  Widget build(BuildContext context) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // 0=Mon
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final filled = last7Days[i];
        final dayIndex = (today - (6 - i)) % 7;
        final label = labels[dayIndex < 0 ? dayIndex + 7 : dayIndex];
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.accentEmerald : Colors.transparent,
                border: Border.all(
                  color: filled
                      ? AppColors.accentEmerald
                      : AppPalette.of(context).textSecondary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: AppColors.accentEmerald.withValues(alpha: 0.4),
                          blurRadius: 6,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppText.label(context, size: 10)),
          ],
        );
      }),
    );
  }
}
