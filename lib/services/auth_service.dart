import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'user_profile_service.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      // ✅ For Chrome
      return "https://strivehigh.thirdvizion.com/api/";
    } else {
      // ✅ For Android/iOS devices
      return "https://strivehigh.thirdvizion.com/api/";
    }
  }

  /// Signup
  static Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final res = await Dio().post("${baseUrl}register/", data: {
        "email": email,
        "password": password,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {"success": true, "message": res.data["message"] ?? "Registered"};
      } else {
        return {"success": false, "message": res.data["error"] ?? "Failed"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await Dio().post("${baseUrl}login/", data: {
        "email": email,
        "password": password,
      });

      if (res.statusCode == 200) {
        final token = res.data["token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", token);
        await prefs.setString("user_email", email); // Save the email for later use

        return {
          "success": true,
          "message": res.data["message"] ?? "Login success",
          "token": token,
        };
      } else {
        return {"success": false, "message": res.data["error"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_email");
    
    // Also clear user profile data on logout
    await UserProfileService.clearUserData();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  static Future<Dio> authedDio() async {
    final dio = Dio();
    final token = await getToken();
    if (token != null) {
      dio.options.headers["Authorization"] = "Token $token";
    }
    return dio;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
