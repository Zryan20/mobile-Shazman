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
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
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
      String message = 'هەڵەیەک ڕوویدا لە چوونەژوورەوە';
      if (e.code == 'user-not-found') {
        message = 'ئەم هەژمارە بوونی نییە';
      } else if (e.code == 'wrong-password') {
        message = 'وشەی تێپەڕ هەڵەیە';
      } else if (e.code == 'invalid-email') {
        message = 'ئیمەیڵەکە نادروستە';
      } else if (e.code == 'user-disabled') {
        message = 'ئەم هەژمارە ڕاگیراوە';
      }
      return AuthResult.failure(message);
    } catch (e) {
      debugPrint('Sign in error: $e');
      return AuthResult.failure('هەڵەیەک ڕوویدا، تکایە دووبارە هەوڵ بدەرەوە');
    }
  }

  // Sign up with name, email and password
  Future<AuthResult> signUpWithEmail(
      String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
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
      String message = 'هەڵەیەک ڕوویدا لە دروستکردنی هەژمار';
      if (e.code == 'weak-password') {
        message = 'وشەی تێپەڕەکە لاوازە';
      } else if (e.code == 'email-already-in-use') {
        message = 'ئەم ئیمەیڵە پێشتر بەکارهێنراوە';
      } else if (e.code == 'invalid-email') {
        message = 'ئیمەیڵەکە نادروستە';
      }
      return AuthResult.failure(message);
    } catch (e) {
      debugPrint('Sign up error: $e');
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
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success('ئیمەیڵی گۆڕینی وشەی تێپەڕ نێردرا بۆ $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = 'هەڵەیەک ڕوویدا لە ناردنی ئیمەیڵ';
      if (e.code == 'user-not-found') {
        message = 'ئەم هەژمارە بوونی نییە';
      } else if (e.code == 'invalid-email') {
        message = 'ئیمەیڵەکە نادروستە';
      }
      return AuthResult.failure(message);
    } catch (e) {
      debugPrint('Password reset error: $e');
      return AuthResult.failure('هەڵەیەک ڕوویدا، تکایە دووبارە هەوڵ بدەرەوە');
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
