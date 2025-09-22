import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class UserAvatarService {
  static const String _avatarNameKey = 'user_avatar_name';
  static const String _avatarImageKey = 'user_avatar_image';

  /// Fetch user avatar information from backend
  static Future<Map<String, String?>> fetchUserAvatarFromBackend() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('No auth token found');
        return {'name': null, 'image': null};
      }

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}user-profile/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final avatarName = data['avatar_name'] as String?;
        final avatarImage = data['avatar_image'] as String?;

        // Cache the avatar information locally
        await _cacheAvatarInfo(avatarName, avatarImage);

        return {'name': avatarName, 'image': avatarImage};
      } else {
        print('Failed to fetch user avatar: ${response.statusCode}');
        return {'name': null, 'image': null};
      }
    } catch (e) {
      print('Error fetching user avatar: $e');
      return {'name': null, 'image': null};
    }
  }

  /// Get user avatar name (from cache or backend)
  static Future<String?> getUserAvatarName() async {
    // First try to get from cache
    final prefs = await SharedPreferences.getInstance();
    String? cachedName = prefs.getString(_avatarNameKey);

    return cachedName;

    // If not in cache, fetch from backend
    final avatarInfo = await fetchUserAvatarFromBackend();
    return avatarInfo['name'];
  }

  /// Get user avatar image path (from cache or backend)
  static Future<String?> getUserAvatarImage() async {
    // First try to get from cache
    final prefs = await SharedPreferences.getInstance();
    String? cachedImage = prefs.getString(_avatarImageKey);

    return cachedImage;

    // If not in cache, fetch from backend
    final avatarInfo = await fetchUserAvatarFromBackend();
    return avatarInfo['image'];
  }

  /// Get the appropriate half avatar image based on avatar name
  static Future<String> getHalfAvatarImage() async {
    final avatarName = await getUserAvatarName();

    if (avatarName != null) {
      switch (avatarName.toLowerCase()) {
        case 'kael':
          return 'lib/assets/avatar/Kael_half.png';
        case 'saira':
        case 'siara':
          return 'lib/assets/avatar/Siara_half.png';
        default:
          // Default to Saira if unknown
          return 'lib/assets/avatar/Siara_half.png';
      }
    }

    // Default to Saira if no avatar name
    return 'lib/assets/avatar/Siara_half.png';
  }

  /// Cache avatar information locally
  static Future<void> _cacheAvatarInfo(String? name, String? image) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) {
      await prefs.setString(_avatarNameKey, name);
    }

    if (image != null) {
      await prefs.setString(_avatarImageKey, image);
    }
  }

  /// Clear cached avatar information
  static Future<void> clearCachedAvatarInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_avatarNameKey);
    await prefs.remove(_avatarImageKey);
  }

  /// Get mood-based avatar response based on selected mood
  static String getMoodResponse(String moodText, int score) {
    switch (moodText.toLowerCase()) {
      case 'fantastic':
        return "That's wonderful! I'm so happy to hear you're feeling fantastic today! 🌟";
      case 'pretty good':
        return "Great to hear you're doing pretty well! Keep up the positive energy! 😊";
      case 'alright':
        return "I'm glad you're feeling alright. Is there anything that could make your day even better? 🙂";
      case 'just okay':
        return "It's okay to have okay days. Would you like to talk about what's on your mind? 🤗";
      case 'balanced':
        return "Balance is beautiful! You're doing great at staying centered. ✨";
      default:
        // Fallback based on score
        if (score >= 4) {
          return "I can see you're in a positive mood today! That's wonderful! 😊";
        } else if (score >= 3) {
          return "How are you feeling today? I'm here to listen and support you. 🤗";
        } else {
          return "I'm here to support you through whatever you're feeling today. 💙";
        }
    }
  }
}
