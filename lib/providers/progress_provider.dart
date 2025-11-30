import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  // Private fields
  int _currentLevel = 1; // A1 level
  double _currentLevelProgress = 15.0; // Progress within current level (0-100%)
  int _streakDays = 3;
  int _totalXP = 245;
  int _completedLessons = 12;
  DateTime? _lastStudyDate;
  
  // Track completed lesson IDs
  Set<String> _completedLessonIds = {};
  
  // SharedPreferences keys
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyCurrentLevelProgress = 'current_level_progress';
  static const String _keyStreakDays = 'streak_days';
  static const String _keyTotalXP = 'total_xp';
  static const String _keyCompletedLessons = 'completed_lessons';
  static const String _keyLastStudyDate = 'last_study_date';
  static const String _keyCompletedLessonIds = 'completed_lesson_ids';
  
  // Getters
  int get currentLevel => _currentLevel;
  double get currentLevelProgress => _currentLevelProgress;
  int get streakDays => _streakDays;
  int get totalXP => _totalXP;
  int get completedLessons => _completedLessons;
  DateTime? get lastStudyDate => _lastStudyDate;
  Set<String> get completedLessonIds => _completedLessonIds;
  
  /// Load progress from SharedPreferences
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load all progress data
      _currentLevel = prefs.getInt(_keyCurrentLevel) ?? 1;
      _currentLevelProgress = prefs.getDouble(_keyCurrentLevelProgress) ?? 0.0;
      _streakDays = prefs.getInt(_keyStreakDays) ?? 0;
      _totalXP = prefs.getInt(_keyTotalXP) ?? 0;
      _completedLessons = prefs.getInt(_keyCompletedLessons) ?? 0;
      
      // Load completed lesson IDs
      final completedLessonsList = prefs.getStringList(_keyCompletedLessonIds) ?? [];
      _completedLessonIds = Set<String>.from(completedLessonsList);
      
      // Load last study date and update streak
      final lastStudyDateString = prefs.getString(_keyLastStudyDate);
      if (lastStudyDateString != null) {
        _lastStudyDate = DateTime.parse(lastStudyDateString);
        _checkAndUpdateStreak();
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ Progress loaded: Level $_currentLevel, XP $_totalXP, Streak $_streakDays days');
        print('📚 Completed lessons: ${_completedLessonIds.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading progress: $e');
      }
      // Use default values if loading fails
      _setDefaultValues();
      notifyListeners();
    }
  }
  
  /// Save progress to SharedPreferences
  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save all progress data
      await prefs.setInt(_keyCurrentLevel, _currentLevel);
      await prefs.setDouble(_keyCurrentLevelProgress, _currentLevelProgress);
      await prefs.setInt(_keyStreakDays, _streakDays);
      await prefs.setInt(_keyTotalXP, _totalXP);
      await prefs.setInt(_keyCompletedLessons, _completedLessons);
      
      // Save completed lesson IDs
      await prefs.setStringList(_keyCompletedLessonIds, _completedLessonIds.toList());
      
      // Save last study date
      if (_lastStudyDate != null) {
        await prefs.setString(_keyLastStudyDate, _lastStudyDate!.toIso8601String());
      }
      
      if (kDebugMode) {
        print('💾 Progress saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving progress: $e');
      }
    }
  }
  
  /// Clear all progress data (for testing or account deletion)
  Future<void> clearProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_keyCurrentLevel);
      await prefs.remove(_keyCurrentLevelProgress);
      await prefs.remove(_keyStreakDays);
      await prefs.remove(_keyTotalXP);
      await prefs.remove(_keyCompletedLessons);
      await prefs.remove(_keyLastStudyDate);
      await prefs.remove(_keyCompletedLessonIds);
      
      _setDefaultValues();
      notifyListeners();
      
      if (kDebugMode) {
        print('🗑️ Progress cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing progress: $e');
      }
    }
  }
  
  /// Set default values
  void _setDefaultValues() {
    _currentLevel = 1;
    _currentLevelProgress = 0.0;
    _streakDays = 0;
    _totalXP = 0;
    _completedLessons = 0;
    _lastStudyDate = null;
    _completedLessonIds = {};
  }
  
  /// Update level progress
  void updateLevelProgress(double progress) {
    _currentLevelProgress = progress.clamp(0.0, 100.0);
    
    // Check if level should advance
    if (_currentLevelProgress >= 100.0 && _currentLevel < 6) {
      _currentLevel++;
      _currentLevelProgress = 0.0;
    }
    
    notifyListeners();
    saveProgress(); // Auto-save after update
  }
  
  /// Complete a lesson
  void completeLesson(int xpGained, {String? lessonId}) {
    _completedLessons++;
    _totalXP += xpGained;
    
    // Mark lesson as completed
    if (lessonId != null) {
      _completedLessonIds.add(lessonId);
    }
    
    // Update level progress (each lesson gives some progress)
    updateLevelProgress(_currentLevelProgress + 10.0);
    
    // Update streak if lesson completed today
    _updateStreak();
    
    notifyListeners();
    saveProgress(); // Auto-save after completing lesson
  }
  
  /// Check if a specific lesson is completed
  bool isLessonCompleted(String lessonId) {
    return _completedLessonIds.contains(lessonId);
  }
  
  /// Mark a lesson as completed (without XP calculation)
  void markLessonCompleted(String lessonId) {
    if (!_completedLessonIds.contains(lessonId)) {
      _completedLessonIds.add(lessonId);
      notifyListeners();
      saveProgress();
    }
  }
  
  /// Get number of completed lessons for a specific level
  int getCompletedLessonsForLevel(int level) {
    // Count lessons that match the level pattern (e.g., "A1_L1" for level 1)
    final levelPrefix = _getLevelPrefix(level);
    return _completedLessonIds
        .where((id) => id.startsWith(levelPrefix))
        .length;
  }
  
  /// Get level prefix from level number
  String _getLevelPrefix(int level) {
    switch (level) {
      case 1: return 'A1_';
      case 2: return 'A2_';
      case 3: return 'B1_';
      case 4: return 'B2_';
      case 5: return 'C1_';
      case 6: return 'C2_';
      default: return 'A1_';
    }
  }
  
  /// Update streak when user completes a lesson
  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastStudyDate == null) {
      // First time studying
      _streakDays = 1;
      _lastStudyDate = today;
    } else {
      final lastStudy = DateTime(
        _lastStudyDate!.year,
        _lastStudyDate!.month,
        _lastStudyDate!.day,
      );
      
      final difference = today.difference(lastStudy).inDays;
      
      if (difference == 0) {
        // Already studied today, don't change streak
        return;
      } else if (difference == 1) {
        // Studied yesterday, continue streak
        _streakDays++;
        _lastStudyDate = today;
      } else {
        // Missed days, reset streak
        _streakDays = 1;
        _lastStudyDate = today;
      }
    }
  }
  
  /// Check and update streak on app launch
  void _checkAndUpdateStreak() {
    if (_lastStudyDate == null) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudy = DateTime(
      _lastStudyDate!.year,
      _lastStudyDate!.month,
      _lastStudyDate!.day,
    );
    
    final difference = today.difference(lastStudy).inDays;
    
    if (difference > 1) {
      // Missed more than one day, reset streak
      _streakDays = 0;
      if (kDebugMode) {
        print('🔥 Streak reset: Missed $difference days');
      }
    }
  }
  
  /// Reset streak (if user misses a day)
  void resetStreak() {
    _streakDays = 0;
    _lastStudyDate = null;
    notifyListeners();
    saveProgress();
  }
  
  /// Get level name
  String getLevelName(int level) {
    switch (level) {
      case 1: return 'A1 - Beginner';
      case 2: return 'A2 - Elementary';
      case 3: return 'B1 - Intermediate';
      case 4: return 'B2 - Upper Intermediate';
      case 5: return 'C1 - Advanced';
      case 6: return 'C2 - Proficiency';
      default: return 'Unknown';
    }
  }
  
  /// Check if level is unlocked
  bool isLevelUnlocked(int level) {
    return level <= _currentLevel + 1; // Current level + 1 next level
  }
  
  /// Check if level is completed
  bool isLevelCompleted(int level) {
    return level < _currentLevel;
  }
  
  /// Add XP manually (for bonus rewards, achievements, etc.)
  void addXP(int xp) {
    _totalXP += xp;
    
    // Calculate progress based on XP
    // Each 100 XP = 10% progress
    final progressGained = (xp / 100) * 10;
    updateLevelProgress(_currentLevelProgress + progressGained);
    
    notifyListeners();
    saveProgress();
  }
  
  /// Get progress percentage for a specific level
  double getProgressForLevel(int level) {
    if (level < _currentLevel) {
      return 100.0; // Completed
    } else if (level == _currentLevel) {
      return _currentLevelProgress;
    } else {
      return 0.0; // Locked
    }
  }
}