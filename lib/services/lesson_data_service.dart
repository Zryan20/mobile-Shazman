// lib/services/lesson_data_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


class LessonDataService {
  // Cache loaded lessons to avoid reloading
  static final Map<String, Map<String, dynamic>> _cache = {};
  
  /// Load lesson data from JSON file
  static Future<Map<String, dynamic>?> loadLessonData(String lessonId) async {
    try {
      // Check cache first
      if (_cache.containsKey(lessonId)) {
        if (kDebugMode) {
          print('📦 Loaded lesson from cache: $lessonId');
        }
        return _cache[lessonId];
      }
      
      // Normalize lesson ID to match file name
      // Convert: a1_s1_l1 or A1_S1_L1 -> lesson_a1_s1_l1.json
      final normalizedId = lessonId.toLowerCase();
      final fileName = 'assets/data/lesson_$normalizedId.json';
      
      if (kDebugMode) {
        print('📂 Loading lesson from: $fileName');
      }
      
      // Load JSON file
      final jsonString = await rootBundle.loadString(fileName);
      final Map<String, dynamic> lessonData = json.decode(jsonString);
      
      // Cache it
      _cache[lessonId] = lessonData;
      
      if (kDebugMode) {
        print('✅ Lesson loaded: ${lessonData['title']} (${lessonData['totalExercises']} exercises)');
      }
      
      return lessonData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading lesson $lessonId: $e');
      }
      return null;
    }
  }
  
  /// Check if lesson has content available
  static Future<bool> hasContent(String lessonId) async {
    try {
      final normalizedId = lessonId.toLowerCase();
      final fileName = 'assets/data/lesson_$normalizedId.json';
      await rootBundle.loadString(fileName);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get vocabulary for a lesson
  static Future<List<Map<String, dynamic>>> getVocabulary(String lessonId) async {
    final lessonData = await loadLessonData(lessonId);
    if (lessonData == null) return [];
    
    final vocabulary = lessonData['vocabulary'] as List<dynamic>?;
    return vocabulary?.cast<Map<String, dynamic>>() ?? [];
  }
  
  /// Get exercises for a lesson
  static Future<List<Map<String, dynamic>>> getExercises(String lessonId) async {
    final lessonData = await loadLessonData(lessonId);
    if (lessonData == null) return [];
    
    final exercises = lessonData['exercises'] as List<dynamic>?;
    return exercises?.cast<Map<String, dynamic>>() ?? [];
  }
  
  /// Get lesson title in Kurdish
  static Future<String?> getLessonTitle(String lessonId, {bool kurdish = true}) async {
    final lessonData = await loadLessonData(lessonId);
    if (lessonData == null) return null;
    
    return kurdish 
        ? lessonData['titleKurdish'] as String?
        : lessonData['title'] as String?;
  }
  
  /// Clear cache (useful for testing or memory management)
  static void clearCache() {
    _cache.clear();
    if (kDebugMode) {
      print('🗑️ Lesson cache cleared');
    }
  }
  
  /// Preload multiple lessons (for better performance)
  static Future<void> preloadLessons(List<String> lessonIds) async {
    if (kDebugMode) {
      print('⏳ Preloading ${lessonIds.length} lessons...');
    }
    
    await Future.wait(
      lessonIds.map((id) => loadLessonData(id))
    );
    
    if (kDebugMode) {
      print('✅ Preloaded ${lessonIds.length} lessons');
    }
  }
}