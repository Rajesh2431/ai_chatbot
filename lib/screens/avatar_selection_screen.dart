import 'dart:ui';
import 'package:flutter/material.dart';
import 'avatar_detail_screen.dart';
import '../routes/circular_reveal_route.dart';
import '../services/avatar_service.dart';

class AvatarSelectionScreen extends StatefulWidget {
  final bool isChangingAvatar;
  final String userEmail;
  
  const AvatarSelectionScreen({
    super.key,
    this.isChangingAvatar = false,
    this.userEmail = '',
  });

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      resizeToAvoidBottomInset: false ,
      body: Container(
        decoration: BoxDecoration(
          // Add your background image here
          image: const DecorationImage(
            image: AssetImage('lib/assets/images/ava_sel.png'), // Replace with your background image
            fit: BoxFit.cover,
          ),
          // Fallback gradient if no background image
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Header Section
                const SizedBox(height: 40),
                
                // App Title
                Text(
                  'Sea Smart',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    letterSpacing: 1.2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Powered by text
                Text(
                  'Powered by StriveHigh',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Main Title
                Text(
                  'Choose your companion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                
                const SizedBox(height: 100),
                
                // Avatar Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: AvatarService.availableAvatars.map((avatar) {
                    return GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        final Offset tapPosition = details.globalPosition;

                        Navigator.of(context).push(
                          CircularRevealRoute(
                            page: AvatarDetailScreen(
                              imagePath: avatar['image']!,
                              name: avatar['name']!,
                              isChangingAvatar: widget.isChangingAvatar,
                              userEmail: widget.userEmail,
                            ),
                            centerAlignment: tapPosition,
                            startRadius: 80.0,
                            revealColor: Colors.teal.shade300,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // Avatar Circle - Large size
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.lightBlue.shade100,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                avatar['image']!,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Avatar Name
                          Text(
                            avatar['name']!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 100),
                
                // Description Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Pick the buddy who'll sail alongside you on this journey. Each one is here to guide, support, and grow with you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Bottom indicator (optional)
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}