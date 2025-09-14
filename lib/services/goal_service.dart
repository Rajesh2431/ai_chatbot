import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'user_profile_service.dart';

class GoalService {
  static String get _baseUrl => AuthService.baseUrl;

  /// Create a new goal setting
  static Future<Map<String, dynamic>> createGoal({
    required String terms,
    required String goals,
    required String notes,
  }) async {
    try {
      // Get user email from UserProfileService
      final email = await UserProfileService.getUserEmail();
      
      if (email.isEmpty) {
        return {
          'success': false,
          'message': 'User email not found. Please complete your profile first.'
        };
      }

      // Get authenticated Dio instance
      final dio = await AuthService.authedDio();
      
      print('Sending createGoal request with data: email=$email, terms=$terms, goals=$goals, notes=$notes');
      final response = await dio.post(
        'https://strivehigh.thirdvizion.com/api/setgoal/',
        data: {
          'email': email,
          'terms': terms,
          'goals': goals,
          'notes': notes,
        },
      );
      print('Received response: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Goal created successfully'
        };
      } else {
        return {
          'success': false,
          'message': response.data['error'] ?? 'Failed to create goal'
        };
      }
    } on DioException catch (e) {
      print('DioException in createGoal: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status: ${e.response?.statusCode}');
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['error'] ?? 'Network error occurred'
        };
      } else {
        return {
          'success': false,
          'message': 'Network error: ${e.message}'
        };
      }
    } catch (e) {
      print('Unexpected error in createGoal: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e'
      };
    }
  }

  /// Get user's goals
  static Future<Map<String, dynamic>> getUserGoals() async {
    try {
      // Get user email from UserProfileService
      final email = await UserProfileService.getUserEmail();
      
      if (email.isEmpty) {
        return {
          'success': false,
          'message': 'User email not found',
          'goals': []
        };
      }

      // Get authenticated Dio instance
      final dio = await AuthService.authedDio();
      
      print('Sending getUserGoals request for email: $email');
      final response = await dio.get(
        'https://strivehigh.thirdvizion.com/api/setgoal/',
      );
      print('Received response: status=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'goals': response.data['goals'] ?? [],
          'message': 'Goals retrieved successfully'
        };
      } else {
        return {
          'success': false,
          'message': response.data['error'] ?? 'Failed to retrieve goals',
          'goals': []
        };
      }
    } on DioException catch (e) {
      print('DioException in getUserGoals: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status: ${e.response?.statusCode}');
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['error'] ?? 'Network error occurred',
          'goals': []
        };
      } else {
        return {
          'success': false,
          'message': 'Network error: ${e.message}',
          'goals': []
        };
      }
    } catch (e) {
      print('Unexpected error in getUserGoals: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
        'goals': []
      };
    }
  }
}
