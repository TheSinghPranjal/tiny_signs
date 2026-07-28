import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/sign.dart';
import '../../data/repositories/sign_repository.dart';
import '../../providers/app_state.dart';
import '../../widgets/celebration_overlay.dart';
import '../lesson/lesson_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  // ---- Colors matched to the reference design ------------------------------
  static const Color _bgPinkTop = Color(0xFFFDEEF3);
  static const Color _bgPinkBottom = Color(0xFFFBE0EA);
  static const Color _navy = Color(0xFF1B1B3A);
  static const Color _grayText = Color(0xFF8D8FA3);
  static const Color _pinkDark = Color(0xFFE3728F);
  static const Color _pinkTrack = Color(0xFFF6D6E0);
  static const Color _pinkBorder = Color(0xFFF6D6E0);
  static const Color _imageCircle = Color(0xFFF3C9D8);

  @override
  Widget build(BuildContext context) {
    final category = SignRepository.categoryById(categoryId)!;
    final signs = SignRepository.signsForCategory(categoryId);
    final appState = context.watch<AppState>();
    final completed = appState.completedCountForCategory(categoryId);
    final progress = signs.isEmpty ? 0.0 : completed / signs.length;
    final tint = AppColors.categoryGradients[
        category.gradientIndex % AppColors.categoryGradients.length];
    final bgTop = Color.lerp(_bgPinkTop, tint.first, 0.35)!;
    final bgBottom = Color.lerp(_bgPinkBottom, tint.last, 0.25)!;
    final accent = Color.lerp(_pinkDark, tint.last, 0.3)!;

    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 600;
    final artSize = isCompact ? (width * 0.36).clamp(120.0, 160.0) : 210.0;
    // Title row (~60) + art height + small bottom breathing room.
    // Previously a fixed 310 left a large empty pink band under the kid.
    final heroMaxHeight = isCompact ? (64 + artSize + 8) : (72 + artSize + 12);

    return Scaffold(
      backgroundColor: bgBottom,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeroHeaderDelegate(
                  categoryEmoji: category.emoji,
                  categoryName: category.name,
                  completed: completed,
                  total: signs.length,
                  description: category.description,
                  progress: progress,
                  accent: accent,
                  kidImage: AssetImage(category.heroImageAsset),
                  maxHeight: heroMaxHeight,
                  artSize: artSize,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: _SignsCard(
                    signs: signs,
                    accent: accent,
                    completedIds: appState.completedSigns,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White rounded card with all sign illustrations in a shared grid.
class _SignsCard extends StatelessWidget {
  const _SignsCard({
    required this.signs,
    required this.accent,
    required this.completedIds,
  });

  final List<Sign> signs;
  final Color accent;
  final Set<String> completedIds;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "You'll learn these signs",
                  style: GoogleFonts.fredoka(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: CategoryDetailScreen._navy,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 700 ? 6 : 4;
              // The circle+label vertical fit is now handled inside
              // _SignIllustrationTile via Expanded, so this ratio is just a
              // sensible starting point — it can no longer overflow.
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
                itemCount: signs.length,
                itemBuilder: (context, index) {
                  final sign = signs[index];
                  return _SignIllustrationTile(
                    sign: sign,
                    isCompleted: completedIds.contains(sign.id),
                    onTap: () {
                      Navigator.of(context).push(
                        StorybookPageRoute(
                          page: LessonScreen(signId: sign.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Circular pink-bordered sign illustration + label.
class _SignIllustrationTile extends StatelessWidget {
  const _SignIllustrationTile({
    required this.sign,
    required this.isCompleted,
    required this.onTap,
  });

  final Sign sign;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Never let AspectRatio overflow the cell — that was painting
                // square image bottoms outside the circle.
                final side = constraints.biggest.shortestSide;
                return Center(
                  child: SizedBox(
                    width: side,
                    height: side,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Circle border + clipped image
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CategoryDetailScreen._pinkBorder,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.5),
                              child: ClipOval(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Transform.scale(
                                  // Assets are circular art on a black square —
                                  // zoom past the black ring so only the art fills.
                                  scale: 1.12,
                                  child: Image.asset(
                                    sign.mainImageAsset,
                                    fit: BoxFit.cover,
                                    width: side,
                                    height: side,
                                    alignment: Alignment.center,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return ColoredBox(
                                        color:
                                            CategoryDetailScreen._imageCircle,
                                        child: Center(
                                          child: Text(
                                            sign.emoji,
                                            style: TextStyle(
                                              fontSize: side * 0.4,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFF98D4B0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sign.word,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: CategoryDetailScreen._navy,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Collapsing hero header
// -----------------------------------------------------------------------------
class _HeroHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeroHeaderDelegate({
    required this.categoryEmoji,
    required this.categoryName,
    required this.completed,
    required this.total,
    required this.description,
    required this.progress,
    required this.accent,
    required this.maxHeight,
    required this.artSize,
    this.kidImage,
  });

  final String categoryEmoji;
  final String categoryName;
  final int completed;
  final int total;
  final String description;
  final double progress;
  final Color accent;
  final double maxHeight;
  final double artSize;
  final ImageProvider? kidImage;

  static const double _minHeight = 88;

  static const Color _navy = CategoryDetailScreen._navy;
  static const Color _grayText = CategoryDetailScreen._grayText;
  static const Color _pinkTrack = CategoryDetailScreen._pinkTrack;

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => _minHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final height = (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);
    final range = maxExtent - minExtent;
    final t = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    final fadeOpacity = (1 - t * 1.35).clamp(0.0, 1.0);

    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 600;

    // Keep kid fully on-screen and reserve its width for the text column.
    final artRight = isCompact ? 8.0 : 16.0;
    final textRightPad = artSize + artRight + 12;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: height,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Bottom-aligned so no empty pink band sits under the art.
            Positioned(
              right: artRight,
              bottom: 4,
              child: Opacity(
                opacity: fadeOpacity,
                child: _KidImageArt(
                  kidImage: kidImage,
                  emoji: categoryEmoji,
                  size: artSize,
                ),
              ),
            ),
            if (fadeOpacity > 0)
              Positioned(
                top: isCompact ? 72 : 80,
                left: 20,
                right: textRightPad,
                bottom: 12,
                child: Opacity(
                  opacity: fadeOpacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        description,
                        maxLines: isCompact ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fredoka(
                          fontSize: isCompact ? 16 : 22,
                          fontWeight: FontWeight.w600,
                          color: _navy,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: isCompact ? 12 : 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 9,
                                backgroundColor: _pinkTrack,
                                valueColor: AlwaysStoppedAnimation(accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                decoration: BoxDecoration(
                  color: t > 0.55
                      ? Color.lerp(
                          Colors.transparent,
                          const Color(0xFFFDEEF3).withValues(alpha: 0.96),
                          ((t - 0.55) / 0.45).clamp(0.0, 1.0),
                        )
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: _navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(categoryEmoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                          Text(
                            '$completed/$total learned',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HeroHeaderDelegate oldDelegate) {
    return oldDelegate.categoryEmoji != categoryEmoji ||
        oldDelegate.categoryName != categoryName ||
        oldDelegate.completed != completed ||
        oldDelegate.total != total ||
        oldDelegate.description != description ||
        oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.kidImage != kidImage ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.artSize != artSize;
  }
}

class _KidImageArt extends StatelessWidget {
  const _KidImageArt({
    this.kidImage,
    required this.emoji,
    required this.size,
  });

  final ImageProvider? kidImage;
  final String emoji;
  final double size;

  static const Color _imageCircle = CategoryDetailScreen._imageCircle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                color: _imageCircle.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 22,
            child: Text('✨', style: TextStyle(fontSize: size * 0.09)),
          ),
          Positioned(
            left: 0,
            top: size * 0.32,
            child: Text('✦', style: TextStyle(fontSize: size * 0.07)),
          ),
          Positioned.fill(
            child: kidImage != null
                ? Image(image: kidImage!, fit: BoxFit.contain)
                : Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: size * 0.38),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
