// lib/models/settings_model.dart - Add copyWith method
class AppSettings {
  bool notificationsEnabled;
  bool emailNotifications;
  bool darkMode;
  bool autoPlayVideos;
  bool downloadOverWifiOnly;
  String studyReminderTime;
  int dailyGoalMinutes;
  String difficultyPreference;
  String contentLanguage;
  List<String> preferredCategories;
  Map<String, bool> accessibilityOptions;

  AppSettings({
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.darkMode = false,
    this.autoPlayVideos = true,
    this.downloadOverWifiOnly = true,
    this.studyReminderTime = '18:00',
    this.dailyGoalMinutes = 60,
    this.difficultyPreference = 'intermediate',
    this.contentLanguage = 'en',
    this.preferredCategories = const [],
    this.accessibilityOptions = const {
      'highContrast': false,
      'textToSpeech': false,
      'reducedMotion': false,
    },
  });

  // ADD THIS copyWith METHOD
  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? darkMode,
    bool? autoPlayVideos,
    bool? downloadOverWifiOnly,
    String? studyReminderTime,
    int? dailyGoalMinutes,
    String? difficultyPreference,
    String? contentLanguage,
    List<String>? preferredCategories,
    Map<String, bool>? accessibilityOptions,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      darkMode: darkMode ?? this.darkMode,
      autoPlayVideos: autoPlayVideos ?? this.autoPlayVideos,
      downloadOverWifiOnly: downloadOverWifiOnly ?? this.downloadOverWifiOnly,
      studyReminderTime: studyReminderTime ?? this.studyReminderTime,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      difficultyPreference: difficultyPreference ?? this.difficultyPreference,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      accessibilityOptions: accessibilityOptions ?? this.accessibilityOptions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'darkMode': darkMode,
      'autoPlayVideos': autoPlayVideos,
      'downloadOverWifiOnly': downloadOverWifiOnly,
      'studyReminderTime': studyReminderTime,
      'dailyGoalMinutes': dailyGoalMinutes,
      'difficultyPreference': difficultyPreference,
      'contentLanguage': contentLanguage,
      'preferredCategories': preferredCategories,
      'accessibilityOptions': accessibilityOptions,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      emailNotifications: map['emailNotifications'] ?? true,
      darkMode: map['darkMode'] ?? false,
      autoPlayVideos: map['autoPlayVideos'] ?? true,
      downloadOverWifiOnly: map['downloadOverWifiOnly'] ?? true,
      studyReminderTime: map['studyReminderTime'] ?? '18:00',
      dailyGoalMinutes: map['dailyGoalMinutes'] ?? 60,
      difficultyPreference: map['difficultyPreference'] ?? 'intermediate',
      contentLanguage: map['contentLanguage'] ?? 'en',
      preferredCategories: List<String>.from(map['preferredCategories'] ?? []),
      accessibilityOptions: Map<String, bool>.from(map['accessibilityOptions'] ?? {}),
    );
  }
}