import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/sign.dart';

class HandSignAnimation extends StatefulWidget {
  const HandSignAnimation({
    super.key,
    required this.gestureType,
    this.size = 160,
    this.leftHanded = false,
  });

  final HandGestureType gestureType;
  final double size;
  final bool leftHanded;

  @override
  State<HandSignAnimation> createState() => _HandSignAnimationState();
}

class _HandSignAnimationState extends State<HandSignAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _HandPainter(
            progress: _controller.value,
            gesture: widget.gestureType,
            leftHanded: widget.leftHanded,
          ),
        );
      },
    );
  }
}

class _HandPainter extends CustomPainter {
  _HandPainter({
    required this.progress,
    required this.gesture,
    required this.leftHanded,
  });

  final double progress;
  final HandGestureType gesture;
  final bool leftHanded;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final skin = const Color(0xFFFFDBAC);
    final outline = const Color(0xFFE8B896);

    canvas.save();
    if (leftHanded) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    switch (gesture) {
      case HandGestureType.fistBump:
        _drawFist(canvas, center, skin, outline, progress * 8);
      case HandGestureType.wave:
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(sin(progress * pi * 2) * 0.4);
        canvas.translate(-center.dx, -center.dy);
        _drawOpenHand(canvas, center, skin, outline);
        canvas.restore();
      case HandGestureType.point:
        _drawPointHand(canvas, center, skin, outline, progress);
      case HandGestureType.thumbsUp:
        _drawThumbsUp(canvas, center, skin, outline);
      case HandGestureType.hugMotion:
        _drawHug(canvas, center, skin, outline, progress);
      case HandGestureType.clap:
        _drawClap(canvas, center, skin, outline, progress);
      case HandGestureType.eatMotion:
        _drawEat(canvas, center, skin, outline, progress);
      case HandGestureType.drinkMotion:
        _drawDrink(canvas, center, skin, outline, progress);
      case HandGestureType.brushTeeth:
        _drawBrush(canvas, center, skin, outline, progress);
      case HandGestureType.crossArms:
        _drawCrossArms(canvas, center, skin, outline);
      default:
        _drawOpenClose(canvas, center, skin, outline, progress);
    }

    canvas.restore();
  }

  void _drawPalm(Canvas canvas, Offset c, Paint fill, Paint stroke, double w, double h) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: w, height: h),
      Radius.circular(w * 0.3),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, stroke);
  }

  void _drawFinger(Canvas canvas, Offset base, double angle, double len, Paint fill, Paint stroke) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -len / 2), width: 18, height: len),
      const Radius.circular(9),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, stroke);
    canvas.restore();
  }

  void _drawOpenHand(Canvas canvas, Offset c, Color skin, Color outline) {
    final fill = Paint()..color = skin;
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _drawPalm(canvas, c.translate(0, 20), fill, stroke, 70, 80);
    for (var i = 0; i < 4; i++) {
      _drawFinger(canvas, c.translate(-24 + i * 16.0, -10), -pi / 2 - 0.1 + i * 0.05, 45, fill, stroke);
    }
    _drawFinger(canvas, c.translate(-38, 5), -pi / 2 - 0.5, 35, fill, stroke);
  }

  void _drawFist(Canvas canvas, Offset c, Color skin, Color outline, double nod) {
    final fill = Paint()..color = skin;
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.save();
    canvas.translate(0, nod);
    _drawPalm(canvas, c, fill, stroke, 65, 70);
    for (var i = 0; i < 4; i++) {
      _drawFinger(canvas, c.translate(-20 + i * 14.0, -20), -pi / 2 + 0.3, 22, fill, stroke);
    }
    _drawFinger(canvas, c.translate(-32, -8), -pi / 2 + 0.2, 18, fill, stroke);
    canvas.restore();
  }

  void _drawPointHand(Canvas canvas, Offset c, Color skin, Color outline, double p) {
    final fill = Paint()..color = skin;
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _drawPalm(canvas, c.translate(0, 15), fill, stroke, 65, 75);
    _drawFinger(canvas, c.translate(0, -15), -pi / 2 - p * 0.3, 55, fill, stroke);
    for (var i = 0; i < 3; i++) {
      _drawFinger(canvas, c.translate(-12 + i * 12.0, 0), pi / 2 + 0.5, 25, fill, stroke);
    }
    _drawFinger(canvas, c.translate(-28, 8), pi / 2 + 0.3, 22, fill, stroke);
  }

  void _drawThumbsUp(Canvas canvas, Offset c, Color skin, Color outline) {
    final fill = Paint()..color = skin;
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _drawPalm(canvas, c.translate(0, 20), fill, stroke, 60, 65);
    _drawFinger(canvas, c.translate(0, -10), -pi / 2, 50, fill, stroke);
    for (var i = 0; i < 3; i++) {
      _drawFinger(canvas, c.translate(-10 + i * 10.0, 10), pi / 2 + 0.4, 20, fill, stroke);
    }
    _drawFinger(canvas, c.translate(-25, 15), pi / 2 + 0.2, 18, fill, stroke);
  }

  void _drawOpenClose(Canvas canvas, Offset c, Color skin, Color outline, double p) {
    final spread = 20 + p * 30;
    final fill = Paint()..color = skin;
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    _drawPalm(canvas, c, fill, stroke, 60 + p * 20, 70);
    _drawOpenHand(canvas, c.translate(-spread * (1 - p), 0), skin, outline);
    _drawOpenHand(canvas, c.translate(spread * (1 - p), 0), skin, outline);
  }

  void _drawHug(Canvas canvas, Offset c, Color skin, Color outline, double p) {
    final fill = Paint()..color = skin;
    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final squeeze = 30 - p * 15;
    _drawOpenHand(canvas, c.translate(-squeeze, 0), skin, outline);
    _drawOpenHand(canvas, c.translate(squeeze, 0), skin, outline);
    canvas.drawCircle(c, 8, fill);
    canvas.drawCircle(c, 8, stroke);
  }

  void _drawClap(Canvas canvas, Offset c, Color skin, Color outline, double p) {
    final gap = 40 - p * 35;
    _drawOpenHand(canvas, c.translate(-gap, 0), skin, outline);
    _drawOpenHand(canvas, c.translate(gap, 0), skin, outline);
  }

  void _drawEat(Canvas canvas, Offset c, Color skin, Color outline, double p) {
    _drawOpenHand(canvas, c.translate(-20, 10), skin, outline);
    final mouth = c.translate(30, -20 + p * 15);
    canvas.drawCircle(mouth, 12, Paint()..color = const Color(0xFFFFB4A2));
  }

  void _drawDrink(Canvas canvas, Offset c, Color skin, Color outline, double p) {
    _drawOpenHand(canvas, c.translate(-15, 0), skin, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(25, -10), width: 30, height: 40),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF7B8CDE),
    );
    canvas.save();
    canvas.translate(c.dx + 25, c.dy - 10);
    canvas.rotate(p * 0.5);
    canvas.restore();
  }

  void _drawBrush(Canvas canvas, Offset c, Color skin, Color outline, double p) {
    _drawOpenHand(canvas, c.translate(-25, 10), skin, outline);
    final brushX = c.dx + sin(p * pi * 2) * 15;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(brushX, c.dy - 20), width: 40, height: 12),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF98D4B0),
    );
  }

  void _drawCrossArms(Canvas canvas, Offset c, Color skin, Color outline) {
    _drawOpenHand(canvas, c.translate(-30, -10), skin, outline);
    _drawOpenHand(canvas, c.translate(30, 10), skin, outline);
  }

  @override
  bool shouldRepaint(covariant _HandPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.gesture != gesture;
}
