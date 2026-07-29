import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

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
    this.videoAsset,
    this.heroBackground = const Color(0xFFFBE1E8),
    this.stepBackground = const Color(0xFFFBE1E8),
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

  /// Optional asset path for a looping demo video in the hero circle.
  final String? videoAsset;

  final Color heroBackground;
  final Color stepBackground;

  // ─── Palette ──────────────────────────────────────────────────────────
  static const Color _navy = Color(0xFF211E4B);
  static const Color _gray = Color(0xFF9A96B8);
  static const Color _purple = Color(0xFF8073E8);
  static const Color _purpleDeep = Color(0xFF6C5CE7);
  static const Color _lilac = Color(0xFFC9BEF0);
  static const Color _cardBg = Colors.white;
  static const Color _tipBg = Color(0xFFFCEFD3);
  static const Color _tipIconBg = Color(0xFFFFE3A3);
  static const Color _tipIconColor = Color(0xFFE6A817);

  int get _stepCount => additionalStepImages.length + 1;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final heroSize = (constraints.maxWidth * (wide ? 0.42 : 0.6)).clamp(
          180.0,
          wide ? 280.0 : 232.0,
        );
        final stepSize = (constraints.maxWidth / (_stepCount + 1.4)).clamp(
          72.0,
          wide ? 110.0 : 96.0,
        );

        return Stack(
          children: [
            // Soft decorative background — stars, sparkles, dots.
            Positioned.fill(child: IgnorePointer(child: _FloatingDecor())),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 12,
                ),
                child: Column(
                  children: [
                    _TitleWithAccents(title: title, wide: wide),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _gray,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: wide ? 30 : 22),
                    _HeroCircle(
                          size: heroSize,
                          image: mainImage,
                          background: heroBackground,
                          videoAsset: videoAsset,
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                          duration: 550.ms,
                        ),
                    SizedBox(height: wide ? 30 : 24),
                    const _SectionPill(label: 'How to do it'),
                    const SizedBox(height: 14),
                    _StepRow(
                      stepSize: stepSize,
                      stepBackground: stepBackground,
                      images: [mainImage, ...additionalStepImages],
                    ),
                    SizedBox(height: wide ? 26 : 20),
                    _InstructionCard(instruction: instruction),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Title flanked by small decorative "swoosh" accents, like the reference.
class _TitleWithAccents extends StatelessWidget {
  const _TitleWithAccents({required this.title, required this.wide});

  final String title;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title.toUpperCase(),
      textAlign: TextAlign.center,
      style: GoogleFonts.fredoka(
        fontSize: wide ? 38 : 32,
        fontWeight: FontWeight.w700,
        color: SignStepsView._navy,
        letterSpacing: 1.2,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Swoosh(),
        const SizedBox(width: 10),
        Flexible(child: titleText),
        const SizedBox(width: 10),
        const _Swoosh(flipped: true),
      ],
    );
  }
}

class _Swoosh extends StatelessWidget {
  const _Swoosh({this.flipped = false});

  final bool flipped;

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double opacity) => Container(
      width: width,
      height: 3.5,
      margin: const EdgeInsets.symmetric(vertical: 1.5),
      decoration: BoxDecoration(
        color: SignStepsView._lilac.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(4),
      ),
    );

    final bars = Column(
      crossAxisAlignment: flipped
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [bar(14, 1), bar(10, 0.7), bar(6, 0.45)],
    );

    return Transform.rotate(angle: flipped ? -0.35 : 0.35, child: bars);
  }
}

/// Small rounded pill used above the step row ("How to do it").
class _SectionPill extends StatelessWidget {
  const _SectionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SignStepsView._purple, SignStepsView._purpleDeep],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: SignStepsView._purpleDeep.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _HeroCircle extends StatefulWidget {
  const _HeroCircle({
    required this.size,
    required this.image,
    required this.background,
    this.videoAsset,
  });

  final double size;
  final ImageProvider image;
  final Color background;
  final String? videoAsset;

  @override
  State<_HeroCircle> createState() => _HeroCircleState();
}

class _HeroCircleState extends State<_HeroCircle> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _playing = false;

  bool get _hasVideo => widget.videoAsset != null;

  @override
  void initState() {
    super.initState();
    _prepareVideo();
  }

  @override
  void didUpdateWidget(covariant _HeroCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoAsset != widget.videoAsset) {
      _disposeController();
      _prepareVideo();
    }
  }

  Future<void> _prepareVideo() async {
    final asset = widget.videoAsset;
    if (asset == null) return;

    final controller = VideoPlayerController.asset(asset);
    try {
      await controller.initialize();
      await controller.setLooping(true);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onVideoTick);
      setState(() {
        _controller = controller;
        _ready = true;
      });
    } catch (_) {
      await controller.dispose();
    }
  }

  void _onVideoTick() {
    final controller = _controller;
    if (controller == null || !mounted) return;
    final isPlaying = controller.value.isPlaying;
    if (isPlaying != _playing) {
      setState(() => _playing = isPlaying);
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !_ready) return;

    if (controller.value.isPlaying) {
      await controller.pause();
      await controller.seekTo(Duration.zero);
      if (mounted) setState(() => _playing = false);
    } else {
      await controller.play();
      if (mounted) setState(() => _playing = true);
    }
  }

  void _disposeController() {
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    _controller = null;
    _ready = false;
    _playing = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final badgeSize = (size * 0.24).clamp(40.0, 56.0);
    final showPlayBadge = _hasVideo && _ready;

    return SizedBox(
      width: size + 12,
      height: size + 12,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SignStepsView._purple.withValues(alpha: 0.22),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.background,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildMedia(),
              ),
            ),
          ),
          // Sparkle accents around the hero circle.
          Positioned(
            top: 4,
            left: 8,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: SignStepsView._lilac.withValues(alpha: 0.9),
            ),
          ),
          Positioned(
            top: 22,
            right: -2,
            child: Icon(
              Icons.circle,
              size: 8,
              color: SignStepsView._purple.withValues(alpha: 0.5),
            ),
          ),
          if (showPlayBadge)
            Positioned(
              bottom: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _togglePlayback,
                  child: Container(
                    width: badgeSize,
                    height: badgeSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          SignStepsView._purple,
                          SignStepsView._purpleDeep,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: SignStepsView._purpleDeep.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: badgeSize * 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    final controller = _controller;
    if (_playing && controller != null && controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }

    return Image(
      image: widget.image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 40),
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: stepSize * 0.34,
                height: stepSize * 0.34,
                decoration: BoxDecoration(
                  color: SignStepsView._lilac.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: SignStepsView._purpleDeep,
                  size: stepSize * 0.22,
                ),
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
    final badge = (size * 0.3).clamp(24.0, 32.0);

    return SizedBox(
      width: size + 6,
      height: size + badge * 0.55,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SignStepsView._purple.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
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
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: badge,
              height: badge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SignStepsView._purple, SignStepsView._purpleDeep],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 5,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
      decoration: BoxDecoration(
        color: SignStepsView._tipBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: SignStepsView._tipIconColor.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: SignStepsView._tipIconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: SignStepsView._tipIconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SignStepsView._navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  instruction,
                  style: GoogleFonts.nunito(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A4A5C),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A handful of soft, fixed-position decorative shapes (stars, dots,
/// sparkles) scattered behind the content, echoing the reference design.
/// Positions are expressed as fractional offsets so they scale with the
/// available space.
class _FloatingDecor extends StatelessWidget {
  const _FloatingDecor();

  static const List<_DecorSpec> _specs = [
    _DecorSpec(
      dx: 0.06,
      dy: 0.10,
      icon: Icons.star_rounded,
      size: 20,
      color: Color(0xFFFFD166),
      opacity: 0.9,
    ),
    _DecorSpec(
      dx: 0.90,
      dy: 0.06,
      icon: Icons.circle,
      size: 10,
      color: SignStepsView._purple,
      opacity: 0.35,
    ),
    _DecorSpec(
      dx: 0.10,
      dy: 0.42,
      icon: Icons.auto_awesome,
      size: 16,
      color: Color(0xFFF4B6C2),
      opacity: 0.8,
    ),
    _DecorSpec(
      dx: 0.92,
      dy: 0.34,
      icon: Icons.circle_outlined,
      size: 18,
      color: SignStepsView._purple,
      opacity: 0.45,
    ),
    _DecorSpec(
      dx: 0.08,
      dy: 0.62,
      icon: Icons.auto_awesome,
      size: 12,
      color: Color(0xFFF4B6C2),
      opacity: 0.7,
    ),
    _DecorSpec(
      dx: 0.94,
      dy: 0.58,
      icon: Icons.auto_awesome,
      size: 14,
      color: SignStepsView._lilac,
      opacity: 0.9,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 700.0;
        return Stack(
          children: [
            for (final spec in _specs)
              Positioned(
                left: spec.dx * w,
                top: spec.dy * h,
                child: Opacity(
                  opacity: spec.opacity,
                  child: Icon(spec.icon, size: spec.size, color: spec.color),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DecorSpec {
  const _DecorSpec({
    required this.dx,
    required this.dy,
    required this.icon,
    required this.size,
    required this.color,
    this.opacity = 1,
  });

  final double dx;
  final double dy;
  final IconData icon;
  final double size;
  final Color color;
  final double opacity;
}
