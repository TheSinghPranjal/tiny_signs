import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_state.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/floating_bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.darkMode;

    return AnimatedSkyBackground(
      isDark: isDark,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, kBottomNavClearance),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Make Tiny Signs just right for you',
              style: GoogleFonts.nunito(
                color: isDark
                    ? AppColors.nightText.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            _SectionTitle(title: 'Appearance'),
            _SettingsTile(
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: 'Soft nighttime colors for bedtime',
              trailing: Switch(
                value: appState.darkMode,
                onChanged: (_) => appState.toggleDarkMode(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(title: 'Accessibility'),
            _SettingsTile(
              icon: Icons.record_voice_over_rounded,
              title: 'Voice Narration',
              subtitle: 'Friendly voice guidance',
              trailing: Switch(
                value: appState.narrationEnabled,
                onChanged: appState.setNarration,
              ),
            ),
            _SettingsTile(
              icon: Icons.subtitles_rounded,
              title: 'Subtitles',
              subtitle: 'Show text with narration',
              trailing: Switch(
                value: appState.subtitlesEnabled,
                onChanged: appState.setSubtitles,
              ),
            ),
            _SettingsTile(
              icon: Icons.vibration_rounded,
              title: 'Vibration Feedback',
              subtitle: 'Gentle haptic responses',
              trailing: Switch(
                value: appState.vibrationEnabled,
                onChanged: appState.setVibration,
              ),
            ),
            _SettingsTile(
              icon: Icons.back_hand_rounded,
              title: 'Left-Handed Mode',
              subtitle: 'Mirror sign animations',
              trailing: Switch(
                value: appState.leftHandedMode,
                onChanged: appState.setLeftHanded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed_rounded,
                          color: isDark
                              ? AppColors.nightText
                              : AppColors.textPrimary),
                      const SizedBox(width: 16),
                      Text(
                        'Speech Speed',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: appState.speechSpeed,
                    min: 0.5,
                    max: 1.5,
                    divisions: 4,
                    label: '${appState.speechSpeed.toStringAsFixed(1)}x',
                    onChanged: appState.setSpeechSpeed,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(title: 'About'),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Tiny Signs',
              subtitle: 'Version 1.0.0 • Baby Sign Language for Ages 6mo–5yr',
              trailing: const Text('👋', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.fredoka(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF7B8CDE),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? AppColors.nightCard : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF7B8CDE)),
        title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: GoogleFonts.nunito(fontSize: 13)),
        trailing: trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
