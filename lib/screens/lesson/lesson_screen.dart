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
import '../../widgets/hand_sign_animation.dart';
import 'practice_quiz_screen.dart';

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
    LessonStep.illustration,
    LessonStep.animation,
    LessonStep.practice,
  ];

  Sign get _sign => SignRepository.signById(widget.signId)!;

  List<Sign> get _categorySigns =>
      SignRepository.signsForCategory(_sign.categoryId);

  int get _signIndex =>
      _categorySigns.indexWhere((s) => s.id == widget.signId);

  void _nextStep() {
    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
      _speakEncouragement();
    } else {
      _completeLesson();
    }
  }

  void _speakEncouragement() {
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
      backgroundColor: isDark ? AppColors.nightBottom : AppColors.skyBottom,
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
                    child: _buildStepContent(step, appState),
                  ),
                ),
                _LessonFooter(
                  step: step,
                  onListen: () => _speakEncouragement(),
                  onNext: _nextStep,
                  onPracticeComplete: () {
                    Navigator.of(context).pushReplacement(
                      StorybookPageRoute(
                        page: PracticeQuizScreen(signId: widget.signId),
                      ),
                    );
                  },
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

  Widget _buildStepContent(LessonStep step, AppState appState) {
    switch (step) {
      case LessonStep.word:
        return _WordSection(sign: _sign, key: const ValueKey('word'));
      case LessonStep.illustration:
        return _IllustrationSection(sign: _sign, key: const ValueKey('illus'));
      case LessonStep.animation:
        return _AnimationSection(
          sign: _sign,
          leftHanded: appState.leftHandedMode,
          key: const ValueKey('anim'),
        );
      case LessonStep.practice:
        return _PracticeSection(sign: _sign, key: const ValueKey('practice'));
    }
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.sign,
    required this.stepIndex,
    required this.totalSteps,
    required this.onBack,
  });

  final Sign sign;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: ProgressStars(current: stepIndex + 1, total: totalSteps),
          ),
          Text(sign.emoji, style: const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}

class _WordSection extends StatelessWidget {
  const _WordSection({super.key, required this.sign});

  final Sign sign;

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.categoryGradients[0];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: gradient.last.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Text(
              sign.word.toUpperCase(),
              style: GoogleFonts.fredoka(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 24),
          Text(
            sign.narration,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _IllustrationSection extends StatelessWidget {
  const _IllustrationSection({super.key, required this.sign});

  final Sign sign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4EDFF), Color(0xFFE8F4FD)],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sign.emoji, style: const TextStyle(fontSize: 100))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -8, duration: 1200.ms),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    sign.illustrationDescription,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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

class _AnimationSection extends StatelessWidget {
  const _AnimationSection({
    super.key,
    required this.sign,
    required this.leftHanded,
  });

  final Sign sign;
  final bool leftHanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Watch the sign',
            style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            sign.signDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 16),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: HandSignAnimation(
              gestureType: sign.handGesture,
              size: 180,
              leftHanded: leftHanded,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '👐 Animated Hand',
            style: GoogleFonts.nunito(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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
            style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w700),
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
                Text(sign.emoji, style: const TextStyle(fontSize: 72)),
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

class _LessonFooter extends StatelessWidget {
  const _LessonFooter({
    required this.step,
    required this.onListen,
    required this.onNext,
    required this.onPracticeComplete,
  });

  final LessonStep step;
  final VoidCallback onListen;
  final VoidCallback onNext;
  final VoidCallback onPracticeComplete;

  @override
  Widget build(BuildContext context) {
    final isPractice = step == LessonStep.practice;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onListen,
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Listen'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onListen,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Replay'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isPractice ? onNext : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPractice
                    ? const Color(0xFF98D4B0)
                    : const Color(0xFF7B8CDE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isPractice ? '⭐ I Did It!' : 'Next ➡',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
