class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();
  
  // Authentication routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // Main app routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Learning routes
  static const String lesson = '/lesson';
  static const String levelUnits = '/level-units';
  static const String lessonDetail = '/lesson-detail';
  static const String lessonComplete = '/lesson-complete';
  static const String practice = '/practice';
  static const String review = '/review';
  
  // Exercise routes
  static const String exerciseFillBlank = '/exercise/fill-blank';
  static const String exerciseMultipleChoice = '/exercise/multiple-choice';
  static const String exerciseMatching = '/exercise/matching';
  static const String exerciseListening = '/exercise/listening';
  static const String exerciseSpeaking = '/exercise/speaking';
  static const String exerciseWriting = '/exercise/writing';
  static const String exerciseReading = '/exercise/reading';
  
  // Progress and statistics routes
  static const String progress = '/progress';
  static const String achievements = '/achievements';
  static const String leaderboard = '/leaderboard';
  static const String statistics = '/statistics';
  
  // Profile and account routes
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String accountSettings = '/account-settings';
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notification-settings';
  
  // Learning preferences routes
  static const String languageSettings = '/language-settings';
  static const String learningGoals = '/learning-goals';
  static const String dailyGoal = '/daily-goal';
  
  // Content routes
  static const String vocabulary = '/vocabulary';
  static const String grammar = '/grammar';
  static const String stories = '/stories';
  static const String podcasts = '/podcasts';
  
  // Social and community routes
  static const String friends = '/friends';
  static const String challenges = '/challenges';
  static const String forum = '/forum';
  
  // Support and information routes
  static const String help = '/help';
  static const String faq = '/faq';
  static const String about = '/about';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
  static const String contactUs = '/contact-us';
  
  // Premium and shop routes
  static const String premium = '/premium';
  static const String shop = '/shop';
  static const String removeAds = '/remove-ads';
  
  // Testing and placement routes
  static const String placementTest = '/placement-test';
  static const String levelTest = '/level-test';
  
  // Onboarding routes
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String selectLevel = '/select-level';
  
  // Get all routes as a list (useful for analytics or debugging)
  static List<String> get allRoutes => [
    splash,
    login,
    signUp,
    forgotPassword,
    resetPassword,
    home,
    profile,
    settings,
    lesson,
    levelUnits,
    lessonDetail,
    lessonComplete,
    practice,
    review,
    exerciseFillBlank,
    exerciseMultipleChoice,
    exerciseMatching,
    exerciseListening,
    exerciseSpeaking,
    exerciseWriting,
    exerciseReading,
    progress,
    achievements,
    leaderboard,
    statistics,
    editProfile,
    changePassword,
    accountSettings,
    notifications,
    notificationSettings,
    languageSettings,
    learningGoals,
    dailyGoal,
    vocabulary,
    grammar,
    stories,
    podcasts,
    friends,
    challenges,
    forum,
    help,
    faq,
    about,
    termsOfService,
    privacyPolicy,
    contactUs,
    premium,
    shop,
    removeAds,
    placementTest,
    levelTest,
    onboarding,
    welcome,
    selectLevel,
  ];
  
  // Check if route requires authentication
  static bool requiresAuth(String route) {
    const publicRoutes = [
      splash,
      login,
      signUp,
      forgotPassword,
      resetPassword,
      onboarding,
      welcome,
      about,
      termsOfService,
      privacyPolicy,
    ];
    
    return !publicRoutes.contains(route);
  }
  
  // Check if route is an authentication route
  static bool isAuthRoute(String route) {
    const authRoutes = [
      login,
      signUp,
      forgotPassword,
      resetPassword,
    ];
    
    return authRoutes.contains(route);
  }
  
  // Check if route is a main navigation route
  static bool isMainRoute(String route) {
    const mainRoutes = [
      home,
      progress,
      profile,
    ];
    
    return mainRoutes.contains(route);
  }
  
  // Get route name for analytics
  static String getRouteName(String route) {
    return route.replaceAll('/', '_').replaceFirst('_', '');
  }
  
  // Parse route with parameters
  static String routeWithParams(String route, Map<String, dynamic> params) {
    String finalRoute = route;
    params.forEach((key, value) {
      finalRoute += finalRoute.contains('?') ? '&' : '?';
      finalRoute += '$key=$value';
    });
    return finalRoute;
  }
}

// Route arguments class for passing data between screens
class RouteArguments {
  final Map<String, dynamic> arguments;
  
  const RouteArguments(this.arguments);
  
  // Get argument by key
  T? get<T>(String key) {
    return arguments[key] as T?;
  }
  
  // Get argument with default value
  T getOrDefault<T>(String key, T defaultValue) {
    return arguments[key] as T? ?? defaultValue;
  }
  
  // Check if argument exists
  bool contains(String key) {
    return arguments.containsKey(key);
  }
  
  // Common argument keys
  static const String lessonId = 'lessonId';
  static const String levelId = 'levelId';
  static const String unitId = 'unitId';
  static const String userId = 'userId';
  static const String title = 'title';
  static const String data = 'data';
  static const String fromRoute = 'fromRoute';
  static const String exerciseType = 'exerciseType';
}

// Route transition types
enum RouteTransition {
  fade,
  slide,
  scale,
  rotation,
  none,
}

// Route configuration class for advanced routing
class RouteConfig {
  final String path;
  final String name;
  final bool requiresAuth;
  final RouteTransition transition;
  final Duration? transitionDuration;
  
  const RouteConfig({
    required this.path,
    required this.name,
    this.requiresAuth = true,
    this.transition = RouteTransition.fade,
    this.transitionDuration,
  });
}