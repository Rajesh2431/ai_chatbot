import 'package:flutter/material.dart';
import '../models/message.dart';
import 'content_service.dart';

class ActionDetectorService {
  /// Detect if AI response suggests actions and return appropriate action buttons
  static List<MessageAction>? detectActions(String aiResponse) {
    String lowerResponse = aiResponse.toLowerCase();
    List<MessageAction> actions = [];

    // Debug: Print the response to see what we're working with
    print('🔍 Analyzing AI response: $lowerResponse');

    // Only detect when AI specifically suggests breathing exercises
    if (_suggestsBreathingExercise(lowerResponse)) {
      print('✅ Detected breathing suggestion');
      actions.add(MessageAction(
        label: 'Try Breathing Exercise',
        route: '/breathing',
        icon: Icons.air,
      ));
    }

    // Only detect when AI specifically suggests journaling
    if (_suggestsJournaling(lowerResponse)) {
      print('✅ Detected journaling suggestion');
      actions.add(MessageAction(
        label: 'Open Journal',
        route: '/journal',
        icon: Icons.book,
      ));
    }

    // Only detect when AI specifically suggests relaxation activities
    if (_suggestsRelaxationActivity(lowerResponse)) {
      print('✅ Detected relaxation suggestion');
      actions.add(MessageAction(
        label: 'Play Calm Game',
        route: '/calm-game',
        icon: Icons.games,
      ));
    }

    // Only detect when AI specifically suggests mood tracking
    if (_suggestsMoodTracking(lowerResponse)) {
      print('✅ Detected mood tracking suggestion');
      actions.add(MessageAction(
        label: 'Track Mood',
        route: '/journal',
        icon: Icons.mood,
      ));
    }

    // Detect video suggestions
    if (_suggestsVideo(lowerResponse)) {
      print('✅ Detected video suggestion');
      final video = ContentService.getRandomVideo();
      actions.add(MessageAction(
        label: 'Watch Video',
        route: '/video',
        icon: Icons.play_circle,
        data: video, // Store video data
      ));
    }

    // Detect LMS/learning suggestions
    if (_suggestsLearning(lowerResponse)) {
      print('✅ Detected learning suggestion');
      actions.add(MessageAction(
        label: 'Learn More',
        route: '/lms',
        icon: Icons.school,
      ));
    }

    // Remove the automatic contextual suggestions - only suggest when AI specifically mentions the activity

    // Add a test button for debugging
    if (lowerResponse.contains('test') || lowerResponse.contains('button')) {
      print('✅ Adding test button');
      actions.add(MessageAction(
        label: 'Test Button',
        route: '/breathing',
        icon: Icons.bug_report,
      ));
    }

    print('🎯 Total actions detected: ${actions.length}');
    return actions.isEmpty ? null : actions;
  }

  /// Detect emotional context that might benefit from multiple activities
  static bool _containsEmotionalContext(String text) {
    List<String> emotionalKeywords = [
      'anxious', 'worried', 'stressed', 'overwhelmed', 'sad', 'depressed',
      'frustrated', 'angry', 'confused', 'lost', 'tired', 'exhausted',
      'emotional', 'feelings', 'difficult', 'hard time', 'struggling',
      'upset', 'bothered', 'troubled', 'concerned', 'nervous', 'tense',
    ];
    return emotionalKeywords.any((keyword) => text.contains(keyword));
  }

  /// Detect specific breathing exercise suggestions
  static bool _suggestsBreathingExercise(String text) {
    List<String> actionPhrases = [
      'try breathing',
      'breathing exercise',
      'breathing technique',
      'breathing can help',
      'try some breathing',
      'practice breathing',
      'focus on your breathing',
      'take deep breaths',
      'breathe slowly',
      'try the breathing',
      'breathing method',
      'do some breathing',
    ];
    print('🫁 Checking breathing phrases in: $text');
    bool found = actionPhrases.any((phrase) => text.contains(phrase));
    print('🫁 Breathing detection result: $found');
    return found;
  }

  /// Detect specific journaling suggestions
  static bool _suggestsJournaling(String text) {
    List<String> actionPhrases = [
      'try journaling',
      'write down your',
      'writing can help',
      'try writing',
      'journal about',
      'consider journaling',
      'write about',
      'express your thoughts',
      'writing might help',
      'capture your thoughts',
      'put your thoughts',
      'record your feelings',
      'write your feelings',
    ];
    print('📝 Checking journaling phrases in: $text');
    bool found = actionPhrases.any((phrase) => text.contains(phrase));
    print('📝 Journaling detection result: $found');
    return found;
  }

  /// Detect specific relaxation activity suggestions
  static bool _suggestsRelaxationActivity(String text) {
    List<String> actionPhrases = [
      'try a calming game',
      'play a game',
      'calming game',
      'peaceful activity',
      'try something peaceful',
      'calming activity',
      'relaxing activity',
      'soothing activity',
      'try an activity',
      'distract yourself',
      'take your mind off',
      'find a distraction',
      'mental break',
    ];
    print('🎮 Checking relaxation phrases in: $text');
    bool found = actionPhrases.any((phrase) => text.contains(phrase));
    print('🎮 Relaxation detection result: $found');
    return found;
  }

  /// Detect specific mood tracking suggestions
  static bool _suggestsMoodTracking(String text) {
    List<String> actionPhrases = [
      'track your mood',
      'monitor your mood',
      'check in with yourself',
      'track how you feel',
      'mood tracking',
      'record your mood',
      'daily check-in',
      'note your feelings',
      'log your emotions',
      'keep track of',
    ];
    print('😊 Checking mood tracking phrases in: $text');
    bool found = actionPhrases.any((phrase) => text.contains(phrase));
    print('😊 Mood tracking detection result: $found');
    return found;
  }

  /// Detect video suggestions
  static bool _suggestsVideo(String text) {
    List<String> actionPhrases = [
      'watch video',
      'helpful video',
      'video for you',
      'check out this video',
      'watch this',
      'video tutorial',
      'guided video',
      'video resource',
    ];
    print('📺 Checking video phrases in: $text');
    bool found = actionPhrases.any((phrase) => text.contains(phrase));
    print('📺 Video detection result: $found');
    return found;
  }

  /// Detect learning/LMS suggestions
  static bool _suggestsLearning(String text) {
    List<String> actionPhrases = [
      'learn more',
      'explore our',
      'learning center',
      'comprehensive resources',
      'educational content',
      'study materials',
      'course materials',
      'learning resources',
    ];
    print('📚 Checking learning phrases in: $text');
    bool found = actionPhrases.any((phrase) => text.contains(phrase));
    print('📚 Learning detection result: $found');
    return found;
  }
}