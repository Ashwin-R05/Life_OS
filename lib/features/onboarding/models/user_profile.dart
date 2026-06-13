class UserProfile {
  final String name;
  final String role;
  final List<String> goals;
  final List<String> modules;
  final String appearance; // 'Dark', 'Light', 'System'
  final bool notificationsPermissionGranted;
  final bool usageAccessPermissionGranted;

  UserProfile({
    required this.name,
    required this.role,
    required this.goals,
    required this.modules,
    required this.appearance,
    required this.notificationsPermissionGranted,
    required this.usageAccessPermissionGranted,
  });

  factory UserProfile.empty() {
    return UserProfile(
      name: '',
      role: '',
      goals: [],
      modules: [],
      appearance: 'System',
      notificationsPermissionGranted: false,
      usageAccessPermissionGranted: false,
    );
  }

  UserProfile copyWith({
    String? name,
    String? role,
    List<String>? goals,
    List<String>? modules,
    String? appearance,
    bool? notificationsPermissionGranted,
    bool? usageAccessPermissionGranted,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      goals: goals ?? this.goals,
      modules: modules ?? this.modules,
      appearance: appearance ?? this.appearance,
      notificationsPermissionGranted:
          notificationsPermissionGranted ?? this.notificationsPermissionGranted,
      usageAccessPermissionGranted:
          usageAccessPermissionGranted ?? this.usageAccessPermissionGranted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'goals': goals,
      'modules': modules,
      'appearance': appearance,
      'notificationsPermissionGranted': notificationsPermissionGranted,
      'usageAccessPermissionGranted': usageAccessPermissionGranted,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      goals: List<String>.from(json['goals'] ?? []),
      modules: List<String>.from(json['modules'] ?? []),
      appearance: json['appearance'] ?? 'System',
      notificationsPermissionGranted:
          json['notificationsPermissionGranted'] ?? false,
      usageAccessPermissionGranted: json['usageAccessPermissionGranted'] ?? false,
    );
  }
}
