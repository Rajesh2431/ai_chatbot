import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'chat_screen.dart';
import 'journal_screen.dart';
import 'setting_screen.dart';
import 'tap_the_calm_game.dart';
import 'quiz_screen.dart';
import 'breathing_timer.dart';
import 'memory_game.dart';
import 'mood_analytics_screen.dart';
import '../services/mood_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _HomeContent(),
    const JournalScreen(),
    const QuizScreen(),
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
      backgroundColor: Colors.white,
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

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Notification and Profile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Notification icon
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                onPressed: () {
                  // Add notification logic here
                },
              ),
              // Profile icon (changed to a generic person icon)
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, color: Color(0xFF4A90E2), size: 40),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Greeting Card
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                image: AssetImage(
                  'lib/assets/icons/ocean_bg.png',
                ), // Replace with your image
                fit: BoxFit.cover,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Hi\nCaptain!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
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
                backgroundImage: 'lib/assets/icons/game_bg.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoryGame()),
                ),
              ),
              _GameTile(
                title: 'Game Name',
                backgroundImage: 'lib/assets/images/game4.jpg',
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
