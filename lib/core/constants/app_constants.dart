class AppConstants {
  // Storage Keys
  static const String keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyUserGoals = 'user_goals';
  static const String keyUserModules = 'user_modules';
  static const String keyUserTheme = 'user_theme';

  // Role Choices
  static const List<String> roles = [
    'Student',
    'Developer',
    'Both',
  ];

  // Goal Choices
  static const List<Map<String, String>> goals = [
    {
      'id': 'study',
      'title': 'Study Better',
      'subtitle': 'Boost cognitive performance & retain info',
      'icon': '🎓',
    },
    {
      'id': 'social',
      'title': 'Reduce Social Media',
      'subtitle': 'Minimize screen time & distractions',
      'icon': '📱',
    },
    {
      'id': 'consistency',
      'title': 'Build Consistency',
      'subtitle': 'Form long-term productive routines',
      'icon': '⚡',
    },
    {
      'id': 'projects',
      'title': 'Organize Projects',
      'subtitle': 'Manage code repositories and docs',
      'icon': '📂',
    },
    {
      'id': 'coding',
      'title': 'Improve Coding',
      'subtitle': 'Track coding targets & write daily',
      'icon': '💻',
    },
  ];

  // Module Choices
  static const List<Map<String, String>> modules = [
    {
      'id': 'notes',
      'title': 'Notes',
      'subtitle': 'Futuristic markdown editor & link graphs',
      'icon': '📝',
    },
    {
      'id': 'tasks',
      'title': 'Tasks',
      'subtitle': 'Kanban, lists & calendar visual boards',
      'icon': '✔️',
    },
    {
      'id': 'habits',
      'title': 'Habits',
      'subtitle': 'Atomic habit tracker & daily streak maps',
      'icon': '🔄',
    },
    {
      'id': 'screentime',
      'title': 'Screen Time',
      'subtitle': 'Android Usage stats blocker & widget overlays',
      'icon': '⏱️',
    },
  ];
}
