class SoarCardAnswer {
  final String questionId;
  final String questionText;
  final String answer;
  final DateTime createdAt;

  SoarCardAnswer({
    required this.questionId,
    required this.questionText,
    required this.answer,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SoarCardAnswer.fromJson(Map<String, dynamic> json) {
    return SoarCardAnswer(
      questionId: json['questionId'] ?? '',
      questionText: json['questionText'] ?? '',
      answer: json['answer'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'SoarCardAnswer(questionId: $questionId, questionText: $questionText, answer: $answer, createdAt: $createdAt)';
  }
}