import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

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

  // Sign in user
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);

    try {
      final authService = AuthService();
      final result = await authService.signInWithEmail(email, password);

      if (result.isSuccess && result.userData != null) {
        _currentUser = User(
          id: result.userData!['id'],
          name: result.userData!['name'],
          email: result.userData!['email'],
          profileImageUrl: null,
          createdAt: DateTime.now(),
        );
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
        _currentUser = User(
          id: result.userData!['id'],
          name: result.userData!['name'],
          email: result.userData!['email'],
          profileImageUrl: null,
          createdAt: DateTime.now(),
        );
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

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);

    try {
      // In a real app, update on Firebase Auth too
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      );

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
