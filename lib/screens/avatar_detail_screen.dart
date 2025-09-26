import 'package:flutter/material.dart';
import '../routes/circular_reveal_route.dart';
import '../services/avatar_service.dart';
import '../services/mood_service.dart';
import 'soarcardinfo_screen.dart';

class AvatarDetailScreen extends StatelessWidget {
  final String imagePath;
  final String name;
  final bool isChangingAvatar;
  final String userEmail;

  const AvatarDetailScreen({
    super.key,
    required this.imagePath,
    required this.name,
    this.isChangingAvatar = false,
    this.userEmail = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        220,
        239,
        248,
      ), // Light blue background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Welcome to SeaSmart title
              const Text(
                'Sea Smart',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 124, 178, 239), // Dark blue
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              const Text(
                'Powered by StriveHigh',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 114, 114, 114), // Dark blue
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
                        // Enhanced GIF animation support
                        gaplessPlayback: true,
                        isAntiAlias: true,
                        filterQuality: FilterQuality.high,
                        // Ensure GIF animations loop properly
                        repeat: ImageRepeat.noRepeat,
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

                    if (isChangingAvatar) {
                      // Just changing avatar - return to previous screen with success result
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                      return;
                    }

                    // Original onboarding flow - check if daily check-in is needed
                    final needsCheckin = await MoodService.needsDailyCheckin();

                    final size = MediaQuery.of(context).size;
                    final center = Offset(size.width / 2, size.height / 2);

                    // Navigate to SOAR Card
                    Navigator.of(context).pushReplacement(
                      CircularRevealRoute(
                        page: SOARProfileIntroScreen(userEmail: userEmail),
                        centerAlignment: center,
                        startRadius: 0,
                        revealColor: const Color(0xFF1976D2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      26,
                      148,
                      197,
                    ), // Blue button
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    isChangingAvatar ? 'Select Avatar' : 'Get Started',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
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
