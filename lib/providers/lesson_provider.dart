import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson_model.dart';
import '../services/lesson_service.dart';

class LessonProvider extends ChangeNotifier {
  // ========================================
  // 🔧 CONFIGURATION: Toggle between mock and API
  // ========================================
  static const bool USE_MOCK_DATA = true; // Set to false when API is ready
  
  // Private fields
  List<Lesson> _lessons = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentLessonIndex = 0;
  
  // Service
  final LessonService _lessonService = LessonService();
  
  // SharedPreferences keys
  static const String _keyCompletedLessons = 'completed_lesson_ids';
  static const String _keyCurrentLessonIndex = 'current_lesson_index';
  
  // Getters
  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentLessonIndex => _currentLessonIndex;
  
  Lesson? get currentLesson {
    if (_lessons.isEmpty || _currentLessonIndex >= _lessons.length) {
      return null;
    }
    return _lessons[_currentLessonIndex];
  }
  
  /// Load lessons from API or mock data
  Future<void> loadLessons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      if (USE_MOCK_DATA) {
        await Future.delayed(const Duration(milliseconds: 500));
        _lessons = _getA1Lessons();
        
        if (kDebugMode) {
          print('✅ Mock lessons loaded: ${_lessons.length} lessons');
        }
      } else {
        _lessons = await _lessonService.fetchLessons();
        
        if (kDebugMode) {
          print('✅ Lessons loaded from API: ${_lessons.length} lessons');
        }
      }
      
      await _loadCompletionStatus();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      
      if (kDebugMode) {
        print('❌ Error loading lessons: $e');
      }
    }
  }
  
  /// Retry loading lessons
  Future<void> retryLoadLessons() async {
    await loadLessons();
  }
  
  /// Load completion status from SharedPreferences
  Future<void> _loadCompletionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedIds = prefs.getStringList(_keyCompletedLessons) ?? [];
      _currentLessonIndex = prefs.getInt(_keyCurrentLessonIndex) ?? 0;
      
      _lessons = _lessons.map((lesson) {
        final isCompleted = completedIds.contains(lesson.id);
        return lesson.copyWith(
          isCompleted: isCompleted,
          isLocked: !_shouldUnlockLesson(lesson),
        );
      }).toList();
      
      if (kDebugMode) {
        print('✅ Completion status loaded: ${completedIds.length} completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading completion status: $e');
      }
    }
  }
  
  /// Check if a lesson should be unlocked
  bool _shouldUnlockLesson(Lesson lesson) {
    if (lesson.lessonNumber == 1) return true;
    
    final previousLesson = _lessons.firstWhere(
      (l) => l.level == lesson.level &&
             l.unitNumber == lesson.unitNumber &&
             l.lessonNumber == lesson.lessonNumber - 1,
      orElse: () => lesson,
    );
    
    return previousLesson.isCompleted;
  }
  
  /// Mark current lesson as completed
  Future<void> completeCurrentLesson() async {
    if (currentLesson == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedIds = prefs.getStringList(_keyCompletedLessons) ?? [];
      
      if (!completedIds.contains(currentLesson!.id)) {
        completedIds.add(currentLesson!.id);
        await prefs.setStringList(_keyCompletedLessons, completedIds);
      }
      
      final index = _lessons.indexWhere((l) => l.id == currentLesson!.id);
      if (index != -1) {
        _lessons[index] = _lessons[index].copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      
      if (_currentLessonIndex < _lessons.length - 1) {
        _currentLessonIndex++;
        await prefs.setInt(_keyCurrentLessonIndex, _currentLessonIndex);
        
        if (_currentLessonIndex < _lessons.length) {
          _lessons[_currentLessonIndex] = _lessons[_currentLessonIndex].copyWith(
            isLocked: false,
          );
        }
      }
      
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ Lesson completed: ${currentLesson!.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error completing lesson: $e');
      }
    }
  }
  
  /// Get lessons by level
  List<Lesson> getLessonsByLevel(int level) {
    return _lessons.where((lesson) => lesson.level == level).toList();
  }
  
  /// Get lesson by ID
  Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Clear all completion data
  Future<void> clearCompletionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCompletedLessons);
      await prefs.remove(_keyCurrentLessonIndex);
      
      _currentLessonIndex = 0;
      
      _lessons = _lessons.map((lesson) {
        return lesson.copyWith(
          isCompleted: false,
          isLocked: lesson.lessonNumber != 1,
          completedAt: null,
        );
      }).toList();
      
      notifyListeners();
      
      if (kDebugMode) {
        print('🗑️ Completion data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing completion data: $e');
      }
    }
  }
  
  // ========================================
  // 📦 A1 LESSONS - Complete Structure
  // ========================================
  
  List<Lesson> _getA1Lessons() {
    return [
      // ========================================
      // SECTION 1: Basics (3 lessons)
      // ========================================
      
      Lesson(
        id: 'a1_s1_l1',
        title: 'سڵاوکردن و ناساندن - Greetings & Introductions',
        description: 'Lesson content loaded from assets/data',
        level: 1,
        unitNumber: 1,
        lessonNumber: 1,
        xpReward: 10,
        estimatedDuration: const Duration(minutes: 5),
        isCompleted: false,
        isLocked: false,
        tags: ['vocabulary'],
      ),
      
      Lesson(
        id: 'a1_s1_l2',
        title: 'ژمارەکان ١-٢٠ - Numbers 1-20',
        description: 'One, two, three... twenty | "How old are you?"',
        level: 1,
        unitNumber: 1,
        lessonNumber: 2,
        xpReward: 10,
        estimatedDuration: const Duration(minutes: 5),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'numbers', 'questions'],
      ),
      
      Lesson(
        id: 'a1_s1_l3',
        title: 'زمانی پۆل - Classroom Language',
        description: 'Pen, book, teacher, listen, write | "Open your book."',
        level: 1,
        unitNumber: 1,
        lessonNumber: 3,
        xpReward: 10,
        estimatedDuration: const Duration(minutes: 6),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'imperatives', 'classroom'],
      ),
      
      // ========================================
      // SECTION 2: People and Family (3 lessons)
      // ========================================
      
      Lesson(
        id: 'a1_s2_l4',
        title: 'ئەندامانی خێزان - Family Members',
        description: 'Mother, father, sister, brother | "This is my mother."',
        level: 1,
        unitNumber: 2,
        lessonNumber: 4,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'family', 'possessive-adjectives'],
      ),
      
      Lesson(
        id: 'a1_s2_l5',
        title: 'هاوڕێیان و کەسان - Friends and People',
        description: 'Boy, girl, man, woman, friend | "He is my friend."',
        level: 1,
        unitNumber: 2,
        lessonNumber: 5,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'people', 'pronouns-he-she'],
      ),
      
      Lesson(
        id: 'a1_s2_l6',
        title: 'وڵات و نەتەوەکان - Countries and Nationalities',
        description: 'Iraq, America, Kurdistan, English, Kurdish | "I am from Kurdistan."',
        level: 1,
        unitNumber: 2,
        lessonNumber: 6,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'countries', 'from'],
      ),
      
      // ========================================
      // SECTION 3: Daily Life (3 lessons)
      // ========================================
      
      Lesson(
        id: 'a1_s3_l7',
        title: 'ژمارە، ڕۆژ و مانگ - Numbers 20-100, Days, Months',
        description: 'Monday, January, birthday | "Today is Monday. My birthday is in May."',
        level: 1,
        unitNumber: 3,
        lessonNumber: 7,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'numbers', 'dates', 'have-got'],
      ),
      
      Lesson(
        id: 'a1_s3_l8',
        title: 'ڕۆتینی ڕۆژانە - Daily Routines',
        description: 'Wake up, go to school, eat, sleep | "I go to school at 8."',
        level: 1,
        unitNumber: 3,
        lessonNumber: 8,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'routines', 'present-simple'],
      ),
      
      Lesson(
        id: 'a1_s3_l9',
        title: 'کات و خشتە - Time and Schedules',
        description: 'Clock, hour, morning, evening | "It\'s 3 o\'clock."',
        level: 1,
        unitNumber: 3,
        lessonNumber: 9,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'time', 'telling-time'],
      ),
      
      // ========================================
      // SECTION 4: Food and Home (3 lessons)
      // ========================================
      
      Lesson(
        id: 'a1_s4_l10',
        title: 'خواردن و خواردنەوە - Food and Drinks',
        description: 'Apple, bread, tea, water | "I like apples."',
        level: 1,
        unitNumber: 4,
        lessonNumber: 10,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'food', 'like'],
      ),
      
      Lesson(
        id: 'a1_s4_l11',
        title: 'لە ماڵەوە - At Home',
        description: 'House, room, bed, chair | "There is a bed in my room."',
        level: 1,
        unitNumber: 4,
        lessonNumber: 11,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'home', 'there-is-are'],
      ),
      
      Lesson(
        id: 'a1_s4_l12',
        title: 'شتە ڕۆژانەکان - Everyday Objects',
        description: 'Phone, bag, keys, money | "This is my phone."',
        level: 1,
        unitNumber: 4,
        lessonNumber: 12,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'objects', 'this-that'],
      ),
      
      // ========================================
      // SECTION 5: World Around Us (3 lessons)
      // ========================================
      
      Lesson(
        id: 'a1_s5_l13',
        title: 'کەش و وەرز - Weather and Seasons',
        description: 'Hot, cold, sunny, rain, winter | "It\'s cold today."',
        level: 1,
        unitNumber: 5,
        lessonNumber: 13,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'weather', 'present-simple'],
      ),
      
      Lesson(
        id: 'a1_s5_l14',
        title: 'ڕەنگ و جلوبەرگ - Colors and Clothes',
        description: 'Red, blue, shirt, shoes | "I\'m wearing a blue shirt."',
        level: 1,
        unitNumber: 5,
        lessonNumber: 14,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'colors', 'clothes', 'present-continuous'],
      ),
      
      Lesson(
        id: 'a1_s5_l15',
        title: 'شار و شوێنەکان - Town and Places',
        description: 'School, park, shop, hospital | "The bank is near the park."',
        level: 1,
        unitNumber: 5,
        lessonNumber: 15,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'places', 'prepositions'],
      ),
      
      // ========================================
      // SECTION 6: Travel and Activities (3 lessons)
      // ========================================
      
      Lesson(
        id: 'a1_s6_l16',
        title: 'گواستنەوە - Transport',
        description: 'Car, bus, train, walk | "I go to school by bus."',
        level: 1,
        unitNumber: 6,
        lessonNumber: 16,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'transport', 'by'],
      ),
      
      Lesson(
        id: 'a1_s6_l17',
        title: 'حەزوسەرگەرمی - Hobbies and Free Time',
        description: 'Play football, watch TV, read books | "I play football on Fridays."',
        level: 1,
        unitNumber: 6,
        lessonNumber: 17,
        xpReward: 15,
        estimatedDuration: const Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'hobbies', 'present-simple-he-she'],
      ),
      
      Lesson(
        id: 'a1_s6_l18',
        title: 'پشوو و پلان - Holidays and Plans',
        description: 'Travel, holiday, beach, visit | "We go on holiday in summer."',
        level: 1,
        unitNumber: 6,
        lessonNumber: 18,
        xpReward: 20,
        estimatedDuration: const Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'holidays', 'going-to'],
      ),
      
      // ========================================
      // SECTION 7: Review and Communication (3 lessons)
      // ========================================
      
      Lesson(
        id: 'a1_s7_l19',
        title: 'پێداچوونەوەی یەکەم - Review 1 (Lessons 1-9)',
        description: 'Review of basics, people, family, and daily life',
        level: 1,
        unitNumber: 7,
        lessonNumber: 19,
        xpReward: 25,
        estimatedDuration: const Duration(minutes: 15),
        isCompleted: false,
        isLocked: true,
        tags: ['review', 'practice', 'mixed'],
      ),
      
      Lesson(
        id: 'a1_s7_l20',
        title: 'پێداچوونەوەی دووەم - Review 2 (Lessons 10-18)',
        description: 'Review of food, home, world, travel, and activities',
        level: 1,
        unitNumber: 7,
        lessonNumber: 20,
        xpReward: 25,
        estimatedDuration: const Duration(minutes: 15),
        isCompleted: false,
        isLocked: true,
        tags: ['review', 'practice', 'mixed'],
      ),
      
      Lesson(
        id: 'a1_s7_l21',
        title: 'ڕاهێنانی کۆتایی - Final Practice',
        description: 'Short dialogues and role play - Complete A1 practice',
        level: 1,
        unitNumber: 7,
        lessonNumber: 21,
        xpReward: 50,
        estimatedDuration: const Duration(minutes: 20),
        isCompleted: false,
        isLocked: true,
        tags: ['review', 'dialogue', 'roleplay', 'final'],
      ),
    ];
  }
}