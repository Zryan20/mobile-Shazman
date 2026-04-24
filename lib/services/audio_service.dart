import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing audio playback in the app
/// Handles pronunciation audio (TTS), background music, and sound effects
class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Audio players
  late AudioPlayer _pronunciationPlayer;
  late AudioPlayer _musicPlayer;
  late AudioPlayer _effectsPlayer;
  late FlutterTts _flutterTts;

  // Audio state
  bool _isInitialized = false;
  bool _soundEffectsEnabled = true;
  bool _musicEnabled = true;
  bool _pronunciationEnabled = true;
  bool _useTtsOnly = true; // Default to true as per user request
  double _volume = 0.8;
  double _musicVolume = 0.5;
  double _effectsVolume = 1.0;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get pronunciationEnabled => _pronunciationEnabled;
  double get volume => _volume;
  double get musicVolume => _musicVolume;
  double get effectsVolume => _effectsVolume;
  
  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('AudioService: Initializing...');
      
      _pronunciationPlayer = AudioPlayer();
      _musicPlayer = AudioPlayer();
      _effectsPlayer = AudioPlayer();
      _flutterTts = FlutterTts();

      // Configure TTS
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Slightly slower for learning
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // Load saved preferences
      await _loadPreferences();
      
      _isInitialized = true;
      debugPrint('AudioService: Initialized successfully');
    } catch (e) {
      debugPrint('AudioService: Initialization failed - $e');
    }
  }
  
  /// Speak English text using TTS
  Future<void> speak(String text) async {
    if (!_pronunciationEnabled || !_isInitialized) return;
    
    try {
      debugPrint('AudioService: Speaking - $text');
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('AudioService: TTS Error - $e');
    }
  }
  
  /// Play pronunciation audio or fallback to TTS
  Future<void> playPronunciation(String text, {String? audioPath}) async {
    if (!_pronunciationEnabled || !_isInitialized) return;

    // If useTtsOnly is true, or if audioPath is null, or if we want to default to TTS
    if (_useTtsOnly || audioPath == null) {
      await speak(text);
      return;
    }
    
    try {
      // Check if file exists would be better here, but for now we try to play
      // and if it fails or if the user explicitly wants "no real sounds", we use TTS.
      await _pronunciationPlayer.stop();
      await _pronunciationPlayer.setVolume(_volume);
      await _pronunciationPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint('AudioService: Audio file error, falling back to TTS - $e');
      await speak(text);
    }
  }
  
  /// Play sound effect
  Future<void> playSoundEffect(SoundEffect effect) async {
    if (!_soundEffectsEnabled || !_isInitialized) return;
    
    try {
      final path = _getSoundEffectPath(effect);
      await _effectsPlayer.stop();
      await _effectsPlayer.setVolume(_effectsVolume);
      await _effectsPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('AudioService: Error playing effect - $e');
    }
  }

  String _getSoundEffectPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.correct: return 'audio/effects/correct.mp3';
      case SoundEffect.incorrect: return 'audio/effects/incorrect.mp3';
      case SoundEffect.success: return 'audio/effects/success.mp3';
      case SoundEffect.levelUp: return 'audio/effects/level_up.mp3';
      case SoundEffect.achievement: return 'audio/effects/achievement.mp3';
      case SoundEffect.click: return 'audio/effects/click.mp3';
      case SoundEffect.swipe: return 'audio/effects/swipe.mp3';
      case SoundEffect.notification: return 'audio/effects/notification.mp3';
    }
  }
  
  /// Set master volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _savePreferences();
  }
  
  /// Enable/disable pronunciation
  Future<void> setPronunciationEnabled(bool enabled) async {
    _pronunciationEnabled = enabled;
    if (!enabled) await _flutterTts.stop();
    await _savePreferences();
  }

  /// Toggle TTS vs Recorded
  Future<void> setUseTtsOnly(bool useTts) async {
    _useTtsOnly = useTts;
    await _savePreferences();
  }
  
  /// Load preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _pronunciationEnabled = prefs.getBool('pronunciation_enabled') ?? true;
      _useTtsOnly = prefs.getBool('use_tts_only') ?? true;
      _volume = prefs.getDouble('audio_volume') ?? 0.8;
    } catch (e) {
      debugPrint('AudioService: Prefs error - $e');
    }
  }
  
  /// Save preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_effects_enabled', _soundEffectsEnabled);
      await prefs.setBool('music_enabled', _musicEnabled);
      await prefs.setBool('pronunciation_enabled', _pronunciationEnabled);
      await prefs.setBool('use_tts_only', _useTtsOnly);
      await prefs.setDouble('audio_volume', _volume);
    } catch (e) {
      debugPrint('AudioService: Save error - $e');
    }
  }

  Future<void> stopPronunciation() async {
    await _flutterTts.stop();
    await _pronunciationPlayer.stop();
  }

  Future<void> dispose() async {
    await _pronunciationPlayer.dispose();
    await _musicPlayer.dispose();
    await _effectsPlayer.dispose();
    _isInitialized = false;
  }
}

enum SoundEffect {
  correct,
  incorrect,
  success,
  levelUp,
  achievement,
  click,
  swipe,
  notification,
}