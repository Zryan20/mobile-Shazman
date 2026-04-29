import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson_model.dart';
import '../services/lesson_service.dart';

class LessonProvider extends ChangeNotifier {
  static const bool USE_MOCK_DATA = true;
  List<Lesson> _lessons = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentLessonIndex = 0;
  
  final LessonService _lessonService = LessonService();
  static const String _keyCompletedLessons = 'completed_lesson_ids';
  static const String _keyCurrentLessonIndex = 'current_lesson_index';
  
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
  
  Future<void> loadLessons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      if (USE_MOCK_DATA) {
        await Future.delayed(const Duration(milliseconds: 500));
        _lessons = _getA1Lessons();
      } else {
        _lessons = await _lessonService.fetchLessons();
      }
      await _loadCompletionStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> retryLoadLessons() async {
    await loadLessons();
  }
  
  Future<void> _loadCompletionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedIds = prefs.getStringList(_keyCompletedLessons) ?? [];
      _currentLessonIndex = prefs.getInt(_keyCurrentLessonIndex) ?? 0;
      
      _lessons = _lessons.map((lesson) {
        final isCompleted = completedIds.contains(lesson.id);
        return lesson.copyWith(
          isCompleted: isCompleted,
          isLocked: !_shouldUnlockLesson(lesson, completedIds),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading completion status: $e');
    }
  }
  
  bool _shouldUnlockLesson(Lesson lesson, List<String> completedIds) {
    if (lesson.id == 'a1_s1_l1') return true;
    
    final lessonIndex = _lessons.indexWhere((l) => l.id == lesson.id);
    if (lessonIndex <= 0) return true;
    
    return completedIds.contains(_lessons[lessonIndex - 1].id);
  }
  
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
    } catch (e) {
      debugPrint('Error completing lesson: $e');
    }
  }
  
  List<Lesson> getLessonsByLevel(int level) {
    return _lessons.where((lesson) => lesson.level == level).toList();
  }
  
  Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<void> clearCompletionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCompletedLessons);
      await prefs.remove(_keyCurrentLessonIndex);
      _currentLessonIndex = 0;
      _lessons = _lessons.map((lesson) {
        return lesson.copyWith(
          isCompleted: false,
          isLocked: lesson.id != 'a1_s1_l1',
          completedAt: null,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing completion data: $e');
    }
  }
  
  List<Lesson> _getA1Lessons() {
    return [
      const Lesson(
        id: 'a1_s1_l1',
        title: 'Basic Greetings',
        titleKurdish: 'سڵاوکردنی بنەڕەتی',
        description: 'Hello, Goodbye, Thank you, Please',
        descriptionKurdish: 'سڵاو، خواحافیز، سوپاس، تکایە',
        level: 1,
        unitNumber: 1,
        lessonNumber: 1,
        xpReward: 10,
        estimatedDuration: Duration(minutes: 5),
        isCompleted: false,
        isLocked: false,
        tags: ['vocabulary', 'greetings'],
      ),
      const Lesson(
        id: 'a1_s1_l2',
        title: 'Introductions',
        titleKurdish: 'ناساندنی خۆت',
        description: 'My name is, Nice to meet you',
        descriptionKurdish: 'ناوم ... ە، خۆشحاڵم بە ناسینت',
        level: 1,
        unitNumber: 1,
        lessonNumber: 2,
        xpReward: 10,
        estimatedDuration: Duration(minutes: 5),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'introductions'],
      ),
      const Lesson(
        id: 'a1_s1_l3',
        title: 'Numbers 1-10',
        titleKurdish: 'ژمارەکان ١-١٠',
        description: 'Learn to count from 1 to 10',
        descriptionKurdish: 'فێربە چۆن لە ١ تا ١٠ بژمێریت',
        level: 1,
        unitNumber: 1,
        lessonNumber: 3,
        xpReward: 10,
        estimatedDuration: Duration(minutes: 5),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'numbers'],
      ),
      const Lesson(
        id: 'a1_s1_l4',
        title: 'Numbers 11-20 & Age',
        titleKurdish: 'ژمارەکان ١١-٢٠ و تەمەن',
        description: 'Learn numbers 11-20 and talking about age',
        descriptionKurdish: 'فێری ژمارەکان ١١-٢٠ ببە و باسکردنی تەمەن',
        level: 1,
        unitNumber: 1,
        lessonNumber: 4,
        xpReward: 10,
        estimatedDuration: Duration(minutes: 5),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'numbers', 'age'],
      ),
      const Lesson(
        id: 'a1_s1_l5',
        title: 'Classroom Objects',
        titleKurdish: 'کەلوپەلی پۆل',
        description: 'Pen, book, teacher',
        descriptionKurdish: 'پێنوس، کتێب، مامۆستا',
        level: 1,
        unitNumber: 1,
        lessonNumber: 5,
        xpReward: 10,
        estimatedDuration: Duration(minutes: 5),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'classroom'],
      ),
      const Lesson(
        id: 'a1_s1_l6',
        title: 'Classroom Phrases',
        titleKurdish: 'دەستەواژەکانی پۆل',
        description: 'Open your book, Listen, Write',
        descriptionKurdish: 'کتێبەکەت بکەرەوە، گوێ بگرە، بنووسە',
        level: 1,
        unitNumber: 1,
        lessonNumber: 6,
        xpReward: 10,
        estimatedDuration: Duration(minutes: 5),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'classroom', 'phrases'],
      ),
      const Lesson(
        id: 'a1_s2_l7',
        title: 'Family Members 1',
        titleKurdish: 'ئەندامانی خێزان ١',
        description: 'Mother, father, sister, brother',
        descriptionKurdish: 'دایک، باوک، خوشک، برا',
        level: 1,
        unitNumber: 2,
        lessonNumber: 7,
        xpReward: 15,
        estimatedDuration: Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'family'],
      ),
      const Lesson(
        id: 'a1_s2_l8',
        title: 'Family Members 2',
        titleKurdish: 'ئەندامانی خێزان ٢',
        description: 'This is my mother, possessive adjectives',
        descriptionKurdish: 'ئەمە دایکمە، جێناوە خاوەندارێتییەکان',
        level: 1,
        unitNumber: 2,
        lessonNumber: 8,
        xpReward: 15,
        estimatedDuration: Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'family'],
      ),
      const Lesson(
        id: 'a1_s2_l9',
        title: 'Friends & People 1',
        titleKurdish: 'هاوڕێیان و کەسان ١',
        description: 'Boy, girl, man, woman, friend',
        descriptionKurdish: 'کوڕ، کچ، پیاو، ژن، هاوڕێ',
        level: 1,
        unitNumber: 2,
        lessonNumber: 9,
        xpReward: 15,
        estimatedDuration: Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'people'],
      ),
      const Lesson(
        id: 'a1_s2_l10',
        title: 'Friends & People 2',
        titleKurdish: 'هاوڕێیان و کەسان ٢',
        description: 'He is my friend, pronouns',
        descriptionKurdish: 'ئەو هاوڕێی منە، جێناوەکان',
        level: 1,
        unitNumber: 2,
        lessonNumber: 10,
        xpReward: 15,
        estimatedDuration: Duration(minutes: 7),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'people'],
      ),
      const Lesson(
        id: 'a1_s2_l12',
        title: 'Countries 2',
        titleKurdish: 'وڵاتەکان ٢',
        description: 'I am from Kurdistan, nationalities',
        descriptionKurdish: 'من خەڵکی کوردستانم، نەتەوەکان',
        level: 1,
        unitNumber: 2,
        lessonNumber: 12,
        xpReward: 15,
        estimatedDuration: Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
        tags: ['vocabulary', 'countries'],
      ),
      // Unit 3: Daily Life & Time
      const Lesson(
        id: 'a1_s3_l13',
        title: 'Daily Routine 1',
        titleKurdish: 'کاری ڕۆژانە ١',
        description: 'Wake up, eat, sleep',
        descriptionKurdish: 'هەستان، خواردن، نوستن',
        level: 1,
        unitNumber: 3,
        lessonNumber: 13,
        xpReward: 20,
        estimatedDuration: Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s3_l14',
        title: 'Daily Routine 2',
        titleKurdish: 'کاری ڕۆژانە ٢',
        description: 'Go to work, study',
        descriptionKurdish: 'چوونە سەر کار، خوێندن',
        level: 1,
        unitNumber: 3,
        lessonNumber: 14,
        xpReward: 20,
        estimatedDuration: Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s3_l15',
        title: 'Time 1',
        titleKurdish: 'کات ١',
        description: 'Hours and minutes',
        descriptionKurdish: 'کاتژمێر و خولەک',
        level: 1,
        unitNumber: 3,
        lessonNumber: 15,
        xpReward: 20,
        estimatedDuration: Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s3_l16',
        title: 'Time 2',
        titleKurdish: 'کات ٢',
        description: 'What time is it?',
        descriptionKurdish: 'کاتژمێر چەندە؟',
        level: 1,
        unitNumber: 3,
        lessonNumber: 16,
        xpReward: 20,
        estimatedDuration: Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s3_l17',
        title: 'Days of the week',
        titleKurdish: 'ڕۆژەکانی هەفتە',
        description: 'Monday to Sunday',
        descriptionKurdish: 'دووشەممە تا یەکشەممە',
        level: 1,
        unitNumber: 3,
        lessonNumber: 17,
        xpReward: 20,
        estimatedDuration: Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s3_l18',
        title: 'Months',
        titleKurdish: 'مانگەکان',
        description: 'January to December',
        descriptionKurdish: 'کانوونی دووەم تا کانوونی یەکەم',
        level: 1,
        unitNumber: 3,
        lessonNumber: 18,
        xpReward: 20,
        estimatedDuration: Duration(minutes: 8),
        isCompleted: false,
        isLocked: true,
      ),
      // Unit 4: Food & Home
      const Lesson(
        id: 'a1_s4_l19',
        title: 'Food 1',
        titleKurdish: 'خواردن ١',
        description: 'Fruits and vegetables',
        descriptionKurdish: 'میوە و سەوزە',
        level: 1,
        unitNumber: 4,
        lessonNumber: 19,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s4_l20',
        title: 'Food 2',
        titleKurdish: 'خواردن ٢',
        description: 'Drinks and snacks',
        descriptionKurdish: 'خواردنەوە و سووکە ژەمەکان',
        level: 1,
        unitNumber: 4,
        lessonNumber: 20,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s4_l21',
        title: 'Home 1',
        titleKurdish: 'ماڵ ١',
        description: 'Rooms in a house',
        descriptionKurdish: 'ژوورەکانی ماڵ',
        level: 1,
        unitNumber: 4,
        lessonNumber: 21,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s4_l22',
        title: 'Home 2',
        titleKurdish: 'ماڵ ٢',
        description: 'Furniture',
        descriptionKurdish: 'کەلوپەلی ناوماڵ',
        level: 1,
        unitNumber: 4,
        lessonNumber: 22,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s4_l23',
        title: 'Cooking',
        titleKurdish: 'لێنانی خواردن',
        description: 'Verbs for cooking',
        descriptionKurdish: 'کردارەکانی لێنانی خواردن',
        level: 1,
        unitNumber: 4,
        lessonNumber: 23,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s4_l24',
        title: 'Review Unit 4',
        titleKurdish: 'پێداچوونەوەی بەشی ٤',
        description: 'Review everything in unit 4',
        descriptionKurdish: 'پێداچوونەوەی هەموو شتێک لە بەشی ٤',
        level: 1,
        unitNumber: 4,
        lessonNumber: 24,
        xpReward: 30,
        estimatedDuration: Duration(minutes: 10),
        isCompleted: false,
        isLocked: true,
      ),
      // Unit 5: Weather & Places
      const Lesson(
        id: 'a1_s5_l25',
        title: 'Weather 1',
        titleKurdish: 'کەشوهەوا ١',
        description: 'Sunny, rainy, cloudy',
        descriptionKurdish: 'خۆرهەتاو، باراناوی، هەوراوی',
        level: 1,
        unitNumber: 5,
        lessonNumber: 25,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s5_l26',
        title: 'Weather 2',
        titleKurdish: 'کەشوهەوا ٢',
        description: 'Hot and cold',
        descriptionKurdish: 'گەرم و سارد',
        level: 1,
        unitNumber: 5,
        lessonNumber: 26,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s5_l27',
        title: 'Places 1',
        titleKurdish: 'شوێنەکان ١',
        description: 'Park, hospital, school',
        descriptionKurdish: 'پارک، نەخۆشخانە، قوتابخانە',
        level: 1,
        unitNumber: 5,
        lessonNumber: 27,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s5_l28',
        title: 'Places 2',
        titleKurdish: 'شوێنەکان ٢',
        description: 'Shop, restaurant, bank',
        descriptionKurdish: 'دوکان، چێشتخانە، بانک',
        level: 1,
        unitNumber: 5,
        lessonNumber: 28,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s5_l29',
        title: 'Directions',
        titleKurdish: 'ئاراستەکان',
        description: 'Left, right, straight',
        descriptionKurdish: 'چەپ، ڕاست، ڕاستەوخۆ',
        level: 1,
        unitNumber: 5,
        lessonNumber: 29,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s5_l30',
        title: 'Transportation',
        titleKurdish: 'گواستنەوە',
        description: 'Car, bus, plane',
        descriptionKurdish: 'ئۆتۆمبێل، پاس، فڕۆکە',
        level: 1,
        unitNumber: 5,
        lessonNumber: 30,
        xpReward: 25,
        estimatedDuration: Duration(minutes: 9),
        isCompleted: false,
        isLocked: true,
      ),
      // Unit 6: Activities & Leisure
      const Lesson(
        id: 'a1_s6_l31',
        title: 'Hobbies 1',
        titleKurdish: 'خولیایەکان ١',
        description: 'Reading, swimming, music',
        descriptionKurdish: 'خوێندنەوە، مەلەکردن، مۆسیقا',
        level: 1,
        unitNumber: 6,
        lessonNumber: 31,
        xpReward: 30,
        estimatedDuration: Duration(minutes: 10),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s6_l32',
        title: 'Hobbies 2',
        titleKurdish: 'خولیایەکان ٢',
        description: 'Sports and games',
        descriptionKurdish: 'وەرزش و یارییەکان',
        level: 1,
        unitNumber: 6,
        lessonNumber: 32,
        xpReward: 30,
        estimatedDuration: Duration(minutes: 10),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s6_l33',
        title: 'Vacation 1',
        titleKurdish: 'پشوو ١',
        description: 'Beach, mountains',
        descriptionKurdish: 'کەنار دەریا، چیاکان',
        level: 1,
        unitNumber: 6,
        lessonNumber: 33,
        xpReward: 30,
        estimatedDuration: Duration(minutes: 10),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s6_l34',
        title: 'Vacation 2',
        titleKurdish: 'پشوو ٢',
        description: 'Hotel, luggage',
        descriptionKurdish: 'وتێل، جانتا',
        level: 1,
        unitNumber: 6,
        lessonNumber: 34,
        xpReward: 30,
        estimatedDuration: Duration(minutes: 10),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s6_l35',
        title: 'Shopping',
        titleKurdish: 'بازاڕکردن',
        description: 'Clothes and prices',
        descriptionKurdish: 'جلوبەرگ و نرخەکان',
        level: 1,
        unitNumber: 6,
        lessonNumber: 35,
        xpReward: 30,
        estimatedDuration: Duration(minutes: 10),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s6_l36',
        title: 'Free Time',
        titleKurdish: 'کاتی بەتاڵ',
        description: 'Talking about free time',
        descriptionKurdish: 'باسکردنی کاتی بەتاڵ',
        level: 1,
        unitNumber: 6,
        lessonNumber: 36,
        xpReward: 30,
        estimatedDuration: Duration(minutes: 10),
        isCompleted: false,
        isLocked: true,
      ),
      // Unit 7: Final Review
      const Lesson(
        id: 'a1_s7_l37',
        title: 'Grammar Review',
        titleKurdish: 'پێداچوونەوەی ڕێزمان',
        description: 'All A1 grammar points',
        descriptionKurdish: 'هەموو خاڵە ڕێزمانییەکانی A1',
        level: 1,
        unitNumber: 7,
        lessonNumber: 37,
        xpReward: 50,
        estimatedDuration: Duration(minutes: 15),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s7_l38',
        title: 'Vocabulary Review',
        titleKurdish: 'پێداچوونەوەی وشەکان',
        description: 'All A1 vocabulary',
        descriptionKurdish: 'هەموو وشەکانی A1',
        level: 1,
        unitNumber: 7,
        lessonNumber: 38,
        xpReward: 50,
        estimatedDuration: Duration(minutes: 15),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s7_l39',
        title: 'Reading Test',
        titleKurdish: 'تاقیکردنەوەی خوێندنەوە',
        description: 'Final A1 reading test',
        descriptionKurdish: 'تاقیکردنەوەی خوێندنەوەی کۆتایی A1',
        level: 1,
        unitNumber: 7,
        lessonNumber: 39,
        xpReward: 50,
        estimatedDuration: Duration(minutes: 15),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s7_l40',
        title: 'Listening Test',
        titleKurdish: 'تاقیکردنەوەی بیستن',
        description: 'Final A1 listening test',
        descriptionKurdish: 'تاقیکردنەوەی بیستنی کۆتایی A1',
        level: 1,
        unitNumber: 7,
        lessonNumber: 40,
        xpReward: 50,
        estimatedDuration: Duration(minutes: 15),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s7_l41',
        title: 'Speaking Test',
        titleKurdish: 'تاقیکردنەوەی قسەکردن',
        description: 'Final A1 speaking test',
        descriptionKurdish: 'تاقیکردنەوەی قسەکردنی کۆتایی A1',
        level: 1,
        unitNumber: 7,
        lessonNumber: 41,
        xpReward: 50,
        estimatedDuration: Duration(minutes: 15),
        isCompleted: false,
        isLocked: true,
      ),
      const Lesson(
        id: 'a1_s7_l42',
        title: 'Final Exam',
        titleKurdish: 'تاقیکردنەوەی کۆتایی',
        description: 'Master A1 Level',
        descriptionKurdish: 'بەدەستهێنانی ئاستی A1',
        level: 1,
        unitNumber: 7,
        lessonNumber: 42,
        xpReward: 100,
        estimatedDuration: Duration(minutes: 20),
        isCompleted: false,
        isLocked: true,
      ),
    ];
  }
}