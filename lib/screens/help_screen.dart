import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_colors.dart';
import '../utils/app_texts_kurdish.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppTextsKurdish.helpCenter),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary600, AppColors.primary700],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'چۆن دەتوانین یارمەتیت بدەین؟',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لێرەین بۆ وەڵامدانەوەی پرسیارەکانت',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppTextsKurdish.contactUs.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primary400 : AppColors.primary600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.email_rounded,
              iconColor: AppColors.primary500,
              title: 'ئیمەیڵمان بۆ بنێرە',
              subtitle: 'support@hozhan.app',
              onTap: () => _launchEmail('support@hozhan.app'),
            ),
            _ContactCard(
              icon: Icons.bug_report_rounded,
              iconColor: AppColors.warning,
              title: AppTextsKurdish.reportProblem,
              subtitle: 'هەڵەیەک یان کێشەیەکت بینیوە؟',
              onTap: () => _launchEmail('bugs@hozhan.app', subject: 'ڕاپۆرتی کێشە'),
            ),
            _ContactCard(
              icon: Icons.feedback_rounded,
              iconColor: AppColors.success,
              title: AppTextsKurdish.sendFeedback,
              subtitle: 'پێشنیار و بیرۆکەکانت بنێرە',
              onTap: () => _launchEmail('feedback@hozhan.app', subject: 'پێشنیار'),
            ),

            const SizedBox(height: 24),

            // FAQs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppTextsKurdish.faq.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primary400 : AppColors.primary600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _FaqAccordion(
              question: 'چۆن دەتوانم وشەی نهێنی بگۆڕم؟',
              answer: 'لە بەشی ڕێکخستنەکان -> هەژمار -> گۆڕینی وشەی نهێنی دەتوانیت وشەی نهێنی نوێ دابنێیت.',
            ),
            const _FaqAccordion(
              question: 'چۆن نمرە (XP) بەدەست دەهێنم؟',
              answer: 'بە تەواوکردنی وانەکان و ڕاهێنانەکان بە سەرکەوتوویی، نمرەی زیاتر بەدەست دەهێنیت.',
            ),
            const _FaqAccordion(
              question: 'ئایا ئەپەکە بە خۆڕاییە؟',
              answer: 'بەڵێ، بەشێکی زۆری ئەپەکە بە خۆڕاییە، بەڵام بۆ تایبەتمەندییە پێشکەوتووەکان دەتوانیت بەشداریی پریمیەم بکەیت.',
            ),
            const _FaqAccordion(
              question: 'چۆن پێشکەوتنەکانم بسڕمەوە؟',
              answer: 'لە ڕێکخستنەکان -> زانیاری و کۆگا -> سڕینەوەی پێشکەوتن دەتوانیت هەموو پێشکەوتنەکانت سفر بکەیتەوە.',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email, {String? subject}) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject != null ? 'subject=${Uri.encodeComponent(subject)}' : null,
    );

    try {
      if (!await launchUrl(emailLaunchUri)) {
        debugPrint('Could not launch email to $email');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              boxShadow: isDark ? null : const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
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
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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

class _FaqAccordion extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqAccordion({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.neutral200),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              widget.question,
              style: TextStyle(
                fontSize: 14,
                fontWeight: _isExpanded ? FontWeight.w600 : FontWeight.w500,
                color: _isExpanded 
                    ? (isDark ? AppColors.primary400 : AppColors.primary600) 
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
            iconColor: isDark ? AppColors.primary400 : AppColors.primary600,
            collapsedIconColor: isDark ? AppColors.textTertiaryDark : AppColors.neutral400,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(
                widget.answer,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
