import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../services/otp_service.dart';
import '../services/backend_service.dart';
import '../providers/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

/// Screen that shows a 6-box OTP entry UI after sign-up.
/// Expects route argument: {'email': String}
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  // ── OTP input fields ──────────────────────────────────────────────────────
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isVerifying = false;
  bool _isSendingOtp = false;
  String? _errorMessage;

  // ── Resend cooldown ───────────────────────────────────────────────────────
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // ── Route args ────────────────────────────────────────────────────────────
  late String _email;
  bool _routeArgParsed = false;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_routeArgParsed) {
      _routeArgParsed = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _email = args?['email'] as String? ?? '';
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _sendOtp(isResend: false),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _cooldownTimer?.cancel();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  void _startCooldown() {
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) { t.cancel(); }
      });
    });
  }

  void _clearOtp() {
    for (final c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
  }

  void _shake() {
    _shakeController.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _sendOtp({bool isResend = true}) async {
    if (_isSendingOtp || _resendCooldown > 0) return;
    // Capture messenger before async gap
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });

    final otpService = OtpService();
    final result = await otpService.sendOtp(_email);

    if (!mounted) return;
    setState(() { _isSendingOtp = false; });

    if (result.isSuccess) {
      _startCooldown();
      if (isResend) {
        _clearOtp();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('کۆدی نوێ نێردرا!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      setState(() => _errorMessage = result.message);
    }
  }

  Future<void> _verifyOtp() async {
    if (_enteredOtp.length != 6) {
      setState(() => _errorMessage = 'تکایە کۆدی ٦ ژمارەیی بنووسە');
      _shake();
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final otpService = OtpService();
    final result = await otpService.verifyOtp(_enteredOtp);

    if (!mounted) return;

    if (result.isSuccess) {
      // Initialize user in Firestore
      try {
        final backendService = context.read<BackendService>();
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await backendService.initializeUser(email: _email);
        }
      } catch (_) {}

      if (!mounted) return;

      // Update user provider then navigate — capture Navigator before await gap
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final userProvider = context.read<UserProvider>();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userProvider.setUserFromData({
          'id': currentUser.uid,
          'email': currentUser.email,
          'name': currentUser.displayName ?? '',
        });
      }

      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('بەخێربێیت! هەژمارەکەت دڵنیاکرایەوە ✓'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = result.message;
      });
      _shake();
      _clearOtp();
    }
  }

  // ── OTP box builder ───────────────────────────────────────────────────────

  Widget _buildOtpBox(int index) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shake = _errorMessage != null
            ? (index.isEven ? 1 : -1) *
                6.0 *
                (1 - _shakeAnimation.value) *
                (1 - _shakeAnimation.value)
            : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: SizedBox(
        width: 46,
        height: 56,
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor: _errorMessage != null
                ? AppColors.error.withValues(alpha: 0.07)
                : AppColors.primary600.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errorMessage != null
                    ? AppColors.error.withValues(alpha: 0.4)
                    : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errorMessage != null
                    ? AppColors.error.withValues(alpha: 0.4)
                    : AppColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _errorMessage != null
                    ? AppColors.error
                    : AppColors.primary600,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() => _errorMessage = null);
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            if (_enteredOtp.length == 6 && !_isVerifying) {
              _verifyOtp();
            }
          },
          onTap: () => _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Header back button ─────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      // Capture navigator before async signOut
                      final navigator = Navigator.of(context);
                      FirebaseAuth.instance.signOut().then((_) {
                        if (!mounted) return;
                        navigator.pushNamedAndRemoveUntil(
                          AppRoutes.signUp,
                          (r) => false,
                        );
                      });
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Animated icon ──────────────────────────────────────────
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary600, AppColors.primary700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary600.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 28),

                // ── Title + subtitle ───────────────────────────────────────
                Text(
                  'دڵنیاکردنەوەی ئیمەیڵ',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'کۆدی ٦ ژمارەیی نێردرا بۆ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // ── OTP boxes ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, _buildOtpBox),
                ),

                // ── Error message ──────────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: _errorMessage != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 32),

                // ── Verify button ──────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'دڵنیاکردنەوە',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Resend section ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'کۆدەکەت نەگەیشت؟',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _resendCooldown > 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'دووبارە بنێرە لە ${_resendCooldown}s',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : TextButton.icon(
                              onPressed: _isSendingOtp
                                  ? null
                                  : () => _sendOtp(isResend: true),
                              icon: _isSendingOtp
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary600,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.refresh_rounded,
                                      color: AppColors.primary600,
                                      size: 18,
                                    ),
                              label: const Text(
                                'کۆدی نوێ بنێرە',
                                style: TextStyle(
                                  color: AppColors.primary600,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Info note ──────────────────────────────────────────────
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'کۆدەکە تەنها ١٠ خولەک کاریگەرە',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
