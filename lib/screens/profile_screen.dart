import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_texts_kurdish.dart';
import '../utils/app_routes.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTextsKurdish.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: Consumer2<UserProvider, ProgressProvider>(
        builder: (context, userProvider, progressProvider, child) {
          final user = userProvider.currentUser;
          
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_rounded,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'هیچ بەکارهێنەرێک چوونەژوورەوەی نەکردووە',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: AppTextsKurdish.signIn,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary600, AppColors.primary700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: user.hasProfileImage
                                ? ClipOval(
                                    child: Image.network(
                                      user.profileImageUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDefaultAvatar(user.initials);
                                      },
                                    ),
                                  )
                                : _buildDefaultAvatar(user.initials),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary600,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _showImagePickerDialog(context);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Email
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Edit Profile Button
                      SmallButton(
                        text: AppTextsKurdish.editProfile,
                        onPressed: () {
                          _showEditProfileDialog(context);
                        },
                        backgroundColor: Colors.white,
                        textColor: AppColors.primary600,
                      ),
                    ],
                  ),
                ),
                
                // Stats Section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        icon: Icons.local_fire_department_rounded,
                        value: _convertToArabicNumerals(progressProvider.streakDays),
                        label: AppTextsKurdish.streak,
                        color: AppColors.streakFire,
                      ),
                      _StatItem(
                        icon: Icons.star_rounded,
                        value: _convertToArabicNumerals(progressProvider.totalXP),
                        label: AppTextsKurdish.totalXP,
                        color: AppColors.xpGold,
                      ),
                      _StatItem(
                        icon: Icons.emoji_events_rounded,
                        value: _convertToArabicNumerals(progressProvider.currentLevel),
                        label: 'ئاست',
                        color: AppColors.primary600,
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Menu Items
                _MenuItem(
                  icon: Icons.school_rounded,
                  title: AppTextsKurdish.currentLevel,
                  subtitle: progressProvider.getLevelName(progressProvider.currentLevel),
                  onTap: () {
                    // Navigate to level details
                  },
                ),
                
                _MenuItem(
                  icon: Icons.trending_up_rounded,
                  title: AppTextsKurdish.progress,
                  subtitle: '${_convertToArabicNumerals(progressProvider.completedLessons)} ${AppTextsKurdish.lessonsCompleted}',
                  onTap: () {
                    // Navigate to progress screen
                  },
                ),
                
                _MenuItem(
                  icon: Icons.emoji_events_rounded,
                  title: AppTextsKurdish.achievements,
                  subtitle: 'دەستکەوتەکانت ببینە',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.achievements);
                  },
                ),
                
                _MenuItem(
                  icon: Icons.leaderboard_rounded,
                  title: AppTextsKurdish.leaderboard,
                  subtitle: 'پلەی خۆت ببینە',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.leaderboard);
                  },
                ),
                
                const Divider(height: 1),
                
                _MenuItem(
                  icon: Icons.notifications_rounded,
                  title: AppTextsKurdish.notifications,
                  subtitle: 'بەڕێوەبردنی ئاگادارکردنەوەکان',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.notificationSettings);
                  },
                ),
                
                _MenuItem(
                  icon: Icons.help_rounded,
                  title: AppTextsKurdish.helpSupport,
                  subtitle: 'یارمەتی وەربگرە',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.help);
                  },
                ),
                
                _MenuItem(
                  icon: Icons.info_rounded,
                  title: AppTextsKurdish.about,
                  subtitle: 'دەربارەی ${AppTextsKurdish.appName}',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.about);
                  },
                ),
                
                const Divider(height: 1),
                
                _MenuItem(
                  icon: Icons.logout_rounded,
                  title: AppTextsKurdish.signOut,
                  subtitle: 'دەرچوون لە هەژمارەکەت',
                  onTap: () {
                    _showSignOutDialog(context);
                  },
                  isDestructive: true,
                ),
                
                const SizedBox(height: 20),
                
                // Version info
                Center(
                  child: Text(
                    '${AppTextsKurdish.appName} وەشان ${AppTextsKurdish.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDefaultAvatar(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.primary600,
        ),
      ),
    );
  }
  
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'گۆڕینی وێنەی پرۆفایل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: AppColors.primary600),
                title: const Text('وێنە بگرە'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement camera
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('کامێرا بەم زووانە دێت!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: AppColors.primary600),
                title: const Text('لە گەلەری هەڵبژێرە'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement gallery picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('هەڵبژاردنی گەلەری بەم زووانە دێت!')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_rounded, color: AppColors.error),
                title: const Text('لابردنی وێنە'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Remove profile picture
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: context.read<UserProvider>().currentUser?.name ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTextsKurdish.editProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: AppTextsKurdish.fullName,
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTextsKurdish.cancel),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                context.read<UserProvider>().updateProfile(name: newName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(AppTextsKurdish.profileUpdated),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text(AppTextsKurdish.save),
          ),
        ],
      ),
    );
  }
  
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppTextsKurdish.signOut),
        content: const Text(AppTextsKurdish.confirmSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppTextsKurdish.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().signOut();
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: Text(
              AppTextsKurdish.signOut,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper function to convert numbers to Arabic-Indic numerals
  String _convertToArabicNumerals(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    
    String result = number.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }
}

// Stat Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Menu Item Widget
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}