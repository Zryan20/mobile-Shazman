import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Firebase options
import 'firebase_options.dart';

// Import providers
import 'providers/user_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/hearts_provider.dart';

// Import services
import 'services/auth_service.dart';
import 'services/backend_service.dart';

// Import utils
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';

// Import screens
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Create backend service and hearts provider
  final backendService = BackendService();
  final heartsProvider = HeartsProvider();

  // Set backend service for hearts provider
  heartsProvider.setBackendService(backendService);

  // Load hearts from local storage first
  await heartsProvider.loadHearts();

  // Sync with backend (if user is logged in)
  try {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await backendService.syncHearts();
      // Hearts will be synced automatically
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase sync skipped: $e');
    }
  }

  runApp(HozhanApp(
    heartsProvider: heartsProvider,
    backendService: backendService,
  ));
}

class HozhanApp extends StatelessWidget {
  final HeartsProvider heartsProvider;
  final BackendService backendService;

  const HozhanApp({
    super.key,
    required this.heartsProvider,
    required this.backendService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HeartsProvider>.value(value: heartsProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        Provider(create: (_) => AuthService()),
        Provider<BackendService>.value(value: backendService),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'هۆژان - فێربوونی ئینگلیزی',
            debugShowCheckedModeBanner: false,

            // Theme mode based on settings
            themeMode:
                settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,

            // Light theme
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
                Theme.of(context).textTheme,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary600,
                primary: AppColors.primary600,
                secondary: AppColors.primary700,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: AppColors.backgroundLight,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary600, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.primary600,
                unselectedItemColor: Colors.grey[600],
                type: BottomNavigationBarType.fixed,
                elevation: 8,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: AppColors.primary600,
                linearTrackColor: Colors.grey,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
                elevation: 6,
              ),
            ),

            // Dark theme
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
                ThemeData.dark().textTheme,
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary600,
                primary: AppColors.primary600,
                secondary: AppColors.primary700,
                brightness: Brightness.dark,
                surface: AppColors.surfaceDark,
              ),
              scaffoldBackgroundColor: AppColors.backgroundDark,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary700,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                color: AppColors.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary600, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: AppColors.surfaceDark,
                selectedItemColor: AppColors.primary400,
                unselectedItemColor: AppColors.textTertiaryDark,
                type: BottomNavigationBarType.fixed,
                elevation: 8,
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: AppColors.primary400,
                linearTrackColor: AppColors.borderDark,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: AppColors.primary600,
                foregroundColor: Colors.white,
                elevation: 6,
              ),
            ),
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.welcome: (context) => const WelcomeScreen(),
              AppRoutes.login: (context) => const LoginScreen(),
              AppRoutes.signUp: (context) => const SignUpScreen(),
              AppRoutes.forgotPassword: (context) =>
                  const ForgotPasswordScreen(),
              AppRoutes.home: (context) => const HomeScreen(),
              AppRoutes.lesson: (context) => const LessonScreen(),
              AppRoutes.profile: (context) => const ProfileScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
              AppRoutes.premium: (context) => const PremiumScreen(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

// Splash Screen Widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load settings first
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.loadSettings();

    // Load hearts system
    if (!mounted) return;
    final heartsProvider = Provider.of<HeartsProvider>(context, listen: false);
    await heartsProvider.loadHearts();

    // Wait for splash animation (reduced time)
    await Future.delayed(const Duration(milliseconds: 1000));

    // Check Auth Status directly
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final progressProvider =
          Provider.of<ProgressProvider>(context, listen: false);

      // Reload user data
      await Future.wait([
        userProvider.loadUser(),
        progressProvider.loadProgress(),
      ]);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary600,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/Hozhan_icon.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'هۆژان',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'زمانی ئینگلیزی فێرببە بە شێوەیەکی خۆش و چێژبەخش',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 60),
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
