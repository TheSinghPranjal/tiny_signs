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

class PracticeQuizScreen extends StatefulWidget {
  const PracticeQuizScreen({super.key, required this.signId});

  final String signId;

  @override
  State<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<PracticeQuizScreen> {
  late final Sign _correctSign;
  late final List<Sign> _options;
  int? _selectedIndex;
  bool _answered = false;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _correctSign = SignRepository.signById(widget.signId)!;
    final categorySigns = SignRepository.signsForCategory(_correctSign.categoryId);
    final others = categorySigns.where((s) => s.id != widget.signId).toList()
      ..shuffle();
    _options = [_correctSign, ...others.take(3)]..shuffle();
  }

  void _selectOption(int index) {
    if (_answered) return;

    final isCorrect = _options[index].id == _correctSign.id;
    final appState = context.read<AppState>();

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    if (appState.vibrationEnabled) {
      HapticFeedback.mediumImpact();
    }

    if (isCorrect) {
      appState.completeSign(_correctSign.id, _correctSign.categoryId);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showCelebration = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: appState.darkMode
          ? AppColors.nightBottom
          : AppColors.skyBottom,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'Practice Mode',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_up_rounded,
                            color: Color(0xFF7B8CDE), size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Can you show me '${_correctSign.word}'?",
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        return _QuizCard(
                          sign: _options[index],
                          isSelected: _selectedIndex == index,
                          isAnswered: _answered,
                          isCorrect: _options[index].id == _correctSign.id,
                          leftHanded: appState.leftHandedMode,
                          onTap: () => _selectOption(index),
                        );
                      },
                    ),
                  ),
                  if (_answered && _selectedIndex != null &&
                      _options[_selectedIndex!].id != _correctSign.id)
                    Text(
                      'Try again! You can do it! 💪',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        color: AppColors.coral,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shake(hz: 2, rotation: 0.02),
                ],
              ),
            ),
          ),
          if (_showCelebration)
            CelebrationOverlay(
              message: "Let's Learn Another!",
              onDismiss: () {
                setState(() => _showCelebration = false);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.sign,
    required this.isSelected,
    required this.isAnswered,
    required this.isCorrect,
    required this.leftHanded,
    required this.onTap,
  });

  final Sign sign;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrect;
  final bool leftHanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    if (isAnswered && isSelected) {
      borderColor = isCorrect ? AppColors.successGreen : AppColors.coral;
    }

    Widget card = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HandSignAnimation(
              gestureType: sign.handGesture,
              size: 80,
              leftHanded: leftHanded,
            ),
            const SizedBox(height: 8),
            Text(
              sign.word,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    if (isAnswered && isSelected && !isCorrect) {
      card = card.animate().shake(hz: 3, rotation: 0.03);
    }

    if (isAnswered && isSelected && isCorrect) {
      card = card
          .animate()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 300.ms,
          );
    }

    return card;
  }
}
