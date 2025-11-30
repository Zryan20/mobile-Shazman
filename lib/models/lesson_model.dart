class Lesson {
  final String id;
  final String title;
  final String description;
  final int level; // 1-6 (A1-C2)
  final int unitNumber;
  final int lessonNumber;
  final int xpReward;
  final Duration estimatedDuration;
  final bool isCompleted;
  final bool isLocked;
  final DateTime? completedAt;
  final List<String>? tags; // e.g., ['grammar', 'vocabulary']
  
  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.unitNumber,
    required this.lessonNumber,
    required this.xpReward,
    required this.estimatedDuration,
    this.isCompleted = false,
    this.isLocked = true,
    this.completedAt,
    this.tags,
  });
  
  // Create copy with modified fields
  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    int? level,
    int? unitNumber,
    int? lessonNumber,
    int? xpReward,
    Duration? estimatedDuration,
    bool? isCompleted,
    bool? isLocked,
    DateTime? completedAt,
    List<String>? tags,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      unitNumber: unitNumber ?? this.unitNumber,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      xpReward: xpReward ?? this.xpReward,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'unitNumber': unitNumber,
      'lessonNumber': lessonNumber,
      'xpReward': xpReward,
      'estimatedDurationMinutes': estimatedDuration.inMinutes,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
    };
  }
  
  // Create from JSON with robust null handling
  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Extract and validate required fields with Kurdish fallbacks
    final String id = (json['id'] as String?) ?? '';
    final String title = (json['title'] as String?) ?? 'وانەی نامۆ'; // "Unknown Lesson"
    final String description = (json['description'] as String?) ?? 'هیچ وەسفێک بەردەست نییە'; // "No description available"
    final int level = (json['level'] as int?) ?? 1;
    final int unitNumber = (json['unitNumber'] as int?) ?? 1;
    final int lessonNumber = (json['lessonNumber'] as int?) ?? 1;
    final int xpReward = (json['xpReward'] as int?) ?? 10;
    final int durationMinutes = (json['estimatedDurationMinutes'] as int?) ?? 5;
    
    return Lesson(
      id: id,
      title: title,
      description: description,
      level: level,
      unitNumber: unitNumber,
      lessonNumber: lessonNumber,
      xpReward: xpReward,
      estimatedDuration: Duration(minutes: durationMinutes),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? true,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      tags: json['tags'] != null && json['tags'] is List
          ? List<String>.from(json['tags'] as List)
          : null,
    );
  }
  
  // Get level name in Kurdish (Sorani)
  String get levelName {
    switch (level) {
      case 1: return 'A1';
      case 2: return 'A2';
      case 3: return 'B1';
      case 4: return 'B2';
      case 5: return 'C1';
      case 6: return 'C2';
      default: return 'نامۆ'; // "Unknown"
    }
  }
  
  // Get level description in Kurdish (Sorani)
  String get levelDescription {
    switch (level) {
      case 1: return 'دەستپێک'; // Beginner
      case 2: return 'سەرەتایی'; // Elementary
      case 3: return 'ناوەند'; // Intermediate
      case 4: return 'ناوەندی بەرز'; // Upper Intermediate
      case 5: return 'پێشکەوتوو'; // Advanced
      case 6: return 'شارەزایی'; // Proficiency
      default: return 'نامۆ'; // Unknown
    }
  }
  
  // Get full level name
  String get fullLevelName => '$levelName - $levelDescription';
  
  // Get lesson identifier (e.g., "A1.1.3") with Arabic-Indic numerals
  String get lessonIdentifier {
    return '$levelName.${_toArabicIndic(unitNumber)}.${_toArabicIndic(lessonNumber)}';
  }
  
  // Get formatted duration in Kurdish with Arabic-Indic numerals
  String get formattedDuration {
    final minutes = estimatedDuration.inMinutes;
    if (minutes < 60) {
      return '${_toArabicIndic(minutes)} خولەک'; // minutes
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${_toArabicIndic(hours)} کاتژمێر'; // hour(s)
      } else {
        return '${_toArabicIndic(hours)} کاتژمێر ${_toArabicIndic(remainingMinutes)} خولەک';
      }
    }
  }
  
  // Convert integer to Arabic-Indic numerals
  String _toArabicIndic(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    
    String result = number.toString();
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabicIndic[i]);
    }
    return result;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Lesson &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.level == level &&
        other.unitNumber == unitNumber &&
        other.lessonNumber == lessonNumber &&
        other.xpReward == xpReward &&
        other.estimatedDuration == estimatedDuration &&
        other.isCompleted == isCompleted &&
        other.isLocked == isLocked &&
        other.completedAt == completedAt;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      level,
      unitNumber,
      lessonNumber,
      xpReward,
      estimatedDuration,
      isCompleted,
      isLocked,
      completedAt,
    );
  }
  
  @override
  String toString() {
    return 'Lesson(id: $id, title: $title, level: $levelName, unit: $unitNumber, lesson: $lessonNumber, completed: $isCompleted, locked: $isLocked)';
  }
}