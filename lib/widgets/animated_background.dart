import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedSkyBackground extends StatefulWidget {
  const AnimatedSkyBackground({
    super.key,
    required this.child,
    this.isDark = false,
  });

  final Widget child;
  final bool isDark;

  @override
  State<AnimatedSkyBackground> createState() => _AnimatedSkyBackgroundState();
}

class _AnimatedSkyBackgroundState extends State<AnimatedSkyBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
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
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF2D2D44)]
                      : [const Color(0xFFB8E0FF), const Color(0xFFE8F4FD)],
                ),
              ),
            ),
            ...List.generate(3, (i) {
              final t = (_controller.value + i * 0.33) % 1.0;
              return Positioned(
                left: MediaQuery.sizeOf(context).width * (0.1 + i * 0.3) +
                    sin(t * pi * 2) * 20,
                top: 80 + i * 40 + cos(t * pi * 2) * 10,
                child: Opacity(
                  opacity: widget.isDark ? 0.15 : 0.7,
                  child: Icon(
                    Icons.cloud,
                    size: 60 + i * 20.0,
                    color: widget.isDark ? Colors.white24 : Colors.white,
                  ),
                ),
              );
            }),
            ...List.generate(5, (i) {
              final t = (_controller.value * 1.5 + i * 0.2) % 1.0;
              return Positioned(
                left: MediaQuery.sizeOf(context).width * t,
                top: 120 + sin(i + t * pi * 4) * 30,
                child: Opacity(
                  opacity: 0.4 + sin(t * pi) * 0.3,
                  child: Text(
                    i.isEven ? '⭐' : '✨',
                    style: TextStyle(fontSize: 12 + i * 2.0),
                  ),
                ),
              );
            }),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
