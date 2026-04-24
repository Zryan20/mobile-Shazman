import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/hearts_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/settings_provider.dart';
import '../services/backend_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_texts_kurdish.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ڕێکخستنەکان'),
      ),
      body: Consumer2<UserProvider, SettingsProvider>(
        builder: (context, userProvider, settingsProvider, child) {
          return ListView(
            children: [
              // Account Section
              _buildSectionHeader('هەژمار'),
              
              _SettingsTile(
                icon: Icons.person_rounded,
                title: 'دەستکاری پرۆفایل',
                subtitle: 'ناو و وێنەکەت بگۆڕە',
                onTap: () {
                  // Navigator.pushNamed(context, AppRoutes.editProfile);
                },
              ),
              
              _SettingsTile(
                icon: Icons.lock_rounded,
                title: 'گۆڕینی وشەی نهێنی',
                subtitle: 'وشەی نهێنی نوێ بکەرەوە',
                onTap: () {
                  // Navigator.pushNamed(context, AppRoutes.changePassword);
                },
              ),
              
              _SettingsTile(
                icon: Icons.email_rounded,
                title: 'ئیمەیڵ',
                subtitle: userProvider.currentUser?.email ?? 'چوونەژوورەوە نییە',
                onTap: null,
              ),
              
              const Divider(height: 32),
              
              
              // Notifications Section
              _buildSectionHeader('ئاگادارکردنەوەکان'),
              
              _SettingsSwitchTile(
                icon: Icons.notifications_rounded,
                title: 'ئاگادارکردنەوەکان',
                subtitle: 'بیرخستنەوە و نوێکاری وەربگرە',
                value: settingsProvider.notificationsEnabled,
                onChanged: settingsProvider.setNotifications,
              ),
              
              const Divider(height: 32),
              
              // Audio & Sound Section
              _buildSectionHeader('دەنگ و میوزیک'),
              
              _SettingsSwitchTile(
                icon: Icons.volume_up_rounded,
                title: 'کاریگەرییەکانی دەنگ',
                subtitle: 'دەنگ بۆ کارلێکەکان',
                value: settingsProvider.soundEffectsEnabled,
                onChanged: settingsProvider.setSoundEffects,
              ),
              
              _SettingsSwitchTile(
                icon: Icons.vibration_rounded,
                title: 'لەرینەوە',
                subtitle: 'وەڵامی لەرینەوە',
                value: settingsProvider.vibrationEnabled,
                onChanged: settingsProvider.setVibration,
              ),
              
              const Divider(height: 32),
              
              // Display Section
              _buildSectionHeader('پیشاندان'),
              
              _SettingsSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'دۆخی تاریک',
                subtitle: 'ڕووکاری تاریک بەکاربهێنە',
                value: settingsProvider.darkModeEnabled,
                onChanged: (value) {
                  settingsProvider.setDarkMode(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('دۆخی تاریک بەم زووانە دێت!'),
                    ),
                  );
                },
              ),
              
              const Divider(height: 32),
              
              // Data & Storage Section
              _buildSectionHeader('زانیاری و کۆگا'),
              
              _SettingsTile(
                icon: Icons.sd_storage_rounded,
                title: 'بەکارهێنانی زانیاری',
                subtitle: 'چاودێری بەکارهێنانی زانیاری',
                onTap: () {
                  _showDataUsageDialog(context);
                },
              ),
              
              _SettingsTile(
                icon: Icons.delete_sweep_rounded,
                title: 'سڕینەوەی پێشکەوتن',
                subtitle: 'هەموو زانیارییەکان سفر بکەرەوە',
                onTap: () {
                  _showClearProgressDialog(context);
                },
              ),
              
              const Divider(height: 32),
              
              // Support Section
              _buildSectionHeader('پشتگیری'),
              
              _SettingsTile(
                icon: Icons.help_rounded,
                title: 'ناوەندی یارمەتی',
                subtitle: 'یارمەتی و پشتگیری وەربگرە',
                onTap: () {
                  // Navigator.pushNamed(context, AppRoutes.help);
                },
              ),
              
              _SettingsTile(
                icon: Icons.bug_report_rounded,
                title: 'ڕاپۆرتی کێشە',
                subtitle: 'باگ یان کێشە ڕاپۆرت بکە',
                onTap: () {
                  // Navigator.pushNamed(context, AppRoutes.contactUs);
                },
              ),
              
              _SettingsTile(
                icon: Icons.feedback_rounded,
                title: 'ناردنی ڕەخنە',
                subtitle: 'بیرۆکەکانت هاوبەش بکە',
                onTap: () {
                  // Navigator.pushNamed(context, AppRoutes.contactUs);
                },
              ),
              
              const Divider(height: 32),
              
              // Legal Section
              _buildSectionHeader('یاسایی'),
              
              _SettingsTile(
                icon: Icons.description_rounded,
                title: 'مەرجەکانی خزمەتگوزاری',
                subtitle: 'مەرجەکانمان بخوێنەرەوە',
                onTap: () {
                  // Navigator.pushNamed(context, AppRoutes.termsOfService);
                },
              ),
              
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'سیاسەتی تایبەتێتی',
                subtitle: 'چۆن زانیارییەکانت دەپارێزین',
                onTap: () {
                  // Navigator.pushNamed(context, AppRoutes.privacyPolicy);
                },
              ),
              
              const Divider(height: 32),
              
              // Danger Zone
              _buildSectionHeader('بەڕێوەبردنی هەژمار', isDestructive: true),
              
              _SettingsTile(
                icon: Icons.delete_forever_rounded,
                title: 'سڕینەوەی هەژمار',
                subtitle: 'هەژمارەکەت بە هەمیشەیی بسڕەوە',
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
                isDestructive: true,
              ),
              
              const SizedBox(height: 32),
              
              // App Version
              const Center(
                child: Column(
                  children: [
                    Text(
                      AppTextsKurdish.appName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'وەشان ${AppTextsKurdish.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDestructive ? AppColors.error : AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  
  void _showDataUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بەکارهێنانی زانیاری'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataItem('دەنگی کاشکراو', '٤٥ مێگابایت'),
            _buildDataItem('وێنەکان', '٣٠ مێگابایت'),
            _buildDataItem('هیتر', '١٠ مێگابایت'),
            const Divider(height: 20),
            _buildDataItem('کۆی گشتی', '٨٥ مێگابایت', isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('باشە'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary600 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showClearProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سڕینەوەی پێشکەوتن'),
        content: const Text(
          'ئایا دڵنیایت کە دەتەوێت هەموو پێشکەوتنەکانت بسڕیتەوە؟ ئەمە وانە تەواوکراوەکان و خاڵەکان سفر دەکاتەوە.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('پاشگەزبوونەوە'),
          ),
          TextButton(
            onPressed: () async {
              final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
              final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
              
              await lessonProvider.clearCompletionData();
              await progressProvider.clearProgress();
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('هەموو پێشکەوتنەکان بە سەرکەوتوویی سڕانەوە'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(
              'سڕینەوە',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'سڕینەوەی هەژمار',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text('دڵنیای کە دەتەوێت هەژمارەکەت بە هەمیشەیی بسڕیتەوە؟ ئەم کردارە ناگەڕێتەوە.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('پاشگەزبوونەوە'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final heartsProvider = Provider.of<HeartsProvider>(context, listen: false);
              final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
              final backendService = Provider.of<BackendService>(context, listen: false);

              // Show loading overlay
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('خەریکی سڕینەوەی هەژمارین...')),
              );

              final result = await userProvider.deleteAccount(backendService);

              if (context.mounted) {
                if (result.isSuccess) {
                  // Stop timers and clear local state (don't let errors here block navigation)
                  try {
                    await heartsProvider.reset();
                    await progressProvider.clearProgress();
                    debugPrint('✅ Local state cleared after deletion.');
                  } catch (e) {
                    debugPrint('⚠️ Error clearing local state (ignoring): $e');
                  }
                  
                  // Navigate to splash/root screen
                  debugPrint('🔄 Navigating to root after successful deletion...');
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  
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
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'سڕینەوە',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;
  
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primary600.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary600,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: onTap != null
          ? const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary600.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.primary600,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary600,
      ),
    );
  }
}