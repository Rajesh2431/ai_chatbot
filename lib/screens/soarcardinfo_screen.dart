import 'package:flutter/material.dart';
import 'soar_card.dart';

class SOARProfileIntroScreen extends StatefulWidget {
  const SOARProfileIntroScreen({super.key, required String userEmail});

  @override
  State<SOARProfileIntroScreen> createState() => _SOARProfileIntroScreenState();
}

class _SOARProfileIntroScreenState extends State<SOARProfileIntroScreen> {
  String? get userEmail => null;

  // Helper method to determine if device is tablet
  bool _isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600; // Tablets typically have shortestSide >= 600
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = _isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with world map background
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
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: _getResponsiveValue(
                        context: context,
                        mobile: 16.0,
                        tablet: 24.0,
                      ),
                    ),

                    // Subtitle
                    _buildSubtitle(context),

                    SizedBox(
                      height: _getResponsiveValue(
                        context: context,
                        mobile: 30.0,
                        tablet: 40.0,
                      ),
                    ),

                    // Character illustrations
                    _buildCharacterIllustrations(context),

                    SizedBox(
                      height: _getResponsiveValue(
                        context: context,
                        mobile: 30.0,
                        tablet: 40.0,
                      ),
                    ),

                    // Description text
                    _buildDescriptionText(context),

                    SizedBox(
                      height: _getResponsiveValue(
                        context: context,
                        mobile: 30.0,
                        tablet: 40.0,
                      ),
                    ),

                    // Disclaimer text
                    _buildDisclaimerText(context),

                    SizedBox(
                      height: _getResponsiveValue(
                        context: context,
                        mobile: 38.0,
                        tablet: 48.0,
                      ),
                    ),

                    // Ready button
                    _buildReadyButton(context),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
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
          mobile: 24.0,
          tablet: 32.0,
        ),
      ),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('lib/assets/images/world.png'),
          fit: BoxFit.cover,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // World map pattern overlay
          SizedBox(
            height: _getResponsiveValue(
              context: context,
              mobile: 40.0,
              tablet: 60.0,
            ),
            width: double.infinity,
          ),

          SizedBox(
            height: _getResponsiveValue(
              context: context,
              mobile: 16.0,
              tablet: 24.0,
            ),
          ),

          // Main title
          Text(
            "LET'S START BUILDING\nYOUR SOAR PROFILE",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveValue(
                context: context,
                mobile: 24.0,
                tablet: 32.0,
              ),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      "Strength, Opportunities,\nAspirations & Recommendation",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: _getResponsiveValue(
          context: context,
          mobile: 20.0,
          tablet: 26.0,
        ),
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2C3E50),
        height: 1.3,
      ),
    );
  }

  Widget _buildCharacterIllustrations(BuildContext context) {
    final isTablet = _isTablet(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCharacter(
          isLeft: true,
          context: context,
          scale: isTablet ? 1.3 : 0.8,
        ),
        _buildCharacter(
          isLeft: false,
          context: context,
          scale: isTablet ? 1.3 : 0.8,
        ),
      ],
    );
  }

  Widget _buildCharacter({
    required bool isLeft,
    required BuildContext context,
    double scale = 1.0,
  }) {
    // Choose asset based on side
    String assetPath = isLeft
        ? 'lib/assets/avatar/AI_Avatar2.png'
        : 'lib/assets/avatar/AI_Avatar.png';

    final characterWidth = _getResponsiveValue(
      context: context,
      mobile: 140.0,
      tablet: 200.0,
    );

    final characterHeight = _getResponsiveValue(
      context: context,
      mobile: 160.0,
      tablet: 230.0,
    );

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: characterWidth,
        height: characterHeight,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person,
                size: _getResponsiveValue(
                  context: context,
                  mobile: 50.0,
                  tablet: 70.0,
                ),
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDescriptionText(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        _getResponsiveValue(context: context, mobile: 20.0, tablet: 28.0),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        "SOAR card is like a map. It shows your strengths, your goals, and where you want to head. Once you answer a few questions, I'll use it to personalize your journey, from courses you take to the support I provide whenever you need it. Think of it as your personal compass at sea designed to keep you steady.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _getResponsiveValue(
            context: context,
            mobile: 16.0,
            tablet: 20.0,
          ),
          color: const Color(0xFF2C3E50),
          height: 1.5,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDisclaimerText(BuildContext context) {
    return Text(
      "*No right or wrong answers; just your story.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: _getResponsiveValue(
          context: context,
          mobile: 14.0,
          tablet: 16.0,
        ),
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildReadyButton(BuildContext context) {
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QuizPage(userEmail: userEmail),
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
          "I'm Ready",
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
