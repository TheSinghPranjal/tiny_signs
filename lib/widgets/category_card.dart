import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';

/// One circular "sign" preview bubble (Hello / Thank You / Please / Yes / •••)
class SignPreviewItem {
  const SignPreviewItem({
    required this.label,
    this.emoji,
    this.imageProvider,
    this.backgroundColor,
    this.isMore = false,
  });

  /// Label shown under the bubble (e.g. "Hello"). Ignored if [isMore] is true.
  final String label;

  /// Emoji fallback when there is no photo yet.
  final String? emoji;

  /// Photo/illustration for the sign. If null, emoji or [backgroundColor] shows.
  final ImageProvider? imageProvider;

  /// Fallback bubble color when there's no image yet.
  final Color? backgroundColor;

  /// If true, renders as the trailing "•••" (more) bubble with no label.
  final bool isMore;
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
    required this.signPreviews,
    required this.onContinue,
    this.kidImage,
    this.badgeEmoji = '👶',
    this.panelEmoji,
    this.tintColor,
    this.onTap,
  });

  final String title;
  final String description;
  final int completedCount;
  final int totalCount;

  /// 0.0 - 1.0
  final double progress;

  final List<SignPreviewItem> signPreviews;
  final VoidCallback onContinue;

  /// Photo for the left panel (space for the kid image).
  final ImageProvider? kidImage;

  /// Small circular badge emoji overlapping the top-left of the photo.
  final String badgeEmoji;

  /// Large emoji shown in the left panel when [kidImage] is null.
  final String? panelEmoji;

  /// Optional tint that softens the card toward a category color.
  final Color? tintColor;

  final VoidCallback? onTap;

  // ---- Colors picked to match the reference design -----------------------
  static const Color _bgPink = Color(0xFFFDEDF3);
  static const Color _imageBg = Color(0xFFF6D9E3);
  static const Color _navy = Color(0xFF191B3A);
  static const Color _grayText = Color(0xFF8D8FA3);
  static const Color _pinkPillBg = Color(0xFFF8D6E1);
  static const Color _pinkDark = Color(0xFFE3728F);
  static const Color _pinkDarker = Color(0xFFDE6488);
  static const Color _trackBg = Color(0xFFF6D6E0);

  @override
  Widget build(BuildContext context) {
    final tint = tintColor ?? _pinkDark;
    final cardBg = Color.lerp(_bgPink, tint, 0.08)!;
    final imageBg = Color.lerp(_imageBg, tint, 0.18)!;
    final accent = Color.lerp(_pinkDark, tint, 0.35)!;
    final accentDark = Color.lerp(_pinkDarker, tint, 0.25)!;
    final pillBg = Color.lerp(_pinkPillBg, tint, 0.12)!;
    final trackBg = Color.lerp(_trackBg, tint, 0.08)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePanel(imageBg: imageBg),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContent(
                  accent: accent,
                  accentDark: accentDark,
                  pillBg: pillBg,
                  trackBg: trackBg,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  // -- Left: space for the kid image + small badge icon --------------------
  Widget _buildImagePanel({required Color imageBg}) {
    return Container(
      width: 118,
      constraints: const BoxConstraints(minHeight: 168),
      decoration: BoxDecoration(
        color: imageBg,
        borderRadius: BorderRadius.circular(22),
        image: kidImage != null
            ? DecorationImage(image: kidImage!, fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        children: [
          if (kidImage == null) ...[
            Positioned(
              top: 36,
              right: 14,
              child: Text(
                '✨',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
            Positioned(
              bottom: 28,
              left: 12,
              child: Text(
                '⭐',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber.withValues(alpha: 0.55),
                ),
              ),
            ),
            Center(
              child: Text(
                panelEmoji ?? badgeEmoji,
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ],
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(badgeEmoji, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Right: title/count, subtitle, sign bubbles, progress + button -------
  Widget _buildContent({
    required Color accent,
    required Color accentDark,
    required Color pillBg,
    required Color trackBg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _grayText,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$completedCount/$totalCount',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: accentDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              for (int i = 0; i < signPreviews.length; i++) ...[
                if (i != 0) const SizedBox(width: 10),
                _buildSignBubble(signPreviews[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 9,
                        backgroundColor: trackBg,
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: accentDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                minimumSize: const Size(0, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: accent.withValues(alpha: 0.35),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Continue',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignBubble(SignPreviewItem item) {
    if (item.isMore) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '•••',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: _grayText,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.backgroundColor ?? const Color(0xFFEAF0FF),
            border: Border.all(color: Colors.white, width: 2),
            image: item.imageProvider != null
                ? DecorationImage(
                    image: item.imageProvider!,
                    fit: BoxFit.cover,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: item.imageProvider == null
              ? Center(
                  child: Text(
                    item.emoji ?? '✨',
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 52,
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
        ),
      ],
    );
  }
}

class SignLessonCard extends StatelessWidget {
  const SignLessonCard({
    super.key,
    required this.word,
    required this.emoji,
    required this.isCompleted,
    required this.onTap,
  });

  final String word;
  final String emoji;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.nightCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 48)),
                if (isCompleted)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text('⭐', style: TextStyle(fontSize: 16)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              word,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
