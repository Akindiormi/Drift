import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// The signature frosted-glass card: backdrop blur, soft green shadow, a hairline
/// border and a thin white highlight along the top edge.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadius.card,
    this.blur = 20,
    this.onTap,
    this.color,
    this.gradient,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? palette.card) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: palette.border, width: 1),
          ),
          child: child,
        ),
      ),
    );

    final wrapped = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
        // thin inner highlight along the top edge
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.topHighlight.withValues(alpha: 0.0), Colors.transparent],
        ),
      ),
      child: card,
    );

    if (onTap == null) return wrapped;
    return _PressableScale(onTap: onTap!, child: wrapped);
  }
}

/// A pill-shaped glass container used for stats, chips and tags.
class GlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool active;

  const GlassPill({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.onTap,
    this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final pill = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: active
                ? AppColors.accentEmerald.withValues(alpha: 0.15)
                : (color ?? palette.cardStrong),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: active ? AppColors.accentEmerald : palette.border,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
    if (onTap == null) return pill;
    return _PressableScale(onTap: onTap!, child: pill);
  }
}

/// A stat chip: coloured icon badge, a large number and a muted label.
class StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Widget? leading;

  const StatChip({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 20,
      child: Row(
        children: [
          leading ??
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppText.number(context, size: 20)),
              Text(label, style: AppText.label(context, size: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A gradient progress bar with an inner glow, used across the app.
class GradientProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  final Gradient gradient;

  const GradientProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.gradient = AppGradients.progress,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(
            height: height,
            color: palette.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primaryDark.withValues(alpha: 0.08),
          ),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(height),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Scale-down-on-press wrapper giving the whole app its tactile feel.
class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
