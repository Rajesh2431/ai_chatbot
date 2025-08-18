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
      'url': 'https://www.youtube.com/watch?v=2HZinZ79FHg', // Replace with your actual video
      'description': 'Techniques to manage anxiety',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=R3Tykr_YA8M', // Replace with your actual video
      'description': 'Daily mindfulness meditation',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=QnFxxEaQYfA', // Replace with your actual video
      'description': 'Calming sounds for better sleep',
    },
    {
      'title': 'Watch this',
      'url': 'https://www.youtube.com/watch?v=L8Y_8RRjxMc', // Replace with your actual video
      'description': 'Effective stress relief techniques',
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
}