import 'package:SeaSmart/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import 'registration_screen.dart';
import 'onboarding_screen.dart';
import 'goal_settings.dart';
import 'daily_checkin_screen.dart';
import 'dashboard_screen.dart';
import 'soar_card_analysis.dart';
import 'soar_card.Dart';
import 'dart:ui';

import 'package:dio/dio.dart';

Future<void> testBackend() async {
  try {
    final res = await Dio().get("https://strivehigh.thirdvizion.com/api/ping/");
    print("✅ Backend response: ${res.data}");
  } catch (e) {
    print("❌ Failed to connect: $e");
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final String loggedInEmail = _emailController.text.trim();

        // Check form statuses and navigate accordingly
        await _checkFormsAndNavigate(loggedInEmail);
      } else {
        _loginErrorDialog();
        //_showErrorDialog('Login Failed', 'User not found, please register first or verify your account.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Login Error', 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // TODO: Implement Google Sign-In
    _showErrorDialog('Feature Not Available', 'Google Sign-In is not implemented yet');
  }

  Future<void> _checkFormsAndNavigate(String email) async {
    if (!mounted) return;

    try {
      // Save user email to local storage
      await UserProfileService.saveUserProfile(
        name: '', // Will be filled during onboarding
        email: email,
      );

      // Mark user as not first time since they've logged in
      await UserProfileService.setNotFirstTime();

      // Check if sailor form is filled
      final sailorUrl = Uri.parse('https://strivehigh.thirdvizion.com/api/sailorformfilled/$email/');
      final sailorResponse = await http.get(sailorUrl);

      if (!mounted) return;

      if (sailorResponse.statusCode == 200) {
        final sailorData = json.decode(sailorResponse.body);
        final isSailorFormFilled = sailorData['is_filled'] == true;

        if (!isSailorFormFilled) {
          // Sailor form not filled - go to onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(userEmail: email),
            ),
          );
          return;
        }
      }

      // Check if goal settings are filled
      final goalUrl = Uri.parse('https://strivehigh.thirdvizion.com/api/goalsettingsfilled/$email/');
      final goalResponse = await http.get(goalUrl);

      if (!mounted) return;

      if (goalResponse.statusCode == 200) {
        final goalData = json.decode(goalResponse.body);
        final isGoalFormFilled = goalData['is_goal_filled'] == true;

        if (!isGoalFormFilled) {
          // Goal settings not filled - go to goal page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GoalPage(userEmail: email),
            ),
          );
          return;
        }
      }

      // Both forms are filled - check if daily check-in is needed
      final needsDailyCheckin = await UserProfileService.needsDailyCheckin();

      if (!mounted) return;

      if (needsDailyCheckin) {
        // User needs daily check-in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DailyCheckinScreen(),
          ),
        );
      } else {
        // User already completed daily check-in - go to soar card analysis
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SoarDashboardPage(userEmail: email),
          ),
        );
      }

    } catch (e) {
      debugPrint('Error checking forms: $e');
      if (!mounted) return;
      
      // On error, default to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(userEmail: email),
        ),
      );
    }
  }

  void _loginErrorDialog() {
  showDialog(
    context: context,
    barrierDismissible: false, // User cannot dismiss by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.1),
                //     blurRadius: 20,
                //     offset: const Offset(0, 10),
                //   ),
                // ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Verification title with checkmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Login Failed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      //const SizedBox(width: 8),
                      // Container(
                      //   width: 24,
                      //   height: 24,
                      //   decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         Color.fromARGB(255, 255, 255, 255),
                      //         Color.fromARGB(255, 255, 255, 255),
                      //       ],
                      //     ),
                      //     //borderRadius: BorderRadius.circular(12),
                      //     // boxShadow: [
                      //     //   BoxShadow(
                      //     //     color: Color.fromARGB(255, 0, 136, 190).withOpacity(0.3),
                      //     //     blurRadius: 8,
                      //     //     offset: const Offset(0, 2),
                      //     //   ),
                      //     // ],
                      //   ),
                      //   // child: const Icon(
                      //   //   Icons.close,
                      //   //   color: Color.fromARGB(255, 255, 0, 0),
                      //   //   size: 16,
                      //   // ),
                      // ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Message
                  const Text(
                    'User not found, please register first or verify your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // OK Button with glassmorphism
                  Container(
                    width: 150,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 0, 136, 190),
                          Color.fromARGB(255, 0, 136, 190),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Color.fromARGB(255, 0, 136, 190).withOpacity(0.3),
                      //     blurRadius: 12,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            // Optional: Navigate back to login screen
                            // Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Ok',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    // Basic email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    // Check for common email domains
    final commonDomains = [
      '@gmail.com',
      '@outlook.com',
      '@hotmail.com',
      '@yahoo.com',
      '@icloud.com',
      '@protonmail.com',
      '@aol.com',
      '@live.com',
      '@msn.com',
      '@yandex.com',
      '@mail.com',
      '@zoho.com',
    ];

    final email = value.toLowerCase();
    bool hasValidDomain = commonDomains.any((domain) => email.endsWith(domain));

    if (!hasValidDomain) {
      return 'Please use a common email provider';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/login_background1.png'),
            fit: BoxFit.cover,
          ),
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Color(0xFF1E3A8A), // Deep blue
          //     Color(0xFF3B82F6), // Medium blue
          //     Color(0xFF60A5FA), // Light blue
          //     Color(0xFFDDD6FE), // Very light purple
          //   ],
          //   stops: [0.0, 0.3, 0.7, 1.0],
          // ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Title Section
                Column(
                  children: [
                    const Text(
                      'Sign in to your',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your email and password to log in',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),

                                  // Google Sign In Button
                                  Container(
                                    width: double.infinity,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: OutlinedButton.icon(
                                      onPressed: _handleGoogleSignIn,
                                      icon: Image.asset(
                                        'lib/assets/icons/google_icon.png',
                                        width: 20,
                                        height: 20,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'G',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      label: const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  Text(
                                    'Or login with',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 150, 150, 150).withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Email Field
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                              color: Color.fromARGB(255, 0, 136, 190),
                                              width: 1,
                                            ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: _validateEmail,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Email',
                                        hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5),
                                          fontSize: 16,
                                        ),
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.blue.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Password Field
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                              color: Color.fromARGB(255, 0, 136, 190),
                                              width: 1,
                                            ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        hintStyle: TextStyle(
                                          color: Colors.black.withOpacity(0.5),
                                          fontSize: 16,
                                        ),
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.blue.withOpacity(0.5),
                                            width: 2,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                            color: Colors.black.withOpacity(0.5),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Remember me and Forgot password
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 0.9,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                });
                                              },
                                              activeColor: Colors.blue,
                                              checkColor: Colors.white,
                                              side: BorderSide(
                                                color: Color.fromARGB(255,150,150,150).withOpacity(0.6),
                                                width: 1.5,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Remember me',
                                            style: TextStyle(
                                              color: const Color.fromARGB(255, 150, 150, 150).withOpacity(0.8),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _showErrorDialog('Feature Not Available', 'Forgot password is not implemented yet');
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        child: Text(
                                          'Forgot Password ?',
                                          style: TextStyle(
                                            color: Colors.blue.shade300,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 30),

                                  // Login Button
                                  Container(
                                    width: double.infinity,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color.fromARGB(255, 0, 136, 190),
                                          Color.fromARGB(255, 0, 136, 190),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      // boxShadow: [ 
                                      //   BoxShadow(
                                      //     color: Color.fromARGB(100, 0, 136, 190).withOpacity(0.3),
                                      //     blurRadius: 12,
                                      //     offset: const Offset(0, 4),
                                      //   ),
                                      // ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Log In',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // Sign up link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: Color.fromARGB(255,150,150,150).withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const RegistrationScreen(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                        ),
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: Colors.blue.shade300,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
);
  }
}