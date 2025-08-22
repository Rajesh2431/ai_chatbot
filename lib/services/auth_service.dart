import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  static const String _lanIp = "192.168.1.28"; // your PC IP
  static const String _port = "8000";

  static String get baseUrl {
  if (kIsWeb) {
    // ✅ For Chrome
    return "http://127.0.0.1:8000/api/";
  } else {
    // ✅ For Android/iOS devices
    return "http://192.168.1.28:8000/api/";
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
}
