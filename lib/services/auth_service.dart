import 'package:flutter/foundation.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  
  // Check if user is currently logged in
  Future<bool> isUserLoggedIn() async {
    try {
      // TODO: Check SharedPreferences or secure storage for saved user session
      // For now, returning false to always show login screen first
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock check - replace with actual logic
      // Check if we have stored user credentials or session token
      return false; // Change this to true if you want to simulate logged in user
      
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }
  
  // Sign in with email and password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      // TODO: Implement actual authentication with your backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure('Email and password are required');
      }
      
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }
      
      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }
      
      // Mock successful authentication
      // In a real app, you'd make an API call here
      final userData = {
        'id': '1',
        'email': email,
        'name': _getNameFromEmail(email),
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      // TODO: Save user data to secure storage
      await _saveUserSession(userData);
      
      return AuthResult.success('Sign in successful', userData);
      
    } catch (e) {
      debugPrint('Sign in error: $e');
      return AuthResult.failure('Sign in failed. Please try again.');
    }
  }
  
  // Sign up with name, email and password
  Future<AuthResult> signUpWithEmail(String name, String email, String password) async {
    try {
      // TODO: Implement actual user registration with your backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      
      // Mock validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return AuthResult.failure('All fields are required');
      }
      
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }
      
      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }
      
      if (name.length < 2) {
        return AuthResult.failure('Name must be at least 2 characters');
      }
      
      // Mock successful registration
      // In a real app, you'd make an API call here
      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'name': name,
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      };
      
      // TODO: Save user data to secure storage
      await _saveUserSession(userData);
      
      return AuthResult.success('Account created successfully', userData);
      
    } catch (e) {
      debugPrint('Sign up error: $e');
      return AuthResult.failure('Sign up failed. Please try again.');
    }
  }
  
  // Sign out current user
  Future<void> signOut() async {
    try {
      // TODO: Clear user session from secure storage
      // TODO: Invalidate token with backend if needed
      await Future.delayed(const Duration(milliseconds: 500));
      
      await _clearUserSession();
      
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
  
  // Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      // TODO: Implement password reset with your backend
      await Future.delayed(const Duration(seconds: 1));
      
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }
      
      // Mock successful password reset
      return AuthResult.success('Password reset email sent to $email');
      
    } catch (e) {
      debugPrint('Password reset error: $e');
      return AuthResult.failure('Failed to send reset email. Please try again.');
    }
  }
  
  // Get current user data from storage
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      // TODO: Get from SharedPreferences or secure storage
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Mock user data - replace with actual storage retrieval
      return null;
      
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }
  
  // Private helper methods
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
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
  
  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    // TODO: Save to SharedPreferences or secure storage
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('user_data', jsonEncode(userData));
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> _clearUserSession() async {
    // TODO: Clear from SharedPreferences or secure storage
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('user_data');
    await Future.delayed(const Duration(milliseconds: 100));
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