import 'package:SeaSmart/screens/daily_checkin_screen.dart';
import 'package:flutter/material.dart';

class MoodMeterInfoScreen extends StatefulWidget {
  const MoodMeterInfoScreen({super.key, required this.userEmail});

  final String? userEmail;

  @override
  State<MoodMeterInfoScreen> createState() => _MoodMeterScreenState();
}

class _MoodMeterScreenState extends State<MoodMeterInfoScreen> {
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
      backgroundColor: Colors.white, // can be removed since image covers it
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 Background image
            Positioned.fill(
              child: Image.asset(
                "lib/assets/images/moodinfo.png", // replace with your asset
                fit: BoxFit.cover,
              ),
            ),

            // 🔹 Main content on top
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
                        // Center illustration with mood meter
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

                        // Get Started button
                        _buildGetStartedButton(context),

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
        "MOOD METER",
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
  //     mobile: 300.0,
  //     tablet: 380.0,
  //   );

  //   return Container(
  //     width: illustrationSize,
  //     height: illustrationSize,
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         // Main background circle with light blue color
  //         Container(
  //           width: illustrationSize,
  //           height: illustrationSize,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: const Color(0xFFE3F2FD).withOpacity(0.4),
  //           ),
  //         ),

  //         // Secondary background circle
  //         Container(
  //           width: illustrationSize * 0.85,
  //           height: illustrationSize * 0.85,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: const Color(0xFFE3F2FD).withOpacity(0.6),
  //           ),
  //         ),

  //         // Inner background circle
  //         Container(
  //           width: illustrationSize * 0.7,
  //           height: illustrationSize * 0.7,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: const Color(0xFFE3F2FD).withOpacity(0.8),
  //           ),
  //         ),

  //         // Hand illustration (pink/coral colored hand pointing up)
  //         Positioned(
  //           bottom: illustrationSize * 0.15,
  //           child: Container(
  //             width: illustrationSize * 0.35,
  //             height: illustrationSize * 0.5,
  //             child: CustomPaint(
  //               painter: HandPainter(),
  //             ),
  //           ),
  //         ),

  //         // Mood cards/emotions floating above hand
  //         Positioned(
  //           top: illustrationSize * 0.15,
  //           left: illustrationSize * 0.15,
  //           child: _buildMoodCard(
  //             context: context,
  //             emoji: '😊',
  //             color: Colors.orange,
  //             size: _getResponsiveValue(context: context, mobile: 45.0, tablet: 55.0),
  //           ),
  //         ),

  //         Positioned(
  //           top: illustrationSize * 0.2,
  //           right: illustrationSize * 0.25,
  //           child: _buildMoodCard(
  //             context: context,
  //             emoji: '😐',
  //             color: Colors.grey.shade300,
  //             size: _getResponsiveValue(context: context, mobile: 40.0, tablet: 50.0),
  //           ),
  //         ),

  //         Positioned(
  //           top: illustrationSize * 0.12,
  //           right: illustrationSize * 0.1,
  //           child: _buildMoodCard(
  //             context: context,
  //             emoji: '😄',
  //             color: Colors.pink.shade100,
  //             size: _getResponsiveValue(context: context, mobile: 42.0, tablet: 52.0),
  //           ),
  //         ),

  //         // Small decorative plus signs
  //         Positioned(
  //           top: illustrationSize * 0.4,
  //           left: illustrationSize * 0.1,
  //           child: Icon(
  //             Icons.add,
  //             color: const Color(0xFF29B6F6).withOpacity(0.6),
  //             size: _getResponsiveValue(context: context, mobile: 16.0, tablet: 20.0),
  //           ),
  //         ),

  //         Positioned(
  //           bottom: illustrationSize * 0.35,
  //           right: illustrationSize * 0.08,
  //           child: Icon(
  //             Icons.add,
  //             color: const Color(0xFF29B6F6).withOpacity(0.6),
  //             size: _getResponsiveValue(context: context, mobile: 16.0, tablet: 20.0),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildMoodCard({
  //   required BuildContext context,
  //   required String emoji,
  //   required Color color,
  //   required double size,
  // }) {
  //   return Container(
  //     width: size,
  //     height: size * 0.8,
  //     decoration: BoxDecoration(
  //       color: color,
  //       borderRadius: BorderRadius.circular(8),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 8,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Center(
  //       child: Text(
  //         emoji,
  //         style: TextStyle(
  //           fontSize: size * 0.5,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDescriptionText(BuildContext context) {
    return Text(
      "Take a moment to reflect — how are you feeling today? This daily mood check helps us understand your emotional state and provide the right support to keep your mind calm and balanced at sea.",
      textAlign: TextAlign.center,
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
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
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
          // Navigate to mood selection screen
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
            borderRadius: BorderRadius.circular(
              _getResponsiveValue(context: context, mobile: 27.5, tablet: 32.5),
            ),
          ),
        ),
        child: Text(
          "Get's Started",
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

// Custom painter for the hand illustration
class HandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFFFB3BA) // Pink/coral color for hand
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw a simplified hand shape pointing upward
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
