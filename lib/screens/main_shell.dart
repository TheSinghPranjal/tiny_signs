import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/floating_bottom_nav.dart';
import 'achievements/achievements_screen.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    AchievementsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().darkMode;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: FloatingBottomNav(
        selectedIndex: _index,
        isDark: isDark,
        onSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
