import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional sign-instruction layout matching the reference design:
/// title + subtitle, large hero circle, numbered step circles (2 or 3),
/// and a bottom tip/instruction card.
///
/// - Pass 1 additional image  → 2-step layout (default)
/// - Pass 2 additional images → 3-step layout
///
/// Step 1 always reuses [mainImage].
class SignStepsView extends StatelessWidget {
  const SignStepsView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mainImage,
    required this.additionalStepImages,
    required this.instruction,
    this.heroBackground = const Color(0xFFF8E4D8),
    this.stepBackground = const Color(0xFFF8E4D8),
  }) : assert(
          additionalStepImages.length >= 1 && additionalStepImages.length <= 2,
          'Provide 1 additional image for 2 steps, or 2 for 3 steps.',
        );

  final String title;
  final String subtitle;
  final ImageProvider mainImage;

  /// Images for steps after step 1.
  /// Length 1 → steps 1+2; length 2 → steps 1+2+3.
  final List<ImageProvider> additionalStepImages;

  final String instruction;
  final Color heroBackground;
  final Color stepBackground;

  static const Color _navy = Color(0xFF1B1B3A);
  static const Color _gray = Color(0xFF8D8FA3);
  static const Color _cardBg = Color(0xFFF7F7F9);
  static const Color _tipBg = Color(0xFFFFF0D6);

  int get _stepCount => additionalStepImages.length + 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final heroSize = (constraints.maxWidth * (wide ? 0.42 : 0.62))
            .clamp(180.0, wide ? 280.0 : 240.0);
        final stepSize = (constraints.maxWidth / (_stepCount + 1.4))
            .clamp(72.0, wide ? 110.0 : 96.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 12),
            child: Column(
              children: [
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: wide ? 36 : 30,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _gray,
                  ),
                ),
                SizedBox(height: wide ? 28 : 20),
                _HeroCircle(
                  size: heroSize,
                  image: mainImage,
                  background: heroBackground,
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                      duration: 500.ms,
                    ),
                SizedBox(height: wide ? 28 : 22),
                _StepRow(
                  stepSize: stepSize,
                  stepBackground: stepBackground,
                  images: [
                    mainImage,
                    ...additionalStepImages,
                  ],
                ),
                SizedBox(height: wide ? 28 : 22),
                _InstructionCard(instruction: instruction),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroCircle extends StatelessWidget {
  const _HeroCircle({
    required this.size,
    required this.image,
    required this.background,
  });

  final double size;
  final ImageProvider image;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: background.withValues(alpha: 0.55),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image(
        image: image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 40),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.images,
    required this.stepSize,
    required this.stepBackground,
  });

  final List<ImageProvider> images;
  final double stepSize;
  final Color stepBackground;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < images.length; i++) ...[
          if (i > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: SignStepsView._navy,
                size: stepSize * 0.28,
              ),
            ),
          ],
          _StepCircle(
            size: stepSize,
            image: images[i],
            stepNumber: i + 1,
            background: stepBackground,
          ),
        ],
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.size,
    required this.image,
    required this.stepNumber,
    required this.background,
  });

  final double size;
  final ImageProvider image;
  final int stepNumber;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final badge = (size * 0.28).clamp(22.0, 30.0);

    return SizedBox(
      width: size,
      height: size + badge * 0.45,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image(
              image: image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  '$stepNumber',
                  style: GoogleFonts.fredoka(
                    fontSize: size * 0.3,
                    color: SignStepsView._navy,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: badge,
              height: badge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SignStepsView._navy,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$stepNumber',
                style: GoogleFonts.nunito(
                  fontSize: badge * 0.45,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.instruction});

  final String instruction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: SignStepsView._cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: SignStepsView._tipBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFE6A817),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: GoogleFonts.nunito(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A4A5C),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
