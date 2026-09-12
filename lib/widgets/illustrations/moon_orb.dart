import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A living moon: slow idle rotation of a twinkling starfield, breathing
/// glow, and a color/intensity tier that escalates with the streak —
/// grey (0) → soft blue (1-6) → violet (7-29) → gold (30-99) → radiant (100+).
/// Gives testers a reason to want the next color.
class MoonOrb extends StatefulWidget {
  final int streak;
  final double size;

  const MoonOrb({super.key, required this.streak, this.size = 160});

  @override
  State<MoonOrb> createState() => _MoonOrbState();
}

class _MoonOrbState extends State<MoonOrb> with TickerProviderStateMixin {
  // Breathing glow — fast enough to read as "alive", slow enough to feel calm.
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  // Slow star-field rotation — barely perceptible, reads as ambient motion.
  late final AnimationController _rotate = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  // Independent per-star twinkle.
  late final AnimationController _twinkle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final List<_Star> _stars = List.generate(14, (i) {
    final angle = (i / 14) * math.pi * 2 + _rand.nextDouble() * 0.3;
    final dist = 0.55 + _rand.nextDouble() * 0.45; // relative to radius
    return _Star(
      angle: angle,
      dist: dist,
      size: 1.0 + _rand.nextDouble() * 1.8,
      phase: _rand.nextDouble(),
    );
  });

  static final _rand = math.Random();

  /// 0=unlit, 1=blue, 2=violet, 3=gold, 4=radiant
  int get _tier {
    if (widget.streak <= 0) return 0;
    if (widget.streak < 7) return 1;
    if (widget.streak < 30) return 2;
    if (widget.streak < 100) return 3;
    return 4;
  }

  Color get _glowColor {
    switch (_tier) {
      case 1:
        return const Color(0xFF6FA8F5); // soft blue
      case 2:
        return AppColors.accentEmerald; // violet
      case 3:
        return AppColors.gold;
      case 4:
        return const Color(0xFFFFF3D0); // radiant near-white gold
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _breathe.dispose();
    _rotate.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullness = (0.35 + (widget.streak / 30).clamp(0, 1) * 0.65);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathe, _rotate, _twinkle]),
        builder: (context, _) => CustomPaint(
          painter: _MoonPainter(
            pulse: _breathe.value,
            rotation: _rotate.value * math.pi * 2,
            twinkle: _twinkle.value,
            stars: _stars,
            color: _glowColor,
            fullness: fullness,
            lit: widget.streak > 0,
            tier: _tier,
          ),
        ),
      ),
    );
  }
}

class _Star {
  final double angle;
  final double dist;
  final double size;
  final double phase;
  const _Star({
    required this.angle,
    required this.dist,
    required this.size,
    required this.phase,
  });
}

class _MoonPainter extends CustomPainter {
  final double pulse;
  final double rotation;
  final double twinkle;
  final List<_Star> stars;
  final Color color;
  final double fullness;
  final bool lit;
  final int tier;

  _MoonPainter({
    required this.pulse,
    required this.rotation,
    required this.twinkle,
    required this.stars,
    required this.color,
    required this.fullness,
    required this.lit,
    required this.tier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.30;
    final fieldRadius = size.width * 0.5;

    // Starfield — rotates slowly, each star twinkles on its own phase.
    for (final star in stars) {
      final a = star.angle + rotation;
      final pos = Offset(
        center.dx + math.cos(a) * fieldRadius * star.dist,
        center.dy + math.sin(a) * fieldRadius * star.dist,
      );
      final localTwinkle =
          (math.sin((twinkle + star.phase) * math.pi * 2) + 1) / 2;
      final opacity = lit ? (0.25 + 0.55 * localTwinkle) : (0.12 + 0.15 * localTwinkle);
      canvas.drawCircle(
        pos,
        star.size * (0.7 + 0.3 * localTwinkle),
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }

    if (lit) {
      // outer soft glow, gently breathing — bigger/brighter at higher tiers
      final glowScale = 1.4 + tier * 0.12;
      canvas.drawCircle(
        center,
        radius * (glowScale + 0.15 * math.sin(pulse * math.pi * 2)),
        Paint()
          ..color = color.withValues(alpha: 0.18 + tier * 0.02)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
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
        alpha: lit ? 0.5 : 0.15,
      ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MoonPainter old) => true;
}
