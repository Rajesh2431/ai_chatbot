import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/soar_card_answer.dart';

class SoarCardService {
  static const String _soarCardKey = 'soar_card_answers';

  /// Save SOAR card answers locally
  static Future<bool> saveSoarCardAnswers(List<SoarCardAnswer> answers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = answers.map((answer) => answer.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(_soarCardKey, jsonString);
    } catch (e) {
      print('Error saving SOAR card answers: $e');
      return false;
    }
  }

  /// Load SOAR card answers from local storage
  static Future<List<SoarCardAnswer>> loadSoarCardAnswers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_soarCardKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => SoarCardAnswer.fromJson(json)).toList();
    } catch (e) {
      print('Error loading SOAR card answers: $e');
      return [];
    }
  }

  /// Clear all SOAR card answers
  static Future<bool> clearSoarCardAnswers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_soarCardKey);
    } catch (e) {
      print('Error clearing SOAR card answers: $e');
      return false;
    }
  }

  /// Check if SOAR card has been completed
  static Future<bool> isSoarCardCompleted() async {
    final answers = await loadSoarCardAnswers();
    return answers.isNotEmpty;
  }
}