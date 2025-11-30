import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_texts_kurdish.dart';
import '../utils/app_routes.dart';
import '../widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تکایە مەرجەکانی خزمەتگوزاری قبوڵ بکە'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final result = await authService.signUpWithEmail(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        final userProvider = context.read<UserProvider>();
        await userProvider.signUp(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        Navigator.pushReplacementNamed(context, AppRoutes.home);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTextsKurdish.signUpSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTextsKurdish.somethingWentWrong),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                
                const SizedBox(height: 20),
                
                // Logo/Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary600,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary600.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppTextsKurdish.createAccount,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'هەژمارێک دروست بکە بۆ دەستپێکردن',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppTextsKurdish.fullName,
                    hintText: 'ناوی تەواوت بنووسە',
                    prefixIcon: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary600,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'تکایە ناوەکەت بنووسە';
                    }
                    if (value.length < 2) {
                      return 'ناو دەبێت بە لایەنی کەمەوە ٢ پیت بێت';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppTextsKurdish.email,
                    hintText: 'ئیمەیڵەکەت بنووسە',
                    prefixIcon: Icon(
                      Icons.email_rounded,
                      color: AppColors.primary600,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'تکایە ئیمەیڵەکەت بنووسە';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return AppTextsKurdish.invalidEmail;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppTextsKurdish.password,
                    hintText: 'وشەی تێپەڕەکەت بنووسە',
                    prefixIcon: Icon(
                      Icons.lock_rounded,
                      color: AppColors.primary600,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible 
                            ? Icons.visibility_rounded 
                            : Icons.visibility_off_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'تکایە وشەی تێپەڕەکەت بنووسە';
                    }
                    if (value.length < 6) {
                      return AppTextsKurdish.weakPassword;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signUp(),
                  decoration: InputDecoration(
                    labelText: AppTextsKurdish.confirmPassword,
                    hintText: 'وشەی تێپەڕەکەت دووبارە بنووسە',
                    prefixIcon: Icon(
                      Icons.lock_rounded,
                      color: AppColors.primary600,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible 
                            ? Icons.visibility_rounded 
                            : Icons.visibility_off_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'تکایە وشەی تێپەڕەکەت دووبارە بنووسە';
                    }
                    if (value != _passwordController.text) {
                      return AppTextsKurdish.passwordsNotMatch;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Terms and conditions checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary600,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptedTerms = !_acceptedTerms;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: 'من ڕازیم بە '),
                                TextSpan(
                                  text: 'مەرجەکانی خزمەتگوزاری',
                                  style: TextStyle(
                                    color: AppColors.primary600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' و '),
                                TextSpan(
                                  text: 'سیاسەتی تایبەتێتی',
                                  style: TextStyle(
                                    color: AppColors.primary600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: AppTextsKurdish.signUp,
                    onPressed: _isLoading ? null : _signUp,
                    isLoading: _isLoading,
                    icon: Icons.person_add_rounded,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'یان',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Google sign up
                SizedBox(
                  width: double.infinity,
                  child: OutlinedCustomButton(
                    text: 'خۆتۆمارکردن لە ڕێگەی گووگڵ',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('خۆتۆمارکردن لە ڕێگەی گووگڵ بەم زووانە دێت!'),
                        ),
                      );
                    },
                    icon: Icons.g_mobiledata_rounded,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Apple sign up
                SizedBox(
                  width: double.infinity,
                  child: OutlinedCustomButton(
                    text: 'خۆتۆمارکردن لە ڕێگەی ئەپڵ',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('خۆتۆمارکردن لە ڕێگەی ئەپڵ بەم زووانە دێت!'),
                        ),
                      );
                    },
                    icon: Icons.apple_rounded,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppTextsKurdish.alreadyHaveAccount,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextCustomButton(
                      text: AppTextsKurdish.signIn,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      fontSize: 14,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}