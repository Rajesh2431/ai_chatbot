import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'chat_screen.dart';
import 'journal_screen.dart';
import 'setting_screen.dart';
import 'tap_the_calm_game.dart';
import 'quiz_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _HomeContent(),
    JournalScreen(),
    QuizScreen(),
    SettingsScreen(),
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
          bottomNavigationBar: Container(
            color: Colors.white,
            child: CurvedNavigationBar(
              index: _selectedIndex,
              height: 60,
              backgroundColor: Colors.white,
              color: const Color(0xFF97CAE4),
              animationDuration: const Duration(milliseconds: 300),
              items: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 28, color: Colors.white),
                    if (_selectedIndex != 0)
                      const SizedBox(height: 2),
                    if (_selectedIndex != 0)
                      const Text('Home', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.book_rounded, size: 28, color: Colors.white),
                    if (_selectedIndex != 1)
                      const SizedBox(height: 2),
                    if (_selectedIndex != 1)
                      const Text('Journal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_rounded, size: 28, color: Colors.white),
                    if (_selectedIndex != 2)
                      const SizedBox(height: 2),
                    if (_selectedIndex != 2)
                      const Text('Quiz', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.settings, size: 28, color: Colors.white),
                    if (_selectedIndex != 3)
                      const SizedBox(height: 2),
                    if (_selectedIndex != 3)
                      const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
              onTap: _onMenuTap,
            ),
          ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              CircleAvatar(
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
                image: AssetImage('lib/assets/icons/ocean_bg.png'), // Replace with your image
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Hi\nCaptain!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2,2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Chat With AI Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF97CAE4),
                padding: const EdgeInsets.symmetric(vertical: 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Chat With AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Games Section
          const Text(
            'Games',
            style: TextStyle(
              color: Color(0xFF6EC1E4),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.1,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: [
              _GameTile(
                title: 'Tap the Calm',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GridCalmGame()),
                ),
              ),
              _GameTile(title: 'Game Name', onTap: () {}),
              _GameTile(title: 'Game Name', onTap: () {}),
              _GameTile(title: 'Game Name', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _GameTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videogame_asset, color: Color(0xFF6EC1E4), size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
