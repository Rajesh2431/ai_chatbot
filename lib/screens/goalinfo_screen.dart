import 'package:flutter/material.dart';

import 'goal_settings.dart';

class GoalInfoScreen extends StatefulWidget {
  const GoalInfoScreen({super.key, required this.userEmail});

  final String? userEmail;

  @override
  State<GoalInfoScreen> createState() => _SmartGoalScreenState();
}

class _SmartGoalScreenState extends State<GoalInfoScreen> {
  // Helper method to determine if device is tablet
  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  // Get responsive values based on device type
  double _getResponsiveValue({
    required BuildContext context,
    required double mobile,
    required double tablet,
  }) {
    return _isTablet(context) ? tablet : mobile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // optional, gets covered by image
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 Background image
            Positioned.fill(
              child: Image.asset(
                "lib/assets/icons/goalinfo_bg.png", // your asset path
                fit: BoxFit.cover, // cover the whole screen
              ),
            ),

            // 🔹 Main content stays on top
            Column(
              children: [
                // Header with gradient background
                _buildHeader(context),

                // Main content
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getResponsiveValue(
                        context: context,
                        mobile: 24.0,
                        tablet: 48.0,
                      ),
                      vertical: 32.0,
                    ),
                    child: Column(
                      children: [
                        // Center illustration with background circle
                        // _buildCenterIllustration(context),
                        SizedBox(
                          height: _getResponsiveValue(
                            context: context,
                            mobile: 450.0,
                            tablet: 50.0,
                          ),
                        ),

                        // Description text
                        _buildDescriptionText(context),

                        const Spacer(),

                        // Next button
                        _buildNextButton(context),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveValue(
          context: context,
          mobile: 24.0,
          tablet: 48.0,
        ),
        vertical: _getResponsiveValue(
          context: context,
          mobile: 40.0,
          tablet: 50.0,
        ),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
        ),
      ),
      child: Text(
        "SETTING GOAL",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _getResponsiveValue(
            context: context,
            mobile: 28.0,
            tablet: 36.0,
          ),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  // Widget _buildCenterIllustration(BuildContext context) {
  //   final illustrationSize = _getResponsiveValue(
  //     context: context,
  //     mobile: 280.0,
  //     tablet: 360.0,
  //   );

  //   return Container(
  //     width: illustrationSize,
  //     height: illustrationSize,
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         // Background circle with light blue color
  //         Container(
  //           width: illustrationSize,
  //           height: illustrationSize,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: const Color(0xFFE3F2FD).withOpacity(0.6),
  //           ),
  //         ),

  //         // Secondary background circle
  //         Container(
  //           width: illustrationSize * 0.8,
  //           height: illustrationSize * 0.8,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: const Color(0xFFE3F2FD).withOpacity(0.8),
  //           ),
  //         ),

  //         // PNG Image
  //         Container(
  //           width: illustrationSize * 0.7,
  //           height: illustrationSize * 0.7,
  //           child: Image.asset(
  //             '', // Replace with your PNG path
  //             fit: BoxFit.contain,
  //             errorBuilder: (context, error, stackTrace) {
  //               return Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade200,
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 child: Icon(
  //                   Icons.trending_up,
  //                   size: _getResponsiveValue(
  //                     context: context,
  //                     mobile: 80.0,
  //                     tablet: 120.0,
  //                   ),
  //                   color: const Color(0xFF29B6F6),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGoalItem(BuildContext context, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Container(
            width: _getResponsiveValue(
              context: context,
              mobile: 16.0,
              tablet: 20.0,
            ),
            height: _getResponsiveValue(
              context: context,
              mobile: 16.0,
              tablet: 20.0,
            ),
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF29B6F6) : Colors.transparent,
              border: Border.all(color: const Color(0xFF29B6F6), width: 2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: _getResponsiveValue(
                context: context,
                mobile: 3.0,
                tablet: 4.0,
              ),
              decoration: BoxDecoration(
                color: isChecked
                    ? const Color(0xFF29B6F6)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: _getResponsiveValue(
            context: context,
            mobile: 20.0,
            tablet: 20.0,
          ),
          color: const Color(0xFF2C3E50),
          height: 1.5,
          letterSpacing: 0.3,
        ),
        children: [
          const TextSpan(text: "Based on the insights from your "),
          TextSpan(
            text: "SOAR",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const TextSpan(
            text:
                " Card, we've identified personalized goals to support your skill development and help you grow both professionally and personally",
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final buttonWidth = _isTablet(context)
        ? MediaQuery.of(context).size.width * 0.6
        : double.infinity;

    return Container(
      width: buttonWidth,
      height: _getResponsiveValue(context: context, mobile: 55.0, tablet: 65.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF29B6F6), Color(0xFF03A9F4)],
        ),
        borderRadius: BorderRadius.circular(
          _getResponsiveValue(context: context, mobile: 27.5, tablet: 32.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to next screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GoalPage(userEmail: widget.userEmail),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              _getResponsiveValue(context: context, mobile: 27.5, tablet: 32.5),
            ),
          ),
        ),
        child: Text(
          "Next",
          style: TextStyle(
            fontSize: _getResponsiveValue(
              context: context,
              mobile: 18.0,
              tablet: 22.0,
            ),
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
