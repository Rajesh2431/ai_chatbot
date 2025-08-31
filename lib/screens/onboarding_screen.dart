import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/user_profile_service.dart';
//import 'avatar_selection_screen.dart';
import 'soar_card.dart'; // <-- Import QuestionPage

class OnboardingScreen extends StatefulWidget {
  final String userEmail;
  const OnboardingScreen({super.key, required this.userEmail});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _contactInfoFormKey = GlobalKey<FormState>();
  final _additionalInfoFormKey = GlobalKey<FormState>();

  int _currentPage = 0;
  final int _totalPages = 4;

  // Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _rankController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _homeLocationController = TextEditingController();
  final _locationController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _spouseNameController = TextEditingController();
  final _childrenNamesController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate email field with the login email
    _emailController.text = widget.userEmail;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _rankController.dispose();
    _yearsExperienceController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _homeLocationController.dispose();
    _locationController.dispose();
    _hobbiesController.dispose();
    _spouseNameController.dispose();
    _childrenNamesController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _relationshipController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _completeOnboarding();
    }
  }

  bool _validateCurrentPage() {
    final missingFields = <String>[];

    switch (_currentPage) {
      case 0:
        return true;

      case 1: // Basic Info
        _basicInfoFormKey.currentState?.validate(); // show inline errors
        if (_nameController.text.trim().isEmpty) missingFields.add('Name');
        final ageText = _ageController.text.trim();
        final age = int.tryParse(ageText);
        if (ageText.isEmpty || age == null || age <= 0) {
          missingFields.add('Valid Age');
        }
        if (_rankController.text.trim().isEmpty) {
          missingFields.add('Rank/Position');
        }
        if (_yearsExperienceController.text.trim().isEmpty) {
          missingFields.add('Years of Experience');
        }
        if (_companyController.text.trim().isEmpty) {
          missingFields.add('Company Name');
        }
        break;

      case 2: // Contact Info
        _contactInfoFormKey.currentState?.validate(); // show inline errors
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          missingFields.add('Phone Number');
        } else {
          final phoneRegex = RegExp(r'^[0-9]{10,15}$');
          if (!phoneRegex.hasMatch(phone)) {
            missingFields.add('Valid Phone Number');
          }
        }
        if (_homeLocationController.text.trim().isEmpty) {
          missingFields.add('Home Location');
        }
        break;

      case 3: // Additional Info
        // Only hobbies is required here; spouse/children optional
        if (_hobbiesController.text.trim().isEmpty) {
          missingFields.add('Hobbies');
        }
        break;
    }

    if (missingFields.isNotEmpty) {
      _showValidationAlert(missingFields);
      return false;
    }
    return true;
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_validateCurrentPage()) {
      // Prepare data for API with backend-expected field names
      final Map<String, dynamic> sailorData = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "age": _ageController.text.trim(),
        "rank": _rankController.text.trim(),
        "phone_number": _phoneController.text.trim(),
        "experience_years": _yearsExperienceController.text.trim(),
        "spouse_name": _spouseNameController.text.trim(),
        "childern_names": _childrenNamesController.text.trim(),
        "home_location": _homeLocationController.text.trim(),
        "hobbies": _hobbiesController.text.trim(),
        "company_name": _companyController.text.trim(),
      };

      try {
        final dio = Dio();
        final response = await dio.post(
          "http://127.0.0.1:8000/api/sailorform/",
          data: sailorData,
        );
        if (response.statusCode == 201 || response.statusCode == 200) {
          await UserProfileService.setNotFirstTime();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuizPage(userEmail: _emailController.text.trim()),
              ),
            );
          }
        } else {
          // Show error if API fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // ---- Glass Alert for Missing Info ----
  void _showValidationAlert(List<String> missingFields) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white.withOpacity(0.10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.error_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Missing Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Please fill in the following required fields:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...missingFields.map(
                      (f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.chevron_right,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                f,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 148, 179, 205), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: List.generate(_totalPages, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildBasicInfoPage(),
                    _buildContactInfoPage(),
                    _buildAdditionalInfoPage(),
                  ],
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 249, 249),
                          foregroundColor: Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          _currentPage == _totalPages - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _glassFormWrapper({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 255, 253, 253).withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color.fromARGB(255, 68, 68, 68).withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 134, 180, 219).withOpacity(0.2), // shadow color
          blurRadius: 12, // softness of shadow
          spreadRadius: 2, // how much it spreads
          offset: const Offset(4, 6), // position of shadow (x, y)
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: child,
      ),
    ),
  );
}


  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.psychology,
              size: 60,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Welcome to SeaSmart',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your personal mental health companion',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          const Text(
            'Let\'s get to know you better so we can provide personalized support for your mental wellness journey.',
            style: TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _basicInfoFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 250, 250, 250),
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Color.fromARGB(255, 1, 142, 250),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'This helps us personalize your experience',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 103, 199, 251),
                fontWeight: FontWeight.w600,
                  shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Color.fromARGB(197, 130, 204, 246),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              
            ),
            const SizedBox(height: 40),
            _glassFormWrapper(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Color.fromARGB(255, 244, 217, 217)),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration(
                      label: 'Your Name',
                      icon: Icons.person_outline,
                      
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: 'Age',
                      icon: Icons.cake_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Age is required';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age <= 0) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rankController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration(
                      label: 'Rank/Position',
                      icon: Icons.work_outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearsExperienceController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      label: 'Years of Experience',
                      icon: Icons.timeline_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration(
                      label: 'Company Name',
                      icon: Icons.business_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _contactInfoFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Colors.black45,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'How can we reach you?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _glassFormWrapper(
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      final phoneRegex = RegExp(r'^[0-9]{10,15}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _homeLocationController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: _inputDecoration(
                      label: 'Home Location',
                      icon: Icons.location_on_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _additionalInfoFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Color.fromARGB(115, 46, 45, 45),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'A few more details for your profile',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _glassFormWrapper(
              child: Column(
                children: [
                  TextFormField(
                    controller: _hobbiesController,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    cursorColor: const Color.fromARGB(255, 255, 255, 255),
                    decoration: _inputDecoration(
                      label: 'Hobbies',
                      icon: Icons.sports_soccer_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _spouseNameController,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    cursorColor: const Color.fromARGB(255, 0, 0, 0),
                    decoration: _inputDecoration(
                      label: 'Spouse Name (optional)',
                      icon: Icons.person_2_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _childrenNamesController,
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    cursorColor: const Color.fromARGB(255, 255, 249, 249),
                    decoration: _inputDecoration(
                      label: 'Children Names (optional)',
                      icon: Icons.child_care_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9)),
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 255, 253, 253).withOpacity(0.9)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color.fromARGB(255, 255, 252, 252), width: 2),
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 255, 243, 243).withOpacity(0.05),
    );
  }
}
