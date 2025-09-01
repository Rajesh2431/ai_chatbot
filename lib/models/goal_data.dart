class GoalData {
  final String goal;
  final String type;
  final String notes;
  final DateTime createdAt;
  final double progress;

  GoalData({
    required this.goal,
    required this.type,
    required this.notes,
    required this.createdAt,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'type': type,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'progress': progress,
    };
  }

  factory GoalData.fromJson(Map<String, dynamic> json) {
    return GoalData(
      goal: json['goal'] ?? '',
      type: json['type'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      progress: (json['progress'] ?? 0.0).toDouble(),
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

  @override
  String toString() {
    return 'GoalData(goal: $goal, type: $type, notes: $notes, createdAt: $createdAt, progress: $progress)';
  }
}