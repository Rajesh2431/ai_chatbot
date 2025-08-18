import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static const String _keyFirstTime = 'is_first_time';
  static const String _keyProfileComplete = 'profile_complete';
  static const String _keyUserName = 'user_name';
  static const String _keyUserAge = 'user_age';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserGender = 'user_gender';
  static const String _keyUserHobbies = 'user_hobbies';
  static const String _keyUserLocation = 'user_location';
  static const String _keyUserRelationshipStatus = 'user_relationship_status';
  static const String _keyUserEmergencyContact = 'user_emergency_contact';
  static const String _keyUserAvatarPath = 'user_avatar_path';
  static const String _keyLastDailyCheckin = 'last_daily_checkin_date';

  /// Check if this is the user's first time opening the app
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true;
  }

  /// Mark that the user has opened the app before
  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, false);
  }

  /// Check if user has completed their profile
  static Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyProfileComplete) ?? false;
  }

  /// Mark profile as complete
  static Future<void> setProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProfileComplete, true);
  }

  /// Get user profile data
  static Future<Map<String, String?>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyUserName) ?? '',
      'age': prefs.getString(_keyUserAge) ?? '',
      'email': prefs.getString(_keyUserEmail) ?? '',
      'phone': prefs.getString(_keyUserPhone) ?? '',
      'gender': prefs.getString(_keyUserGender) ?? '',
      'hobbies': prefs.getString(_keyUserHobbies) ?? '',
      'location': prefs.getString(_keyUserLocation) ?? '',
      'relationshipStatus': prefs.getString(_keyUserRelationshipStatus) ?? '',
      'emergencyContact': prefs.getString(_keyUserEmergencyContact) ?? '',
      'avatarPath': prefs.getString(_keyUserAvatarPath),
    };
  }

  /// Save user profile data
  static Future<void> saveUserProfile({
    required String name,
    String? age,
    String? email,
    String? phone,
    String? gender,
    String? hobbies,
    String? location,
    String? relationshipStatus,
    String? emergencyContact,
    String? avatarPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyUserName, name);
    if (age != null && age.isNotEmpty) await prefs.setString(_keyUserAge, age);
    if (email != null && email.isNotEmpty) await prefs.setString(_keyUserEmail, email);
    if (phone != null && phone.isNotEmpty) await prefs.setString(_keyUserPhone, phone);
    if (gender != null && gender.isNotEmpty) await prefs.setString(_keyUserGender, gender);
    if (hobbies != null && hobbies.isNotEmpty) await prefs.setString(_keyUserHobbies, hobbies);
    if (location != null && location.isNotEmpty) await prefs.setString(_keyUserLocation, location);
    if (relationshipStatus != null && relationshipStatus.isNotEmpty) await prefs.setString(_keyUserRelationshipStatus, relationshipStatus);
    if (emergencyContact != null && emergencyContact.isNotEmpty) await prefs.setString(_keyUserEmergencyContact, emergencyContact);
    if (avatarPath != null && avatarPath.isNotEmpty) await prefs.setString(_keyUserAvatarPath, avatarPath);
    
    // Mark profile as complete if name is provided
    if (name.isNotEmpty) {
      await setProfileComplete();
    }
  }

  /// Get user's display name
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? 'User';
  }

  /// Save user avatar path
  static Future<void> saveUserAvatar(String avatarPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAvatarPath, avatarPath);
  }

  /// Get user avatar path
  static Future<String?> getUserAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserAvatarPath);
  }

  /// Check if user needs daily check-in today
  static Future<bool> needsDailyCheckin() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckinDate = prefs.getString(_keyLastDailyCheckin);
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    
    return lastCheckinDate != today;
  }

  /// Mark daily check-in as completed for today
  static Future<void> markDailyCheckinComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    await prefs.setString(_keyLastDailyCheckin, today);
  }

  /// Clear all user data (for testing or logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstTime);
    await prefs.remove(_keyProfileComplete);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserAge);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserGender);
    await prefs.remove(_keyUserHobbies);
    await prefs.remove(_keyUserLocation);
    await prefs.remove(_keyUserRelationshipStatus);
    await prefs.remove(_keyUserEmergencyContact);
    await prefs.remove(_keyUserAvatarPath);
    await prefs.remove(_keyLastDailyCheckin);
  }
}