import 'content_service.dart';
import 'api_service.dart';

/// Example integration showing how to use enhanced ContentService with AI
class ContentIntegrationExample {
  /// Enhanced AI response that includes intelligent video suggestions
  static Future<Map<String, dynamic>> getEnhancedAIResponse(
    String userMessage,
  ) async {
    try {
      // 1. Get regular AI response
      final aiResponse = await OpenRouterAPI.getResponse(userMessage);

      // 2. Analyze user message for video suggestions
      final suggestedVideo = ContentService.analyzeMessageAndSuggestVideo(
        userMessage,
      );
      final emotions = ContentService.analyzeMessageSentiment(userMessage);

      // 3. Create enhanced response
      String enhancedResponse = aiResponse;

      // 4. Add intelligent video suggestion if relevant
      if (suggestedVideo != null) {
        enhancedResponse +=
            '\n\n${ContentService.getIntelligentVideoSuggestion(userMessage)}';
      }

      return {
        'success': true,
        'response': enhancedResponse,
        'suggestedVideo': suggestedVideo,
        'detectedEmotions': emotions,
        'hasVideoSuggestion': suggestedVideo != null,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'response':
            'I apologize, but I encountered an error. Please try again.',
      };
    }
  }

  /// Process user message and return contextual response with video
  static Map<String, dynamic> processUserMessage(String userMessage) {
    // Analyze the message
    final suggestedVideo = ContentService.analyzeMessageAndSuggestVideo(
      userMessage,
    );
    final emotions = ContentService.analyzeMessageSentiment(userMessage);
    final contextualResponse = ContentService.getContextualResponse(
      userMessage,
    );

    return {
      'contextualResponse': contextualResponse,
      'suggestedVideo': suggestedVideo,
      'detectedEmotions': emotions,
      'analysisComplete': true,
    };
  }

  /// Example usage in chat screen
  static void exampleUsage() {
    // Example user messages and expected behavior:

    print('=== Example 1: Anxiety Message ===');
    final anxietyMessage = "I'm feeling really anxious and stressed about work";
    final result1 = processUserMessage(anxietyMessage);
    print('User: $anxietyMessage');
    print('AI: ${result1['contextualResponse']}');
    print('Suggested Video: ${result1['suggestedVideo']?['title'] ?? 'None'}');
    print('Emotions: ${result1['detectedEmotions']}');

    print('\n=== Example 2: Loneliness Message ===');
    final lonelinessMessage =
        "I feel so lonely on this ship, missing my family";
    final result2 = processUserMessage(lonelinessMessage);
    print('User: $lonelinessMessage');
    print('AI: ${result2['contextualResponse']}');
    print('Suggested Video: ${result2['suggestedVideo']?['title'] ?? 'None'}');
    print('Emotions: ${result2['detectedEmotions']}');

    print('\n=== Example 3: General Message ===');
    final generalMessage = "How are you today?";
    final result3 = processUserMessage(generalMessage);
    print('User: $generalMessage');
    print('AI: ${result3['contextualResponse']}');
    print('Suggested Video: ${result3['suggestedVideo']?['title'] ?? 'None'}');
    print('Emotions: ${result3['detectedEmotions']}');
  }
}

/// Widget integration example for chat screen
class ChatMessageWithVideo {
  final String message;
  final Map<String, String>? suggestedVideo;
  final List<String> detectedEmotions;
  final bool isFromUser;

  ChatMessageWithVideo({
    required this.message,
    this.suggestedVideo,
    this.detectedEmotions = const [],
    required this.isFromUser,
  });

  /// Create AI response with video suggestion
  factory ChatMessageWithVideo.createAIResponse(String userMessage) {
    final analysis = ContentIntegrationExample.processUserMessage(userMessage);

    return ChatMessageWithVideo(
      message: analysis['contextualResponse'],
      suggestedVideo: analysis['suggestedVideo'],
      detectedEmotions: List<String>.from(analysis['detectedEmotions']),
      isFromUser: false,
    );
  }

  /// Check if this message has a video suggestion
  bool get hasVideoSuggestion => suggestedVideo != null;

  /// Get video title for display
  String get videoTitle => suggestedVideo?['title'] ?? '';

  /// Get video description for display
  String get videoDescription => suggestedVideo?['description'] ?? '';

  /// Launch the suggested video
  Future<void> launchSuggestedVideo() async {
    if (suggestedVideo != null) {
      await ContentService.launchVideo(suggestedVideo!['url']!);
    }
  }
}
