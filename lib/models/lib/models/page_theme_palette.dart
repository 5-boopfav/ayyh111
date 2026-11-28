import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PageThemePalette {
  final Color background;
  final Color paper;
  final Color ink;
  final Color accent;
  final Color outerFrame;
  final Color innerFrame;
  final Color frameFill;

  const PageThemePalette({
    required this.background,
    required this.paper,
    required this.ink,
    required this.accent,
    required this.outerFrame,
    required this.innerFrame,
    required this.frameFill,
  });

  factory PageThemePalette.fromHueAndShade({
    required double hue,
    required double shade,
  }) {
    final double h = hue % 360.0;
    final double s = shade.clamp(0.0, 1.0);

    final double paperLightness = ui.lerpDouble(0.992, 0.85, s)!;
    final double paperSat = ui.lerpDouble(0.10, 0.36, s)!;

    final double bgLightness = ui.lerpDouble(0.96, 0.78, s)!;
    final double bgSat = ui.lerpDouble(0.18, 0.38, s)!;

    final Color paper =
        HSLColor.fromAHSL(1.0, h, paperSat, paperLightness).toColor();
    final Color background =
        HSLColor.fromAHSL(1.0, h, bgSat, bgLightness).toColor();

    final double inkLightness = ui.lerpDouble(0.15, 0.10, s)!;
    final Color ink = HSLColor.fromAHSL(1.0, h, 0.25, inkLightness).toColor();

    final Color accent = HSLColor.fromAHSL(1.0, h, 0.68, 0.34).toColor();
    final Color outerFrame = HSLColor.fromAHSL(1.0, h, 0.72, 0.30).toColor();
    final Color innerFrame = HSLColor.fromAHSL(1.0, h, 0.62, 0.56).toColor();
    final Color frameFill = HSLColor.fromAHSL(1.0, h, 0.55, 0.84).toColor();

    return PageThemePalette(
      background: background,
      paper: paper,
      ink: ink,
      accent: accent,
      outerFrame: outerFrame,
      innerFrame: innerFrame,
      frameFill: frameFill,
    );
  }
}
