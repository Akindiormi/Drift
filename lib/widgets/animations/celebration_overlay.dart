import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A confetti particle.
class _Confetto {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;
  _Confetto(this.angle, this.speed, this.size, this.color, this.rotationSpeed);
}

/// A one-shot confetti burst painted over the screen. Insert into an Overlay or
/// a Stack; it removes itself via [onComplete].
class ConfettiBurst extends StatefulWidget {
  final VoidCallback? onComplete;
  final int count;

  const ConfettiBurst({super.key, this.onComplete, this.count = 90});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  late final List<_Confetto> _pieces;

  static const _colors = [
    AppColors.success,
    AppColors.accentEmerald,
    AppColors.gold,
    Color(0xFFE9C55A),
    AppColors.secondaryGreen,
  ];

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _pieces = List.generate(widget.count, (i) {
      return _Confetto(
        -math.pi / 2 + (rnd.nextDouble() - 0.5) * math.pi * 1.2,
        3 + rnd.nextDouble() * 7,
        5 + rnd.nextDouble() * 8,
        _colors[rnd.nextInt(_colors.length)],
        (rnd.nextDouble() - 0.5) * 0.4,
      );
    });
    _c.forward().whenComplete(() => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_pieces, _c.value),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetto> pieces;
  final double t;
  _ConfettiPainter(this.pieces, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.42);
    final gravity = 380.0;
    for (final p in pieces) {
      final vx = math.cos(p.angle) * p.speed * 60;
      final vy = math.sin(p.angle) * p.speed * 60;
      final x = origin.dx + vx * t;
      final y = origin.dy + vy * t + 0.5 * gravity * t * t;
      final opacity = (1 - t).clamp(0.0, 1.0);
      if (opacity <= 0) continue;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 12 * p.rotationSpeed + p.angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(2),
        ),
        Paint()..color = p.color.withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

/// Shows a lightweight celebration overlay (confetti + a small badge card) for
/// milestones below 100%. Auto-dismisses.
Future<void> showCelebration(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.emoji_events_rounded,
  Color color = AppColors.gold,
  int confettiCount = 90,
}) async {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _CelebrationCard(
      title: title,
      message: message,
      icon: icon,
      color: color,
      confettiCount: confettiCount,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _CelebrationCard extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final int confettiCount;
  final VoidCallback onDone;

  const _CelebrationCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.onDone,
    this.confettiCount = 90,
  });

  @override
  State<_CelebrationCard> createState() => _CelebrationCardState();
}

class _CelebrationCardState extends State<_CelebrationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        child: Stack(
          children: [
            ConfettiBurst(count: widget.confettiCount),
            Center(
              child: ScaleTransition(
                scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
                child: FadeTransition(
                  opacity: _c,
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.4),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              widget.color,
                              widget.color.withValues(alpha: 0.7),
                            ]),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.icon,
                              color: Colors.white, size: 44),
                        ),
                        const SizedBox(height: 18),
                        Text(widget.title,
                            textAlign: TextAlign.center,
                            style: AppText.display(context,
                                size: 22, color: AppColors.primaryDark)),
                        const SizedBox(height: 8),
                        Text(widget.message,
                            textAlign: TextAlign.center,
                            style: AppText.body(context, size: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
