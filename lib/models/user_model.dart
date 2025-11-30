class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserPreferences? preferences;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
  });
  
  // Create copy with modified fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'preferences': preferences?.toJson(),
    };
  }
  
  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : null,
    );
  }
  
  // Get first name
  String get firstName {
    return name.split(' ').first;
  }
  
  // Get initials for avatar
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
  
  // Check if user has profile image
  bool get hasProfileImage => profileImageUrl != null && profileImageUrl!.isNotEmpty;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profileImageUrl == profileImageUrl &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.preferences == preferences;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      profileImageUrl,
      createdAt,
      lastLoginAt,
      preferences,
    );
  }
  
  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

// User preferences model
class UserPreferences {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String language; // App interface language
  final String targetLanguage; // Learning language (e.g., 'english')
  final int dailyGoalMinutes;
  final bool darkModeEnabled;
  final double audioVolume;
  
  const UserPreferences({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.language = 'en',
    this.targetLanguage = 'english',
    this.dailyGoalMinutes = 15,
    this.darkModeEnabled = false,
    this.audioVolume = 1.0,
  });
  
  // Create copy with modified fields
  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? language,
    String? targetLanguage,
    int? dailyGoalMinutes,
    bool? darkModeEnabled,
    double? audioVolume,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      language: language ?? this.language,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      audioVolume: audioVolume ?? this.audioVolume,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'language': language,
      'targetLanguage': targetLanguage,
      'dailyGoalMinutes': dailyGoalMinutes,
      'darkModeEnabled': darkModeEnabled,
      'audioVolume': audioVolume,
    };
  }
  
  // Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      language: json['language'] as String? ?? 'en',
      targetLanguage: json['targetLanguage'] as String? ?? 'english',
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 15,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      audioVolume: (json['audioVolume'] as num?)?.toDouble() ?? 1.0,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserPreferences &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.language == language &&
        other.targetLanguage == targetLanguage &&
        other.dailyGoalMinutes == dailyGoalMinutes &&
        other.darkModeEnabled == darkModeEnabled &&
        other.audioVolume == audioVolume;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      notificationsEnabled,
      soundEnabled,
      language,
      targetLanguage,
      dailyGoalMinutes,
      darkModeEnabled,
      audioVolume,
    );
  }
  
  @override
  String toString() {
    return 'UserPreferences(notifications: $notificationsEnabled, sound: $soundEnabled, language: $language, target: $targetLanguage, dailyGoal: $dailyGoalMinutes min)';
  }
}