import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_texts_kurdish.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      final result = await authService.resetPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        setState(() {
          _emailSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
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
      appBar: AppBar(
        title: Text(AppTextsKurdish.forgotPassword),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary600.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 50,
                color: AppColors.primary600,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title
          Center(
            child: Text(
              AppTextsKurdish.resetPassword,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Center(
            child: Text(
              'ئیمەیڵەکەت بنووسە، ئێمە لینکێکی گەڕانەوەی وشەی تێپەڕت دەنێرین',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _resetPassword(),
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
          
          const SizedBox(height: 32),
          
          // Reset button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'ناردنی لینکی گەڕانەوە',
              onPressed: _isLoading ? null : _resetPassword,
              isLoading: _isLoading,
              icon: Icons.send_rounded,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Back to login
          Center(
            child: TextCustomButton(
              text: 'گەڕانەوە بۆ چوونەژوورەوە',
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icons.arrow_back_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        
        // Success icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 60,
            color: AppColors.success,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Success title
        const Text(
          'ئیمەیڵ نێردرا!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Success message
        Text(
          'لینکێکی گەڕانەوەی وشەی تێپەڕ نێردراوە بۆ',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Email address
        Text(
          _emailController.text.trim(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary600,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_rounded, color: AppColors.info),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'هەنگاوەکانی دواتر:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStep('١', 'سەیری ئیمەیڵەکەت بکە'),
              _buildStep('٢', 'لەسەر لینکی گەڕانەوە کلیک بکە'),
              _buildStep('٣', 'وشەی تێپەڕی نوێ دانێ'),
              _buildStep('٤', 'بچۆژوورەوە بە وشەی تێپەڕە نوێکەت'),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Resend button
        TextCustomButton(
          text: 'ئیمەیڵت وەرنەگرت؟ دووبارە بینێرە',
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          icon: Icons.refresh_rounded,
        ),
        
        const SizedBox(height: 16),
        
        // Back to login button
        SizedBox(
          width: double.infinity,
          child: OutlinedCustomButton(
            text: 'گەڕانەوە بۆ چوونەژوورەوە',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icons.arrow_back_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}