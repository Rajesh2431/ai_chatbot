import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import 'mood_service.dart';

class ChatHistoryService {
  static const String _chatHistoryKey = 'chat_history';

  /// Save chat messages for a specific date
  static Future<void> saveChatHistory(
    String date,
    List<Message> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing chat history
    final historyJson = prefs.getString(_chatHistoryKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);

    // Convert messages to JSON
    final messagesJson = messages
        .map(
          (message) => {
            'text': message.text,
            'isUser': message.isUser,
            'timestamp': DateTime.now().toIso8601String(),
            'actions': message.actions
                ?.map(
                  (action) => {
                    'label': action.label,
                    'route': action.route,
                    'data': action.data,
                  },
                )
                .toList(),
          },
        )
        .toList();

    // Get mood data for the date
    final moodData = await _getMoodDataForDate(date);

    // Store messages and mood data for the date
    history[date] = {
      'messages': messagesJson,
      'messageCount': messagesJson.length,
      'lastUpdated': DateTime.now().toIso8601String(),
      'moodData': moodData,
    };

    // Save back to preferences
    await prefs.setString(_chatHistoryKey, jsonEncode(history));
  }

  /// Get chat history for a specific date
  static Future<List<Message>> getChatHistory(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_chatHistoryKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);

    if (!history.containsKey(date)) {
      return [];
    }

    final dayData = history[date];
    final messagesJson = dayData['messages'] as List<dynamic>;

    return messagesJson.map((messageJson) {
      final actions = messageJson['actions'] as List<dynamic>?;
      return Message(
        text: messageJson['text'],
        isUser: messageJson['isUser'],
        actions: actions
            ?.map(
              (actionJson) => MessageAction(
                label: actionJson['label'],
                route: actionJson['route'],
                icon: Icons
                    .help, // Default icon, you might want to store icon data
                data: actionJson['data'] != null
                    ? Map<String, String>.from(actionJson['data'])
                    : null,
              ),
            )
            .toList(),
      );
    }).toList();
  }

  /// Get all chat history dates
  static Future<List<String>> getChatHistoryDates() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_chatHistoryKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);

    final dates = history.keys.toList();
    dates.sort(
      (a, b) => b.compareTo(a),
    ); // Sort by date descending (newest first)
    return dates;
  }

  /// Get chat summary for a specific date
  static Future<Map<String, dynamic>?> getChatSummary(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_chatHistoryKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);

    if (!history.containsKey(date)) {
      return null;
    }

    final dayData = history[date];
    final moodData = dayData['moodData'] as Map<String, dynamic>?;
    
    return {
      'date': date,
      'messageCount': dayData['messageCount'],
      'lastUpdated': dayData['lastUpdated'],
      'moodData': moodData,
      'moodScore': moodData?['overallScore'] ?? 3.0,
      'moodEmoji': getMoodEmoji((moodData?['overallScore'] ?? 3.0).toDouble()),
      'moodDescription': getMoodDescription((moodData?['overallScore'] ?? 3.0).toDouble()),
    };
  }

  /// Delete chat history for a specific date
  static Future<void> deleteChatHistory(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_chatHistoryKey) ?? '{}';
    final Map<String, dynamic> history = jsonDecode(historyJson);

    history.remove(date);
    await prefs.setString(_chatHistoryKey, jsonEncode(history));
  }

  /// Clear all chat history
  static Future<void> clearAllChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
  }

  /// Get today's date string
  static String getTodayDateString() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  /// Get mood data for a specific date
  static Future<Map<String, dynamic>?> _getMoodDataForDate(String date) async {
    try {
      final moodHistory = await MoodService.getMoodHistory();
      if (moodHistory.containsKey(date)) {
        final dayData = moodHistory[date] as Map<String, dynamic>;
        return {
          'overallScore': dayData['overall_score'] ?? 3.0,
          'questions': dayData['questions'] ?? {},
          'timestamp': dayData['timestamp'],
        };
      }
    } catch (e) {
      print('Error getting mood data for $date: $e');
    }
    return null;
  }

  /// Get mood data from chat history
  static Map<String, dynamic>? getMoodDataFromHistory(String date, Map<String, dynamic> historyData) {
    return historyData['moodData'] as Map<String, dynamic>?;
  }

  /// Get mood emoji based on score
  static String getMoodEmoji(double score) {
    if (score >= 4.5) return '😄';
    if (score >= 4.0) return '😊';
    if (score >= 3.0) return '🙂';
    if (score >= 2.0) return '😐';
    return '😔';
  }

  /// Get mood description based on score
  static String getMoodDescription(double score) {
    if (score >= 4.5) return 'Excellent Mood';
    if (score >= 4.0) return 'Great Mood';
    if (score >= 3.0) return 'Good Mood';
    if (score >= 2.0) return 'Okay Mood';
    return 'Needs Support';
  }

  /// Format date for display
  static String formatDateForDisplay(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final chatDate = DateTime(date.year, date.month, date.day);

      if (chatDate == today) {
        return 'Today';
      } else if (chatDate == yesterday) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
