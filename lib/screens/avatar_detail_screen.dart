import 'package:flutter/material.dart';
import '../routes/circular_reveal_route.dart';
import '../services/avatar_service.dart';
import '../services/mood_service.dart';
import 'dashboard_screen.dart';
import 'daily_checkin_screen.dart';

class AvatarDetailScreen extends StatelessWidget {
  final String imagePath;
  final String name;

  const AvatarDetailScreen({
    super.key,
    required this.imagePath,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Welcome to SeaSmart title
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1565C0), // Dark blue
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const Text(
                'SeaSmart',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0), // Dark blue
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Avatar image in center (supports GIF animation)
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 280,
                      maxHeight: 400,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        // This ensures GIF animations play properly
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),

              // Description text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'This is a safe, private space to get mental health support.',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF424242), // Dark gray
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 50),

              // Get Started button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    // Save avatar selection using AvatarService
                    await AvatarService.saveAvatarSelection(name, imagePath);

                    if (!context.mounted) return;

                    // Check if daily check-in is needed
                    final needsCheckin = await MoodService.needsDailyCheckin();

                    final size = MediaQuery.of(context).size;
                    final center = Offset(size.width / 2, size.height / 2);

                    if (needsCheckin) {
                      // Navigate to daily check-in first
                      Navigator.of(context).pushReplacement(
                        CircularRevealRoute(
                          page: DailyCheckinScreen(
                            avatarName: name,
                            avatarImage: imagePath,
                          ),
                          centerAlignment: center,
                          startRadius: 0,
                          revealColor: const Color(0xFF1976D2),
                        ),
                      );
                    } else {
                      // Go directly to dashboard
                      Navigator.of(context).pushReplacement(
                        CircularRevealRoute(
                          page: const DashboardScreen(),
                          centerAlignment: center,
                          startRadius: 0,
                          revealColor: const Color(0xFF1976D2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2), // Blue button
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
