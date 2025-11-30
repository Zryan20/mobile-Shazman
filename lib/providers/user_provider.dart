import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

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
      // TODO: Load from SharedPreferences or secure storage
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock user data - replace with actual loading logic
      _currentUser = User(
        id: '1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      
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
      // TODO: Implement actual authentication
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful sign in
      _currentUser = User(
        id: '1',
        name: _getNameFromEmail(email),
        email: email,
        profileImageUrl: null,
        createdAt: DateTime.now(),
      );
      
      // TODO: Save user to secure storage
      return true;
      
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
      // TODO: Implement actual user creation
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock successful sign up
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        profileImageUrl: null,
        createdAt: DateTime.now(),
      );
      
      // TODO: Save user to secure storage
      return true;
      
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
      // TODO: Clear from secure storage
      await Future.delayed(const Duration(milliseconds: 500));
      
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
      // TODO: Update on server
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      );
      
      // TODO: Save updated user to storage
      return true;
      
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper method to extract name from email
  String _getNameFromEmail(String email) {
    final username = email.split('@').first;
    final parts = username.split('.');
    
    if (parts.length > 1) {
      return parts.map((part) => 
        part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : ''
      ).join(' ');
    }
    
    return username.isNotEmpty 
      ? username[0].toUpperCase() + username.substring(1)
      : 'User';
  }
}