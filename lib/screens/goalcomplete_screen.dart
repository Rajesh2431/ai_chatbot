import 'package:flutter/material.dart';
import 'moodinfo_screen.dart';
import 'soar_card.dart';

class GoalCompletedScreen extends StatefulWidget {
  const GoalCompletedScreen({super.key, required String userEmail});

  @override
  State<GoalCompletedScreen> createState() => _GoalCompletedScreen();
}

class _GoalCompletedScreen extends State<GoalCompletedScreen>
    with TickerProviderStateMixin {
  String? get userEmail => null;

  late AnimationController _rippleController;
  late AnimationController _tickController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<double> _rippleAnimation;
  late Animation<double> _tickAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _tickController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Setup animations
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _tickAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tickController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.bounceOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _rippleController.repeat();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      _tickController.forward();
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _tickController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Main content
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _getResponsiveValue(
                    context: context,
                    mobile: 24.0,
                    tablet: 48.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Animated Center Circle with Tick
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildAnimatedCenterTick(context),
                        );
                      },
                    ),

                    SizedBox(
                      height: _getResponsiveValue(
                        context: context,
                        mobile: 60.0,
                        tablet: 80.0,
                      ),
                    ),

                    // Goal complete text
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Text(
                            "Goal setting\ncompleted",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _getResponsiveValue(
                                context: context,
                                mobile: 24.0,
                                tablet: 32.0,
                              ),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                              height: 1.3,
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),

            // Next button at bottom
            _buildNextButton(context),

            SizedBox(
              height: _getResponsiveValue(
                context: context,
                mobile: 24.0,
                tablet: 32.0,
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
        vertical: _getResponsiveValue(
          context: context,
          mobile: 32.0,
          tablet: 40.0,
        ),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        "GOAL!",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _getResponsiveValue(
            context: context,
            mobile: 24.0,
            tablet: 32.0,
          ),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildAnimatedCenterTick(BuildContext context) {
    final size = _getResponsiveValue(
      context: context,
      mobile: 280.0,
      tablet: 350.0,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated ripple circles (outermost)
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outermost ripple
                  Transform.scale(
                    scale: 1.0 + (_rippleAnimation.value * 0.2),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                          0xFF4FC3F7,
                        ).withOpacity(0.05 * (1.0 - _rippleAnimation.value)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Static concentric circles (matching the image)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4FC3F7).withOpacity(0.08),
            ),
          ),
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4FC3F7).withOpacity(0.12),
            ),
          ),
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF29B6F6).withOpacity(0.15),
            ),
          ),
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2196F3).withOpacity(0.18),
            ),
          ),
          Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1976D2).withOpacity(0.22),
            ),
          ),

          // Central white circle with animated scale
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Inner blue circle
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: size * 0.18,
                  height: size * 0.18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2196F3),
                  ),
                ),
              );
            },
          ),

          // Animated checkmark
          AnimatedBuilder(
            animation: _tickAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _tickAnimation.value,
                child: Container(
                  width: size * 0.18,
                  height: size * 0.18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2196F3),
                  ),
                  child: CustomPaint(
                    painter: CheckmarkPainter(
                      progress: _tickAnimation.value,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveValue(
          context: context,
          mobile: 24.0,
          tablet: 48.0,
        ),
      ),
      child: Container(
        width: double.infinity,
        height: _getResponsiveValue(
          context: context,
          mobile: 56.0,
          tablet: 64.0,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MoodMeterInfoScreen(userEmail: '',)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for the animated checkmark
class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final checkPath = Path();

    // Define checkmark points
    final startPoint = Offset(center.dx - size.width * 0.2, center.dy);
    final middlePoint = Offset(
      center.dx - size.width * 0.05,
      center.dy + size.height * 0.15,
    );
    final endPoint = Offset(
      center.dx + size.width * 0.25,
      center.dy - size.height * 0.15,
    );

    if (progress > 0) {
      // First stroke (start to middle)
      if (progress <= 0.5) {
        final firstProgress = progress * 2;
        final currentPoint = Offset(
          startPoint.dx + (middlePoint.dx - startPoint.dx) * firstProgress,
          startPoint.dy + (middlePoint.dy - startPoint.dy) * firstProgress,
        );

        checkPath.moveTo(startPoint.dx, startPoint.dy);
        checkPath.lineTo(currentPoint.dx, currentPoint.dy);
      } else {
        // Second stroke (middle to end)
        final secondProgress = (progress - 0.5) * 2;
        final currentPoint = Offset(
          middlePoint.dx + (endPoint.dx - middlePoint.dx) * secondProgress,
          middlePoint.dy + (endPoint.dy - middlePoint.dy) * secondProgress,
        );

        checkPath.moveTo(startPoint.dx, startPoint.dy);
        checkPath.lineTo(middlePoint.dx, middlePoint.dy);
        checkPath.lineTo(currentPoint.dx, currentPoint.dy);
      }

      canvas.drawPath(checkPath, paint);
    }
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
