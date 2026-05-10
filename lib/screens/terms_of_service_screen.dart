import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_texts_kurdish.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppTextsKurdish.termsOfService),
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: '١. قبوڵکردنی مەرجەکان'),
            _SectionText(text: 'بە بەکارهێنانی ئەپی هۆژان، تۆ ڕازیت بە هەموو ئەو مەرج و ڕێسایانەی لەم پەڕەیەدا ئاماژەیان پێکراوە.'),
            SizedBox(height: 20),
            
            _SectionTitle(title: '٢. بەکارهێنانی ئەپەکە'),
            _SectionText(text: 'ئەم ئەپە بۆ مەبەستی فێربوونی زمانی ئینگلیزی دروستکراوە. بەکارهێنەر بەرپرسە لە پاراستنی وشەی نهێنی هەژمارەکەی و نابێت ئەپەکە بۆ کاری نایاسایی بەکاربهێنرێت.'),
            SizedBox(height: 20),
            
            _SectionTitle(title: '٣. مافی لەبەرگرتنەوە'),
            _SectionText(text: 'هەموو ناوەڕۆکەکانی ئەپەکە (وانەکان، ڕاهێنانەکان، دیزاین، لۆگۆ) موڵکی تایبەتی هۆژانن و نابێت بەبێ مۆڵەت لە شوێنی تر بەکاربهێنرێنەوە.'),
            SizedBox(height: 20),
            
            _SectionTitle(title: '٤. خزمەتگوزارییەکان'),
            _SectionText(text: 'ئێمە هەوڵدەدەین ئەپەکە بەردەوام کار بکات، بەڵام بەرپرس نین لە وەستانی کاتی بەهۆی کێشەی تەکنیکی یان چاکسازییەوە.'),
            SizedBox(height: 40),
            
            Center(
              child: Text(
                'کۆتا نوێکردنەوە: ٢٠٢٦',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary600,
        ),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;

  const _SectionText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: AppColors.textSecondary,
      ),
    );
  }
}
