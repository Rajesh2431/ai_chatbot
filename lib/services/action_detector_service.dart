import 'package:flutter/material.dart';
import '../models/message.dart';

class ActionDetectorService {
  /// Detect if AI response suggests actions and return appropriate action buttons
  static List<MessageAction>? detectActions(String aiResponse) {
    String lowerResponse = aiResponse.toLowerCase();
    List<MessageAction> actions = [];

    // Only detect when AI specifically suggests breathing exercises
    if (_suggestsBreathingExercise(lowerResponse)) {
      actions.add(MessageAction(
        label: 'Try Breathing Exercise',
        route: '/breathing',
        icon: Icons.air,
      ));
    }

    // Only detect when AI specifically suggests journaling
    if (_suggestsJournaling(lowerResponse)) {
      actions.add(MessageAction(
        label: 'Open Journal',
        route: '/journal',
        icon: Icons.book,
      ));
    }

    // Only detect when AI specifically suggests relaxation activities
    if (_suggestsRelaxationActivity(lowerResponse)) {
      actions.add(MessageAction(
        label: 'Play Calm Game',
        route: '/calm-game',
        icon: Icons.games,
      ));
    }

    // Only detect when AI specifically suggests mood tracking
    if (_suggestsMoodTracking(lowerResponse)) {
      actions.add(MessageAction(
        label: 'Track Mood',
        route: '/journal',
        icon: Icons.mood,
      ));
    }

    return actions.isEmpty ? null : actions;
  }

  /// Detect specific breathing exercise suggestions
  static bool _suggestsBreathingExercise(String text) {
    List<String> actionPhrases = [
      'try breathing',
      'breathing exercise',
      'breathing technique',
      'deep breath',
      'inhale for',
      'exhale for',
      'breath in',
      'breath out',
      'breathing pattern',
      'try the breathing',
      'practice breathing',
      'do some breathing',
      'breathing method'
    ];
    return actionPhrases.any((phrase) => text.contains(phrase));
  }

  /// Detect specific journaling suggestions
  static bool _suggestsJournaling(String text) {
    List<String> actionPhrases = [
      'try journaling',
      'write in a journal',
      'keep a journal',
      'start journaling',
      'write down your',
      'try writing',
      'journal about',
      'writing can help',
      'put your thoughts',
      'write your feelings',
      'journal your',
      'try keeping a diary'
    ];
    return actionPhrases.any((phrase) => text.contains(phrase));
  }

  /// Detect specific relaxation activity suggestions
  static bool _suggestsRelaxationActivity(String text) {
    List<String> actionPhrases = [
      'try a game',
      'play a game',
      'calming game',
      'relaxing activity',
      'try an activity',
      'do something calming',
      'engage in',
      'try something peaceful',
      'calming exercise',
      'relaxation activity'
    ];
    return actionPhrases.any((phrase) => text.contains(phrase));
  }

  /// Detect specific mood tracking suggestions
  static bool _suggestsMoodTracking(String text) {
    List<String> actionPhrases = [
      'track your mood',
      'monitor your mood',
      'record your feelings',
      'keep track of',
      'log your emotions',
      'track how you feel',
      'mood tracking',
      'check in with yourself',
      'record your mood',
      'note your feelings'
    ];
    return actionPhrases.any((phrase) => text.contains(phrase));
  }
}