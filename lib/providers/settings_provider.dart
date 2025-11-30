import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoplayEnabled = true;
  bool _subtitlesEnabled = false;
  double _audioVolume = 0.8;

  static const String _keyNotifications = 'notifications_enabled';
  static const String _keySoundEffects = 'sound_effects_enabled';
  static const String _keyMusic = 'music_enabled';
  static const String _keyVibration = 'vibration_enabled';
  static const String _keyDarkMode = 'dark_mode_enabled';
  static const String _keyAutoplay = 'autoplay_enabled';
  static const String _keySubtitles = 'subtitles_enabled';
  static const String _keyAudioVolume = 'audio_volume';

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get autoplayEnabled => _autoplayEnabled;
  bool get subtitlesEnabled => _subtitlesEnabled;
  double get audioVolume => _audioVolume;

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> loadSettings() async {
    if (!await _isOnline()) {
      if (kDebugMode) print('❌ Offline. Settings not loaded.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
      _soundEffectsEnabled = prefs.getBool(_keySoundEffects) ?? true;
      _musicEnabled = prefs.getBool(_keyMusic) ?? true;
      _vibrationEnabled = prefs.getBool(_keyVibration) ?? true;
      _darkModeEnabled = prefs.getBool(_keyDarkMode) ?? false;
      _autoplayEnabled = prefs.getBool(_keyAutoplay) ?? true;
      _subtitlesEnabled = prefs.getBool(_keySubtitles) ?? false;
      _audioVolume = prefs.getDouble(_keyAudioVolume) ?? 0.8;

      notifyListeners();
      if (kDebugMode) print('✅ Settings loaded successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Error loading settings: $e');
      _setDefaultSettings();
    }
  }

  Future<void> saveSettings() async {
    if (!await _isOnline()) {
      if (kDebugMode) print('❌ Offline. Settings not saved.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_keyNotifications, _notificationsEnabled);
      await prefs.setBool(_keySoundEffects, _soundEffectsEnabled);
      await prefs.setBool(_keyMusic, _musicEnabled);
      await prefs.setBool(_keyVibration, _vibrationEnabled);
      await prefs.setBool(_keyDarkMode, _darkModeEnabled);
      await prefs.setBool(_keyAutoplay, _autoplayEnabled);
      await prefs.setBool(_keySubtitles, _subtitlesEnabled);
      await prefs.setDouble(_keyAudioVolume, _audioVolume);

      if (kDebugMode) print('💾 Settings saved successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Error saving settings: $e');
    }
  }

  void _setDefaultSettings() {
    _notificationsEnabled = true;
    _soundEffectsEnabled = true;
    _musicEnabled = true;
    _vibrationEnabled = true;
    _darkModeEnabled = false;
    _autoplayEnabled = true;
    _subtitlesEnabled = false;
    _audioVolume = 0.8;
    notifyListeners();
  }

  Future<void> clearSettings() async {
    if (!await _isOnline()) {
      if (kDebugMode) print('❌ Offline. Cannot clear settings.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyNotifications);
      await prefs.remove(_keySoundEffects);
      await prefs.remove(_keyMusic);
      await prefs.remove(_keyVibration);
      await prefs.remove(_keyDarkMode);
      await prefs.remove(_keyAutoplay);
      await prefs.remove(_keySubtitles);
      await prefs.remove(_keyAudioVolume);

      _setDefaultSettings();

      if (kDebugMode) print('🗑️ Settings cleared');
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing settings: $e');
    }
  }

  void setNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setSoundEffects(bool enabled) {
    _soundEffectsEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setMusic(bool enabled) {
    _musicEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setVibration(bool enabled) {
    _vibrationEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setDarkMode(bool enabled) {
    _darkModeEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setAutoplay(bool enabled) {
    _autoplayEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setSubtitles(bool enabled) {
    _subtitlesEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setAudioVolume(double volume) {
    _audioVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
    saveSettings();
  }

  void toggleNotifications() => setNotifications(!_notificationsEnabled);
  void toggleSoundEffects() => setSoundEffects(!_soundEffectsEnabled);
  void toggleMusic() => setMusic(!_musicEnabled);
  void toggleVibration() => setVibration(!_vibrationEnabled);
  void toggleDarkMode() => setDarkMode(!_darkModeEnabled);
  void toggleAutoplay() => setAutoplay(!_autoplayEnabled);
  void toggleSubtitles() => setSubtitles(!_subtitlesEnabled);
}
