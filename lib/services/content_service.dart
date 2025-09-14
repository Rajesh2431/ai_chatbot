import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class ContentService {
  // YouTube video links for mental health content
  static const List<Map<String, String>> youtubeVideos = [
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=tl7zwf_cg1U', // Replace with your actual video
      'description': '5-minute guided breathing exercise',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=R3Tykr_YA8M', // Replace with your actual video
      'description': 'What is mental health? (Adult reflections, myths vs. facts)',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=R3Tykr_YA8M', // Replace with your actual video
      'description': 'Understanding Seafarers Loneliness at Sea',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=L8Y_8RRjxMc', // Replace with your actual video
      'description': 'Stay a Little Longer at the Mess Table',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=7iIPssc44Qs', // Replace with your actual video
      'description': 'Use Music to Bring You Home',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=Rx6Q8-S_Jkg', // Replace with your actual video
      'description': 'Write Down What You Can’t Say Out Loud',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=w-mUE_9AuZg', // Replace with your actual video
      'description': 'Be There for Someone Else — Even Quietly',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=FU_p9qxEcOU', // Replace with your actual video
      'description': ' Create Simple Rituals to Mark Time',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=iLO9QAuRxN0&t=1s', // Replace with your actual video
      'description': 'Reach Out Before It Builds Up',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=HXqmnuUrvMA', // Replace with your actual video
      'description': 'Understanding Cultural Differences',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=HSZE38GsGUo', // Replace with your actual video
      'description': 'Additional Cultural Behaviors',
    },
  ];

  // LMS website link
  static const String lmsWebsiteUrl = 'https://course.strive-high.com/courses/mental-health-2/'; // Replace with your actual LMS URL
  static const String lmsWebsiteName = 'Mental Health Learning Center';

  /// Get a random YouTube video
  static Map<String, String> getRandomVideo() {
    final random = Random();
    return youtubeVideos[random.nextInt(youtubeVideos.length)];
  }

  /// Launch YouTube video
  static Future<void> launchVideo(String url) async {
    try {
      // Create different URL formats for better compatibility
      final Uri videoUri = Uri.parse(url);
      String? videoId = _extractYouTubeVideoId(url);
      
      bool launched = false;
      
      // First try: YouTube app with vnd.youtube scheme (if video ID available)
      if (videoId != null) {
        try {
          final youtubeAppUri = Uri.parse('vnd.youtube:$videoId');
          launched = await launchUrl(
            youtubeAppUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
        } catch (e) {
          launched = false;
        }
      }
      
      // Second try: Launch in external application (YouTube app or browser)
      if (!launched) {
        try {
          launched = await launchUrl(
            videoUri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          launched = false;
        }
      }
      
      // Third try: Launch with platform default
      if (!launched) {
        try {
          launched = await launchUrl(
            videoUri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          launched = false;
        }
      }
      
      // Fourth try: Launch in web view as last resort
      if (!launched) {
        launched = await launchUrl(
          videoUri,
          mode: LaunchMode.inAppWebView,
        );
      }
      
      if (!launched) {
        throw 'Could not launch video: No suitable app found';
      }
    } catch (e) {
      print('Error launching video: $e');
      rethrow;
    }
  }

  /// Extract YouTube video ID from URL
  static String? _extractYouTubeVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  /// Launch LMS website
  static Future<void> launchLMSWebsite() async {
    try {
      final Uri lmsUri = Uri.parse(lmsWebsiteUrl);
      
      // Try to launch with different modes for better Android compatibility
      bool launched = false;
      
      // First try: Launch in external browser
      try {
        launched = await launchUrl(
          lmsUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        launched = false;
      }
      
      // Second try: Launch with platform default
      if (!launched) {
        launched = await launchUrl(
          lmsUri,
          mode: LaunchMode.platformDefault,
        );
      }
      
      // Third try: Launch in web view as fallback
      if (!launched) {
        launched = await launchUrl(
          lmsUri,
          mode: LaunchMode.inAppWebView,
        );
      }
      
      if (!launched) {
        throw 'Could not launch LMS website: No suitable browser found';
      }
    } catch (e) {
      print('Error launching LMS website: $e');
      // You might want to show a user-friendly error message here
      rethrow;
    }
  }

  /// Get video suggestion text for AI
  static String getVideoSuggestionText() {
    final video = getRandomVideo();
    return 'I have a helpful video for you: "${video['title']}" - ${video['description']}. Watch video to learn more 📺';
  }

  /// Get LMS suggestion text for AI
  static String getLMSSuggestionText() {
    return 'Explore our $lmsWebsiteName for comprehensive mental health resources. Learn more about wellness techniques 📚';
  }

  // Enhanced video data with keywords for AI matching
  static const List<Map<String, String>> _enhancedVideoKeywords = [
    {
      'index': '0',
      'keywords': 'breathing, anxiety, stress, panic, calm, relaxation, meditation, breathe, deep breathing, mindfulness, worried, nervous',
    },
    {
      'index': '1', 
      'keywords': 'mental health, understanding, facts, myths, awareness, education, psychology, wellbeing, confused, learning',
    },
    {
      'index': '2',
      'keywords': 'loneliness, isolation, seafarer, alone, lonely, sea, ship, homesick, missing family, social connection, isolated',
    },
    {
      'index': '3',
      'keywords': 'social, connection, friendship, community, together, mess table, eating, bonding, relationships, teamwork',
    },
    {
      'index': '4',
      'keywords': 'music, homesick, home, family, memories, comfort, therapy, emotional, nostalgia, missing home, sad',
    },
    {
      'index': '5',
      'keywords': 'writing, journaling, expression, feelings, emotions, communication, thoughts, diary, therapeutic writing, unexpressed',
    },
    {
      'index': '6',
      'keywords': 'support, helping others, empathy, compassion, friendship, care, kindness, being present, solidarity, teamwork',
    },
    {
      'index': '7',
      'keywords': 'routine, ritual, time, structure, habits, daily, organization, schedule, consistency, stability, lost, confused',
    },
    {
      'index': '8',
      'keywords': 'help, support, reaching out, communication, asking for help, prevention, early intervention, talking, overwhelmed',
    },
    {
      'index': '9',
      'keywords': 'culture, diversity, differences, understanding, respect, multicultural, tolerance, acceptance, international, conflict',
    },
    {
      'index': '10',
      'keywords': 'cultural behavior, adaptation, customs, traditions, adjustment, integration, cross-cultural, diversity, different',
    },
  ];

  /// Analyze user message and suggest the most relevant video
  static Map<String, String>? analyzeMessageAndSuggestVideo(String userMessage) {
    if (userMessage.trim().isEmpty) return null;

    final message = userMessage.toLowerCase();
    
    // Calculate relevance scores for each video
    List<MapEntry<int, double>> videoScores = [];
    
    for (int i = 0; i < _enhancedVideoKeywords.length; i++) {
      final keywords = _enhancedVideoKeywords[i]['keywords']!.toLowerCase();
      final keywordList = keywords.split(', ');
      
      double score = 0.0;
      int matchCount = 0;
      
      // Check for keyword matches
      for (String keyword in keywordList) {
        if (message.contains(keyword.trim())) {
          matchCount++;
          // Give higher score for exact matches
          if (message.split(' ').contains(keyword.trim())) {
            score += 2.0;
          } else {
            score += 1.0;
          }
        }
      }
      
      // Bonus for multiple keyword matches
      if (matchCount > 1) {
        score += matchCount * 0.5;
      }
      
      // Check for emotional intensity words
      final intensityWords = ['very', 'really', 'extremely', 'so', 'too', 'much', 'badly', 'terrible', 'awful', 'horrible'];
      for (String intensity in intensityWords) {
        if (message.contains(intensity)) {
          score += 0.5;
          break;
        }
      }
      
      if (score > 0) {
        videoScores.add(MapEntry(i, score));
      }
    }
    
    // Sort by score (highest first)
    videoScores.sort((a, b) => b.value.compareTo(a.value));
    
    // Return the highest scoring video if any matches found
    if (videoScores.isNotEmpty && videoScores.first.value >= 1.0) {
      final bestVideoIndex = videoScores.first.key;
      if (bestVideoIndex < youtubeVideos.length) {
        return youtubeVideos[bestVideoIndex];
      }
    }
    
    // If no good match found, return null (will use random video)
    return null;
  }

  /// Get intelligent video suggestion based on user message
  static String getIntelligentVideoSuggestion(String userMessage) {
    final suggestedVideo = analyzeMessageAndSuggestVideo(userMessage);
    
    if (suggestedVideo != null) {
      return 'Based on what you\'re sharing, I think this video might help: "${suggestedVideo['title']}" - ${suggestedVideo['description']}. Would you like to watch it? 📺';
    } else {
      // Fallback to random video
      final video = getRandomVideo();
      return 'I have a helpful video that might interest you: "${video['title']}" - ${video['description']}. Feel free to check it out 📺';
    }
  }

  /// Analyze message sentiment and return emotional keywords found
  static List<String> analyzeMessageSentiment(String userMessage) {
    final message = userMessage.toLowerCase();
    final emotionalKeywords = <String>[];
    
    // Define emotional categories and their keywords
    final emotionMap = {
      'anxiety': ['anxious', 'worried', 'nervous', 'panic', 'fear', 'scared', 'stress', 'overwhelmed'],
      'sadness': ['sad', 'depressed', 'down', 'lonely', 'empty', 'hopeless', 'crying', 'tears'],
      'anger': ['angry', 'mad', 'frustrated', 'irritated', 'annoyed', 'rage', 'furious'],
      'loneliness': ['lonely', 'alone', 'isolated', 'disconnected', 'missing', 'homesick'],
      'confusion': ['confused', 'lost', 'uncertain', 'don\'t know', 'unclear', 'mixed up'],
      'fatigue': ['tired', 'exhausted', 'drained', 'weary', 'burnt out', 'sleepy'],
      'positive': ['happy', 'good', 'great', 'excited', 'grateful', 'thankful', 'better'],
    };
    
    for (String category in emotionMap.keys) {
      for (String keyword in emotionMap[category]!) {
        if (message.contains(keyword)) {
          emotionalKeywords.add(category);
          break; // Only add category once
        }
      }
    }
    
    return emotionalKeywords;
  }

  /// Get contextual response based on message analysis
  static String getContextualResponse(String userMessage) {
    final emotions = analyzeMessageSentiment(userMessage);
    final suggestedVideo = analyzeMessageAndSuggestVideo(userMessage);
    
    String response = '';
    
    // Acknowledge emotions first
    if (emotions.isNotEmpty) {
      if (emotions.contains('anxiety') || emotions.contains('stress')) {
        response += 'I understand you\'re feeling anxious or stressed. ';
      } else if (emotions.contains('sadness') || emotions.contains('loneliness')) {
        response += 'I can sense you\'re going through a difficult time. ';
      } else if (emotions.contains('anger') || emotions.contains('frustration')) {
        response += 'It sounds like you\'re feeling frustrated. ';
      } else if (emotions.contains('positive')) {
        response += 'I\'m glad to hear you\'re feeling positive! ';
      }
    }
    
    // Add video suggestion
    if (suggestedVideo != null) {
      response += 'I found a video that might be particularly helpful for what you\'re experiencing: "${suggestedVideo['title']}" - ${suggestedVideo['description']}. ';
    }
    
    response += 'Would you like me to share the video link? 📺';
    
    return response;
  }
}