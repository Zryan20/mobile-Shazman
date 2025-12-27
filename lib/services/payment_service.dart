import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Model for premium subscription plans
class PremiumPlan {
  final String id;
  final String name;
  final String nameKurdish;
  final int price; // in IQD
  final String duration;
  final String durationKurdish;
  final int savings; // for yearly plan

  const PremiumPlan({
    required this.id,
    required this.name,
    required this.nameKurdish,
    required this.price,
    required this.duration,
    required this.durationKurdish,
    this.savings = 0,
  });

  static const monthly = PremiumPlan(
    id: 'monthly',
    name: 'Monthly',
    nameKurdish: 'مانگانە',
    price: 15000,
    duration: '1 Month',
    durationKurdish: '١ مانگ',
  );

  static const yearly = PremiumPlan(
    id: 'yearly',
    name: 'Yearly',
    nameKurdish: 'ساڵانە',
    price: 110000,
    duration: '12 Months',
    durationKurdish: '١٢ مانگ',
    savings: 70000, // 12 * 15000 - 110000 = 70000 IQD saved
  );

  static const List<PremiumPlan> allPlans = [monthly, yearly];
}

/// Service for handling payment gateway integrations
class PaymentService {
  final Dio _dio = Dio();

  // FIB Payment Configuration
  static const String _fibSandboxUrl =
      'https://fib-sandbox.gateway.url'; // TODO: Replace with actual URL
  static const String _fibProductionUrl =
      'https://fib-production.gateway.url'; // TODO: Replace with actual URL

  // FastPay Payment Configuration
  static const String _fastPaySandboxUrl = 'https://sandbox.fast-pay.iq';
  static const String _fastPayProductionUrl = 'https://fast-pay.iq';

  // Environment flag (set to false for production)
  static const bool _useSandbox = true;

  String get _fibBaseUrl => _useSandbox ? _fibSandboxUrl : _fibProductionUrl;
  String get _fastPayBaseUrl =>
      _useSandbox ? _fastPaySandboxUrl : _fastPayProductionUrl;

  PaymentService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Initialize FIB payment
  /// Returns a payment URL that the user should be redirected to
  Future<Map<String, dynamic>> initiateFIBPayment({
    required String userId,
    required PremiumPlan plan,
  }) async {
    try {
      if (kDebugMode) {
        print('🏦 Initiating FIB payment for ${plan.name} plan...');
      }

      // TODO: Get FIB credentials from environment or secure storage
      const clientId = 'YOUR_FIB_CLIENT_ID';
      const clientSecret = 'YOUR_FIB_CLIENT_SECRET';

      // Step 1: Get OAuth token
      final tokenResponse = await _dio.post(
        '$_fibBaseUrl/auth/token',
        data: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      final accessToken = tokenResponse.data['access_token'];

      // Step 2: Create payment
      final paymentResponse = await _dio.post(
        '$_fibBaseUrl/api/v1/payments',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'amount': plan.price,
          'currency': 'IQD',
          'description': 'Shazman+ ${plan.name} Subscription',
          'callback_url':
              'https://your-app.com/payment/callback', // TODO: Set your callback URL
          'metadata': {
            'user_id': userId,
            'plan_type': plan.id,
          },
        },
      );

      final paymentUrl = paymentResponse.data['redirect_url'];
      final transactionId = paymentResponse.data['payment_id'];

      if (kDebugMode) {
        print('✅ FIB payment initiated: $transactionId');
      }

      return {
        'success': true,
        'paymentUrl': paymentUrl,
        'transactionId': transactionId,
        'gateway': 'fib',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ FIB payment error: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Initialize FastPay payment
  /// Returns a redirect URL that the user should be redirected to
  Future<Map<String, dynamic>> initiateFastPayPayment({
    required String userId,
    required PremiumPlan plan,
  }) async {
    try {
      if (kDebugMode) {
        print('💳 Initiating FastPay payment for ${plan.name} plan...');
      }

      // TODO: Get FastPay credentials from environment or secure storage
      const storeId = 'YOUR_FASTPAY_STORE_ID';
      const storePassword = 'YOUR_FASTPAY_STORE_PASSWORD';

      // Generate unique order ID
      final orderId = 'SHAZMAN_${DateTime.now().millisecondsSinceEpoch}';

      // Step 1: Request transaction URL from FastPay
      final response = await _dio.post(
        '$_fastPayBaseUrl/api/v1/transaction/initialize',
        data: {
          'store_id': storeId,
          'store_password': storePassword,
          'order_id': orderId,
          'amount': plan.price.toDouble(),
          'currency': 'IQD',
          'success_url':
              'https://your-app.com/payment/success', // TODO: Set your URLs
          'fail_url': 'https://your-app.com/payment/fail',
          'cancel_url': 'https://your-app.com/payment/cancel',
          'ipn_url':
              'https://your-cloud-function.com/webhooks/fastpay', // TODO: Set webhook URL
          'customer_name': userId,
          'product_description': 'Shazman+ ${plan.name} Subscription',
        },
      );

      final redirectUrl = response.data['redirect_url'];
      final transactionId = response.data['transaction_id'];

      if (kDebugMode) {
        print('✅ FastPay payment initiated: $transactionId');
      }

      return {
        'success': true,
        'redirectUrl': redirectUrl,
        'transactionId': transactionId,
        'orderId': orderId,
        'gateway': 'fastpay',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ FastPay payment error: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verify FIB payment status
  Future<Map<String, dynamic>> verifyFIBPayment(String transactionId) async {
    try {
      // TODO: Implement FIB payment verification
      // This should be called after user returns from payment gateway

      if (kDebugMode) {
        print('🔍 Verifying FIB payment: $transactionId');
      }

      // Get OAuth token first (same as initiation)
      // Then query payment status

      return {
        'success': true,
        'status': 'completed', // or 'pending', 'failed'
        'transactionId': transactionId,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ FIB verification error: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Verify FastPay payment status
  Future<Map<String, dynamic>> verifyFastPayPayment(
      String transactionId) async {
    try {
      // TODO: Implement FastPay payment verification using their validation API

      if (kDebugMode) {
        print('🔍 Verifying FastPay payment: $transactionId');
      }

      const storeId = 'YOUR_FASTPAY_STORE_ID';
      const storePassword = 'YOUR_FASTPAY_STORE_PASSWORD';

      final response = await _dio.post(
        '$_fastPayBaseUrl/api/v1/transaction/validate',
        data: {
          'store_id': storeId,
          'store_password': storePassword,
          'transaction_id': transactionId,
        },
      );

      final status =
          response.data['status']; // 'SUCCESS', 'FAILED', 'PENDING', 'CANCELED'

      return {
        'success': true,
        'status': status.toLowerCase(),
        'transactionId': transactionId,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ FastPay verification error: $e');
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
