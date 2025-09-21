import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
  
class WelcomeScreen extends StatelessWidget {
  final String userEmail;

  const WelcomeScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: Colors.white,
      body: Container(decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("lib/assets/images/wel.png"), 
          fit: BoxFit.cover)
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
                  color: Color.fromARGB(255, 0, 136, 190).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color.fromARGB(255, 0, 136, 190).withOpacity(0.2),
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
                  color: const Color.fromARGB(255, 0, 136, 190).withOpacity(0),
                  width: 2,
                ),
              ),
              // child: ClipRRect(
              //   //borderRadius: BorderRadius.circular(100), // keeps it circular
              //   child: Image.asset(
              //     "lib/assets/images/wel.png", // replace with your image path
              //     fit: BoxFit.cover,
              //     height: 200,
              //     width: double.infinity,
  
              //   ),
              // ),
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
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 136, 190),
                      Color.fromARGB(255, 0, 120, 170),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 0, 136, 190).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to next screen (questionnaire or login)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingScreen(userEmail: userEmail),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sail with Calm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// Custom painter for wave lines
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 0, 136, 190)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.quadraticBezierTo(
      size.width * 0.25, size.height * 0.1,
      size.width * 0.5, size.height * 0.3,
    );
    path1.quadraticBezierTo(
      size.width * 0.75, size.height * 0.5,
      size.width, size.height * 0.3,
    );

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.25, size.height * 0.5,
      size.width * 0.5, size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.75, size.height * 0.9,
      size.width, size.height * 0.7,
    );

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}