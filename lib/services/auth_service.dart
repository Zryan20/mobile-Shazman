import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Check if user is currently logged in
  Future<bool> isUserLoggedIn() async {
    try {
      final user = _auth.currentUser;
      return user != null;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('تکایە دڵنیابەرەوە لە زانیارییەکانت');
      }

      final userData = {
        'id': user.uid,
        'email': user.email,
        'name': user.displayName ?? _getNameFromEmail(user.email ?? ''),
      };

      return AuthResult.success('چوونەژوورەوە سەرکەوتووبوو', userData);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException code: ${e.code}');
      debugPrint('❌ FirebaseAuthException message: ${e.message}');
      
      String message = 'هەڵەیەک ڕوویدا لە چوونەژوورەوە';
      if (e.code == 'user-not-found') {
        message = 'ئەم هەژمارە بوونی نییە';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'وشەی تێپەڕ هەڵەیە یان ئیمەیڵەکە نادروستە';
      } else if (e.code == 'invalid-email') {
        message = 'ئیمەیڵەکە نادروستە';
      } else if (e.code == 'user-disabled') {
        message = 'ئەم هەژمارە ڕاگیراوە';
      } else if (e.code == 'too-many-requests') {
        message = 'هەوڵی زۆر دراوە، تکایە دواتر هەوڵ بدەرەوە';
      }
      return AuthResult.failure(message);
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      return AuthResult.failure('هەڵەیەک ڕوویدا، تکایە دووبارە هەوڵ بدەرەوە');
    }
  }

  // Sign up with name, email and password
  Future<AuthResult> signUpWithEmail(
      String name, String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return AuthResult.failure('هەڵەیەک ڕوویدا لە دروستکردنی هەژمار');
      }

      // Update display name
      await user.updateDisplayName(name);

      final userData = {
        'id': user.uid,
        'email': user.email,
        'name': name,
      };

      return AuthResult.success('هەژمارەکەت بە سەرکەوتوویی دروستکرا', userData);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException code: ${e.code}');
      debugPrint('❌ FirebaseAuthException message: ${e.message}');
      
      String message = 'هەڵەیەک ڕوویدا لە دروستکردنی هەژمار';
      if (e.code == 'weak-password') {
        message = 'وشەی تێپەڕەکە لاوازە';
      } else if (e.code == 'email-already-in-use') {
        message = 'ئەم ئیمەیڵە پێشتر بەکارهێنراوە';
      } else if (e.code == 'invalid-email') {
        message = 'ئیمەیڵەکە نادروستە';
      } else if (e.code == 'operation-not-allowed') {
        message = 'دروستکردنی هەژمار ڕێگەنەدراوە';
      }
      return AuthResult.failure(message);
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      return AuthResult.failure('هەڵەیەک ڕوویدا، تکایە دووبارە هەوڵ بدەرەوە');
    }
  }

  // Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
      return AuthResult.success('ئیمەیڵی گۆڕینی وشەی تێپەڕ نێردرا بۆ $normalizedEmail');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException code: ${e.code}');
      
      String message = 'هەڵەیەک ڕوویدا لە ناردنی ئیمەیڵ';
      if (e.code == 'user-not-found') {
        message = 'ئەم هەژمارە بوونی نییە';
      } else if (e.code == 'invalid-email') {
        message = 'ئیمەیڵەکە نادروستە';
      }
      return AuthResult.failure(message);
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      return AuthResult.failure('هەڵەیەک ڕوویدا، تکایە دووبارە هەوڵ بدەرەوە');
    }
  }

  // Delete current user account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure('بەکارهێنەر نەدۆزرایەوە');
      }

      await user.delete();
      return AuthResult.success('هەژمارەکەت بە سەرکەوتوویی سڕایەوە');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException code: ${e.code}');
      
      String message = 'هەڵەیەک ڕوویدا لە سڕینەوەی هەژمار';
      if (e.code == 'requires-recent-login') {
        message = 'تکایە جارێکی تر بچۆوە ژوورەوە بۆ ئەوەی بتوانیت هەژمارەکەت بسڕیتەوە (بەهۆکاری پاراستن)';
      }
      return AuthResult.failure(message);
    } catch (e) {
      debugPrint('❌ Account deletion error: $e');
      return AuthResult.failure('هەڵەیەک ڕوویدا لە کاتی سڕینەوەی هەژمار');
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return {
      'id': user.uid,
      'email': user.email,
      'name': user.displayName ?? _getNameFromEmail(user.email ?? ''),
    };
  }

  // Private helper methods

  String _getNameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    final username = email.split('@').first;
    final parts = username.split('.');

    if (parts.length > 1) {
      return parts
          .map((part) =>
              part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : '')
          .join(' ');
    }

    return username.isNotEmpty
        ? username[0].toUpperCase() + username.substring(1)
        : 'User';
  }
}

// Authentication result class
class AuthResult {
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? userData;

  const AuthResult._({
    required this.isSuccess,
    required this.message,
    this.userData,
  });

  factory AuthResult.success(String message, [Map<String, dynamic>? userData]) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      userData: userData,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }

  @override
  String toString() {
    return 'AuthResult(isSuccess: $isSuccess, message: $message, userData: $userData)';
  }
}
