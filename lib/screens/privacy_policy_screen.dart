import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_texts_kurdish.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppTextsKurdish.privacyPolicy),
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
            _SectionTitle(title: '١. زانیارییە کۆکراوەکان'),
            _SectionText(text: 'ئێمە تەنها ئەو زانیارییانە کۆدەکەینەوە کە پێویستن بۆ کارپێکردنی ئەپەکە، وەک ناو و ئیمەیڵ بۆ دروستکردنی هەژمار و پاشەکەوتکردنی پێشکەوتنەکانت.'),
            SizedBox(height: 20),
            
            _SectionTitle(title: '٢. بەکارهێنانی زانیارییەکان'),
            _SectionText(text: 'زانیارییەکانت تەنها بۆ باشترکردنی ئەزموونی فێربوون و پاراستنی هەژمارەکەت بەکاردەهێنرێت. ئێمە زانیارییەکانت نافرۆشین بە هیچ لایەنێکی سێیەم.'),
            SizedBox(height: 20),
            
            _SectionTitle(title: '٣. پاراستنی داتا'),
            _SectionText(text: 'داتاکانت بە شێوەیەکی پارێزراو لە ڕاژەکانی فایەربەیس (Firebase) هەڵدەگیرێن کە سەر بە کۆمپانیای گووگڵە و بەرزترین ستانداردی پاراستنیان هەیە.'),
            SizedBox(height: 20),
            
            _SectionTitle(title: '٤. سڕینەوەی هەژمار'),
            _SectionText(text: 'دەتوانیت لە هەر کاتێکدا هەژمارەکەت و هەموو زانیارییەکانت بە یەکجاری بسڕیتەوە لە ڕێگەی بەشی ڕێکخستنەکانەوە.'),
            SizedBox(height: 20),
            
            _SectionTitle(title: '٥. گۆڕانکاری لە سیاسەتەکە'),
            _SectionText(text: 'لە کاتی هەبوونی هەر گۆڕانکارییەک لەم سیاسەتەدا، لە ڕێگەی ئەپەکەوە یان ئیمەیڵەوە ئاگادارت دەکەینەوە.'),
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
