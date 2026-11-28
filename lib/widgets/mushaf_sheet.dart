import 'package:flutter/material.dart';

import '../models/page_theme_palette.dart';

String toArabicIndicDigits(int number) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return number
      .toString()
      .split('')
      .map((ch) => digits[int.parse(ch)])
      .join();
}

class MushafSingleSheet extends StatelessWidget {
  final int pageNumber;
  final String surahName;
  final String juzTitle;
  final PageThemePalette palette;
  final double scale;
  final int wirdRead;
  final int wirdGoal;

  const MushafSingleSheet({
    super.key,
    required this.pageNumber,
    required this.surahName,
    required this.juzTitle,
    required this.palette,
    required this.scale,
    required this.wirdRead,
    required this.wirdGoal,
  });

  @override
  Widget build(BuildContext context) {
    final String assetPath = 'assets/images/quran/$pageNumber.png';
    final double wirdRatio =
        wirdGoal > 0 ? (wirdRead / wirdGoal).clamp(0.0, 1.0) : 0.0;

    return Transform.scale(
      scale: scale,
      child: Container(
        color: palette.paper,
        child: CustomPaint(
          painter: _OrnateMushafFramePainter(
            outerColor: palette.outerFrame,
            innerColor: palette.innerFrame,
            frameFill: palette.frameFill,
            paperColor: palette.paper,
            accentColor: palette.accent,
            inkColor: palette.ink,
            surahLabel: 'سُورَةُ $surahName',
            juzLabel: juzTitle,
            pageLabel: toArabicIndicDigits(pageNumber),
            wirdRatio: wirdRatio,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(17, 36, 17, 26),
            child: SizedBox.expand(
              child: Image.asset(
                assetPath,
                fit: BoxFit.fill,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 44,
                          color: palette.outerFrame.withValues(alpha: 0.75),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'صفحة الختمة رقم $pageNumber من 604',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: palette.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          assetPath,
                          style: TextStyle(
                            fontSize: 12,
                            color: palette.ink.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrnateMushafFramePainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;
  final Color frameFill;
  final Color paperColor;
  final Color accentColor;
  final Color inkColor;
  final String surahLabel;
  final String juzLabel;
  final String pageLabel;
  final double wirdRatio;

  _OrnateMushafFramePainter({
    required this.outerColor,
    required this.innerColor,
    required this.frameFill,
    required this.paperColor,
    required this.accentColor,
    required this.inkColor,
    required this.surahLabel,
    required this.juzLabel,
    required this.pageLabel,
    required this.wirdRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 40 || size.height <= 40) return;

    const double topFrameY = 16.0;
    const double bottomMargin = 14.0;
    const double bandThickness = 13.0;

    final Rect outerRect = Rect.fromLTRB(
      1.5,
      topFrameY,
      size.width - 1.5,
      size.height - bottomMargin,
    );
    final Rect innerRect = outerRect.deflate(bandThickness);

    final Path bandPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(outerRect)
      ..addRect(innerRect);

    canvas.drawPath(
      bandPath,
      Paint()
        ..color = frameFill
        ..style = PaintingStyle.fill,
    );

    canvas.save();
    canvas.clipPath(bandPath);
    _drawRepeatingFloralBand(canvas, outerRect, bandThickness);
    canvas.restore();

    final Paint heavyBorder = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final Paint fineBorder = Paint()
      ..color = outerColor.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    canvas.drawRect(outerRect, heavyBorder);
    canvas.drawRect(outerRect.deflate(2.4), fineBorder);
    canvas.drawRect(innerRect.inflate(2.4), fineBorder);
    canvas.drawRect(innerRect, heavyBorder);

    _drawCornerMedallion(canvas, outerRect.topLeft, innerRect.topLeft);
    _drawCornerMedallion(canvas, outerRect.topRight, innerRect.topRight);
    _drawCornerMedallion(canvas, outerRect.bottomLeft, innerRect.bottomLeft);
    _drawCornerMedallion(canvas, outerRect.bottomRight, innerRect.bottomRight);

    final double barW = (innerRect.width * 0.36) * wirdRatio.clamp(0.0, 1.0);
    if (barW > 1) {
      canvas.drawLine(
        Offset(innerRect.center.dx - barW * 0.5, innerRect.bottom),
        Offset(innerRect.center.dx + barW * 0.5, innerRect.bottom),
        Paint()
          ..color = accentColor
          ..strokeWidth = 2.0,
      );
    }

    const double cartoucheH = 26.0;
    const double juzW = 116.0;
    const double surahW = 120.0;

    final Rect juzRect = Rect.fromLTWH(
      outerRect.left + 20.0,
      2.0,
      juzW,
      cartoucheH,
    );
    final Rect surahRect = Rect.fromLTWH(
      outerRect.right - surahW - 20.0,
      2.0,
      surahW,
      cartoucheH,
    );

    _drawScallopedCartouche(
      canvas: canvas,
      rect: juzRect,
      text: juzLabel,
      fontSize: 11.5,
    );
    _drawScallopedCartouche(
      canvas: canvas,
      rect: surahRect,
      text: surahLabel,
      fontSize: 11.5,
    );

    final double bridgeLeft = juzRect.right + 28.0;
    final double bridgeRight = surahRect.left - 4.0;
    if (bridgeRight > bridgeLeft + 12.0) {
      final Rect bridgeRect = Rect.fromLTRB(
        bridgeLeft,
        topFrameY - 4.0,
        bridgeRight,
        topFrameY + 4.0,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bridgeRect, const Radius.circular(4)),
        Paint()..color = frameFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bridgeRect, const Radius.circular(4)),
        Paint()
          ..color = outerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      const double step = 10.0;
      for (double x = bridgeRect.left + 6.0;
          x < bridgeRect.right - 4.0;
          x += step) {
        _drawDiamondRosette(
          canvas,
          Offset(x, bridgeRect.center.dy),
          2.6,
        );
      }
    }

    const double pageBoxW = 78.0;
    const double pageBoxH = 24.0;
    final Rect pageRect = Rect.fromCenter(
      center: Offset(outerRect.center.dx, outerRect.bottom + 2.0),
      width: pageBoxW,
      height: pageBoxH,
    );
    _drawScallopedCartouche(
      canvas: canvas,
      rect: pageRect,
      text: pageLabel,
      fontSize: 12.5,
    );
  }

  void _drawRepeatingFloralBand(
      Canvas canvas, Rect outerRect, double bandThickness) {
    final Paint scrollPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final Paint accentDotPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;

    const double step = 14.0;

    for (double x = outerRect.left; x <= outerRect.right + step; x += step) {
      final double topY = outerRect.top + bandThickness * 0.5;
      final double botY = outerRect.bottom - bandThickness * 0.5;

      _drawBandMotif(canvas, Offset(x, topY), scrollPaint, accentDotPaint);
      _drawBandMotif(canvas, Offset(x, botY), scrollPaint, accentDotPaint);
    }

    for (double y = outerRect.top; y <= outerRect.bottom + step; y += step) {
      final double leftX = outerRect.left + bandThickness * 0.5;
      final double rightX = outerRect.right - bandThickness * 0.5;

      _drawBandMotif(canvas, Offset(leftX, y), scrollPaint, accentDotPaint);
      _drawBandMotif(canvas, Offset(rightX, y), scrollPaint, accentDotPaint);
    }
  }

  void _drawBandMotif(
    Canvas canvas,
    Offset center,
    Paint strokePaint,
    Paint fillPaint,
  ) {
    canvas.drawCircle(center, 4.6, strokePaint);
    canvas.drawCircle(center, 2.1, fillPaint);

    final Path petal = Path()
      ..moveTo(center.dx, center.dy - 6.0)
      ..lineTo(center.dx + 6.0, center.dy)
      ..lineTo(center.dx, center.dy + 6.0)
      ..lineTo(center.dx - 6.0, center.dy)
      ..close();
    canvas.drawPath(petal, strokePaint);
  }

  void _drawCornerMedallion(Canvas canvas, Offset outerPt, Offset innerPt) {
    final Offset mid = Offset(
      (outerPt.dx + innerPt.dx) * 0.5,
      (outerPt.dy + innerPt.dy) * 0.5,
    );
    canvas.drawCircle(
      mid,
      6.2,
      Paint()
        ..color = paperColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      mid,
      6.2,
      Paint()
        ..color = outerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    _drawDiamondRosette(canvas, mid, 3.3);
  }

  void _drawDiamondRosette(Canvas canvas, Offset c, double r) {
    final Path p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r, c.dy)
      ..close();
    canvas.drawPath(p, Paint()..color = outerColor);
  }

  void _drawScallopedCartouche({
    required Canvas canvas,
    required Rect rect,
    required String text,
    required double fontSize,
  }) {
    final Path shape = _buildCartouchePath(rect);

    canvas.drawPath(
      shape.shift(const Offset(0, 1.0)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    canvas.drawPath(
      shape,
      Paint()
        ..color = frameFill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shape,
      Paint()
        ..color = outerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );

    final Path innerShape = _buildCartouchePath(rect.deflate(2.8));
    canvas.drawPath(
      innerShape,
      Paint()
        ..color = paperColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      innerShape,
      Paint()
        ..color = outerColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );

    _drawDiamondRosette(
        canvas, Offset(rect.left + 8.5, rect.center.dy), 2.3);
    _drawDiamondRosette(
        canvas, Offset(rect.right - 8.5, rect.center.dy), 2.3);

    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: inkColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: rect.width - 22);

    tp.paint(
      canvas,
      Offset(
        rect.center.dx - tp.width * 0.5,
        rect.center.dy - tp.height * 0.5,
      ),
    );
  }

  Path _buildCartouchePath(Rect r) {
    const double notch = 6.0;
    return Path()
      ..moveTo(r.left + notch, r.top)
      ..lineTo(r.right - notch, r.top)
      ..quadraticBezierTo(r.right - notch, r.top + notch, r.right, r.top + notch)
      ..lineTo(r.right, r.bottom - notch)
      ..quadraticBezierTo(
          r.right - notch, r.bottom - notch, r.right - notch, r.bottom)
      ..lineTo(r.left + notch, r.bottom)
      ..quadraticBezierTo(
          r.left + notch, r.bottom - notch, r.left, r.bottom - notch)
      ..lineTo(r.left, r.top + notch)
      ..quadraticBezierTo(r.left + notch, r.top + notch, r.left + notch, r.top)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _OrnateMushafFramePainter oldDelegate) =>
      oldDelegate.outerColor != outerColor ||
      oldDelegate.innerColor != innerColor ||
      oldDelegate.frameFill != frameFill ||
      oldDelegate.paperColor != paperColor ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.inkColor != inkColor ||
      oldDelegate.surahLabel != surahLabel ||
      oldDelegate.juzLabel != juzLabel ||
      oldDelegate.pageLabel != pageLabel ||
      oldDelegate.wirdRatio != wirdRatio;
}
