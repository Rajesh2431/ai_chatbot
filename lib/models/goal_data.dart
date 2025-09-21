enum GoalPeriod { midterm, longterm }

class GoalData {
  final String id;
  final String goal;
  final String category;
  final String notes;
  final GoalPeriod period;
  final DateTime createdAt;
  final DateTime? targetDate;
  final double progress;
  final bool isRecommended;
  final String? recommendationReason;

  GoalData({
    required this.id,
    required this.goal,
    required this.category,
    required this.notes,
    required this.period,
    required this.createdAt,
    this.targetDate,
    this.progress = 0.0,
    this.isRecommended = false,
    this.recommendationReason, required String type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal': goal,
      'category': category,
      'notes': notes,
      'period': period.name,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'progress': progress,
      'isRecommended': isRecommended,
      'recommendationReason': recommendationReason,
    };
  }

  factory GoalData.fromJson(Map<String, dynamic> json) {
    return GoalData(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      goal: json['goal'] ?? '',
      category: json['category'] ?? '',
      notes: json['notes'] ?? '',
      period: json['period'] == 'longterm' ? GoalPeriod.longterm : GoalPeriod.midterm,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      progress: (json['progress'] ?? 0.0).toDouble(),
      isRecommended: json['isRecommended'] ?? false,
      recommendationReason: json['recommendationReason'], type: '',
    );
  }

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }

  String get periodDisplayName {
    switch (period) {
      case GoalPeriod.midterm:
        return 'Mid-term (3-12 months)';
      case GoalPeriod.longterm:
        return 'Long-term (1+ years)';
    }
  }

  String get periodShortName {
    switch (period) {
      case GoalPeriod.midterm:
        return 'Mid-term';
      case GoalPeriod.longterm:
        return 'Long-term';
    }
  }

  String get type => '';

  @override
  String toString() {
    return 'GoalData(id: $id, goal: $goal, category: $category, notes: $notes, period: $period, createdAt: $createdAt, progress: $progress)';
  }
}