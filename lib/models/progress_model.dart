class Progress {
  final String userId;
  final int currentLevel; // 1-6 (A1-C2)
  final double currentLevelProgress; // 0-100% progress within current level
  final int totalXP;
  final int streakDays;
  final DateTime? lastActivityDate;
  final List<LevelProgress> levelProgressList;
  final List<String> completedLessonIds;
  final Map<String, int> lessonAttempts; // lessonId -> number of attempts
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Progress({
    required this.userId,
    required this.currentLevel,
    required this.currentLevelProgress,
    required this.totalXP,
    required this.streakDays,
    this.lastActivityDate,
    required this.levelProgressList,
    required this.completedLessonIds,
    required this.lessonAttempts,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Create a new progress instance (for new users)
  factory Progress.initial(String userId) {
    final now = DateTime.now();
    return Progress(
      userId: userId,
      currentLevel: 1,
      currentLevelProgress: 0.0,
      totalXP: 0,
      streakDays: 0,
      lastActivityDate: null,
      levelProgressList: List.generate(
        6,
        (index) => LevelProgress(
          level: index + 1,
          progress: 0.0,
          isUnlocked: index == 0, // Only A1 unlocked initially
          isCompleted: false,
          xpEarned: 0,
          lessonsCompleted: 0,
          totalLessons: 0, // Will be set when lessons are loaded
        ),
      ),
      completedLessonIds: [],
      lessonAttempts: {},
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // Create copy with modified fields
  Progress copyWith({
    String? userId,
    int? currentLevel,
    double? currentLevelProgress,
    int? totalXP,
    int? streakDays,
    DateTime? lastActivityDate,
    List<LevelProgress>? levelProgressList,
    List<String>? completedLessonIds,
    Map<String, int>? lessonAttempts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Progress(
      userId: userId ?? this.userId,
      currentLevel: currentLevel ?? this.currentLevel,
      currentLevelProgress: currentLevelProgress ?? this.currentLevelProgress,
      totalXP: totalXP ?? this.totalXP,
      streakDays: streakDays ?? this.streakDays,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      levelProgressList: levelProgressList ?? this.levelProgressList,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      lessonAttempts: lessonAttempts ?? this.lessonAttempts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentLevel': currentLevel,
      'currentLevelProgress': currentLevelProgress,
      'totalXP': totalXP,
      'streakDays': streakDays,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'levelProgressList': levelProgressList.map((lp) => lp.toJson()).toList(),
      'completedLessonIds': completedLessonIds,
      'lessonAttempts': lessonAttempts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Create from JSON
  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      userId: json['userId'] as String,
      currentLevel: json['currentLevel'] as int,
      currentLevelProgress: (json['currentLevelProgress'] as num).toDouble(),
      totalXP: json['totalXP'] as int,
      streakDays: json['streakDays'] as int,
      lastActivityDate: json['lastActivityDate'] != null
          ? DateTime.parse(json['lastActivityDate'] as String)
          : null,
      levelProgressList: (json['levelProgressList'] as List)
          .map((lp) => LevelProgress.fromJson(lp as Map<String, dynamic>))
          .toList(),
      completedLessonIds: List<String>.from(json['completedLessonIds'] as List),
      lessonAttempts: Map<String, int>.from(json['lessonAttempts'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  // Get total completed lessons
  int get totalCompletedLessons => completedLessonIds.length;
  
  // Get progress for specific level
  LevelProgress? getProgressForLevel(int level) {
    try {
      return levelProgressList.firstWhere((lp) => lp.level == level);
    } catch (e) {
      return null;
    }
  }
  
  // Check if level is unlocked
  bool isLevelUnlocked(int level) {
    final levelProgress = getProgressForLevel(level);
    return levelProgress?.isUnlocked ?? false;
  }
  
  // Check if level is completed
  bool isLevelCompleted(int level) {
    final levelProgress = getProgressForLevel(level);
    return levelProgress?.isCompleted ?? false;
  }
  
  // Check if lesson is completed
  bool isLessonCompleted(String lessonId) {
    return completedLessonIds.contains(lessonId);
  }
  
  // Get number of attempts for a lesson
  int getLessonAttempts(String lessonId) {
    return lessonAttempts[lessonId] ?? 0;
  }
  
  // Check if streak is active (activity within last 24 hours)
  bool get isStreakActive {
    if (lastActivityDate == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActivityDate!);
    return difference.inHours < 24;
  }
  
  // Get level name
  String getLevelName(int level) {
    switch (level) {
      case 1: return 'A1 - Beginner';
      case 2: return 'A2 - Elementary';
      case 3: return 'B1 - Intermediate';
      case 4: return 'B2 - Upper Intermediate';
      case 5: return 'C1 - Advanced';
      case 6: return 'C2 - Proficiency';
      default: return 'Unknown';
    }
  }
  
  @override
  String toString() {
    return 'Progress(userId: $userId, currentLevel: $currentLevel, currentLevelProgress: $currentLevelProgress%, totalXP: $totalXP, streak: $streakDays days, completedLessons: $totalCompletedLessons)';
  }
}

// Level progress model
class LevelProgress {
  final int level; // 1-6 (A1-C2)
  final double progress; // 0-100%
  final bool isUnlocked;
  final bool isCompleted;
  final int xpEarned;
  final int lessonsCompleted;
  final int totalLessons;
  final DateTime? completedAt;
  final DateTime? unlockedAt;
  
  const LevelProgress({
    required this.level,
    required this.progress,
    required this.isUnlocked,
    required this.isCompleted,
    required this.xpEarned,
    required this.lessonsCompleted,
    required this.totalLessons,
    this.completedAt,
    this.unlockedAt,
  });
  
  // Create copy with modified fields
  LevelProgress copyWith({
    int? level,
    double? progress,
    bool? isUnlocked,
    bool? isCompleted,
    int? xpEarned,
    int? lessonsCompleted,
    int? totalLessons,
    DateTime? completedAt,
    DateTime? unlockedAt,
  }) {
    return LevelProgress(
      level: level ?? this.level,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      xpEarned: xpEarned ?? this.xpEarned,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      totalLessons: totalLessons ?? this.totalLessons,
      completedAt: completedAt ?? this.completedAt,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'progress': progress,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'xpEarned': xpEarned,
      'lessonsCompleted': lessonsCompleted,
      'totalLessons': totalLessons,
      'completedAt': completedAt?.toIso8601String(),
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
  
  // Create from JSON
  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      level: json['level'] as int,
      progress: (json['progress'] as num).toDouble(),
      isUnlocked: json['isUnlocked'] as bool,
      isCompleted: json['isCompleted'] as bool,
      xpEarned: json['xpEarned'] as int,
      lessonsCompleted: json['lessonsCompleted'] as int,
      totalLessons: json['totalLessons'] as int,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
  
  // Get level name
  String get levelName {
    switch (level) {
      case 1: return 'A1';
      case 2: return 'A2';
      case 3: return 'B1';
      case 4: return 'B2';
      case 5: return 'C1';
      case 6: return 'C2';
      default: return 'Unknown';
    }
  }
  
  // Get level description
  String get levelDescription {
    switch (level) {
      case 1: return 'Beginner';
      case 2: return 'Elementary';
      case 3: return 'Intermediate';
      case 4: return 'Upper Intermediate';
      case 5: return 'Advanced';
      case 6: return 'Proficiency';
      default: return 'Unknown';
    }
  }
  
  // Get full level name
  String get fullLevelName => '$levelName - $levelDescription';
  
  // Get completion percentage
  double get completionPercentage {
    if (totalLessons == 0) return 0.0;
    return (lessonsCompleted / totalLessons) * 100;
  }
  
  @override
  String toString() {
    return 'LevelProgress(level: $levelName, progress: $progress%, unlocked: $isUnlocked, completed: $isCompleted, lessons: $lessonsCompleted/$totalLessons)';
  }
}