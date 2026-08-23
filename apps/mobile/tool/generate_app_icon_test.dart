import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taboor/core/themes/app_colors.dart';
import 'package:taboor/features/splash/presentation/widgets/taboor_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate 1024 icon (teal bg fills screen)', () async {
    const size = 1024.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Full-screen teal background (no amber box).
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()..color = AppColors.primary,
    );

    // Centered white "T" glyph filling most of the screen.
    const glyphSize = size * 0.76;
    final glyphOffset = (size - glyphSize) / 2;
    canvas.save();
    canvas.translate(glyphOffset, glyphOffset);
    canvas.scale(glyphSize / 100);
    const TbLogoPainter().paint(canvas, const Size(100, 100));
    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final dir = Directory('assets/app_icon');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    File('${dir.path}/icon.png')
        .writeAsBytesSync(byteData!.buffer.asUint8List());

    expect(File('${dir.path}/icon.png').existsSync(), isTrue);
  });

  test('generate 1024 foreground (transparent, same teal square)', () async {
    const size = 1024.0;
    // Adaptive foreground: keep the full square logo (it already is a solid
    // graphic) centered within the safe zone.
    const logoBox = 820.0;
    final offset = (size - logoBox) / 2;
    final scale = logoBox / 95;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.save();
    canvas.translate(offset, offset);
    canvas.scale(scale);

    // Single teal rounded square filling the box.
    final primaryRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 95, 95),
      const Radius.circular(28),
    );
    canvas.drawRRect(primaryRRect, Paint()..color = AppColors.primary);

    // T glyph centered inside the square (slightly larger).
    final glyphScale = 95 / 100 * 1.15;
    canvas.save();
    canvas.scale(glyphScale);
    canvas.translate(-2.5, -2.5);
    const TbLogoPainter().paint(canvas, const Size(100, 100));
    canvas.restore();

    canvas.restore();

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    final dir = Directory('assets/app_icon');
    if (!dir.existsSync()) dir.createSync(recursive: true);

    File('${dir.path}/foreground.png')
        .writeAsBytesSync(byteData!.buffer.asUint8List());

    expect(File('${dir.path}/foreground.png').existsSync(), isTrue);
  });
}