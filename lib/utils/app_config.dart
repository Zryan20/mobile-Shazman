/// Global feature flags for the Hozhan app.
/// Flip these when features are ready for production.
class AppConfig {
  AppConfig._();

  /// Set to [true] when email OTP verification is ready to go live.
  /// When [false]: sign-up goes directly to Home, no OTP screen shown.
  static const bool otpEnabled = false;
}
