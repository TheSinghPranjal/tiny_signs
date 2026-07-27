import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/sign_repository.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _load();
  }

  bool _darkMode = false;
  bool _narrationEnabled = true;
  bool _subtitlesEnabled = true;
  bool _vibrationEnabled = true;
  bool _leftHandedMode = false;
  double _speechSpeed = 1.0;
  int _dailyStreak = 0;
  int _totalStars = 0;
  final Set<String> _completedSigns = {};
  final Set<String> _completedCategories = {};
  final Set<String> _earnedBadges = {};

  bool get darkMode => _darkMode;
  bool get narrationEnabled => _narrationEnabled;
  bool get subtitlesEnabled => _subtitlesEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get leftHandedMode => _leftHandedMode;
  double get speechSpeed => _speechSpeed;
  int get dailyStreak => _dailyStreak;
  int get totalStars => _totalStars;
  Set<String> get completedSigns => Set.unmodifiable(_completedSigns);
  Set<String> get earnedBadges => Set.unmodifiable(_earnedBadges);

  int completedCountForCategory(String categoryId) {
    return SignRepository.signsForCategory(categoryId)
        .where((s) => _completedSigns.contains(s.id))
        .length;
  }

  double progressForCategory(String categoryId) {
    final total = SignRepository.signsForCategory(categoryId).length;
    if (total == 0) return 0;
    return completedCountForCategory(categoryId) / total;
  }

  bool isSignCompleted(String signId) => _completedSigns.contains(signId);

  bool isCategoryCompleted(String categoryId) {
    final signs = SignRepository.signsForCategory(categoryId);
    return signs.isNotEmpty &&
        signs.every((s) => _completedSigns.contains(s.id));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    _narrationEnabled = prefs.getBool('narration') ?? true;
    _subtitlesEnabled = prefs.getBool('subtitles') ?? true;
    _vibrationEnabled = prefs.getBool('vibration') ?? true;
    _leftHandedMode = prefs.getBool('leftHanded') ?? false;
    _speechSpeed = prefs.getDouble('speechSpeed') ?? 1.0;
    _dailyStreak = prefs.getInt('streak') ?? 3;
    _totalStars = prefs.getInt('stars') ?? 12;
    _completedSigns.addAll(prefs.getStringList('completed') ?? []);
    _completedCategories.addAll(prefs.getStringList('categories') ?? []);
    _earnedBadges.addAll(prefs.getStringList('badges') ?? ['first_sign']);
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('narration', _narrationEnabled);
    await prefs.setBool('subtitles', _subtitlesEnabled);
    await prefs.setBool('vibration', _vibrationEnabled);
    await prefs.setBool('leftHanded', _leftHandedMode);
    await prefs.setDouble('speechSpeed', _speechSpeed);
    await prefs.setInt('streak', _dailyStreak);
    await prefs.setInt('stars', _totalStars);
    await prefs.setStringList('completed', _completedSigns.toList());
    await prefs.setStringList('categories', _completedCategories.toList());
    await prefs.setStringList('badges', _earnedBadges.toList());
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    _save();
    notifyListeners();
  }

  void setNarration(bool value) {
    _narrationEnabled = value;
    _save();
    notifyListeners();
  }

  void setSubtitles(bool value) {
    _subtitlesEnabled = value;
    _save();
    notifyListeners();
  }

  void setVibration(bool value) {
    _vibrationEnabled = value;
    _save();
    notifyListeners();
  }

  void setLeftHanded(bool value) {
    _leftHandedMode = value;
    _save();
    notifyListeners();
  }

  void setSpeechSpeed(double value) {
    _speechSpeed = value;
    _save();
    notifyListeners();
  }

  void completeSign(String signId, String categoryId) {
    if (!_completedSigns.contains(signId)) {
      _completedSigns.add(signId);
      _totalStars += 3;
      if (_completedSigns.length == 1) {
        _earnedBadges.add('first_sign');
      }
      if (_completedSigns.length >= 10) {
        _earnedBadges.add('ten_signs');
      }
      if (_completedSigns.length >= 50) {
        _earnedBadges.add('super_signer');
      }
    }
    if (isCategoryCompleted(categoryId) &&
        !_completedCategories.contains(categoryId)) {
      _completedCategories.add(categoryId);
      _totalStars += 10;
      _earnedBadges.add('category_$categoryId');
    }
    _save();
    notifyListeners();
  }
}
