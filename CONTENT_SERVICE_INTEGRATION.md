# 🎥 Enhanced ContentService - AI-Powered Video Recommendations

## Overview

The enhanced `ContentService` now includes intelligent message analysis and contextual video recommendations. The AI analyzes user messages and suggests the most relevant mental health videos based on emotional content and keywords.

## 🚀 Key Features

### 1. **Intelligent Message Analysis**
- Analyzes user messages for emotional keywords
- Detects sentiment and emotional state
- Matches content to user needs

### 2. **Smart Video Recommendations**
- Suggests videos based on message content
- Scores relevance using keyword matching
- Provides contextual responses

### 3. **Emotion Detection**
- Identifies emotional categories (anxiety, sadness, anger, etc.)
- Provides empathetic responses
- Tailors suggestions to emotional state

## 📋 Available Methods

### Core Analysis Methods

```dart
// Analyze message and get best matching video
Map<String, String>? suggestedVideo = ContentService.analyzeMessageAndSuggestVideo(userMessage);

// Detect emotions in user message
List<String> emotions = ContentService.analyzeMessageSentiment(userMessage);

// Get intelligent video suggestion with context
String suggestion = ContentService.getIntelligentVideoSuggestion(userMessage);

// Get full contextual response
String response = ContentService.getContextualResponse(userMessage);
```

### Video Categories & Keywords

The system recognizes these categories and keywords:

| Category | Keywords | Example Messages |
|----------|----------|------------------|
| **Breathing** | breathing, anxiety, stress, panic, calm | "I'm feeling anxious", "Need to calm down" |
| **Loneliness** | lonely, alone, isolated, homesick | "I feel so lonely", "Missing my family" |
| **Social** | friendship, community, together, bonding | "Want to connect with others" |
| **Expression** | writing, journaling, feelings, emotions | "Can't express my feelings" |
| **Support** | help, support, reaching out | "Need someone to talk to" |
| **Culture** | culture, diversity, differences | "Cultural conflicts at work" |

## 🔧 Integration Examples

### 1. Basic Integration in Chat Screen

```dart
// In your chat message handler
void _handleUserMessage(String userMessage) {
  // Get AI analysis
  final analysis = ContentService.analyzeMessageAndSuggestVideo(userMessage);
  final emotions = ContentService.analyzeMessageSentiment(userMessage);
  final response = ContentService.getContextualResponse(userMessage);
  
  // Create AI response with video suggestion
  setState(() {
    messages.add(ChatMessage(
      text: response,
      isUser: false,
      suggestedVideo: analysis,
      detectedEmotions: emotions,
    ));
  });
}
```

### 2. Enhanced API Integration

```dart
// Modify your existing API service
static Future<Map<String, dynamic>> getEnhancedResponse(String userMessage) async {
  // Get regular AI response
  final aiResponse = await OpenRouterAPI.getResponse(userMessage);
  
  // Add intelligent video suggestion
  final videoSuggestion = ContentService.getIntelligentVideoSuggestion(userMessage);
  
  return {
    'aiResponse': aiResponse,
    'videoSuggestion': videoSuggestion,
    'hasVideo': ContentService.analyzeMessageAndSuggestVideo(userMessage) != null,
  };
}
```

### 3. Using the Video Suggestion Widget

```dart
// In your chat UI
if (message.suggestedVideo != null) {
  VideoSuggestionCard(
    video: message.suggestedVideo!,
    onTap: () async {
      await ContentService.launchVideo(message.suggestedVideo!['url']!);
    },
  )
}
```

## 📊 Message Analysis Examples

### Example 1: Anxiety Message
```dart
Input: "I'm feeling really anxious and stressed about work"

Output:
- Detected Emotions: ['anxiety']
- Suggested Video: "Breathing Exercise for Stress Relief"
- Response: "I understand you're feeling anxious or stressed. I found a video that might be particularly helpful..."
```

### Example 2: Loneliness Message
```dart
Input: "I feel so lonely on this ship, missing my family"

Output:
- Detected Emotions: ['loneliness', 'sadness']
- Suggested Video: "Coping with Loneliness at Sea"
- Response: "I can sense you're going through a difficult time. Based on what you're sharing..."
```

### Example 3: Cultural Issues
```dart
Input: "Having trouble understanding cultural differences with my crewmates"

Output:
- Detected Emotions: ['confusion']
- Suggested Video: "Understanding Cultural Differences"
- Response: "I found a video that might be particularly helpful for what you're experiencing..."
```

## 🎯 Scoring Algorithm

The system uses a sophisticated scoring algorithm:

1. **Keyword Matching** (1-2 points per match)
   - Exact word matches: 2 points
   - Partial matches: 1 point

2. **Multiple Keywords** (0.5 bonus per additional match)
   - Rewards messages with multiple relevant keywords

3. **Emotional Intensity** (0.5 bonus)
   - Detects words like "very", "really", "extremely"

4. **Minimum Threshold** (1.0 points)
   - Only suggests videos with sufficient relevance

## 🔄 Fallback Behavior

- If no video scores above threshold → Returns random video
- If message is empty → Returns null
- If analysis fails → Graceful degradation to existing functionality

## 🛠️ Customization Options

### Adding New Videos
```dart
// Add to youtubeVideos list with keywords
{
  'title': 'Your Video Title',
  'url': 'https://youtube.com/watch?v=...',
  'description': 'Video description',
}

// Add corresponding keywords to _enhancedVideoKeywords
{
  'index': 'X', // Video index
  'keywords': 'keyword1, keyword2, keyword3, ...',
}
```

### Modifying Emotion Categories
```dart
// In analyzeMessageSentiment method
final emotionMap = {
  'your_category': ['keyword1', 'keyword2', ...],
  // Add more categories as needed
};
```

## 📱 UI Components

### VideoSuggestionCard
- Beautiful gradient design
- Play button icon
- Video title and description
- Tap to launch functionality

### EnhancedMessageBubble
- Regular message display
- Integrated video suggestions
- Emotion indicators (optional)
- Seamless chat integration

## 🔍 Testing & Debugging

### Test Different Message Types
```dart
// Test various emotional states
final testMessages = [
  "I'm anxious about tomorrow",
  "Feeling lonely and homesick",
  "Stressed about work deadlines",
  "Having cultural misunderstandings",
  "Need help expressing my feelings",
];

for (String message in testMessages) {
  final result = ContentService.analyzeMessageAndSuggestVideo(message);
  print('Message: $message');
  print('Suggested: ${result?['title'] ?? 'None'}');
}
```

### Enable Emotion Indicators
```dart
// Show detected emotions in chat (for debugging)
EnhancedMessageBubble(
  message: aiResponse,
  isUser: false,
  detectedEmotions: emotions, // Shows emotion chips
)
```

## 🚀 Performance Considerations

- **Lightweight Analysis**: Fast keyword matching algorithm
- **Cached Results**: Consider caching analysis results for repeated messages
- **Async Operations**: Video launching is handled asynchronously
- **Error Handling**: Graceful fallbacks for all operations

## 🔮 Future Enhancements

1. **Machine Learning**: Train models on user interactions
2. **Personalization**: Learn user preferences over time
3. **Analytics**: Track video engagement and effectiveness
4. **Dynamic Content**: Fetch videos from CMS/API
5. **Multi-language**: Support for different languages
6. **Voice Analysis**: Analyze voice messages for emotion

## 📞 Integration Support

For questions or issues with integration:
1. Check the example files in `/lib/services/content_integration_example.dart`
2. Review the widget examples in `/lib/widgets/video_suggestion_card.dart`
3. Test with the provided message examples
4. Ensure all dependencies are properly imported

---

**Ready to enhance your mental health app with intelligent video recommendations!** 🎯✨