import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/lesson_model.dart';

class LessonService {
  // TODO: Replace with your actual API base URL
  static const String _baseUrl = 'https://api.shazman.com'; // Change this!
  static const String _lessonsEndpoint = '/api/v1/lessons';
  
  /// Check internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  
  /// Fetch all lessons from API (requires internet)
  Future<List<Lesson>> fetchLessons() async {
    // Check internet connection first
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw NoInternetException('پەیوەندی ئینتەرنێت نییە. تکایە پەیوەندی ئینتەرنێت بپشکنە');
    }
    
    try {
      final url = Uri.parse('$_baseUrl$_lessonsEndpoint');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add authentication header if needed
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('کاتی چاوەڕوانکراو تەواوبوو. تکایە دووبارە هەوڵ بدەرەوە');
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final lessons = jsonData
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('✅ Loaded ${lessons.length} lessons from API');
        return lessons;
      } else if (response.statusCode == 401) {
        throw AuthenticationException('دەست پێگەیشتن ڕەتکرایەوە. تکایە دووبارە بچۆژوورەوە');
      } else if (response.statusCode == 404) {
        throw NotFoundException('وانەکان نەدۆزرانەوە');
      } else if (response.statusCode >= 500) {
        throw ServerException('کێشەیەک لە سێرڤەردا هەیە. تکایە دواتر هەوڵ بدەرەوە');
      } else {
        throw ApiException('هەڵەیەک ڕوویدا: ${response.statusCode}');
      }
    } on SocketException {
      throw NoInternetException('پەیوەندی ئینتەرنێت نییە. تکایە پەیوەندی ئینتەرنێت بپشکنە');
    } on TimeoutException catch (e) {
      throw e;
    } on NoInternetException {
      rethrow;
    } catch (e) {
      print('❌ Error fetching lessons from API: $e');
      throw ApiException('هەڵەیەک لە بارکردنی وانەکاندا ڕوویدا');
    }
  }
  
  /// Fetch lessons for a specific level (requires internet)
  Future<List<Lesson>> fetchLessonsByLevel(int level) async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw NoInternetException('پەیوەندی ئینتەرنێت نییە. تکایە پەیوەندی ئینتەرنێت بپشکنە');
    }
    
    try {
      final url = Uri.parse('$_baseUrl$_lessonsEndpoint?level=$level');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Lesson.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException('وانەکانی ئاستی $level بارنەبوون');
      }
    } on SocketException {
      throw NoInternetException('پەیوەندی ئینتەرنێت نییە. تکایە پەیوەندی ئینتەرنێت بپشکنە');
    } catch (e) {
      if (e is NoInternetException) rethrow;
      print('❌ Error fetching lessons for level $level: $e');
      throw ApiException('هەڵەیەک لە بارکردنی وانەکانی ئاستی $level');
    }
  }
  
  /// Fetch a single lesson by ID (requires internet)
  Future<Lesson> fetchLessonById(String lessonId) async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw NoInternetException('پەیوەندی ئینتەرنێت نییە. تکایە پەیوەندی ئینتەرنێت بپشکنە');
    }
    
    try {
      final url = Uri.parse('$_baseUrl$_lessonsEndpoint/$lessonId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Lesson.fromJson(jsonData as Map<String, dynamic>);
      } else {
        throw ApiException('وانە $lessonId بارنەبوو');
      }
    } on SocketException {
      throw NoInternetException('پەیوەندی ئینتەرنێت نییە. تکایە پەیوەندی ئینتەرنێت بپشکنە');
    } catch (e) {
      if (e is NoInternetException) rethrow;
      print('❌ Error fetching lesson $lessonId: $e');
      throw ApiException('هەڵەیەک لە بارکردنی وانە $lessonId');
    }
  }
  
  /// Update lesson completion status on server (requires internet)
  Future<void> updateLessonCompletion(String lessonId, bool isCompleted) async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      throw NoInternetException('پەیوەندی ئینتەرنێت نییە. پێشکەوتنەکەت پاشەکەوت دەکرێت بەڵام سینک ناکرێت');
    }
    
    try {
      final url = Uri.parse('$_baseUrl$_lessonsEndpoint/$lessonId/complete');
      
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add authentication header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'isCompleted': isCompleted,
          'completedAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('✅ Lesson $lessonId completion synced to server');
      } else {
        throw ApiException('پێشکەوتن سینک نەکرا');
      }
    } on SocketException {
      throw NoInternetException('پەیوەندی ئینتەرنێت نییە. پێشکەوتنەکەت پاشەکەوت دەکرێت بەڵام سینک ناکرێت');
    } catch (e) {
      if (e is NoInternetException) rethrow;
      print('❌ Error updating lesson completion: $e');
      // Don't throw - allow offline completion tracking locally
    }
  }
}

// Custom exceptions
class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
  
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  
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