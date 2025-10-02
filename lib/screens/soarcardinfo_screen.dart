import 'package:flutter/material.dart';
import 'soar_card.dart';

class SOARProfileIntroScreen extends StatefulWidget {
  const SOARProfileIntroScreen({super.key, required String userEmail});

  @override
  State<SOARProfileIntroScreen> createState() => _SOARProfileIntroScreenState();
}

class _SOARProfileIntroScreenState extends State<SOARProfileIntroScreen> {
  String? get userEmail => null;

  // Enhanced device type detection
  DeviceType _getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = (size.width * size.width + size.height * size.height);

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header with world map background
                      _buildHeader(context),

                      // Main content
                      Expanded(
                        child: Container(
                          padding: _getResponsivePadding(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: _getResponsiveSpacing(context, 16.0),
                              ),

                              // Subtitle
                              _buildSubtitle(context),

                              SizedBox(
                                height: _getResponsiveSpacing(context, 24.0),
                              ),

                              // Character illustrations
                              _buildCharacterIllustrations(context),

                              SizedBox(
                                height: _getResponsiveSpacing(context, 24.0),
                              ),

                              // Description text
                              _buildDescriptionText(context),

                              SizedBox(
                                height: _getResponsiveSpacing(context, 20.0),
                              ),

                              // Disclaimer text
                              _buildDisclaimerText(context),

                              SizedBox(
                                height: _getResponsiveSpacing(context, 24.0),
                              ),

                              // Ready button
                              _buildReadyButton(context),

                              SizedBox(
                                height: _getResponsiveSpacing(context, 16.0),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final headerPadding = _getResponsivePadding(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: headerPadding.horizontal / 2,
        vertical: deviceType == DeviceType.mobile ? 24.0 : 32.0,
      ),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('lib/assets/images/world.png'),
          fit: BoxFit.cover,
          opacity: 0.3,
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
          SizedBox(height: _getResponsiveSpacing(context, 20.0)),

          // Main title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "LET'S START BUILDING\nYOUR SOAR PROFILE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 24.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
            ),
          ),

          SizedBox(height: _getResponsiveSpacing(context, 20.0)),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "Strength, Opportunities,\nAspirations & Recommendation",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 18.0),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterIllustrations(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate character size based on available width
    double characterWidth;
    double characterHeight;

    switch (deviceType) {
      case DeviceType.mobile:
        characterWidth = (screenWidth * 0.35).clamp(100.0, 140.0);
        characterHeight = characterWidth * 1.15;
        break;
      case DeviceType.tablet:
        characterWidth = (screenWidth * 0.25).clamp(160.0, 200.0);
        characterHeight = characterWidth * 1.15;
        break;
      case DeviceType.largeTablet:
        characterWidth = 220.0;
        characterHeight = 253.0;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCharacter(
          isLeft: true,
          context: context,
          width: characterWidth,
          height: characterHeight,
        ),
        _buildCharacter(
          isLeft: false,
          context: context,
          width: characterWidth,
          height: characterHeight,
        ),
      ],
    );
  }

  Widget _buildCharacter({
    required bool isLeft,
    required BuildContext context,
    required double width,
    required double height,
  }) {
    String assetPath = isLeft
        ? 'lib/assets/avatar/AI_Avatar2.png'
        : 'lib/assets/avatar/AI_Avatar.png';

    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.person, size: width * 0.4, color: Colors.grey),
          );
        },
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
      padding: EdgeInsets.all(_getResponsiveSpacing(context, 20.0)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        "SOAR card is like a map. It shows your strengths, your goals, and where you want to head. Once you answer a few questions, I'll use it to personalize your journey, from courses you take to the support I provide whenever you need it. Think of it as your personal compass at sea designed to keep you steady.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 15.0),
          color: const Color(0xFF2C3E50),
          height: 1.5,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDisclaimerText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        "*No right or wrong answers; just your story.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(context, 13.0),
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildReadyButton(BuildContext context) {
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
              builder: (context) => QuizPage(userEmail: userEmail),
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
          "I'm Ready",
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
