import 'package:shared_preferences/shared_preferences.dart';

class AvatarService {
  static const String _hasSelectedAvatarKey = 'has_selected_avatar';
  static const String _selectedAvatarNameKey = 'selected_avatar_name';
  static const String _selectedAvatarImageKey = 'selected_avatar_image';

  // Available avatars
  static const List<Map<String, String>> availableAvatars = [
    {
      "name": "Saira",
      "image": "lib/assets/avatar/saira.png",
    },
    {
      "name": "Kael",
      "image": "lib/assets/avatar/kael.png",
    },
  ];

  // Check if user has selected an avatar
  static Future<bool> hasSelectedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSelectedAvatarKey) ?? false;
  }

  // Save avatar selection
  static Future<void> saveAvatarSelection(String name, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSelectedAvatarKey, true);
    await prefs.setString(_selectedAvatarNameKey, name);
    await prefs.setString(_selectedAvatarImageKey, imagePath);
  }

  // Get selected avatar name
  static Future<String?> getSelectedAvatarName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedAvatarNameKey);
  }

  // Get selected avatar image path
  static Future<String?> getSelectedAvatarImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedAvatarImageKey);
  }

  // Get selected avatar as a map
  static Future<Map<String, String>?> getSelectedAvatar() async {
    final name = await getSelectedAvatarName();
    final image = await getSelectedAvatarImage();
    
    if (name != null && image != null) {
      return {
        'name': name,
        'image': image,
      };
    }
    return null;
  }

  // Clear avatar selection (for testing or reset)
  static Future<void> clearAvatarSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSelectedAvatarKey);
    await prefs.remove(_selectedAvatarNameKey);
    await prefs.remove(_selectedAvatarImageKey);
  }
}