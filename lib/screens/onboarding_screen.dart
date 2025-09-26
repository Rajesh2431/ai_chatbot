import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/user_profile_service.dart';
import '../services/auth_service.dart';
import 'avatar_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final String userEmail;
  const OnboardingScreen({super.key, required this.userEmail});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _contactInfoFormKey = GlobalKey<FormState>();
  final _additionalInfoFormKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;
  final int _totalPages = 4;

  // Controllers - keeping all existing controllers for backend compatibility
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
    // Remove setting emailController.text to widget.userEmail to allow manual input
    //_emailController.text = widget.userEmail;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
    _checkAndNavigateIfFormFilled();
  }

  Future<void> _checkAndNavigateIfFormFilled() async {
    bool isFilled = await checkFormFilled();
    if (isFilled && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AvatarSelectionScreen(userEmail: widget.userEmail),
        ),
      );
    }
  }

  Future<bool> checkFormFilled() async {
    final url = Uri.parse(
      'https://strivehigh.thirdvizion.com/api/sailorformfilled/${widget.userEmail}/',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['is_filled'] == true;
      }
    } catch (e) {
      // Handle error or ignore
    }
    return false;
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        _animationController.reset();
        _animationController.forward();
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
        _basicInfoFormKey.currentState?.validate();
        if (_nameController.text.trim().isEmpty) missingFields.add('Name');
        // final ageText = _ageController.text.trim();
        // final age = int.tryParse(ageText);
        //  if (ageText.isEmpty || age == null || age <= 0) {
        //    missingFields.add('Valid Age');
        //  }
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
        _contactInfoFormKey.currentState?.validate();
        if (_emailController.text.trim().isEmpty) {
          missingFields.add('Email');
        } else {
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(_emailController.text.trim())) {
            missingFields.add('Valid Email');
          }
        }
        //final phone = _phoneController.text.trim();
        // if (phone.isEmpty) {
        //   missingFields.add('Phone Number');
        // } else {
        //   final phoneRegex = RegExp(r'^[0-9]{10,15}$');
        //   if (!phoneRegex.hasMatch(phone)) {
        //     missingFields.add('Valid Phone Number');
        //   }
        // }
        if (_homeLocationController.text.trim().isEmpty) {
          missingFields.add('Home Location');
        }
        break;

      case 3: // Additional Info
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
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_validateCurrentPage()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 118, 147, 147),
            ),
          ),
        ),
      );

      int? parseIntOrNull(String text) {
        if (text.isEmpty) return null;
        return int.tryParse(text);
      }

      Map<String, dynamic> sailorData = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "age": parseIntOrNull(_ageController.text.trim()),
        "rank": _rankController.text.trim(),
        "experience_years": parseIntOrNull(
          _yearsExperienceController.text.trim(),
        ),
        "home_location": _homeLocationController.text.trim(),
        "hobbies": _hobbiesController.text.trim(),
        "company_name": _companyController.text.trim(),
      };

      if (_phoneController.text.trim().isNotEmpty) {
        sailorData["phone_number"] = _phoneController.text.trim();
      }
      if (_spouseNameController.text.trim().isNotEmpty) {
        sailorData["spouse_name"] = _spouseNameController.text.trim();
      }
      if (_childrenNamesController.text.trim().isNotEmpty) {
        sailorData["children_names"] = _childrenNamesController.text.trim();
      }

      try {
        final dio = await AuthService.authedDio();
        final response = await dio.post(
          "${AuthService.baseUrl}sailorform/",
          data: sailorData,
        );

        Navigator.of(context).pop(); // Close loading dialog

        if (response.statusCode == 201 || response.statusCode == 200) {
          await UserProfileService.setNotFirstTime();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AvatarSelectionScreen(userEmail: widget.userEmail),
              ),
            );
          }
        } else {
          _showErrorSnackBar('Failed to save profile: ${response.statusCode}');
        }
      } catch (e) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showValidationAlert(List<String> missingFields) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange.shade600,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Missing Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please fill in the following required fields:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ...missingFields.map(
                  (field) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            field,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F7FA),
      body: GestureDetector(
        // Dismiss keyboard when tapping outside input fields
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/images/back.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Pages with keyboard-aware scrolling
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      // Dismiss keyboard when changing pages
                      FocusScope.of(context).unfocus();
                    },
                    children: [
                      _buildJourneyPage(context, widget.userEmail),
                      _buildBasicInfoPage(),
                      _buildContactInfoPage(),
                      _buildPersonalInfoPage(),
                    ],
                  ),
                ),

                // Keyboard-aware navigation section
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  // Adjust padding when keyboard is visible
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom > 0
                        ? 10 // Reduced padding when keyboard is visible
                        : 20, // Normal padding when keyboard is hidden
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Back/Next Navigation for pages 1-3
                      if (_currentPage > 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              // Back Button
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3498DB),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF3498DB,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(28),
                                    onTap: () {
                                      // Dismiss keyboard before navigation
                                      FocusScope.of(context).unfocus();
                                      _previousPage();
                                    },
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // Page Indicator
                              Row(
                                children: List.generate(_totalPages - 1, (
                                  index,
                                ) {
                                  final pageIndex = index + 1;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _currentPage == pageIndex
                                            ? const Color(0xFF3498DB)
                                            : const Color(0xFFBDC3C7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const Spacer(),

                              // Next/Complete Button
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _currentPage == _totalPages - 1
                                      ? const Color(0xFF27AE60)
                                      : const Color(0xFF3498DB),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (_currentPage == _totalPages - 1
                                                  ? const Color(0xFF27AE60)
                                                  : const Color(0xFF3498DB))
                                              .withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(28),
                                    onTap: () {
                                      // Dismiss keyboard before navigation
                                      FocusScope.of(context).unfocus();
                                      _nextPage();
                                    },
                                    child: Icon(
                                      _currentPage == _totalPages - 1
                                          ? Icons.check
                                          : Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Journey Page Navigation (first page)
                      if (_currentPage == 0)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _nextPage();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: const Color(
                                0xFF3498DB,
                              ).withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Let's Start your journey",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFF3498DB),
                                    size: 20,
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _basicInfoFormKey,
            child: Column(
              children: [
                const SizedBox(height: 5),
                // Header
                const Text(
                  'Sea Smart',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3498DB),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Anchor Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Image.asset(
                    'lib/assets/images/anc.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),

                // Description
                const Text(
                  'Tell us about yourself to get started\non your journey.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3498DB,
                            ).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(
                            color: Color(0xFFBDC3C7),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Color(0xFF3498DB),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Rank/Position Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rank/Position',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3498DB,
                            ).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: _rankController.text.isNotEmpty
                            ? _rankController.text
                            : null,
                        items: const [
                          DropdownMenuItem(
                            value: 'Captain',
                            child: Text('Captain'),
                          ),
                          DropdownMenuItem(
                            value: 'Chief Officer',
                            child: Text('Chief Officer'),
                          ),
                          DropdownMenuItem(
                            value: 'Second Officer',
                            child: Text('Second Officer'),
                          ),
                          // DropdownMenuItem(value: 'Third Officer', child: Text('Third Officer')),
                          // DropdownMenuItem(value: 'Chief Engineer', child: Text('Chief Engineer')),
                          // DropdownMenuItem(value: 'Second Engineer', child: Text('Second Engineer')),
                          // DropdownMenuItem(value: 'Third Engineer', child: Text('Third Engineer')),
                          // DropdownMenuItem(value: 'Fourth Engineer', child: Text('Fourth Engineer')),
                          // DropdownMenuItem(value: 'Chief Mate', child: Text('Chief Mate')),
                          // DropdownMenuItem(value: 'Second Mate', child: Text('Second Mate')),
                          // DropdownMenuItem(value: 'Third Mate', child: Text('Third Mate')),
                          // DropdownMenuItem(value: 'Deck Cadet', child: Text('Deck Cadet')),
                          // DropdownMenuItem(value: 'Engine Cadet', child: Text('Engine Cadet')),
                          // DropdownMenuItem(value: 'Able Seaman', child: Text('Able Seaman')),
                          // DropdownMenuItem(value: 'Ordinary Seaman', child: Text('Ordinary Seaman')),
                          // DropdownMenuItem(value: 'Bosun', child: Text('Bosun')),
                          // DropdownMenuItem(value: 'AB', child: Text('AB')),
                          // DropdownMenuItem(value: 'OS', child: Text('OS')),
                          // DropdownMenuItem(value: 'Cook', child: Text('Cook')),
                          // DropdownMenuItem(value: 'Steward', child: Text('Steward')),
                          // DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _rankController.text = value ?? '';
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Select Your Position',
                          hintStyle: TextStyle(
                            color: Color(0xFFBDC3C7),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.work_outline,
                            color: Color(0xFF3498DB),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Rank/Position is required';
                          }
                          return null;
                        },
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 16,
                        ),
                        dropdownColor: Colors.white,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF3498DB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Years of Experience Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Years of Experience',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3498DB,
                            ).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _yearsExperienceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Years',
                          hintStyle: TextStyle(
                            color: Color(0xFFBDC3C7),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.timeline,
                            color: Color(0xFF3498DB),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Years of Experience is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Company Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF3498DB,
                            ).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _companyController,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Company Name',
                          hintStyle: TextStyle(
                            color: Color(0xFFBDC3C7),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.business,
                            color: Color(0xFF3498DB),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Company Name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Extra space for navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Journey Page - Keyboard Friendly
  Widget _buildJourneyPage(BuildContext context, String userEmail) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/wel_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 3),

                // Welcome text
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 3),

                // App name
                const Text(
                  'Sea Smart',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 136, 190),
                  ),
                ),

                const SizedBox(height: 1),

                // Powered by text
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                // Blue container with tagline
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      0,
                      136,
                      190,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        0,
                        136,
                        190,
                      ).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Your safe harbor for\nlearning, support, & peace of mind',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 0, 136, 190),
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Description text
                Text(
                  'Sea Smart is your buddy at sea, helping you stay calm, connected, and continuously growing through every voyage.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // Illustration/Icon placeholder
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100.withAlpha(0),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        0,
                        136,
                        190,
                      ).withOpacity(0),
                      width: 2,
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom text
                Text(
                  'Before we set sail, let\'s ask a few quick questions. This helps us chart the best course for your wellness and support. ⚓',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Continue button
                // Container(
                //   width: double.infinity,
                //   height: 54,
                //   decoration: BoxDecoration(
                //     gradient: const LinearGradient(
                //       colors: [
                //         Color.fromARGB(255, 0, 136, 190),
                //         Color.fromARGB(255, 0, 120, 170),
                //       ],
                //     ),
                //     borderRadius: BorderRadius.circular(27),
                //     boxShadow: [
                //       BoxShadow(
                //         color: const Color.fromARGB(255, 0, 136, 190).withOpacity(0.3),
                //         blurRadius: 12,
                //         offset: const Offset(0, 4),
                //       ),
                //     ],
                //   ),
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.pushReplacement(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) =>
                //               OnboardingScreen(userEmail: userEmail),
                //         ),
                //       );
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.transparent,
                //       foregroundColor: Colors.white,
                //       shadowColor: Colors.transparent,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(27),
                //       ),
                //       elevation: 0,
                //     ),
                //     child: const Text(
                //       'Sail with Calm',
                //       style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              const SizedBox(height: 5),
              // Header
              const Text(
                'Sea Smart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3498DB),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Anchor Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                  //     blurRadius: 15,
                  //     offset: const Offset(0, 8),
                  //   ),
                  // ],
                ),
                child: Image.asset(
                  'lib/assets/images/anc.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),

              // Description
              const Text(
                'Share your details so we can stay connected\non your voyage.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).nextFocus();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Color(0xFF3498DB),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Phone Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phone (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Number',
                        hintStyle: TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: Color(0xFF3498DB),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Home Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _homeLocationController,
                      decoration: const InputDecoration(
                        hintText: 'Location',
                        hintStyle: TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.home_outlined,
                          color: Color(0xFF3498DB),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Extra space for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              const SizedBox(height: 5),
              // Header
              const Text(
                'Sea Smart',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3498DB),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Anchor Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                  //     blurRadius: 15,
                  //     offset: const Offset(0, 8),
                  //   ),
                  // ],
                ),
                child: Image.asset(
                  'lib/assets/images/anc.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),

              // Description
              const Text(
                'Personalize your voyage with a little info\nabout you.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Hobbies Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hobbies',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _hobbiesController,
                      decoration: const InputDecoration(
                        hintText: 'Interest',
                        hintStyle: TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.interests_outlined,
                          color: Color(0xFF3498DB),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Spouse Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spouse (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _spouseNameController,
                      decoration: const InputDecoration(
                        hintText: 'Spouse Name',
                        hintStyle: TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Color(0xFF3498DB),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Children Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Children (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _childrenNamesController,
                      decoration: const InputDecoration(
                        hintText: 'Child Name',
                        hintStyle: TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.child_care_outlined,
                          color: Color(0xFF3498DB),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100), // Extra space for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        enabled: enabled,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.7),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          errorStyle: const TextStyle(color: Colors.orange, fontSize: 12),
        ),
        cursorColor: Colors.white,
      ),
    );
  }
}
