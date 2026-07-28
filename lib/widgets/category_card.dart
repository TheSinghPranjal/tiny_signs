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

  /// Tablet / landscape keeps the wide storybook layout.
  static const double _wideBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final tint = tintColor ?? _pinkDark;
    final colors = _CardColors(
      cardBg: Color.lerp(_bgPink, tint, 0.08)!,
      imageBg: Color.lerp(_imageBg, tint, 0.18)!,
      accent: Color.lerp(_pinkDark, tint, 0.35)!,
      accentDark: Color.lerp(_pinkDarker, tint, 0.25)!,
      pillBg: Color.lerp(_pinkPillBg, tint, 0.12)!,
      trackBg: Color.lerp(_trackBg, tint, 0.08)!,
    );

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideBreakpoint;
          return Container(
            padding: EdgeInsets.all(isWide ? 16 : 14),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: isWide
                ? _WideLayout(
                    colors: colors,
                    title: title,
                    description: description,
                    completedCount: completedCount,
                    totalCount: totalCount,
                    progress: progress,
                    signPreviews: signPreviews,
                    onContinue: onContinue,
                    kidImage: kidImage,
                    badgeEmoji: badgeEmoji,
                    panelEmoji: panelEmoji,
                  )
                : _CompactLayout(
                    colors: colors,
                    title: title,
                    description: description,
                    completedCount: completedCount,
                    totalCount: totalCount,
                    progress: progress,
                    signPreviews: signPreviews,
                    onContinue: onContinue,
                    kidImage: kidImage,
                    badgeEmoji: badgeEmoji,
                    panelEmoji: panelEmoji,
                  ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}

class _CardColors {
  const _CardColors({
    required this.cardBg,
    required this.imageBg,
    required this.accent,
    required this.accentDark,
    required this.pillBg,
    required this.trackBg,
  });

  final Color cardBg;
  final Color imageBg;
  final Color accent;
  final Color accentDark;
  final Color pillBg;
  final Color trackBg;
}

/// Phone layout: compact header + full-width previews + stacked progress/CTA.
class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.colors,
    required this.title,
    required this.description,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
    required this.signPreviews,
    required this.onContinue,
    required this.kidImage,
    required this.badgeEmoji,
    required this.panelEmoji,
  });

  final _CardColors colors;
  final String title;
  final String description;
  final int completedCount;
  final int totalCount;
  final double progress;
  final List<SignPreviewItem> signPreviews;
  final VoidCallback onContinue;
  final ImageProvider? kidImage;
  final String badgeEmoji;
  final String? panelEmoji;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImagePanel(
              imageBg: colors.imageBg,
              kidImage: kidImage,
              badgeEmoji: badgeEmoji,
              panelEmoji: panelEmoji,
              width: 72,
              height: 72,
              emojiSize: 34,
              badgeSize: 26,
              badgeEmojiSize: 12,
              showDecor: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: CategoryCard._navy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CountPill(
                        completedCount: completedCount,
                        totalCount: totalCount,
                        pillBg: colors.pillBg,
                        accentDark: colors.accentDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: CategoryCard._grayText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SignPreviewRow(items: signPreviews, compact: true),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: colors.trackBg,
                  valueColor: AlwaysStoppedAnimation(colors.accent),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${(progress.clamp(0.0, 1.0) * 100).round()}%',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: colors.accentDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _ContinueButton(
            onPressed: onContinue,
            accent: colors.accent,
            expanded: true,
          ),
        ),
      ],
    );
  }
}

/// iPad / wide layout: illustration panel beside full content.
class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.colors,
    required this.title,
    required this.description,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
    required this.signPreviews,
    required this.onContinue,
    required this.kidImage,
    required this.badgeEmoji,
    required this.panelEmoji,
  });

  final _CardColors colors;
  final String title;
  final String description;
  final int completedCount;
  final int totalCount;
  final double progress;
  final List<SignPreviewItem> signPreviews;
  final VoidCallback onContinue;
  final ImageProvider? kidImage;
  final String badgeEmoji;
  final String? panelEmoji;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ImagePanel(
            imageBg: colors.imageBg,
            kidImage: kidImage,
            badgeEmoji: badgeEmoji,
            panelEmoji: panelEmoji,
            width: 140,
            minHeight: 190,
            emojiSize: 56,
            badgeSize: 36,
            badgeEmojiSize: 16,
            showDecor: true,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
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
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: CategoryCard._navy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: CategoryCard._grayText,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CountPill(
                      completedCount: completedCount,
                      totalCount: totalCount,
                      pillBg: colors.pillBg,
                      accentDark: colors.accentDark,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SignPreviewRow(items: signPreviews, compact: false),
                const SizedBox(height: 14),
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
                                backgroundColor: colors.trackBg,
                                valueColor:
                                    AlwaysStoppedAnimation(colors.accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: colors.accentDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    _ContinueButton(
                      onPressed: onContinue,
                      accent: colors.accent,
                      expanded: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({
    required this.imageBg,
    required this.kidImage,
    required this.badgeEmoji,
    required this.panelEmoji,
    required this.width,
    required this.emojiSize,
    required this.badgeSize,
    required this.badgeEmojiSize,
    required this.showDecor,
    this.height,
    this.minHeight,
  });

  final Color imageBg;
  final ImageProvider? kidImage;
  final String badgeEmoji;
  final String? panelEmoji;
  final double width;
  final double? height;
  final double? minHeight;
  final double emojiSize;
  final double badgeSize;
  final double badgeEmojiSize;
  final bool showDecor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: minHeight != null
          ? BoxConstraints(minHeight: minHeight!)
          : null,
      decoration: BoxDecoration(
        color: imageBg,
        borderRadius: BorderRadius.circular(height != null ? 18 : 22),
        image: kidImage != null
            ? DecorationImage(image: kidImage!, fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        children: [
          if (kidImage == null) ...[
            if (showDecor) ...[
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
            ],
            Center(
              child: Text(
                panelEmoji ?? badgeEmoji,
                style: TextStyle(fontSize: emojiSize),
              ),
            ),
          ],
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(height != null ? 6 : 10),
              child: Container(
                width: badgeSize,
                height: badgeSize,
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
                  child: Text(
                    badgeEmoji,
                    style: TextStyle(fontSize: badgeEmojiSize),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.completedCount,
    required this.totalCount,
    required this.pillBg,
    required this.accentDark,
  });

  final int completedCount;
  final int totalCount;
  final Color pillBg;
  final Color accentDark;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.onPressed,
    required this.accent,
    required this.expanded,
  });

  final VoidCallback onPressed;
  final Color accent;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: expanded ? 20 : 18,
          vertical: expanded ? 14 : 12,
        ),
        minimumSize: Size(expanded ? double.infinity : 0, expanded ? 48 : 42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        shadowColor: accent.withValues(alpha: 0.35),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Continue',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: expanded ? 15 : 14,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}

class _SignPreviewRow extends StatelessWidget {
  const _SignPreviewRow({
    required this.items,
    required this.compact,
  });

  final List<SignPreviewItem> items;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visible = compact && items.length > 4
        ? [
            ...items.take(3),
            const SignPreviewItem(label: '', isMore: true),
          ]
        : items;

    return Row(
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          if (i != 0) SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: _SignBubble(item: visible[i], compact: compact),
          ),
        ],
      ],
    );
  }
}

class _SignBubble extends StatelessWidget {
  const _SignBubble({
    required this.item,
    required this.compact,
  });

  final SignPreviewItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 44.0;

    if (item.isMore) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
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
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w900,
                color: CategoryCard._grayText,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: compact ? 4 : 5),
          Text(
            ' ',
            style: GoogleFonts.nunito(
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.backgroundColor ?? const Color(0xFFEAF0FF),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: item.imageProvider != null
              ? Transform.scale(
                  scale: 1.12,
                  child: Image(
                    image: item.imageProvider!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        item.emoji ?? '✨',
                        style: TextStyle(fontSize: compact ? 16 : 18),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    item.emoji ?? '✨',
                    style: TextStyle(fontSize: compact ? 16 : 18),
                  ),
                ),
        ),
        SizedBox(height: compact ? 4 : 5),
        Text(
          item.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
            fontSize: compact ? 9.5 : 10.5,
            fontWeight: FontWeight.w700,
            color: CategoryCard._navy,
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
