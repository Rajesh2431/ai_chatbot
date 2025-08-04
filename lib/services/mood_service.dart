import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class MoodService {
  static const String _moodDataKey = 'mood_data';
  static const String _lastCheckinKey = 'last_checkin_date';

  // Store daily mood score for a specific question
  static Future<void> storeDailyMoodScore(String question, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Get existing mood data
    final moodDataJson = prefs.getString(_moodDataKey) ?? '{}';
    final Map<String, dynamic> moodData = jsonDecode(moodDataJson);
    
    // Initialize today's data if it doesn't exist
    if (!moodData.containsKey(today)) {
      moodData[today] = {
        'questions': {},
        'overall_score': 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
    
    // Store the question score
    moodData[today]['questions'][question] = score;
    
    // Save back to preferences
    await prefs.setString(_moodDataKey, jsonEncode(moodData));
  }

  // Store overall daily mood score
  static Future<void> storeDailyOverallMood(double overallScore) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Get existing mood data
    final moodDataJson = prefs.getString(_moodDataKey) ?? '{}';
    final Map<String, dynamic> moodData = jsonDecode(moodDataJson);
    
    // Initialize today's data if it doesn't exist
    if (!moodData.containsKey(today)) {
      moodData[today] = {
        'questions': {},
        'overall_score': overallScore,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } else {
      moodData[today]['overall_score'] = overallScore;
    }
    
    // Save back to preferences
    await prefs.setString(_moodDataKey, jsonEncode(moodData));
    
    // Cancel the completion reminder since check-in is done
    await NotificationService.cancelCheckinCompletionReminder();
  }

  // Get today's overall mood score
  static Future<double> getTodaysMoodScore() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final moodDataJson = prefs.getString(_moodDataKey) ?? '{}';
    final Map<String, dynamic> moodData = jsonDecode(moodDataJson);
    
    if (moodData.containsKey(today)) {
      return (moodData[today]['overall_score'] as num).toDouble();
    }
    
    return 3.0; // Default neutral mood (middle of 1-5 scale)
  }

  // Get mood analytics for dashboard (last 7 days)
  static Future<List<double>> getWeeklyMoodScores() async {
    final prefs = await SharedPreferences.getInstance();
    final moodDataJson = prefs.getString(_moodDataKey) ?? '{}';
    final Map<String, dynamic> moodData = jsonDecode(moodDataJson);
    
    List<double> weeklyScores = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateString = date.toIso8601String().split('T')[0];
      
      if (moodData.containsKey(dateString)) {
        weeklyScores.add((moodData[dateString]['overall_score'] as num).toDouble());
      } else {
        weeklyScores.add(3.0); // Default neutral if no data (middle of 1-5 scale)
      }
    }
    
    return weeklyScores;
  }

  // Get current mood level (1-6 scale for dashboard display)
  static Future<int> getCurrentMoodLevel() async {
    final todayScore = await getTodaysMoodScore();
    
    // Convert 1-5 scale to 1-6 scale for dashboard
    if (todayScore >= 4.8) return 6; // Excellent
    if (todayScore >= 4.2) return 5; // Very Good
    if (todayScore >= 3.5) return 4; // Good
    if (todayScore >= 2.8) return 3; // Okay
    if (todayScore >= 2.0) return 2; // Not Great
    return 1; // Poor
  }

  // Check if user needs daily check-in
  static Future<bool> needsDailyCheckin() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckinDate = prefs.getString(_lastCheckinKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    return lastCheckinDate != today;
  }

  // Get mood trend (improving, stable, declining)
  static Future<String> getMoodTrend() async {
    final weeklyScores = await getWeeklyMoodScores();
    
    if (weeklyScores.length < 2) return 'stable';
    
    final recent = weeklyScores.sublist(weeklyScores.length - 3);
    final earlier = weeklyScores.sublist(0, weeklyScores.length - 3);
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final earlierAvg = earlier.isNotEmpty 
        ? earlier.reduce((a, b) => a + b) / earlier.length 
        : recentAvg;
    
    if (recentAvg > earlierAvg + 0.3) return 'improving';
    if (recentAvg < earlierAvg - 0.3) return 'declining';
    return 'stable';
  }

  // Clear all mood data (for testing)
  static Future<void> clearMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moodDataKey);
    await prefs.remove(_lastCheckinKey);
  }

  // Get detailed mood history
  static Future<Map<String, dynamic>> getMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final moodDataJson = prefs.getString(_moodDataKey) ?? '{}';
    return jsonDecode(moodDataJson);
  }

  // Enable daily check-in notifications
  static Future<void> enableDailyNotifications({
    int hour = 9,
    int minute = 0,
  }) async {
    await NotificationService.scheduleDailyCheckinReminder(
      hour: hour,
      minute: minute,
    );
  }

  // Disable daily check-in notifications
  static Future<void> disableDailyNotifications() async {
    await NotificationService.cancelDailyCheckinReminder();
  }

  // Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    return await NotificationService.areNotificationsEnabled();
  }

  // Get notification time
  static Future<String> getNotificationTime() async {
    return await NotificationService.getNotificationTime();
  }

  // Schedule reminder if check-in is missed
  static Future<void> scheduleCheckinReminderIfNeeded() async {
    final needsCheckin = await needsDailyCheckin();
    final notificationsEnabled = await areNotificationsEnabled();
    
    if (needsCheckin && notificationsEnabled) {
      await NotificationService.scheduleCheckinCompletionReminder();
    }
  }

  // Show welcome notification for new users
  static Future<void> showWelcomeNotification() async {
    await NotificationService.showInstantNotification(
      title: 'Welcome to SeaSmart! 🌟',
      body: 'Daily check-in reminders are now enabled. We\'ll remind you at 9:00 AM each day.',
      payload: 'welcome',
    );
  }
}