import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../illustrations/moon_orb.dart';

/// The visual card that gets exported as an image for sharing.
class ShareableStreakCard extends StatelessWidget {
  final int streak;
  const ShareableStreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppGradients.screen(true),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Drift',
            style: AppText.display(context, size: 22, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          MoonOrb(streak: streak, size: 150),
          const SizedBox(height: 20),
          Text(
            '$streak',
            style: AppText.display(context, size: 56, color: Colors.white),
          ),
          Text(
            'night streak',
            style: AppText.label(context, size: 13, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

/// Captures a widget wrapped in [RepaintBoundary] and shares it as a PNG.
Future<void> captureAndShare(GlobalKey boundaryKey, {String text = ''}) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;

  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;
  final Uint8List bytes = byteData.buffer.asUint8List();

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/drift_streak_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(bytes);

  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: text),
  );
}
