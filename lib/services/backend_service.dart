import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Backend service for syncing hearts and premium status with Firestore
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
        });

        if (kDebugMode) {
          print('✅ User initialized in Firestore: $_userId');
        }
      } else {
        // Update last seen
        await userDoc.update({
          'profile.lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing user: $e');
      }
      rethrow;
    }
  }

  /// Sync hearts from server
  Future<Map<String, dynamic>> syncHearts() async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final userDoc = await _firestore.collection('users').doc(_userId).get();

      if (!userDoc.exists) {
        // Initialize if doesn't exist
        await initializeUser(
          email: _auth.currentUser!.email!,
          displayName: _auth.currentUser!.displayName,
        );
        return {
          'currentHearts': 5,
          'lastLossTime': null,
          'isPremium': false,
        };
      }

      final heartsData = userDoc.data()?['hearts'] ?? {};
      final premiumData = userDoc.data()?['premium'] ?? {};

      final currentHearts = heartsData['current'] ?? 5;
      final lastLossTime = heartsData['lastLossTime'] as Timestamp?;
      final isPremium = premiumData['isActive'] ?? false;

      if (kDebugMode) {
        print(
            '💾 Hearts synced from server: $currentHearts/5, Premium: $isPremium');
      }

      return {
        'currentHearts': currentHearts,
        'lastLossTime': lastLossTime?.toDate(),
        'isPremium': isPremium,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing hearts: $e');
      }
      rethrow;
    }
  }

  /// Update hearts on server when user loses a heart
  Future<bool> loseHeart({
    required int newHeartCount,
    required DateTime lossTime,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('users').doc(_userId).update({
        'hearts.current': newHeartCount,
        'hearts.lastLossTime': Timestamp.fromDate(lossTime),
        'hearts.totalLost': FieldValue.increment(1),
      });

      if (kDebugMode) {
        print('💔 Heart loss synced to server: $newHeartCount remaining');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing heart loss: $e');
      }
      return false;
    }
  }

  /// Update hearts on server when user recovers a heart
  Future<bool> recoverHeart({
    required int newHeartCount,
    DateTime? newLossTime,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('users').doc(_userId).update({
        'hearts.current': newHeartCount,
        'hearts.lastLossTime':
            newLossTime != null ? Timestamp.fromDate(newLossTime) : null,
        'hearts.totalRecovered': FieldValue.increment(1),
      });

      if (kDebugMode) {
        print('💚 Heart recovery synced to server: $newHeartCount/5');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing heart recovery: $e');
      }
      return false;
    }
  }

  /// Refill all hearts (after watching ad or manual refill)
  Future<bool> refillHearts() async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore.collection('users').doc(_userId).update({
        'hearts.current': 5,
        'hearts.lastLossTime': null,
      });

      if (kDebugMode) {
        print('💖 Hearts refilled on server');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refilling hearts: $e');
      }
      return false;
    }
  }

  /// Check premium status from server
  Future<Map<String, dynamic>> checkPremiumStatus() async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final userDoc = await _firestore.collection('users').doc(_userId).get();
      final premiumData = userDoc.data()?['premium'] ?? {};

      final isActive = premiumData['isActive'] ?? false;
      final planType = premiumData['planType'];
      final expiryDate = (premiumData['expiryDate'] as Timestamp?)?.toDate();

      // Check if subscription has expired
      if (isActive &&
          expiryDate != null &&
          DateTime.now().isAfter(expiryDate)) {
        // Deactivate expired subscription
        await _firestore.collection('users').doc(_userId).update({
          'premium.isActive': false,
        });

        if (kDebugMode) {
          print('⏰ Premium subscription expired');
        }

        return {
          'isActive': false,
          'planType': null,
          'expiryDate': null,
        };
      }

      if (kDebugMode) {
        print('💎 Premium status: $isActive, Plan: $planType');
      }

      return {
        'isActive': isActive,
        'planType': planType,
        'expiryDate': expiryDate,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking premium status: $e');
      }
      return {
        'isActive': false,
        'planType': null,
        'expiryDate': null,
      };
    }
  }

  /// Activate premium subscription (called after successful payment)
  Future<bool> activatePremium({
    required String planType,
    required String transactionId,
    required String paymentGateway,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final now = DateTime.now();
      DateTime expiryDate;

      // Calculate expiry date based on plan type
      if (planType == 'monthly') {
        expiryDate = DateTime(now.year, now.month + 1, now.day);
      } else if (planType == 'yearly') {
        expiryDate = DateTime(now.year + 1, now.month, now.day);
      } else {
        throw Exception('Invalid plan type: $planType');
      }

      await _firestore.collection('users').doc(_userId).update({
        'premium.isActive': true,
        'premium.planType': planType,
        'premium.purchaseDate': Timestamp.fromDate(now),
        'premium.expiryDate': Timestamp.fromDate(expiryDate),
        'premium.paymentGateway': paymentGateway,
        'premium.transactionId': transactionId,
        'hearts.current': 5, // Give full hearts
        'hearts.lastLossTime': null,
      });

      // Create transaction record
      await _firestore.collection('transactions').add({
        'userId': _userId,
        'type': 'premium_purchase',
        'amount': planType == 'monthly' ? 15000 : 110000,
        'currency': 'IQD',
        'gateway': paymentGateway,
        'status': 'completed',
        'gatewayTransactionId': transactionId,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
        'metadata': {
          'planType': planType,
          'expiryDate': Timestamp.fromDate(expiryDate),
        },
      });

      if (kDebugMode) {
        print('💎 Premium activated: $planType, expires: $expiryDate');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error activating premium: $e');
      }
      return false;
    }
  }

  /// Stream user's hearts data (for real-time updates)
  Stream<Map<String, dynamic>> watchHearts() {
    if (_userId == null) {
      return Stream.value({
        'currentHearts': 5,
        'lastLossTime': null,
        'isPremium': false,
      });
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {
          'currentHearts': 5,
          'lastLossTime': null,
          'isPremium': false,
        };
      }

      final heartsData = snapshot.data()?['hearts'] ?? {};
      final premiumData = snapshot.data()?['premium'] ?? {};

      return {
        'currentHearts': heartsData['current'] ?? 5,
        'lastLossTime': (heartsData['lastLossTime'] as Timestamp?)?.toDate(),
        'isPremium': premiumData['isActive'] ?? false,
      };
    });
  }

  /// Stream user's premium status (for real-time updates)
  Stream<Map<String, dynamic>> watchPremiumStatus() {
    if (_userId == null) {
      return Stream.value({
        'isActive': false,
        'planType': null,
        'expiryDate': null,
      });
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return {
          'isActive': false,
          'planType': null,
          'expiryDate': null,
        };
      }

      final premiumData = snapshot.data()?['premium'] ?? {};

      return {
        'isActive': premiumData['isActive'] ?? false,
        'planType': premiumData['planType'],
        'expiryDate': (premiumData['expiryDate'] as Timestamp?)?.toDate(),
      };
    });
  }
}
