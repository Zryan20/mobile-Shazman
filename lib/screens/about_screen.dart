import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';
import '../utils/app_texts_kurdish.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('دەربارەی ئەپ'),
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // App Logo
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withOpacity(0.3) 
                          : AppColors.primary600.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/Hozhan-icon.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name & Version
            Text(
              AppTextsKurdish.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.primary600.withOpacity(0.2) : AppColors.primary100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'وەشان ${AppTextsKurdish.appVersion}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primary400 : AppColors.primary600,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'هۆژان ئەپێکی پێشکەوتووە بۆ فێربوونی زمانی ئینگلیزی، بەکارهێنانی ئاسانە و یارمەتیت دەدات بە شێوەیەکی خێرا و سەرنجڕاکێش زمانەکە فێرببیت.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Developer Info / Links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'پەیوەندی و بەستەرەکان'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.primary400 : AppColors.primary600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.language_rounded,
                    title: 'ماڵپەڕی فەرمی',
                    subtitle: 'hozhan.app',
                    onTap: () => _launchUrl('https://hozhan.app'),
                  ),
                  _InfoCard(
                    icon: Icons.email_rounded,
                    title: 'ئیمەیڵ',
                    subtitle: 'info@hozhan.app',
                    onTap: () => _launchUrl('mailto:info@hozhan.app'),
                  ),
                  _InfoCard(
                    icon: Icons.privacy_tip_rounded,
                    title: 'سیاسەتی تایبەتێتی',
                    subtitle: 'چۆنیەتی پاراستنی زانیارییەکانت',
                    onTap: () {
                      // Navigate to privacy policy or open url
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Copyright
            Text(
              '© ${2026} هەموو مافەکانی پارێزراوە بۆ هۆژان',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching url: $e');
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.neutral200),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primary600.withOpacity(0.2) : AppColors.primary100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: isDark ? AppColors.primary400 : AppColors.primary600, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isDark ? AppColors.textTertiaryDark : AppColors.neutral400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
