import 'package:SeaSmart/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import 'dart:ui';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  //String _selectedCountryCode = '+1';
  bool _termsAndCondition = false;

  // final List<String> _countryCodes = [
  //   '+1', '+44', '+33', '+49', '+81', '+86', '+91', '+61', '+55', '+52'
  // ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.signup(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

  if (result['success'] == true) {
  _showVerificationDialog();
} else {
  throw Exception(result['message'] ?? 'Registration failed');
}

  }

  Future<void> _handleGoogleSignUp() async {
    // TODO: Implement Google Sign-Up
    _showErrorSnackBar('Google Sign-Up not implemented yet');
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _showVerificationDialog() {
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
                        'Verification',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 0, 136, 190),
                              Color.fromARGB(255, 0, 120, 170),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Color.fromARGB(255, 0, 136, 190).withOpacity(0.3),
                          //     blurRadius: 8,
                          //     offset: const Offset(0, 2),
                          //   ),
                          // ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Message
                  const Text(
                    'Almost there! Open your email and click the link to verify your account.',
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
                            Navigator.pushReplacementNamed(context, '/login');
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

void _userErrorDialog() {
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
                        'Registration Failed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Message
                  const Text(
                    'User already exists or invalid details provided. Please try again.',
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
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.pushReplacementNamed(context, '/login');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
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
      resizeToAvoidBottomInset: false, // Keeps background static
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/images/login_background1.png'), // Your background image
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Top section with back button and title
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Title Section
                Column(
                  children: [
                    const Text(
                      'Create your',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: Colors.blue.shade300,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
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

                                  // First Name and Last Name Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
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
                                            controller: _firstNameController,
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return 'Required';
                                              }
                                              return null;
                                            },
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'First Name',
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
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
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
                                            controller: _lastNameController,
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return 'Required';
                                              }
                                              return null;
                                            },
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Last Name',
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
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

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

                                  // Date of Birth Field
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
                                      controller: _dobController,
                                      readOnly: true,
                                      onTap: _selectDate,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please select your date of birth';
                                        }
                                        return null;
                                      },
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Date of Birth',
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
                                        suffixIcon: Icon(
                                          Icons.calendar_today,
                                          color: Colors.black.withOpacity(0.5),
                                          size: 20,
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
                                          return 'Please enter a password';
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

                                  const SizedBox(height: 5),

                                  Row(
                                      children: [
                                        Transform.scale(
                                          scale: 0.9,
                                          child: Checkbox(
                                            value: _termsAndCondition,
                                            onChanged: (value) {
                                              setState(() {
                                                _termsAndCondition = value ?? false;
                                              });
                                            },
                                            activeColor: Colors.blue,
                                            checkColor: Colors.white,
                                            side: BorderSide(
                                              color: Color.fromARGB(255, 150, 150, 150),
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                'Terms and Conditions applied*',
                                                style: TextStyle(
                                                  color: const Color.fromARGB(255, 150, 150, 150),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              TextButton(
                                                onPressed: () async {
                                                  // Replace with your actual website URL
                                                  const url = 'https://strivehigh.thirdvizion.com/';
                                                  try {
                                                    if (await canLaunch(url)) {
                                                      await launch(url);
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Could not open website'),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Could not open website'),
                                                      ),
                                                    );
                                                  }
                                                },
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  minimumSize: Size.zero,
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: Text(
                                                  'learn more',
                                                  style: TextStyle(
                                                    color: Colors.blue.shade300,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    decoration: TextDecoration.underline,
                                                    decorationColor: Colors.blue.shade300,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 30),

                                  // Sign Up Button
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
                                      //     color: Color.fromARGB(255, 0, 136, 190),
                                      //     blurRadius: 12,
                                      //     offset: const Offset(0, 4),
                                      //   ),
                                      // ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : () {
                                        if (!_termsAndCondition) {
                                          _showErrorSnackBar('You must agree to the terms and conditions');
                                          return;
                                        }
                                        
                                        _handleRegistration().catchError((error) {
                                          // Registration failed - show error dialog
                                          _userErrorDialog();
                                        });
                                      },
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
                                              'Sign Up',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  Text(
                                    'Or',
                                    style: TextStyle(
                                      color: Color.fromARGB(255,150,150,150).withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Google Sign Up Button
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
                                      onPressed: _handleGoogleSignUp,
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
                                        'Sign up with Google',
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

                                  const SizedBox(height: 30),
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