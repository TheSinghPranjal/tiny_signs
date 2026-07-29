import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/sign.dart';
import '../../data/repositories/sign_repository.dart';
import '../../providers/app_state.dart';
import '../../widgets/celebration_overlay.dart';
import '../../widgets/sign_steps_view.dart';

/// Lesson flow:
/// 1. Word reveal
/// 2. Sign steps (hero + numbered 2/3-step circles + instruction card)
/// 3. Practice ("I Did It!")
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.signId});

  final String signId;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _stepIndex = 0;
  bool _showCelebration = false;
  String _celebrationMessage = 'Great Job!';

  static const _steps = [
    LessonStep.word,
    LessonStep.signSteps,
    LessonStep.practice,
  ];

  static const Color _bgLavender = Color(0xFFF6F1FB);

  Sign get _sign => SignRepository.signById(widget.signId)!;

  List<Sign> get _categorySigns =>
      SignRepository.signsForCategory(_sign.categoryId);

  int get _signIndex =>
      _categorySigns.indexWhere((s) => s.id == widget.signId);

  void _nextStep() {
    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
      _hapticTick();
    } else {
      _completeLesson();
    }
  }

  void _hapticTick() {
    final appState = context.read<AppState>();
    if (appState.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void _completeLesson() {
    final appState = context.read<AppState>();
    appState.completeSign(_sign.id, _sign.categoryId);
    if (appState.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      _showCelebration = true;
      _celebrationMessage = _randomEncouragement();
    });
  }

  String _randomEncouragement() {
    const messages = [
      'Great Job!',
      "You're Amazing!",
      'Wonderful!',
      'Super Star!',
      'You Did It!',
    ];
    return messages[_signIndex % messages.length];
  }

  Sign? get _nextSign {
    if (_signIndex >= 0 && _signIndex < _categorySigns.length - 1) {
      return _categorySigns[_signIndex + 1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final step = _steps[_stepIndex];
    final isDark = appState.darkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.nightBottom : _bgLavender,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _LessonHeader(
                  sign: _sign,
                  stepIndex: _stepIndex,
                  totalSteps: _steps.length,
                  onBack: () => Navigator.pop(context),
                  onFinish: _completeLesson,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStepContent(step),
                  ),
                ),
                _LessonFooter(
                  step: step,
                  onNext: _nextStep,
                ),
              ],
            ),
          ),
          if (_showCelebration)
            CelebrationOverlay(
              message: _celebrationMessage,
              onDismiss: () {
                setState(() => _showCelebration = false);
                final next = _nextSign;
                if (next != null) {
                  Navigator.of(context).pushReplacement(
                    StorybookPageRoute(
                      page: LessonScreen(signId: next.id),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent(LessonStep step) {
    switch (step) {
      case LessonStep.word:
        return _WordSection(sign: _sign, key: const ValueKey('word'));
      case LessonStep.signSteps:
        return _SignStepsSection(sign: _sign, key: const ValueKey('steps'));
      case LessonStep.practice:
        return _PracticeSection(sign: _sign, key: const ValueKey('practice'));
    }
  }
}

/// Header: rounded white close button · star progress · green "finish" check.
class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.sign,
    required this.stepIndex,
    required this.totalSteps,
    required this.onBack,
    required this.onFinish,
  });

  final Sign sign;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onFinish;

  static const Color _navy = Color(0xFF211E4B);
  static const Color _green = Color(0xFF4CC97A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.close_rounded,
            iconColor: _navy,
            background: Colors.white,
            onTap: onBack,
          ),
          Expanded(
            child: ProgressStars(current: stepIndex + 1, total: totalSteps),
          ),
          // _RoundIconButton(
          //   icon: Icons.check_rounded,
          //   iconColor: Colors.white,
          //   background: _green,
          //   onTap: onFinish,
          // ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }
}

// word section

class _WordSection extends StatelessWidget {
  const _WordSection({super.key, required this.sign});

  final Sign sign;

  static const Color _navy = Color(0xFF211E4B);
  static const Color _pinkLight = Color(0xFFFFF5F8);
  static const Color _pinkMid = Color(0xFFFCE0E8);
  static const Color _pinkAccent = Color(0xFFF5A8BC);
  static const Color _frameBg = Color(0xFFFBE8EE);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = (constraints.maxWidth * 0.72).clamp(220.0, 300.0);

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _WordHeroCard(
                      size: imageSize,
                      imageAsset: sign.mainImageAsset,
                      fallbackEmoji: sign.emoji,
                      background: _frameBg,
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                      duration: 550.ms,
                    ),
                const SizedBox(height: 28),
                _WordBadge(
                      word: sign.word,
                      pinkLight: _pinkLight,
                      pinkMid: _pinkMid,
                      pinkAccent: _pinkAccent,
                      textColor: _navy,
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    sign.narration,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color: _navy.withValues(alpha: 0.78),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WordHeroCard extends StatelessWidget {
  const _WordHeroCard({
    required this.size,
    required this.imageAsset,
    required this.fallbackEmoji,
    required this.background,
  });

  final double size;
  final String imageAsset;
  final String fallbackEmoji;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ColoredBox(
          color: background,
          child: Image.asset(
            imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(fallbackEmoji, style: const TextStyle(fontSize: 96)),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordBadge extends StatelessWidget {
  const _WordBadge({
    required this.word,
    required this.pinkLight,
    required this.pinkMid,
    required this.pinkAccent,
    required this.textColor,
  });

  final String word;
  final Color pinkLight;
  final Color pinkMid;
  final Color pinkAccent;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _WordSparkles(color: pinkAccent),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [pinkLight, pinkMid],
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: pinkMid.withValues(alpha: 0.55),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            word.toUpperCase(),
            style: GoogleFonts.fredoka(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _WordSparkles(color: pinkAccent, flipped: true),
      ],
    );
  }
}

/// Three slanted pink dashes flanking the word pill.
class _WordSparkles extends StatelessWidget {
  const _WordSparkles({required this.color, this.flipped = false});

  final Color color;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double opacity) => Container(
          width: width,
          height: 3.5,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(4),
          ),
        );

    final bars = Column(
      crossAxisAlignment:
          flipped ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        bar(16, 1),
        bar(12, 0.75),
        bar(8, 0.5),
      ],
    );

    return Transform.rotate(
      angle: flipped ? -0.4 : 0.4,
      child: bars,
    );
  }
}

/// Hero circle + numbered steps (2 by default, 3 when stepThree is set)
/// + instruction tip card.
///
/// second screen signs
class _SignStepsSection extends StatelessWidget {
  const _SignStepsSection({super.key, required this.sign});

  final Sign sign;

  @override
  Widget build(BuildContext context) {
    final mainImage = AssetImage(sign.mainImageAsset);
    final additionalImages = <ImageProvider>[
      AssetImage(sign.stepTwoImageAsset),
      if (sign.stepThreeImageAsset != null)
        AssetImage(sign.stepThreeImageAsset!),
    ];

    return SignStepsView(
      title: sign.word,
      subtitle: sign.subtitleLabel,
      mainImage: mainImage,
      additionalStepImages: additionalImages,
      instruction: sign.instructionText,
    );
  }
}


// third screen practise
class _PracticeSection extends StatelessWidget {
  const _PracticeSection({super.key, required this.sign});

  final Sign sign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your turn!',
            style:
            GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Try making the "${sign.word}" sign',
            style: GoogleFonts.nunito(fontSize: 18),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8D5F2), Color(0xFFD4B8E8)],
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      sign.mainImageAsset,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Text(
                          sign.emoji, style: const TextStyle(fontSize: 72)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Watch, imitate, then tap "I Did It!"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary action button — gradient pill with a rocket accent, matching
/// the reference design.
class _LessonFooter extends StatelessWidget {
  const _LessonFooter({
    required this.step,
    required this.onNext,
  });

  final LessonStep step;
  final VoidCallback onNext;

  static const Color _mint = Color(0xFF6FCB9F);
  static const Color _mintDeep = Color(0xFF4CB587);
  static const Color _purple = Color(0xFF8073E8);
  static const Color _purpleDeep = Color(0xFF6C5CE7);

  @override
  Widget build(BuildContext context) {
    final isPractice = step == LessonStep.practice;
    final colors = isPractice ? [_mint, _mintDeep] : [_purple, _purpleDeep];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onNext,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    isPractice ? '⭐ I Did It!' : 'Next',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 14,
                    child: isPractice
                        ? const SizedBox.shrink()
                        : Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  if (!isPractice)
                    const Positioned(
                      right: -6,
                      bottom: -10,
                      child: Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white70,
                        size: 26,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}