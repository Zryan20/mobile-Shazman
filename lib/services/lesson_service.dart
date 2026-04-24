import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'Lessons';
  
  /// Fetch all lessons from Firestore
  Future<List<Lesson>> fetchLessons() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('level')
          .orderBy('lessonNumber')
          .get();
      
      final lessons = querySnapshot.docs
          .map((doc) => Lesson.fromJson(doc.data()))
          .toList();
      
      print('✅ Loaded ${lessons.length} lessons from Firestore');
      return lessons;
    } catch (e) {
      print('❌ Error fetching lessons from Firestore: $e');
      throw ApiException('هەڵەیەک لە بارکردنی وانەکاندا ڕوویدا');
    }
  }
  
  /// Fetch lessons for a specific level from Firestore
  Future<List<Lesson>> fetchLessonsByLevel(int level) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('level', isEqualTo: level)
          .orderBy('lessonNumber')
          .get();
      
      return querySnapshot.docs
          .map((doc) => Lesson.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching lessons for level $level: $e');
      throw ApiException('هەڵەیەک لە بارکردنی وانەکانی ئاستی $level');
    }
  }
  
  /// Fetch a single lesson by ID from Firestore
  Future<Lesson> fetchLessonById(String lessonId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(lessonId).get();
      
      if (doc.exists) {
        return Lesson.fromJson(doc.data()!);
      } else {
        throw NotFoundException('وانە نەدۆزرایەوە');
      }
    } catch (e) {
      print('❌ Error fetching lesson $lessonId: $e');
      throw ApiException('هەڵەیەک لە بارکردنی وانە $lessonId');
    }
  }
  
  /// Update lesson completion status
  Future<void> updateLessonCompletion(String lessonId, bool isCompleted) async {
    // Progress syncing is already handled by BackendService.updateProgress
    print('✅ Lesson $lessonId status updated (Synced via ProgressProvider)');
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
  
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  
  @override
  String toString() => message;
}