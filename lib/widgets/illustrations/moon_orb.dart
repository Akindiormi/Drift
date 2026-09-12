import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// An animated moon that glows brighter and fuller with the streak:
/// dim crescent unlit, violet glow at 3 days, gold glow at 7, radiant at 30.
class MoonOrb extends StatefulWidget {
  final int streak;
  final double size;

  const MoonOrb({super.key, required this.streak, this.size = 140});

  @override
  State<MoonOrb> createState() => _MoonOrbState();
}

class _MoonOrbState extends State<MoonOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  Color get _glowColor {
    if (widget.streak >= 30) return const Color(0xFFF3D48A);
    if (widget.streak >= 7) return AppColors.gold;
    return AppColors.accentEmerald;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullness = (0.35 + (widget.streak / 30).clamp(0, 1) * 0.65);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _MoonPainter(
            pulse: _c.value,
            color: _glowColor,
            fullness: fullness,
            lit: widget.streak > 0,
          ),
        ),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final double pulse;
  final Color color;
  final double fullness;
  final bool lit;

  _MoonPainter({
    required this.pulse,
    required this.color,
    required this.fullness,
    required this.lit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.32;

    if (lit) {
      // outer soft glow, gently breathing
      canvas.drawCircle(
        center,
        radius * (1.6 + 0.15 * math.sin(pulse * math.pi * 2)),
        Paint()
          ..color = color.withValues(alpha: 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
      );
      canvas.drawCircle(
        center,
        radius * 1.15,
        Paint()
          ..color = color.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    }

    // moon body
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: lit
              ? [Colors.white, color.withValues(alpha: 0.85)]
              : [
                  Colors.grey.withValues(alpha: 0.35),
                  Colors.grey.withValues(alpha: 0.2),
                ],
          center: const Alignment(-0.3, -0.3),
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // shadow crescent overlay — shrinks as "fullness" (streak) grows.
    // Clipped to the moon disc so it reads as a phase, not a floating blob.
    canvas.save();
    final moonPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(moonPath);
    final shadowOffset = radius * (1.0 - fullness) * 1.4;
    canvas.drawCircle(
      Offset(center.dx + shadowOffset, center.dy - radius * 0.05),
      radius * 0.98,
      Paint()..color = (lit ? AppColors.primaryDark : Colors.black).withValues(
        alpha: lit ? 0.55 : 0.15,
      ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MoonPainter old) =>
      old.pulse != pulse ||
      old.color != color ||
      old.fullness != fullness ||
      old.lit != lit;
}
