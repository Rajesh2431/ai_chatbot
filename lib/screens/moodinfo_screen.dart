import 'package:SeaSmart/screens/daily_checkin_screen.dart';
import 'package:flutter/material.dart';

class MoodMeterInfoScreen extends StatefulWidget {
  const MoodMeterInfoScreen({super.key, required this.userEmail});

  final String? userEmail;

  @override
  State<MoodMeterInfoScreen> createState() => _MoodMeterScreenState();
}

class _MoodMeterScreenState extends State<MoodMeterInfoScreen> {
  // Enhanced device type detection
  DeviceType _getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (size.shortestSide < 600) {
      return DeviceType.mobile;
    } else if (size.shortestSide < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.largeTablet;
    }
  }

  // Get responsive padding
  EdgeInsets _getResponsivePadding(BuildContext context) {
    final deviceType = _getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0);
      case DeviceType.largeTablet:
        return const EdgeInsets.symmetric(horizontal: 80.0, vertical: 32.0);
    }
  }

  // Get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseMobile) {
    final deviceType = _getDeviceType(context);
    final width = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.mobile:
        // Scale based on width for different mobile sizes
        return baseMobile * (width / 375).clamp(0.85, 1.15);
      case DeviceType.tablet:
        return baseMobile * 1.4;
      case DeviceType.largeTablet:
        return baseMobile * 1.6;
    }
  }

  // Get responsive spacing
  double _getResponsiveSpacing(BuildContext context, double baseMobile) {
    final deviceType = _getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseMobile;
      case DeviceType.tablet:
        return baseMobile * 1.5;
      case DeviceType.largeTablet:
        return baseMobile * 2.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "lib/assets/images/moodinfo.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey.shade100);
                },
              ),
            ),

            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header with gradient background
                          _buildHeader(context),

                          // Main content
                          Expanded(
                            child: Container(
                              padding: _getResponsivePadding(context),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Dynamic spacing based on screen height
                                  SizedBox(
                                    height: _getResponsiveTopSpacing(
                                      context,
                                      screenHeight,
                                      deviceType,
                                    ),
                                  ),

                                  // Description text
                                  _buildDescriptionText(context),

                                  const Spacer(),

                                  // Get Started button
                                  _buildGetStartedButton(context),

                                  SizedBox(
                                    height: _getResponsiveSpacing(
                                      context,
                                      24.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Calculate top spacing based on screen height and device type
  double _getResponsiveTopSpacing(
    BuildContext context,
    double screenHeight,
    DeviceType deviceType,
  ) {
    switch (deviceType) {
      case DeviceType.mobile:
        // For mobile, use a percentage of remaining height
        if (screenHeight < 700) {
          return screenHeight * 0.25; // Smaller phones
        } else if (screenHeight < 800) {
          return screenHeight * 0.35; // Medium phones
        } else {
          return screenHeight * 0.45; // Larger phones
        }
      case DeviceType.tablet:
        return screenHeight * 0.15;
      case DeviceType.largeTablet:
        return screenHeight * 0.12;
    }
  }

  Widget _buildHeader(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final headerPadding = _getResponsivePadding(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: headerPadding.horizontal / 2,
        vertical: deviceType == DeviceType.mobile ? 32.0 : 40.0,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "MOOD METER",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 28.0),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionText(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final maxWidth = deviceType == DeviceType.mobile
        ? double.infinity
        : MediaQuery.of(context).size.width * 0.8;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveSpacing(context, 16.0),
      ),
      child: Text(
        "Take a moment to reflect — how are you feeling today? This daily mood check helps us understand your emotional state and provide the right support to keep your mind calm and balanced at sea.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 18.0),
          color: const Color(0xFF2C3E50),
          height: 1.6,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double buttonWidth;
    switch (deviceType) {
      case DeviceType.mobile:
        buttonWidth = screenWidth * 0.85;
        break;
      case DeviceType.tablet:
        buttonWidth = screenWidth * 0.6;
        break;
      case DeviceType.largeTablet:
        buttonWidth = screenWidth * 0.4;
        break;
    }

    final buttonHeight = _getResponsiveSpacing(context, 54.0);
    final borderRadius = buttonHeight / 2;

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF29B6F6), Color(0xFF03A9F4)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  DailyCheckinScreen(userEmail: widget.userEmail),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          "Get Started",
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 18.0),
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

enum DeviceType { mobile, tablet, largeTablet }

// Custom painter for the hand illustration (preserved for future use)
class HandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFFFB3BA) // Pink/coral color for hand
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height;

    // Palm (oval shape)
    final palmRect = Rect.fromCenter(
      center: Offset(centerX, centerY * 0.75),
      width: size.width * 0.6,
      height: size.height * 0.4,
    );
    canvas.drawOval(palmRect, paint);

    // Thumb
    final thumbRect = Rect.fromCenter(
      center: Offset(centerX - size.width * 0.25, centerY * 0.65),
      width: size.width * 0.2,
      height: size.height * 0.25,
    );
    canvas.drawOval(thumbRect, paint);

    // Fingers
    for (int i = 0; i < 4; i++) {
      final fingerX = centerX - size.width * 0.2 + (i * size.width * 0.13);
      final fingerRect = Rect.fromCenter(
        center: Offset(fingerX, centerY * 0.4),
        width: size.width * 0.12,
        height: size.height * 0.35,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(fingerRect, const Radius.circular(15)),
        paint,
      );
    }

    // Wrist/arm
    final wristRect = Rect.fromCenter(
      center: Offset(centerX, centerY * 0.9),
      width: size.width * 0.4,
      height: size.height * 0.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(wristRect, const Radius.circular(10)),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
