import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/repositories/sign_repository.dart';
import '../../providers/app_state.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/floating_bottom_nav.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.darkMode;
    final totalSigns = SignRepository.signs.length;
    final learned = appState.completedSigns.length;

    return AnimatedSkyBackground(
      isDark: isDark,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep learning — you\'re doing great!',
                      style: GoogleFonts.nunito(
                        color: isDark
                            ? AppColors.nightText.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _ProgressCard(
                      learned: learned,
                      total: totalSigns,
                      stars: appState.totalStars,
                      streak: appState.dailyStreak,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Achievements',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, kBottomNavClearance),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final badge = _badges[index];
                    final earned = appState.earnedBadges.contains(badge.id);
                    return _BadgeCard(
                      emoji: badge.emoji,
                      title: badge.title,
                      description: badge.description,
                      earned: earned,
                    );
                  },
                  childCount: _badges.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.learned,
    required this.total,
    required this.stars,
    required this.streak,
  });

  final int learned;
  final int total;
  final int stars;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8D5F2), Color(0xFFD4B8E8)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4B8E8).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('🌟', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            '$learned / $total signs learned',
            style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? learned / total : 0,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.5),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7B8CDE)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(emoji: '⭐', label: '$stars stars'),
              _StatChip(emoji: '🔥', label: '$streak day streak'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.earned,
  });

  final String emoji;
  final String title;
  final String description;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: earned ? Colors.white : Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            earned ? emoji : '🔒',
            style: TextStyle(fontSize: 40, color: earned ? null : Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: earned ? AppColors.textPrimary : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: earned ? AppColors.textSecondary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  const _Badge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
}

const _badges = [
  _Badge(
    id: 'first_sign',
    emoji: '🌱',
    title: 'First Sign',
    description: 'Learn your very first sign',
  ),
  _Badge(
    id: 'ten_signs',
    emoji: '🌟',
    title: 'Rising Star',
    description: 'Learn 10 signs',
  ),
  _Badge(
    id: 'super_signer',
    emoji: '🏆',
    title: 'Super Signer',
    description: 'Learn 50 signs',
  ),
  _Badge(
    id: 'category_beginner',
    emoji: '👶',
    title: 'Beginner Pro',
    description: 'Complete Beginner category',
  ),
  _Badge(
    id: 'category_food',
    emoji: '🍎',
    title: 'Foodie',
    description: 'Complete Food category',
  ),
  _Badge(
    id: 'category_family',
    emoji: '👨‍👩‍👧',
    title: 'Family Star',
    description: 'Complete Family category',
  ),
  _Badge(
    id: 'streak_7',
    emoji: '🔥',
    title: 'Week Warrior',
    description: '7 day learning streak',
  ),
  _Badge(
    id: 'perfect_practice',
    emoji: '💯',
    title: 'Perfect Practice',
    description: 'Get 5 quiz answers correct',
  ),
];
