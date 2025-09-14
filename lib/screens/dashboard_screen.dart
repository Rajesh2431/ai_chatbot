import 'dart:io';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'chat_screen.dart';
import 'journal_screen.dart';
import 'setting_screen.dart';
import 'tap_the_calm_game.dart';
//import 'quiz_screen.dart';
import 'breathing_timer.dart';
import 'memory_game.dart';
import 'mood_analytics_screen.dart';
import 'user_profile_screen.dart';
import 'grow_screen.dart';

import '../widgets/ai_drawer.dart';
import '../services/mood_service.dart';
import '../services/user_profile_service.dart';
import '../services/avatar_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const _HomeContent(),
    const JournalScreen(),
    const GrowScreen(),
    const SettingsScreen(),
  ];

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const AIDrawer(),
      body: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50,
        backgroundColor: Colors.white,
        color: const Color(0xFF5DC1F3),
        buttonBackgroundColor: const Color(0xFF4A90E2),
        animationDuration: const Duration(milliseconds: 300),
        animationCurve: Curves.easeInOut,
        items: [
          // Home
          _selectedIndex == 0
              ? const Icon(Icons.home, size: 32, color: Colors.white)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home, size: 24, color: Colors.white),
                    SizedBox(height: 2),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
          // Journal
          _selectedIndex == 1
              ? const Icon(Icons.book_rounded, size: 32, color: Colors.white)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.book_rounded, size: 24, color: Colors.white),
                    SizedBox(height: 2),
                    Text(
                      'Journal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
          // Quiz
          _selectedIndex == 2
              ? const Icon(Icons.quiz_rounded, size: 32, color: Colors.white)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.quiz_rounded, size: 24, color: Colors.white),
                    SizedBox(height: 2),
                    Text(
                      'Quiz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
          // Settings
          _selectedIndex == 3
              ? const Icon(Icons.settings, size: 32, color: Colors.white)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings, size: 24, color: Colors.white),
                    SizedBox(height: 2),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ],
        onTap: _onMenuTap,
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String _userName = 'User';
  String? _userAvatarPath;
  String _aiAvatarName = 'Saira';
  String _aiAvatarImage = 'lib/assets/avatar/saira.png';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadAIAvatar();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserProfileService.getUserProfile();
      if (mounted) {
        setState(() {
          _userName = profile['name']?.isNotEmpty == true
              ? profile['name']!
              : 'User';
          _userAvatarPath = profile['avatarPath'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _loadAIAvatar() async {
    try {
      final selectedAvatar = await AvatarService.getSelectedAvatar();
      if (selectedAvatar != null && mounted) {
        setState(() {
          _aiAvatarName = selectedAvatar['name']!;
          _aiAvatarImage = selectedAvatar['image']!;
        });
      }
    } catch (e) {
      debugPrint('Error loading AI avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: AI Menu and User Profile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // AI Menu icon
              IconButton(
                icon: const Icon(
                  Icons.smart_toy,
                  color: Color(0xFF4A90E2),
                  size: 28,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: 'AI Settings',
              ),
              // User profile icon (clickable)
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadUserProfile();
                    _loadAIAvatar();
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _userAvatarPath != null
                        ? (_userAvatarPath!.startsWith('lib/assets/'))
                              ? Image.asset(
                                  _userAvatarPath!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: Color(0xFF4A90E2),
                                    size: 28,
                                  ),
                                )
                              : Image.file(
                                  File(_userAvatarPath!),
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: Color(0xFF4A90E2),
                                    size: 28,
                                  ),
                                )
                        : const Icon(
                            Icons.person,
                            color: Color(0xFF4A90E2),
                            size: 28,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // AI Avatar Greeting Card
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4FC3F7), // Light blue
                  Color(0xFF29B6F6), // Medium blue
                  Color(0xFF0288D1), // Darker blue
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative elements (bubbles/coral effect)
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: -30,
                  right: 50,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: -10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Left side - Greeting text
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hi',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'I\'m $_aiAvatarName, your AI companion',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right side - AI Avatar (Bigger)
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ClipOval(
                                child: Image.asset(
                                  _aiAvatarImage,
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  errorBuilder: (_, __, ___) => Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.smart_toy,
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chat With AI Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              height: 120,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Animated GIF background
                    Image.asset(
                      'lib/assets/videos/calm_bg1.gif',
                      fit: BoxFit.cover,
                    ),
                    // Text overlay
                    Container(
                      padding: const EdgeInsets.all(18),
                      alignment: Alignment.center,
                      child: const Text(
                        'Chat With AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Mood Analytics Section - Clickable
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MoodAnalyticsScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mood Analytics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF42A5F5),
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            'View Details',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Mood indicator arrow
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 30,
                  ),
                  const SizedBox(height: 15),
                  // Mood scale
                  FutureBuilder<int>(
                    future: MoodService.getCurrentMoodLevel(),
                    builder: (context, snapshot) {
                      final currentLevel = snapshot.data ?? 3;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MoodIndicator(
                            color: Colors.green[400]!,
                            isActive: currentLevel >= 6,
                          ),
                          _MoodIndicator(
                            color: Colors.green[300]!,
                            isActive: currentLevel >= 5,
                          ),
                          _MoodIndicator(
                            color: Colors.yellow[600]!,
                            isActive: currentLevel >= 4,
                          ),
                          _MoodIndicator(
                            color: Colors.orange[500]!,
                            isActive: currentLevel >= 3,
                          ),
                          _MoodIndicator(
                            color: Colors.red[500]!,
                            isActive: currentLevel >= 2,
                          ),
                          _MoodIndicator(
                            color: Colors.red[700]!,
                            isActive: currentLevel >= 1,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  // Mood labels
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Very Good',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Good',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Poor',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Games Section
          const Text(
            'Activities',
            style: TextStyle(
              color: Color(0xFF6EC1E4),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            children: [
              _GameTile(
                title: 'Tap the Calm',
                backgroundImage: 'lib/assets/icons/game_bg.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GridCalmGame()),
                ),
              ),
              _GameTile(
                title: 'Breathing',
                backgroundImage: 'lib/assets/icons/breathing_bg.jpg',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BreathingScreen()),
                ),
              ),
              _GameTile(
                title: 'Memory Game',
                backgroundImage: 'lib/assets/icons/game3.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoryGame()),
                ),
              ),
              _GameTile(
                title: 'x',
                backgroundImage: 'lib/assets/icons/game4.png',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodIndicator extends StatelessWidget {
  final Color color;
  final bool isActive;

  const _MoodIndicator({required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String backgroundImage;

  const _GameTile({
    required this.title,
    required this.onTap,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(backgroundImage, fit: BoxFit.cover),
            // Optional dark overlay
            Container(color: Colors.black.withValues(alpha: 0.25)),
            // Icon + Text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videogame_asset,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
