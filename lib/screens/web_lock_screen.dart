import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class WebLockScreen extends StatefulWidget {
  const WebLockScreen({super.key});

  @override
  State<WebLockScreen> createState() => _WebLockScreenState();
}

class _WebLockScreenState extends State<WebLockScreen> {
  final List<String> _pin = [];
  final String _correctPin = "2025"; // The secret access code
  String? _errorMessage;

  void _onNumberTap(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(number);
        _errorMessage = null;
      });
      
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pin.join();
    if (enteredPin == _correctPin) {
      // Save unlock status locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('web_unlocked', true);
      
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
    } else {
      setState(() {
        _pin.clear();
        _errorMessage = "کۆدەکە هەڵەیە، تکایە دووبارە هەوڵ بدەرەوە";
      });
      
      // Feedback vibration or shake effect could go here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary600,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary600,
              AppColors.primary700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'هۆژان - Hozhan',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'کۆدی دەستپێگەیشتن داخڵ بکە',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              
              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isFilled ? Colors.white : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              
              const Spacer(),
              
              // Number Pad
              _buildNumberPad(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80), // Empty space for layout balance
            _buildNumberButton('0'),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((n) => _buildNumberButton(n)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => _onNumberTap(number),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: _onDelete,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Colors.white70,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
