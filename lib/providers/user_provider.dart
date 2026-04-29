import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Load user from storage
  Future<void> loadUser() async {
    _setLoading(true);

    try {
      final authService = AuthService();
      final userData = await authService.getCurrentUserData();

      if (userData != null) {
        _currentUser = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          profileImageUrl: null,
          createdAt: DateTime
              .now(), // Firebase doesn't provide this easily on user object
        );
      } else {
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  // Set current user from existing data (avoids redundant auth calls)
  void setUserFromData(Map<String, dynamic> userData) {
    _currentUser = User(
      id: userData['id'],
      name: userData['name'],
      email: userData['email'],
      profileImageUrl: null,
      createdAt: DateTime.now(),
    );
    notifyListeners();
  }

  // Sign in user
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);

    try {
      final authService = AuthService();
      final result = await authService.signInWithEmail(email, password);

      if (result.isSuccess && result.userData != null) {
        setUserFromData(result.userData!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign up user
  Future<bool> signUp(String name, String email, String password) async {
    _setLoading(true);

    try {
      final authService = AuthService();
      final result = await authService.signUpWithEmail(name, email, password);

      if (result.isSuccess && result.userData != null) {
        setUserFromData(result.userData!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error signing up: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out user
  Future<void> signOut() async {
    _setLoading(true);

    try {
      final authService = AuthService();
      await authService.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile (persists to Firebase Auth)
  Future<bool> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);

    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && name != null && name.isNotEmpty) {
        await firebaseUser.updateDisplayName(name);
      }

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      );

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete user account
  Future<AuthResult> deleteAccount(BackendService backendService) async {
    _setLoading(true);

    try {
      debugPrint('🚀 Starting account deletion process...');
      
      // 1. Delete Firestore data
      debugPrint('Step 1: Deleting Firestore user data...');
      try {
        await backendService.deleteUserData();
        debugPrint('✅ Firestore data deleted successfully.');
      } catch (e) {
        debugPrint('⚠️ Firestore data deletion failed but continuing: $e');
        // We continue to Step 2 so the auth account is still deleted
      }

      // 2. Delete Firebase Auth account
      debugPrint('Step 2: Deleting Firebase Auth account...');
      final authService = AuthService();
      final result = await authService.deleteAccount();

      if (result.isSuccess) {
        debugPrint('✅ Firebase Auth account deleted: ${result.message}');
        _currentUser = null;
        notifyListeners();
      } else {
        debugPrint('❌ Firebase Auth deletion failed: ${result.message}');
      }

      return result;
    } catch (e) {
      debugPrint('❌ Critical error in UserProvider deleteAccount: $e');
      return AuthResult.failure('هەڵەیەک ڕوویدا لە کاتی سڕینەوەی هەژمار: $e');
    } finally {
      _setLoading(false);
    }
  }
}
