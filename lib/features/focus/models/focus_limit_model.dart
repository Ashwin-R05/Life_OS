class FocusLimitModel {
  final String category; // 'Social' | 'Entertainment' | 'Gaming' | 'Distraction'
  final int limitMinutes;
  final bool isActive;

  FocusLimitModel({
    required this.category,
    required this.limitMinutes,
    this.isActive = true,
  });

  FocusLimitModel copyWith({
    String? category,
    int? limitMinutes,
    bool? isActive,
  }) {
    return FocusLimitModel(
      category: category ?? this.category,
      limitMinutes: limitMinutes ?? this.limitMinutes,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'limitMinutes': limitMinutes,
      'isActive': isActive,
    };
  }

  factory FocusLimitModel.fromJson(Map<String, dynamic> json) {
    return FocusLimitModel(
      category: json['category'] as String,
      limitMinutes: json['limitMinutes'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
