import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('ئاگادارکردنەوەکان'),
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top gradient banner
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          settings.notificationsEnabled
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ئاگادارکردنەوەکان',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settings.notificationsEnabled
                                  ? 'ئاگادارکردنەوەکان کراوەن'
                                  : 'ئاگادارکردنەوەکان داخراون',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Master toggle in header
                      Switch(
                        value: settings.notificationsEnabled,
                        onChanged: (val) => settings.setNotifications(val),
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.primary800,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Disabled overlay message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: !settings.notificationsEnabled
                      ? Padding(
                          key: const ValueKey('disabled-msg'),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.warning.withOpacity(0.4)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline_rounded,
                                    color: AppColors.warning, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'ئاگادارکردنەوەکانت داخراوە. کردنەوەی سویچەکە بۆ دیتنی هەموو بژاردەکان.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.warningDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('no-msg')),
                ),

                if (!settings.notificationsEnabled) const SizedBox(height: 16),

                // Learning Reminders section
                _SectionHeader(
                  title: 'یادکردنەوەی فێربوون',
                  enabled: settings.notificationsEnabled,
                ),
                _NotifTile(
                  icon: Icons.school_rounded,
                  iconColor: AppColors.primary600,
                  title: 'یادکردنەوەی وانەی ڕۆژانە',
                  subtitle: 'ئاگادارت بکاتەوە کاتێک کاتی فێربوونەکەتە',
                  value: settings.notificationsEnabled,
                  masterEnabled: settings.notificationsEnabled,
                  onChanged: (val) => settings.setNotifications(val),
                ),
                _NotifTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.streakFire,
                  title: 'بەردەوامی ڕۆژانە',
                  subtitle:
                      'یادت بکاتەوە بۆ بەردەوامکردنی سیلسلەی خوێندنەکەت',
                  value: settings.notificationsEnabled,
                  masterEnabled: settings.notificationsEnabled,
                  onChanged: (val) => settings.setNotifications(val),
                ),

                const SizedBox(height: 8),

                // Progress & XP section
                _SectionHeader(
                  title: 'پێشکەوتن و نمرە',
                  enabled: settings.notificationsEnabled,
                ),
                _NotifTile(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.xpGold,
                  title: 'بەدەستهێنانی XP',
                  subtitle: 'ئاگادارت بکاتەوە کاتێک نمرەی نوێت بەدەستهێنا',
                  value: settings.notificationsEnabled,
                  masterEnabled: settings.notificationsEnabled,
                  onChanged: (val) => settings.setNotifications(val),
                ),
                _NotifTile(
                  icon: Icons.emoji_events_rounded,
                  iconColor: Colors.amber,
                  title: 'دەستخستنی بەدەستهێنانەکان',
                  subtitle: 'کاتێک موفاقاتێکی نوێ بەدەست دەهێنیت',
                  value: settings.notificationsEnabled,
                  masterEnabled: settings.notificationsEnabled,
                  onChanged: (val) => settings.setNotifications(val),
                ),

                const SizedBox(height: 8),

                // App section
                _SectionHeader(
                  title: 'ئەپ',
                  enabled: settings.notificationsEnabled,
                ),
                _NotifTile(
                  icon: Icons.campaign_rounded,
                  iconColor: AppColors.info,
                  title: 'نوێکاریەکان و هەواڵ',
                  subtitle: 'تازەترین نوێکاریەکان و هەواڵی هۆژان',
                  value: settings.notificationsEnabled,
                  masterEnabled: settings.notificationsEnabled,
                  onChanged: (val) => settings.setNotifications(val),
                ),
                _NotifTile(
                  icon: Icons.vibration_rounded,
                  iconColor: AppColors.secondary600,
                  title: 'لەرزین',
                  subtitle: 'لەرزینی مۆبایل لەگەڵ ئاگادارکردنەوەکان',
                  value: settings.vibrationEnabled &&
                      settings.notificationsEnabled,
                  masterEnabled: settings.notificationsEnabled,
                  onChanged: settings.notificationsEnabled
                      ? (val) => settings.setVibration(val)
                      : null,
                ),

                const SizedBox(height: 32),

                // Footer note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '* هەندێک ئاگادارکردنەوە پشت دەبەستن بە ڕێکخستنی ئامێرەکەت',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool enabled;

  const _SectionHeader({required this.title, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: enabled ? AppColors.primary600 : AppColors.neutral400,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Notification toggle tile ─────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool masterEnabled;
  final ValueChanged<bool>? onChanged;

  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.masterEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = masterEnabled ? iconColor : AppColors.neutral300;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: AnimatedOpacity(
        opacity: masterEnabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 250),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: effectiveColor, size: 22),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            trailing: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary600,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ),
    );
  }
}
