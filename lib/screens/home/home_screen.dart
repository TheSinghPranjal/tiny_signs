import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/sign_repository.dart';
import '../../providers/app_state.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/category_card.dart';
import '../../widgets/celebration_overlay.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../../widgets/mascot_widget.dart';
import '../categories/category_detail_screen.dart';
import '../lesson/lesson_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.darkMode;

    return AnimatedSkyBackground(
      isDark: isDark,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tiny Signs',
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                              Text(
                                'Learn to communicate! 👋',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  color: isDark
                                      ? AppColors.nightText.withValues(alpha: 0.7)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const MascotWidget(size: 72),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _StreakCard(
                      streak: appState.dailyStreak,
                      stars: appState.totalStars,
                    ),
                    const SizedBox(height: 20),
                    _StartLearningButton(
                      onPressed: () {
                        final firstIncomplete = SignRepository.signs.firstWhere(
                          (s) => !appState.isSignCompleted(s.id),
                          orElse: () => SignRepository.signs.first,
                        );
                        Navigator.of(context).push(
                          StorybookPageRoute(
                            page: LessonScreen(signId: firstIncomplete.id),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pick a topic to explore',
                      style: GoogleFonts.nunito(
                        color: isDark
                            ? AppColors.nightText.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, kBottomNavClearance),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = SignRepository.categories[index];
                    final signs = SignRepository.signsForCategory(category.id);
                    final completed =
                        appState.completedCountForCategory(category.id);
                    final progress =
                        appState.progressForCategory(category.id);
                    final tint = AppColors.categoryGradients[
                        category.gradientIndex %
                            AppColors.categoryGradients.length][1];
                    final previewSigns = signs.take(4).toList();
                    final bubbleColors = [
                      const Color(0xFF5B7FE0),
                      const Color(0xFFF4A261),
                      const Color(0xFF7BC67E),
                      const Color(0xFFE3728F),
                    ];

                    void openCategory() {
                      Navigator.of(context).push(
                        StorybookPageRoute(
                          page: CategoryDetailScreen(categoryId: category.id),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CategoryCard(
                        title: category.name,
                        description: category.description,
                        completedCount: completed,
                        totalCount: signs.length,
                        progress: progress,
                        badgeEmoji: category.emoji,
                        panelEmoji: category.emoji,
                        kidImage: AssetImage(category.heroImageAsset),
                        tintColor: tint,
                        onTap: openCategory,
                        onContinue: openCategory,
                        signPreviews: [
                          for (var i = 0; i < previewSigns.length; i++)
                            SignPreviewItem(
                              label: previewSigns[i].word,
                              emoji: previewSigns[i].emoji,
                              imageProvider:
                                  AssetImage(previewSigns[i].imageAsset),
                              backgroundColor:
                                  bubbleColors[i % bubbleColors.length]
                                      .withValues(alpha: 0.18),
                            ),
                          if (signs.length > 4)
                            const SignPreviewItem(label: '', isMore: true),
                        ],
                      ),
                    );
                  },
                  childCount: SignRepository.categories.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak, required this.stars});

  final int streak;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3D3D5C), const Color(0xFF4A4A6A)]
              : [const Color(0xFFFFF3C4), const Color(0xFFFFE082)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔥 $streak day streak!',
                style: GoogleFonts.fredoka(fontSize: 18),
              ),
              Text(
                '$stars stars earned',
                style: GoogleFonts.nunito(fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          ...List.generate(
            streak.clamp(0, 3),
            (_) => const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text('⭐', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }
}

class _StartLearningButton extends StatelessWidget {
  const _StartLearningButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B8CDE),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 4,
          shadowColor: const Color(0xFF7B8CDE).withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              'Start Learning',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 1500.ms,
        );
  }
}
