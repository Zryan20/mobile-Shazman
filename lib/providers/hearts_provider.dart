import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class HeartsProvider extends ChangeNotifier {
  // Heart system constants
  static const int MAX_HEARTS = 5;
  static const int HEART_RECOVERY_HOURS = 5;
  static const Duration HEART_RECOVERY_DURATION = Duration(hours: HEART_RECOVERY_HOURS);
  
  // Private fields
  int _currentHearts = MAX_HEARTS;
  DateTime? _lastHeartLossTime;
  bool _isPremium = false; // Shazman+ status
  Timer? _heartRecoveryTimer;
  
  // SharedPreferences keys
  static const String _keyCurrentHearts = 'current_hearts';
  static const String _keyLastHeartLossTime = 'last_heart_loss_time';
  static const String _keyIsPremium = 'is_premium';
  
  // Getters
  int get currentHearts => _currentHearts;
  int get maxHearts => MAX_HEARTS;
  bool get hasHearts => _isPremium || _currentHearts > 0;
  bool get isPremium => _isPremium;
  DateTime? get lastHeartLossTime => _lastHeartLossTime;
  
  /// Get hearts percentage (for UI)
  double get heartsPercentage => _currentHearts / MAX_HEARTS;
  
  /// Check if hearts are full
  bool get isFullHearts => _currentHearts >= MAX_HEARTS;
  
  /// Get time until next heart recovery
  Duration? get timeUntilNextHeart {
    if (_isPremium || _currentHearts >= MAX_HEARTS || _lastHeartLossTime == null) {
      return null;
    }
    
    final now = DateTime.now();
    final nextHeartTime = _lastHeartLossTime!.add(HEART_RECOVERY_DURATION);
    
    if (now.isAfter(nextHeartTime)) {
      return Duration.zero;
    }
    
    return nextHeartTime.difference(now);
  }
  
  /// Get formatted time until next heart (e.g., "4:23:15")
  String? get formattedTimeUntilNextHeart {
    final time = timeUntilNextHeart;
    if (time == null) return null;
    
    final hours = time.inHours;
    final minutes = time.inMinutes.remainder(60);
    final seconds = time.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Get formatted time until next heart in Arabic numerals
  String? get formattedTimeUntilNextHeartArabic {
    final formatted = formattedTimeUntilNextHeart;
    if (formatted == null) return null;
    return _toArabicNumerals(formatted);
  }
  
  /// Load hearts data from storage
  Future<void> loadHearts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _currentHearts = prefs.getInt(_keyCurrentHearts) ?? MAX_HEARTS;
      _isPremium = prefs.getBool(_keyIsPremium) ?? false;
      
      final lastLossString = prefs.getString(_keyLastHeartLossTime);
      if (lastLossString != null) {
        _lastHeartLossTime = DateTime.parse(lastLossString);
      }
      
      // Check if hearts should be recovered
      await _checkHeartRecovery();
      
      // Start recovery timer
      _startHeartRecoveryTimer();
      
      notifyListeners();
      
      if (kDebugMode) {
        print('💖 Hearts loaded: $_currentHearts/$MAX_HEARTS, Premium: $_isPremium');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading hearts: $e');
      }
      // Set default values on error
      _currentHearts = MAX_HEARTS;
      _isPremium = false;
    }
  }
  
  /// Save hearts data to storage
  Future<void> _saveHearts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt(_keyCurrentHearts, _currentHearts);
      await prefs.setBool(_keyIsPremium, _isPremium);
      
      if (_lastHeartLossTime != null) {
        await prefs.setString(_keyLastHeartLossTime, _lastHeartLossTime!.toIso8601String());
      } else {
        await prefs.remove(_keyLastHeartLossTime);
      }
      
      if (kDebugMode) {
        print('💾 Hearts saved: $_currentHearts/$MAX_HEARTS');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving hearts: $e');
      }
    }
  }
  
  /// Lose a heart (when user makes a mistake)
  Future<bool> loseHeart() async {
    // Premium users never lose hearts
    if (_isPremium) {
      if (kDebugMode) {
        print('💎 Premium user - heart not lost');
      }
      return true; // Can continue
    }
    
    if (_currentHearts <= 0) {
      if (kDebugMode) {
        print('💔 No hearts left!');
      }
      return false; // Cannot continue
    }
    
    _currentHearts--;
    _lastHeartLossTime = DateTime.now();
    
    await _saveHearts();
    notifyListeners();
    
    if (kDebugMode) {
      print('💔 Heart lost! Remaining: $_currentHearts/$MAX_HEARTS');
    }
    
    // Start recovery timer if not already running
    if (_heartRecoveryTimer == null || !_heartRecoveryTimer!.isActive) {
      _startHeartRecoveryTimer();
    }
    
    return _currentHearts > 0; // Can continue if hearts remain
  }
  
  /// Recover one heart
  Future<void> recoverHeart() async {
    if (_isPremium || _currentHearts >= MAX_HEARTS) {
      return;
    }
    
    _currentHearts++;
    
    // Update last heart loss time for next recovery
    if (_currentHearts < MAX_HEARTS) {
      _lastHeartLossTime = DateTime.now();
    } else {
      _lastHeartLossTime = null; // All hearts recovered
    }
    
    await _saveHearts();
    notifyListeners();
    
    if (kDebugMode) {
      print('💚 Heart recovered! Current: $_currentHearts/$MAX_HEARTS');
    }
  }
  
  /// Check and recover hearts based on time elapsed
  Future<void> _checkHeartRecovery() async {
    if (_isPremium || _currentHearts >= MAX_HEARTS || _lastHeartLossTime == null) {
      return;
    }
    
    final now = DateTime.now();
    final timeSinceLastLoss = now.difference(_lastHeartLossTime!);
    final heartsToRecover = (timeSinceLastLoss.inHours / HEART_RECOVERY_HOURS).floor();
    
    if (heartsToRecover > 0) {
      final newHearts = (_currentHearts + heartsToRecover).clamp(0, MAX_HEARTS);
      final actualRecovered = newHearts - _currentHearts;
      
      _currentHearts = newHearts;
      
      if (_currentHearts >= MAX_HEARTS) {
        _lastHeartLossTime = null;
      } else {
        // Adjust last loss time
        _lastHeartLossTime = _lastHeartLossTime!.add(
          Duration(hours: actualRecovered * HEART_RECOVERY_HOURS)
        );
      }
      
      await _saveHearts();
      
      if (kDebugMode) {
        print('💚 Auto-recovered $actualRecovered hearts. Current: $_currentHearts/$MAX_HEARTS');
      }
    }
  }
  
  /// Start automatic heart recovery timer
  void _startHeartRecoveryTimer() {
    _heartRecoveryTimer?.cancel();
    
    if (_isPremium || _currentHearts >= MAX_HEARTS) {
      return;
    }
    
    // Update every second for UI
    _heartRecoveryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timeUntil = timeUntilNextHeart;
      
      if (timeUntil == null || timeUntil <= Duration.zero) {
        recoverHeart();
      } else {
        // Just notify to update UI countdown
        notifyListeners();
      }
      
      // Stop timer if hearts are full
      if (_currentHearts >= MAX_HEARTS) {
        timer.cancel();
      }
    });
    
    if (kDebugMode) {
      print('⏰ Heart recovery timer started');
    }
  }
  
  /// Refill all hearts (e.g., watch ad, purchase refill)
  Future<void> refillHearts() async {
    if (_isPremium) {
      if (kDebugMode) {
        print('💎 Premium user already has unlimited hearts');
      }
      return;
    }
    
    _currentHearts = MAX_HEARTS;
    _lastHeartLossTime = null;
    
    await _saveHearts();
    notifyListeners();
    
    if (kDebugMode) {
      print('💖 Hearts refilled! Current: $_currentHearts/$MAX_HEARTS');
    }
  }
  
  /// Purchase Shazman+ (premium)
  Future<void> purchasePremium() async {
    _isPremium = true;
    _currentHearts = MAX_HEARTS; // Give full hearts
    _lastHeartLossTime = null;
    
    await _saveHearts();
    notifyListeners();
    
    if (kDebugMode) {
      print('💎 Shazman+ activated! Unlimited hearts!');
    }
  }
  
  /// Cancel premium (for testing or subscription end)
  Future<void> cancelPremium() async {
    _isPremium = false;
    
    await _saveHearts();
    notifyListeners();
    
    if (kDebugMode) {
      print('💔 Shazman+ cancelled');
    }
  }
  
  /// Check premium status (e.g., verify subscription)
  Future<void> checkPremiumStatus() async {
    // TODO: Verify with backend/subscription service
    // For now, just load from storage
    await loadHearts();
  }
  
  /// Reset hearts (for testing)
  Future<void> resetHearts() async {
    _currentHearts = MAX_HEARTS;
    _lastHeartLossTime = null;
    _isPremium = false;
    
    await _saveHearts();
    notifyListeners();
    
    if (kDebugMode) {
      print('🔄 Hearts reset to default');
    }
  }
  
  /// Get hearts status message
  String getHeartsStatusMessage() {
    if (_isPremium) {
      return 'دڵی بێسنوور - Shazman+';
    }
    
    if (_currentHearts >= MAX_HEARTS) {
      return '$_currentHearts/$MAX_HEARTS - تەواو!';
    }
    
    if (_currentHearts == 0) {
      final timeUntil = formattedTimeUntilNextHeartArabic;
      return 'هیچ دڵێک نەماوە! دڵی دواتر: $timeUntil';
    }
    
    return '$_currentHearts/$MAX_HEARTS';
  }
  
  /// Convert numbers to Arabic-Indic numerals
  String _toArabicNumerals(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    
    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabicIndic[i]);
    }
    return result;
  }
  
  /// Dispose timer
  @override
  void dispose() {
    _heartRecoveryTimer?.cancel();
    super.dispose();
  }
  
  /// Get hearts display for UI (with emojis)
  String getHeartsDisplay() {
    if (_isPremium) {
      return '💎 ∞';
    }
    
    final filledHearts = '❤️' * _currentHearts;
    final emptyHearts = '🤍' * (MAX_HEARTS - _currentHearts);
    return '$filledHearts$emptyHearts';
  }
  
  /// Check if user can start lesson
  bool canStartLesson() {
    return _isPremium || _currentHearts > 0;
  }
  
  /// Get warning message when hearts are low
  String? getLowHeartsWarning() {
    if (_isPremium || _currentHearts >= 3) {
      return null;
    }
    
    if (_currentHearts == 0) {
      return 'هیچ دڵێکت نەماوە! چاوەڕوانی گەڕانەوەیان بکە یان Shazman+ بکڕە.';
    }
    
    if (_currentHearts == 1) {
      return 'تەنها ١ دڵت ماوە! وریا بە!';
    }
    
    return '٢ دڵت ماوە. وریا بە لە هەڵەکان!';
  }
}