import 'mood_service.dart';

class MoodBasedChatService {
  /// Get mood-based context for AI responses
  static Future<String> getMoodBasedContext() async {
    final todaysMood = await MoodService.getTodaysMoodScore();
    final moodTrend = await MoodService.getMoodTrend();
    final moodLevel = await MoodService.getCurrentMoodLevel();
    final moodHistory = await MoodService.getMoodHistory();
    
    // Get today's detailed mood data
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todaysData = moodHistory[today] as Map<String, dynamic>?;
    
    String moodContext = _generateMoodContext(todaysMood, moodLevel, moodTrend);
    String conversationStyle = _getConversationStyle(todaysMood, moodLevel);
    String supportStrategy = _getSupportStrategy(todaysMood, moodTrend);
    String questionSuggestions = _getQuestionSuggestions(todaysMood, moodLevel);
    
    // Add specific mood details if available
    String detailedMoodInfo = '';
    if (todaysData != null && todaysData['questions'] != null) {
      detailedMoodInfo = _getDetailedMoodInfo(todaysData['questions']);
    }
    
    return '''
MOOD-BASED CONVERSATION CONTEXT:

USER'S CURRENT MOOD STATE:
- Overall Mood Score: ${todaysMood.toStringAsFixed(1)}/4.0
- Mood Level: ${_getMoodLevelDescription(moodLevel)}
- Mood Trend: $moodTrend
- Needs Support Level: ${_getSupportLevel(todaysMood)}

$detailedMoodInfo

CONVERSATION APPROACH:
$moodContext

CONVERSATION STYLE:
$conversationStyle

SUPPORT STRATEGY:
$supportStrategy

SUGGESTED QUESTIONS TO ASK:
$questionSuggestions

IMPORTANT INSTRUCTIONS:
- Tailor your responses to the user's current mood state
- Be more supportive and gentle if mood is low
- Celebrate and encourage if mood is high
- Ask follow-up questions based on their mood level
- Reference their mood appropriately in conversation
- Keep responses brief (1-2 sentences) but emotionally appropriate
''';
  }

  static String _generateMoodContext(double moodScore, int moodLevel, String trend) {
    if (moodScore >= 4.0) {
      return "User is in an excellent/great mood state. They're feeling very positive today and may be open to growth-oriented conversations, goal-setting, or sharing positive experiences.";
    } else if (moodScore >= 3.0) {
      return "User is in a good/neutral mood state. They may need gentle encouragement and balanced support. Avoid being overly cheerful but remain optimistic.";
    } else {
      return "User is struggling today and needs extra compassion and support. Be gentle, validating, and focus on immediate comfort and coping strategies.";
    }
  }

  static String _getConversationStyle(double moodScore, int moodLevel) {
    if (moodScore >= 4.0) {
      return "- Use upbeat, encouraging language\n- Ask about positive experiences and goals\n- Suggest growth activities\n- Celebrate their excellent mood";
    } else if (moodScore >= 3.0) {
      return "- Use balanced, supportive language\n- Acknowledge their mixed feelings\n- Offer gentle encouragement\n- Focus on stability and small wins";
    } else {
      return "- Use extra gentle, compassionate language\n- Validate their difficult feelings\n- Focus on immediate comfort and support\n- Avoid overwhelming suggestions";
    }
  }

  static String _getSupportStrategy(double moodScore, String trend) {
    String baseStrategy = '';
    
    if (moodScore >= 4.0) {
      baseStrategy = "Encourage continued positive practices, explore what's working well, suggest ways to maintain excellent mood.";
    } else if (moodScore >= 3.0) {
      baseStrategy = "Provide balanced support, help identify what might improve their day, offer gentle coping strategies.";
    } else {
      baseStrategy = "Prioritize emotional validation, offer immediate comfort, suggest simple self-care activities.";
    }

    // Add trend-based adjustments
    if (trend == 'improving') {
      baseStrategy += " Acknowledge their progress and encourage continued improvement.";
    } else if (trend == 'declining') {
      baseStrategy += " Show extra concern and offer additional support resources.";
    }

    return baseStrategy;
  }

  static String _getQuestionSuggestions(double moodScore, int moodLevel) {
    if (moodScore >= 4.0) {
      return '''- "What's been the highlight of your day so far?"
- "What's contributing to your excellent mood today?"
- "Is there something you're looking forward to?"
- "What activities make you feel this amazing?"''';
    } else if (moodScore >= 3.0) {
      return '''- "What's one small thing that could make your day a bit better?"
- "How are you taking care of yourself today?"
- "What's been on your mind lately?"
- "Is there anything specific you'd like support with?"''';
    } else {
      return '''- "What's been the most challenging part of your day?"
- "How can I best support you right now?"
- "What usually helps when you're feeling this way?"
- "Would you like to talk about what's bothering you?"''';
    }
  }

  static String _getDetailedMoodInfo(Map<String, dynamic> questions) {
    StringBuffer details = StringBuffer();
    details.writeln('TODAY\'S CHECK-IN DETAILS:');
    
    questions.forEach((question, score) {
      String interpretation = _interpretQuestionScore(question, score as int);
      details.writeln('- $question: ${_getScoreDescription(score)} ($interpretation)');
    });
    
    return details.toString();
  }

  static String _interpretQuestionScore(String question, int score) {
    if (question.toLowerCase().contains('feeling')) {
      if (score == 5) return 'feeling excellent';
      if (score == 4) return 'feeling great';
      if (score == 3) return 'feeling good';
      if (score == 2) return 'feeling okay';
      return 'struggling today';
    } else if (question.toLowerCase().contains('sleep')) {
      if (score == 5) return 'excellent sleep';
      if (score == 4) return 'well-rested';
      if (score == 3) return 'decent sleep';
      if (score == 2) return 'average sleep';
      return 'sleep issues';
    } else if (question.toLowerCase().contains('energy')) {
      if (score == 5) return 'very high energy';
      if (score == 4) return 'high energy';
      if (score == 3) return 'good energy';
      if (score == 2) return 'moderate energy';
      return 'low energy';
    } else if (question.toLowerCase().contains('stress')) {
      if (score == 5) return 'completely calm';
      if (score == 4) return 'very calm';
      if (score == 3) return 'mostly calm';
      if (score == 2) return 'some stress';
      return 'very stressed';
    } else if (question.toLowerCase().contains('optimistic')) {
      if (score == 5) return 'extremely optimistic';
      if (score == 4) return 'very optimistic';
      if (score == 3) return 'positive outlook';
      if (score == 2) return 'neutral outlook';
      return 'pessimistic';
    }
    return 'needs attention';
  }

  static String _getScoreDescription(int score) {
    switch (score) {
      case 5: return 'Excellent';
      case 4: return 'Great';
      case 3: return 'Good';
      case 2: return 'Fair';
      case 1: return 'Poor';
      default: return 'Unknown';
    }
  }

  static String _getMoodLevelDescription(int level) {
    switch (level) {
      case 6: return 'Excellent';
      case 5: return 'Very Good';
      case 4: return 'Good';
      case 3: return 'Okay';
      case 2: return 'Not Great';
      case 1: return 'Poor';
      default: return 'Unknown';
    }
  }

  static String _getSupportLevel(double moodScore) {
    if (moodScore >= 4.0) return 'Low - Encouragement focused';
    if (moodScore >= 3.0) return 'Moderate - Balanced support';
    return 'High - Extra compassion needed';
  }

  /// Get mood-appropriate greeting
  static Future<String> getMoodBasedGreeting() async {
    final moodScore = await MoodService.getTodaysMoodScore();
    final moodLevel = await MoodService.getCurrentMoodLevel();
    
    if (moodScore >= 4.0) {
      return "I can see you're having an excellent day! I'm here to chat and support you. 😊";
    } else if (moodScore >= 3.0) {
      return "I'm here to listen and support you through whatever you're feeling today. 🤗";
    } else {
      return "I can sense today might be challenging for you. I'm here to provide gentle support. 💙";
    }
  }

  /// Check if user completed daily check-in
  static Future<bool> hasCompletedDailyCheckin() async {
    return !(await MoodService.needsDailyCheckin());
  }

  /// Get mood-based activity suggestions
  static Future<List<String>> getMoodBasedSuggestions() async {
    final moodScore = await MoodService.getTodaysMoodScore();
    
    if (moodScore >= 4.0) {
      return [
        "Since you're feeling excellent, maybe try a creative activity or set a new goal!",
        "Your positive energy could be perfect for connecting with friends or family.",
        "Consider journaling about what's making you feel so amazing today.",
      ];
    } else if (moodScore >= 3.0) {
      return [
        "A gentle breathing exercise might help center your thoughts.",
        "Writing in your journal could help process your feelings.",
        "A calming activity might bring some peace to your day.",
      ];
    } else {
      return [
        "Let's try some breathing exercises to help you feel more grounded.",
        "Writing down your thoughts might help you process difficult feelings.",
        "A peaceful, calming activity could provide some comfort right now.",
      ];
    }
  }
}