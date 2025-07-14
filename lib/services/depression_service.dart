import '../models/question.dart';
import 'dart:math';

class DepressionService {
  static final List<Question> questions = [
    Question(
      text: "Little interest or pleasure in doing things?",
      options: [
        "Not at all",
        "Several days",
        "More than half the days",
        "Nearly every day",
      ],
      scores: [0, 1, 2, 3],
    ),
    Question(
      text: "Feeling down, depressed, or hopeless?",
      options: [
        "Not at all",
        "Several days",
        "More than half the days",
        "Nearly every day",
      ],
      scores: [0, 1, 2, 3],
    ),
    Question(
      text: "Trouble falling or staying asleep, or sleeping too much?",
      options: [
        "Not at all",
        "Several days",
        "More than half the days",
        "Nearly every day",
      ],
      scores: [0, 1, 2, 3],
    ),
    Question(
      text: "Feeling tired or having little energy?",
      options: [
        "Not at all",
        "Several days",
        "More than half the days",
        "Nearly every day",
      ],
      scores: [0, 1, 2, 3],
    ),
    Question(
      text: "Poor appetite or overeating?",
      options: [
        "Not at all",
        "Several days",
        "More than half the days",
        "Nearly every day",
      ],
      scores: [0, 1, 2, 3],
    ),
    // Question(
    //   text:
    //       "Feeling bad about yourself — or that you are a failure or have let yourself or your family down?",
    //   options: [
    //     "Not at all",
    //     "Several days",
    //     "More than half the days",
    //     "Nearly every day",
    //   ],
    //   scores: [0, 1, 2, 3],
    // ),
    // Question(
    //   text:
    //       "Trouble concentrating on things, such as reading the newspaper or watching television?",
    //   options: [
    //     "Not at all",
    //     "Several days",
    //     "More than half the days",
    //     "Nearly every day",
    //   ],
    //   scores: [0, 1, 2, 3],
    // ),
    // Question(
    //   text:
    //       "Have you been moving or talking so slowly that others might notice? Or the opposite — feeling so restless or fidgety that you move around much more than usual?",
    //   options: [
    //     "Not at all",
    //     "Several days",
    //     "More than half the days",
    //     "Nearly every day",
    //   ],
    //   scores: [0, 1, 2, 3],
    // ),
    // Question(
    //   text:
    //       "Thoughts that you would be better off dead or of hurting yourself in some way?",
    //   options: [
    //     "Not at all",
    //     "Several days",
    //     "More than half the days",
    //     "Nearly every day",
    //   ],
    //   scores: [0, 1, 2, 3],
    // ),
  ];

  static String getRecommendedActivities(String level) {
    switch (level.toLowerCase()) {
      case 'minimal depression':
        return 'Great! Try: \n• Breathing & Focus Games\n• Nature Exploration Quests';
      case 'mild depression':
        return 'Helpful activities: \n• Art Therapy Simulations\n• Guided Visualization Quests';
      case 'moderate depression':
        return 'Try:\n• Puzzle & Pattern Recognition Games\n• CBT-Based Mini-Games';
      case 'moderately severe depression':
        return 'Suggested:\n• Mindfulness Tap Games\n• Emotion Matching Activities';
      case 'severe depression':
        return 'Strongly recommended:\n• Journaling with Game Mechanics\n• Sound & Rhythm Interaction Games';
      default:
        return 'Try any activity that makes you feel safe and supported.';
    }
  }

  static final List<String> welcomeMessages = [
    "Welcome! Let's talk about your mental health.",
    "Hey there. I'm here to support you.",
    "Hello. Ready when you are to check in.",
    "Hi! Let’s walk through a few quick questions.",
    "You're not alone. Let's begin with a few thoughts.",
  ];

  static String getRandomWelcomeMessage() {
    final rand = Random();
    return welcomeMessages[rand.nextInt(welcomeMessages.length)];
  }

  static String getResultMessage(int score) {
    if (score <= 4) return "minimal depression";
    if (score <= 9) return "mild depression";
    if (score <= 14) return "moderate depression";
    if (score <= 19) return "moderately severe depression";
    return "severe depression";
  }
}
