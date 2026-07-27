import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingParticles extends StatelessWidget {
  const FloatingParticles({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: List.generate(8, (i) {
          return Positioned(
            left: 20.0 + (i * 47) % 300,
            top: 100.0 + (i * 73) % 400,
            child: Text(
              ['🫧', '⭐', '✨', '💫'][i % 4],
              style: TextStyle(fontSize: 16 + (i % 3) * 4.0),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(
                  begin: 0,
                  end: -20 - (i % 3) * 8,
                  duration: (2 + i % 3).seconds,
                  curve: Curves.easeInOut,
                )
                .fade(begin: 0.3, end: 0.9),
          );
        }),
      ),
    );
  }
}

class MascotWidget extends StatelessWidget {
  const MascotWidget({super.key, this.size = 100});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD6BA), Color(0xFFFFB4A2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Eye(size: size * 0.12),
                  SizedBox(width: size * 0.15),
                  _Eye(size: size * 0.12),
                ],
              ),
              SizedBox(height: size * 0.05),
              Container(
                width: size * 0.2,
                height: size * 0.08,
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ],
          ),
          Positioned(
            right: size * 0.05,
            top: size * 0.25,
            child: Text('👋', style: TextStyle(fontSize: size * 0.25))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(begin: -0.2, end: 0.3, duration: 600.ms),
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          margin: EdgeInsets.only(bottom: size * 0.15),
          decoration: const BoxDecoration(
            color: Color(0xFF3D3D5C),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
