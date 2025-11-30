import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Service for managing advertisements in the app
/// Supports banner ads, interstitial ads, and rewarded ads
class AdsService {
  // Singleton pattern
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  // Ads configuration
  bool _isInitialized = false;
  bool _adsEnabled = true;
  bool _isPremiumUser = false;
  
  // Ad display tracking
  int _interstitialAdCounter = 0;
  int _lessonsCompletedSinceLastAd = 0;
  DateTime? _lastInterstitialAdTime;
  
  // Configuration constants
  static const int _lessonsBeforeInterstitial = 3; // Show ad every 3 lessons
  static const int _minTimeBetweenAds = 60; // Minimum 60 seconds between ads
  static const int _rewardedAdXPBonus = 10; // XP bonus for watching rewarded ad
  
  // Ad unit IDs (replace with your actual IDs)
  // TODO: Replace these with your Google AdMob/Facebook Ads IDs
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get adsEnabled => _adsEnabled && !_isPremiumUser;
  bool get isPremiumUser => _isPremiumUser;
  String get bannerAdUnitId => _bannerAdUnitId;
  String get interstitialAdUnitId => _interstitialAdUnitId;
  String get rewardedAdUnitId => _rewardedAdUnitId;
  
  /// Initialize the ads service
  /// Call this in main.dart before running the app
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('AdsService: Already initialized');
      return;
    }
    
    try {
      debugPrint('AdsService: Initializing...');
      
      // TODO: Initialize Google Mobile Ads SDK
      // Example:
      // await MobileAds.instance.initialize();
      
      // Load user premium status
      await _loadPremiumStatus();
      
      _isInitialized = true;
      debugPrint('AdsService: Initialized successfully');
      
    } catch (e) {
      debugPrint('AdsService: Initialization failed - $e');
      _isInitialized = false;
    }
  }
  
  /// Load banner ad
  /// Returns true if ad should be shown
  Future<bool> loadBannerAd() async {
    if (!adsEnabled) {
      debugPrint('AdsService: Banner ads disabled');
      return false;
    }
    
    try {
      debugPrint('AdsService: Loading banner ad...');
      
      // TODO: Implement actual banner ad loading
      // Example:
      // _bannerAd = BannerAd(
      //   adUnitId: _bannerAdUnitId,
      //   size: AdSize.banner,
      //   request: AdRequest(),
      //   listener: BannerAdListener(...),
      // );
      // await _bannerAd.load();
      
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
      debugPrint('AdsService: Banner ad loaded');
      return true;
      
    } catch (e) {
      debugPrint('AdsService: Banner ad loading failed - $e');
      return false;
    }
  }
  
  /// Check if interstitial ad should be shown
  bool shouldShowInterstitialAd() {
    if (!adsEnabled) {
      return false;
    }
    
    // Check lessons counter
    if (_lessonsCompletedSinceLastAd < _lessonsBeforeInterstitial) {
      return false;
    }
    
    // Check time since last ad
    if (_lastInterstitialAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialAdTime!);
      if (timeSinceLastAd.inSeconds < _minTimeBetweenAds) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Load and show interstitial ad
  Future<bool> showInterstitialAd() async {
    if (!shouldShowInterstitialAd()) {
      debugPrint('AdsService: Not time to show interstitial ad yet');
      return false;
    }
    
    try {
      debugPrint('AdsService: Loading interstitial ad...');
      
      // TODO: Implement actual interstitial ad
      // Example:
      // await InterstitialAd.load(
      //   adUnitId: _interstitialAdUnitId,
      //   request: AdRequest(),
      //   adLoadCallback: InterstitialAdLoadCallback(...),
      // );
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate ad display
      
      // Reset counters
      _lessonsCompletedSinceLastAd = 0;
      _lastInterstitialAdTime = DateTime.now();
      _interstitialAdCounter++;
      
      debugPrint('AdsService: Interstitial ad shown (#$_interstitialAdCounter)');
      return true;
      
    } catch (e) {
      debugPrint('AdsService: Interstitial ad failed - $e');
      return false;
    }
  }
  
  /// Load and show rewarded ad
  /// Returns XP bonus if ad was watched completely
Future<int> showRewardedAd() async {
  int reward = 0;

  try {
    debugPrint('AdsService: Loading rewarded ad...');

    await Future.delayed(const Duration(seconds: 2)); // Simulate ad

    bool watchedFully = true; // TODO: Get this from ad callback

    if (watchedFully) {
      debugPrint('AdsService: Rewarded ad completed - Granting $_rewardedAdXPBonus XP');
      reward = _rewardedAdXPBonus;
    } else {
      debugPrint('AdsService: Rewarded ad not completed');
      reward = 0;
    }
  } catch (e) {
    debugPrint('AdsService: Rewarded ad failed - $e');
    reward = 0;
  }

  return reward;
}



  
  /// Called when user completes a lesson
  void onLessonCompleted() {
    _lessonsCompletedSinceLastAd++;
    debugPrint('AdsService: Lessons completed since last ad: $_lessonsCompletedSinceLastAd');
  }
  
  /// Check if rewarded ad is available
  Future<bool> isRewardedAdAvailable() async {
    if (!adsEnabled) {
      return false;
    }
    
    try {
      // TODO: Check if rewarded ad is loaded
      // Example:
      // return _rewardedAd != null && _rewardedAd.responseInfo != null;
      
      return true; // Mock: Always available
      
    } catch (e) {
      debugPrint('AdsService: Error checking rewarded ad availability - $e');
      return false;
    }
  }
  
  /// Enable or disable ads
  void setAdsEnabled(bool enabled) {
    _adsEnabled = enabled;
    debugPrint('AdsService: Ads ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Set premium user status (removes ads)
  Future<void> setPremiumStatus(bool isPremium) async {
    _isPremiumUser = isPremium;
    debugPrint('AdsService: Premium status set to $isPremium');
    
    // TODO: Save premium status to persistent storage
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('is_premium_user', isPremium);
    
    if (isPremium) {
      // Dispose any loaded ads
      disposeAllAds();
    }
  }
  
  /// Load premium status from storage
  Future<void> _loadPremiumStatus() async {
    try {
      // TODO: Load from SharedPreferences or backend
      // Example:
      // final prefs = await SharedPreferences.getInstance();
      // _isPremiumUser = prefs.getBool('is_premium_user') ?? false;
      
      _isPremiumUser = false; // Mock: Default to free user
      debugPrint('AdsService: Premium status loaded: $_isPremiumUser');
      
    } catch (e) {
      debugPrint('AdsService: Error loading premium status - $e');
      _isPremiumUser = false;
    }
  }
  
  /// Dispose all loaded ads
  void disposeAllAds() {
    try {
      // TODO: Dispose all ad instances
      // Example:
      // _bannerAd?.dispose();
      // _interstitialAd?.dispose();
      // _rewardedAd?.dispose();
      
      debugPrint('AdsService: All ads disposed');
      
    } catch (e) {
      debugPrint('AdsService: Error disposing ads - $e');
    }
  }
  
  /// Get time until next interstitial ad
  Duration getTimeUntilNextAd() {
    if (_lastInterstitialAdTime == null) {
      return Duration.zero;
    }
    
    final timeSinceLastAd = DateTime.now().difference(_lastInterstitialAdTime!);
    final timeRemaining = _minTimeBetweenAds - timeSinceLastAd.inSeconds;
    
    if (timeRemaining <= 0) {
      return Duration.zero;
    }
    
    return Duration(seconds: timeRemaining);
  }
  
  /// Get lessons remaining until next interstitial ad
  int getLessonsUntilNextAd() {
    final remaining = _lessonsBeforeInterstitial - _lessonsCompletedSinceLastAd;
    return remaining > 0 ? remaining : 0;
  }
  
  /// Show ad-free trial offer dialog
  static void showPremiumOffer(BuildContext context) {
    // TODO: Implement premium offer dialog
    debugPrint('AdsService: Showing premium offer');
  }
  
  /// Analytics - Get total ads shown
  int getTotalAdsShown() {
    return _interstitialAdCounter;
  }
  
  /// Reset ad counters (for testing)
  void resetCounters() {
    _interstitialAdCounter = 0;
    _lessonsCompletedSinceLastAd = 0;
    _lastInterstitialAdTime = null;
    debugPrint('AdsService: Counters reset');
  }
}

/// Ad placement helper
class AdPlacement {
  static const String homeScreen = 'home_screen';
  static const String lessonComplete = 'lesson_complete';
  static const String levelComplete = 'level_complete';
  static const String profileScreen = 'profile_screen';
  static const String settingsScreen = 'settings_screen';
}

/// Ad event callback
typedef AdEventCallback = void Function(AdEvent event);

/// Ad events
enum AdEvent {
  loaded,
  failedToLoad,
  opened,
  closed,
  clicked,
  impression,
  rewarded,
}

/// Ad result
class AdResult {
  final bool success;
  final String message;
  final int? reward;
  
  const AdResult({
    required this.success,
    required this.message,
    this.reward,
  });
  
  factory AdResult.success([String message = 'Ad shown successfully', int? reward]) {
    return AdResult(
      success: true,
      message: message,
      reward: reward,
    );
  }
  
  factory AdResult.failure(String message) {
    return AdResult(
      success: false,
      message: message,
    );
  }
}