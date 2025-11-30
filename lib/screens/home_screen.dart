import '../widgets/no_internet_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../utils/app_texts_kurdish.dart';
import '../widgets/custom_button.dart';
import '../widgets/lesson_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/hearts_widget.dart';
import '../screens/learning_path_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Load user progress when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadProgress();
      context.read<LessonProvider>().loadLessons();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          _LearningTab(),
          _ProgressTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: AppTextsKurdish.learn,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded),
            label: AppTextsKurdish.progress,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: AppTextsKurdish.profile,
          ),
        ],
      ),
    );
  }
}

// Learning Tab - Main course content
class _LearningTab extends StatelessWidget {
  const _LearningTab();

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    return Consumer3<UserProvider, LessonProvider, ProgressProvider>(
      builder:
          (context, userProvider, lessonProvider, progressProvider, child) {
        if (lessonProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (lessonProvider.errorMessage != null) {
          return NoInternetWidget(
            message: lessonProvider.errorMessage,
            onRetry: () {
              lessonProvider.retryLoadLessons();
            },
          );
        }

        final user = userProvider.currentUser;
        final currentLevel = progressProvider.currentLevel;
        final streakDays = progressProvider.streakDays;

        // Responsive padding
        final horizontalPadding =
            isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar - Responsive height
              SliverAppBar(
                expandedHeight:
                    isSmallScreen ? 160 : (isMediumScreen ? 180 : 200),
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary600,
                actions: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: HeartsAppBarWidget(), // ADD THIS
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary600,
                          AppColors.primary700,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Character/Brand logo - Responsive size
                              Container(
                                width: isSmallScreen
                                    ? 48
                                    : (isMediumScreen ? 54 : 60),
                                height: isSmallScreen
                                    ? 48
                                    : (isMediumScreen ? 54 : 60),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 24 : 30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(isSmallScreen ? 6 : 8),
                                  child: Image.asset(
                                    'assets/images/shazman_icon.png',
                                    width: isSmallScreen ? 36 : 44,
                                    height: isSmallScreen ? 36 : 44,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              SizedBox(
                                  width: isSmallScreen
                                      ? 10
                                      : (isMediumScreen ? 12 : 16)),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'سڵاو، ${user?.name ?? 'خوێندکار'}!',
                                      style: TextStyle(
                                        fontSize: isSmallScreen
                                            ? 18
                                            : (isMediumScreen ? 20 : 24),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: isSmallScreen ? 2 : 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_fire_department_rounded,
                                          color: Colors.orange[300],
                                          size: isSmallScreen ? 16 : 20,
                                        ),
                                        SizedBox(width: isSmallScreen ? 3 : 4),
                                        Flexible(
                                          child: Text(
                                            '${_toArabicIndic(streakDays)} ${AppTextsKurdish.day} ${AppTextsKurdish.streak}',
                                            style: TextStyle(
                                              fontSize: isSmallScreen
                                                  ? 13
                                                  : (isMediumScreen ? 14 : 16),
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Settings button
                              IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.settings);
                                },
                                icon: Icon(
                                  Icons.settings_rounded,
                                  color: Colors.white,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                constraints: const BoxConstraints(
                                    minWidth: 40, minHeight: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Current Level Progress
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'ئاستی ئێستا: ${_getLevelName(currentLevel)}',
                              style: TextStyle(
                                fontSize: isSmallScreen
                                    ? 15
                                    : (isMediumScreen ? 16 : 18),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen
                                  ? 8
                                  : (isMediumScreen ? 10 : 12),
                              vertical: isSmallScreen ? 4 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary600.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_toArabicIndic(progressProvider.currentLevelProgress.toInt())}٪',
                              style: TextStyle(
                                color: AppColors.primary600,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                          height:
                              isSmallScreen ? 8 : (isMediumScreen ? 10 : 12)),

                      CustomProgressBar(
                        progress: progressProvider.currentLevelProgress / 100,
                        height: isSmallScreen ? 6 : 8,
                      ),

                      SizedBox(
                          height:
                              isSmallScreen ? 16 : (isMediumScreen ? 20 : 24)),

                      // Continue Learning Button
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 48 : 56,
                        child: CustomButton(
                          text: AppTextsKurdish.continueLearning,
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.lesson);
                          },
                          icon: Icons.play_arrow_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Course Sections (A1-C2)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTextsKurdish.englishCourse,
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? 16 : (isMediumScreen ? 18 : 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Course sections
                      ...List.generate(6, (index) {
                        final level = index + 1;
                        final levelName = _getLevelName(level);
                        final levelDescription = _getLevelDescription(level);
                        final isUnlocked = level <= currentLevel ;
                        final isCompleted = level < currentLevel;
                        final isCurrent = level == currentLevel;

                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: isSmallScreen
                                  ? 10
                                  : (isMediumScreen ? 12 : 16)),
                          child: LessonCard(
                            title: levelName,
                            subtitle: levelDescription,
                            progress: isCompleted
                                ? 1.0
                                : (isCurrent
                                    ? progressProvider.currentLevelProgress /
                                        100
                                    : 0.0),
                            isLocked: !isUnlocked,
                            isCompleted: isCompleted,
                            onTap: isUnlocked
                                ? () {
                                    _navigateToLevel(context, level);
                                  }
                                : null,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: isSmallScreen ? 12 : 20),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return 'A1 - دەستپێک';
      case 2:
        return 'A2 - سەرەتایی';
      case 3:
        return 'B1 - ناوەند';
      case 4:
        return 'B2 - ناوەندی بەرز';
      case 5:
        return 'C1 - پێشکەوتوو';
      case 6:
        return 'C2 - شارەزایی';
      default:
        return 'نامۆ';
    }
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'دەستەواژە و دەربڕینی ڕۆژانە';
      case 2:
        return 'گفتوگۆی سادە و دۆخی باو';
      case 3:
        return 'قسەکردنی ڕوون لەسەر بابەتی ئاشنا';
      case 4:
        return 'دەقی ئاڵۆز و بابەتی چەمکی';
      case 5:
        return 'مەودایەکی بەرفراوان لە دەقی قورس';
      case 6:
        return 'لێهاتوویی و تێگەیشتنی وەک زمانی دایک';
      default:
        return '';
    }
  }

  void _navigateToLevel(BuildContext context, int level) {
    final progressProvider =
        Provider.of<ProgressProvider>(context, listen: false);

    // Check if level is unlocked
    if (!progressProvider.isLevelUnlocked(level)) {
      // Show locked message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('تکایە ئاستی پێشوو تەواو بکە بۆ کردنەوەی ئەم ئاستە'),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to learning path
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LearningPathScreen(level: level),
      ),
    );
  }

  // Convert to Arabic-Indic numerals
  String _toArabicIndic(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = number.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabicIndic[i]);
    }
    return result;
  }
}

// Progress Tab
class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;
    final horizontalPadding =
        isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);

    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTextsKurdish.yourProgress,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : (isMediumScreen ? 24 : 28),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(
                    height: isSmallScreen ? 16 : (isMediumScreen ? 20 : 24)),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: AppTextsKurdish.streak,
                        value: _toArabicIndic(progressProvider.streakDays),
                        subtitle: AppTextsKurdish.days,
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.orange,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                      ),
                    ),
                    SizedBox(
                        width: isSmallScreen ? 10 : (isMediumScreen ? 12 : 16)),
                    Expanded(
                      child: _StatCard(
                        title: AppTextsKurdish.totalXP,
                        value: _toArabicIndic(progressProvider.totalXP),
                        subtitle: AppTextsKurdish.points,
                        icon: Icons.star_rounded,
                        color: Colors.amber,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                    height: isSmallScreen ? 10 : (isMediumScreen ? 12 : 16)),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: AppTextsKurdish.lessons,
                        value:
                            _toArabicIndic(progressProvider.completedLessons),
                        subtitle: AppTextsKurdish.completed,
                        icon: Icons.check_circle_rounded,
                        color: Colors.green,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                      ),
                    ),
                    SizedBox(
                        width: isSmallScreen ? 10 : (isMediumScreen ? 12 : 16)),
                    Expanded(
                      child: _StatCard(
                        title: AppTextsKurdish.currentLevel,
                        value: _getLevelName(progressProvider.currentLevel)
                            .split(' ')[0],
                        subtitle: 'ئاست',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.primary600,
                        isSmallScreen: isSmallScreen,
                        isMediumScreen: isMediumScreen,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                    height: isSmallScreen ? 20 : (isMediumScreen ? 24 : 32)),

                // Weekly Progress Chart Placeholder
                Container(
                  width: double.infinity,
                  height: isSmallScreen ? 160 : (isMediumScreen ? 180 : 200),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 12 : 16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          size: isSmallScreen ? 36 : 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Text(
                          'چارتی پێشکەوتنی هەفتانە',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'بەم زووانە دێت',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1:
        return 'A1 - دەستپێک';
      case 2:
        return 'A2 - سەرەتایی';
      case 3:
        return 'B1 - ناوەند';
      case 4:
        return 'B2 - ناوەندی بەرز';
      case 5:
        return 'C1 - پێشکەوتوو';
      case 6:
        return 'C2 - شارەزایی';
      default:
        return 'نامۆ';
    }
  }

  String _toArabicIndic(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = number.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabicIndic[i]);
    }
    return result;
  }
}

// Profile Tab
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;
    final horizontalPadding =
        isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary600, AppColors.primary700],
                    ),
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 16 : 20),
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        width: isSmallScreen ? 64 : (isMediumScreen ? 70 : 80),
                        height: isSmallScreen ? 64 : (isMediumScreen ? 70 : 80),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(isSmallScreen ? 32 : 40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: isSmallScreen ? 32 : 40,
                          color: AppColors.primary600,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      Text(
                        user?.name ?? 'میوان',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? 20 : (isMediumScreen ? 22 : 24),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: isSmallScreen ? 3 : 4),

                      Text(
                        user?.email ?? 'guest@shazman.com',
                        style: TextStyle(
                          fontSize:
                              isSmallScreen ? 13 : (isMediumScreen ? 14 : 16),
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                    height: isSmallScreen ? 20 : (isMediumScreen ? 24 : 32)),

                // Menu Items
                Expanded(
                  child: Column(
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.edit_rounded,
                        title: AppTextsKurdish.editProfile,
                        onTap: () {},
                        isSmallScreen: isSmallScreen,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.notifications_rounded,
                        title: AppTextsKurdish.notifications,
                        onTap: () {},
                        isSmallScreen: isSmallScreen,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.help_rounded,
                        title: AppTextsKurdish.helpSupport,
                        onTap: () {},
                        isSmallScreen: isSmallScreen,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.info_rounded,
                        title: AppTextsKurdish.about,
                        onTap: () {},
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 20),
                      _ProfileMenuItem(
                        icon: Icons.logout_rounded,
                        title: AppTextsKurdish.signOut,
                        onTap: () {
                          _showSignOutDialog(context);
                        },
                        isDestructive: true,
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTextsKurdish.signOut),
        content: Text(AppTextsKurdish.confirmSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTextsKurdish.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<UserProvider>().signOut();
              Navigator.pop(context);
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
}

// Statistics Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSmallScreen;
  final bool isMediumScreen;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSmallScreen,
    required this.isMediumScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : (isMediumScreen ? 14 : 16)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: color,
                  size: isSmallScreen ? 16 : (isMediumScreen ? 18 : 20)),
              SizedBox(width: isSmallScreen ? 4 : (isMediumScreen ? 6 : 8)),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : (isMediumScreen ? 12 : 14),
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : (isMediumScreen ? 22 : 24),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12),
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Profile Menu Item Widget
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isSmallScreen;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 4 : 8,
        ),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.primary600,
          size: isSmallScreen ? 20 : 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 14 : 16,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: isSmallScreen ? 14 : 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        ),
        minVerticalPadding: 0,
      ),
    );
  }
}
