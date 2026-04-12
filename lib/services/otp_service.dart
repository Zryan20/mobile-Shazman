import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Service for sending and verifying email OTPs via Firebase Cloud Functions.
class OtpService {
  // Singleton
  static final OtpService _instance = OtpService._internal();
  factory OtpService() => _instance;
  OtpService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Send a 6-digit OTP to the given [email].
  /// Returns an [OtpResult] with success/failure info.
  Future<OtpResult> sendOtp(String email) async {
    try {
      final callable = _functions.httpsCallable('sendOtp');
      final result = await callable.call({'email': email});
      final data = result.data as Map<dynamic, dynamic>;
      return OtpResult.success(data['message'] as String? ?? 'کۆدەکە نێردرا');
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ sendOtp error [${e.code}]: ${e.message}');
      return OtpResult.failure(e.message ?? 'هەڵەیەک ڕوویدا لە ناردنی کۆد');
    } catch (e) {
      debugPrint('❌ sendOtp unexpected error: $e');
      return OtpResult.failure('هەڵەیەک ڕوویدا، تکایە دووبارە هەوڵ بدەرەوە');
    }
  }

  /// Verify the [otp] entered by the user.
  /// Returns an [OtpResult] indicating success or the reason for failure.
  Future<OtpResult> verifyOtp(String otp) async {
    try {
      final callable = _functions.httpsCallable('verifyOtp');
      final result = await callable.call({'otp': otp});
      final data = result.data as Map<dynamic, dynamic>;
      return OtpResult.success(data['message'] as String? ?? 'دڵنیاکردنەوە سەرکەوتوو بوو');
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ verifyOtp error [${e.code}]: ${e.message}');
      return OtpResult.failure(e.message ?? 'هەڵەیەک ڕوویدا لە پشکنینی کۆد');
    } catch (e) {
      debugPrint('❌ verifyOtp unexpected error: $e');
      return OtpResult.failure('هەڵەیەک ڕوویدا، تکایە دووبارە هەوڵ بدەرەوە');
    }
  }
}

/// Result returned by [OtpService] methods.
class OtpResult {
  final bool isSuccess;
  final String message;

  const OtpResult._({required this.isSuccess, required this.message});

  factory OtpResult.success(String message) =>
      OtpResult._(isSuccess: true, message: message);

  factory OtpResult.failure(String message) =>
      OtpResult._(isSuccess: false, message: message);
}
