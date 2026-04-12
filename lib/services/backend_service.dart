import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Backend service for syncing hearts, progress, and account data with Firestore
class BackendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Initialize user document in Firestore (call on first login or signup)
  Future<void> initializeUser({
    required String email,
    String? displayName,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final userDoc = _firestore.collection('users').doc(_userId);
      final docSnapshot = await userDoc.get();

      // Only create if doesn't exist
      if (!docSnapshot.exists) {
        await userDoc.set({
          'profile': {
            'email': email,
            'displayName': displayName ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'lastSeen': FieldValue.serverTimestamp(),
          },
          'hearts': {
            'current': 5,
            'lastLossTime': null,
            'totalLost': 0,
            'totalRecovered': 0,
          },
          'premium': {
            'isActive': false,
            'planType': null,
            'purchaseDate': null,
            'expiryDate': null,
            'paymentGateway': null,
            'transactionId': null,
            'autoRenew': false,
          },
          'progress': {
            'currentLevel': 1,
            'currentLevelProgress': 0.0,
            'streakDays': 0,
            'totalXP': 0,
            'completedLessons': 0,
            'lastStudyDate': null,
            'completedLessonIds': [],
          },
        });
      }
    } catch (e) {
      debugPrint('Error initializing user in Firestore: $e');
      rethrow;
    }
  }

  /// Delete user data from Firestore
  Future<void> deleteUserData() async {
    final uid = _userId;
    if (uid == null) {
      debugPrint('⚠️ Cannot delete user data: _userId is null');
      return;
    }

    try {
      debugPrint('🗑️ Attempting to delete Firestore document: users/$uid');
      
      // Add a timeout because Firestore delete can hang if rules deny it
      await _firestore
          .collection('users')
          .doc(uid)
          .delete()
          .timeout(const Duration(seconds: 10), onTimeout: () {
            throw Exception('Firestore deletion timed out. Check your security rules.');
          });
          
      debugPrint('✅ User data deleted from Firestore: $uid');
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException deleting user data: ${e.code} - ${e.message}');
      // Re-throw so the UI can handle it
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error deleting user data: $e');
      rethrow;
    }
  }

  /// Sync hearts with Firestore
  Future<Map<String, dynamic>> syncHearts() async {
    if (_userId == null) return {'currentHearts': 5, 'lastLossTime': null, 'isPremium': false};

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final heartsData = data['hearts'] as Map<String, dynamic>?;
        final premiumData = data['premium'] as Map<String, dynamic>?;

        DateTime? lastLossTime;
        if (heartsData != null && heartsData['lastLossTime'] != null) {
          lastLossTime = (heartsData['lastLossTime'] as Timestamp).toDate();
        }

        return {
          'currentHearts': heartsData?['current'] ?? 5,
          'lastLossTime': lastLossTime,
          'isPremium': premiumData?['isActive'] ?? false,
        };
      }
    } catch (e) {
      debugPrint('Error syncing hearts from Firestore: $e');
    }
    return {'currentHearts': 5, 'lastLossTime': null, 'isPremium': false};
  }

  /// Update hearts when lost
  Future<void> loseHeart({required int newHeartCount, required DateTime lossTime}) async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'hearts.current': newHeartCount,
        'hearts.lastLossTime': Timestamp.fromDate(lossTime),
        'hearts.totalLost': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error updating heart loss in Firestore: $e');
    }
  }

  /// Update hearts when recovered
  Future<void> recoverHeart({required int newHeartCount, DateTime? newLossTime}) async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'hearts.current': newHeartCount,
        'hearts.lastLossTime': newLossTime != null ? Timestamp.fromDate(newLossTime) : null,
        'hearts.totalRecovered': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error updating heart recovery in Firestore: $e');
    }
  }

  /// Activate premium status
  Future<void> activatePremium({
    required String planType,
    required String transactionId,
    required String paymentGateway,
  }) async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'premium.isActive': true,
        'premium.planType': planType,
        'premium.transactionId': transactionId,
        'premium.paymentGateway': paymentGateway,
        'premium.purchaseDate': FieldValue.serverTimestamp(),
        'hearts.current': 5, // Refill hearts on premium activation
      });
    } catch (e) {
      debugPrint('Error activating premium in Firestore: $e');
    }
  }

  /// Check premium status
  Future<Map<String, dynamic>> checkPremiumStatus() async {
    if (_userId == null) return {'isActive': false};

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final premiumData = data['premium'] as Map<String, dynamic>?;
        return {
          'isActive': premiumData?['isActive'] ?? false,
        };
      }
    } catch (e) {
      debugPrint('Error checking premium status in Firestore: $e');
    }
    return {'isActive': false};
  }

  /// Sync progress with Firestore
  Future<Map<String, dynamic>?> syncProgress() async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      if (doc.exists && doc.data()!.containsKey('progress')) {
        return doc.data()!['progress'] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error syncing progress from Firestore: $e');
    }
    return null;
  }

  /// Update progress in Firestore
  Future<void> updateProgress(Map<String, dynamic> progressData) async {
    if (_userId == null) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'progress': progressData,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating progress in Firestore: $e');
    }
  }
}
