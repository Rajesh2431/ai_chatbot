import 'dart:io';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../services/user_profile_service.dart';
import '../services/mood_service.dart';
import '../services/soar_card_service.dart';
import '../services/goal_service.dart';
import '../models/soar_card_answer.dart';
import 'breathing_timer.dart';
import 'tap_the_calm_game.dart';
import 'memory_game.dart';
import 'journal_screen.dart';
import 'mood_analytics_screen.dart';
import 'user_profile_screen.dart';
import 'soar_card.dart';
import 'goal_settings.dart';
import 'chat_screen.dart';
import 'setting_screen.dart';
import 'academy.dart';
import 'certificate_screen.dart';
import 'soar_card_analysis.dart';

class GrowScreen extends StatefulWidget {
  const GrowScreen({super.key});

  @override
  State<GrowScreen> createState() => _GrowScreenState();
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

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("journal")));
}

class CertificatePage extends StatelessWidget {
  const CertificatePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("certificates screen")));
}

class MoodPage extends StatelessWidget {
  const MoodPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("mood analytics screen")));
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Progress Report screen")));
}


class HorizontalCalendar extends StatelessWidget {
  const HorizontalCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70, // ✅ fixes overflow by limiting calendar height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10, // number of days
        itemBuilder: (context, index) {
          return Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              color: index == 0 ? const Color(0xFF3498DB) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: index == 0 ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day',
                  style: TextStyle(
                    fontSize: 12,
                    color: index == 0 ? Colors.white : Colors.black54,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



class _GrowScreenState extends State<GrowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedBottomIndex = 0; // Bottom navigation index
  String _userName = 'Name';
  String? _userAvatarPath;
  int _dayAtSea = 32;
  String _destination = 'USA';
  int _estimatedArrival = 4;
  double _wellnessScore = 30.0;
  List<SoarCardAnswer> _soarAnswers = [];
  List<dynamic> _userGoals = [];
  bool _loadingSoarData = true;
  bool _loadingGoals = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1,
    ); // Default to Grow tab
    _loadUserData();
    _loadSoarData();
    _loadGoalsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await UserProfileService.getUserProfile();
      final todaysMoodScore = await MoodService.getTodaysMoodScore();

      if (mounted) {
        setState(() {
          _userName = profile['name'] ?? 'Name';
          _userAvatarPath = profile['avatarPath'];
          _wellnessScore = todaysMoodScore;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadSoarData() async {
    try {
      final answers = await SoarCardService.loadSoarCardAnswers();
      if (mounted) {
        setState(() {
          _soarAnswers = answers;
          _loadingSoarData = false;
        });
      }
    } catch (e) {
      print('Error loading SOAR data: $e');
      if (mounted) {
        setState(() {
          _loadingSoarData = false;
        });
      }
    }
  }

  Future<void> _loadGoalsData() async {
    try {
      final result = await GoalService.getUserGoals();
      if (mounted) {
        setState(() {
          _userGoals = result['goals'] ?? [];
          _loadingGoals = false;
        });
      }
    } catch (e) {
      print('Error loading goals data: $e');
      if (mounted) {
        setState(() {
          _loadingGoals = false;
        });
      }
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _selectedBottomIndex == 0
          ? _buildGrowScreenContent() // Show grow screen content for home
          : _getPageForIndex(_selectedBottomIndex), // Show other pages
      // bottomNavigationBar: CurvedNavigationBar(
      //   index: _selectedBottomIndex,
      //   height: 50,
      //   backgroundColor: const Color(0xFFF8F9FA),
      //   color: const Color(0xFF5DC1F3),
      //   buttonBackgroundColor: const Color(0xFF4A90E2),
      //   animationDuration: const Duration(milliseconds: 300),
      //   animationCurve: Curves.easeInOut,
      //   items: [
      //     // Home (Grow Screen)
      //     _selectedBottomIndex == 0
      //         ? const Icon(Icons.home, size: 32, color: Colors.white)
      //         : const Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(Icons.home, size: 24, color: Colors.white),
      //               SizedBox(height: 2),
      //               Text(
      //                 'Home',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //     // Journal
      //     _selectedBottomIndex == 1
      //         ? const Icon(Icons.book_rounded, size: 32, color: Colors.white)
      //         : const Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(Icons.book_rounded, size: 24, color: Colors.white),
      //               SizedBox(height: 2),
      //               Text(
      //                 'Journal',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //     // Chat
      //     _selectedBottomIndex == 2
      //         ? const Icon(
      //             Icons.chat_bubble_rounded,
      //             size: 32,
      //             color: Colors.white,
      //           )
      //         : const Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(
      //                 Icons.chat_bubble_rounded,
      //                 size: 24,
      //                 color: Colors.white,
      //               ),
      //               SizedBox(height: 2),
      //               Text(
      //                 'Chat',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //     // Settings
      //     _selectedBottomIndex == 3
      //         ? const Icon(Icons.settings, size: 32, color: Colors.white)
      //         : const Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Icon(Icons.settings, size: 24, color: Colors.white),
      //               SizedBox(height: 2),
      //               Text(
      //                 'Settings',
      //                 style: TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 12,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ],
      //           ),
      //   ],
      //   onTap: _onBottomNavTap,
      // ),
    );
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 1:
        return const JournalScreen();
      case 2:
        return const ChatScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildGrowScreenContent();
    }
  }

  Widget _buildGrowScreenContent() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: const Color(0xFFF8F9FA),
            elevation: 0,
            floating: false,
            pinned: false,
            snap: false,
            expandedHeight: 300.0, // Compact header
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  // Header - positioned at very top
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 4,
                      20,
                      4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Profile Avatar
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _userAvatarPath != null
                                  ? (_userAvatarPath!.startsWith('lib/assets/'))
                                        ? Image.asset(
                                            _userAvatarPath!,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                  size: 24,
                                                ),
                                          )
                                        : Image.file(
                                            File(_userAvatarPath!),
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                  size: 24,
                                                ),
                                          )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),

                        // Title
                        Image.asset(
                          "lib/assets/images/strive.png", // your PNG file
                          height: 40, // adjust as needed
                          fit: BoxFit.contain,
                        ),

                        // Menu Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 1),

                  const Text("Sea Smart",
                  style: TextStyle(fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 53, 154, 255)
                  ),
                  ),

                  // User Info Card - more compact
                 
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage("lib/assets/images/wave_bg.png"), // your PNG file
                          fit: BoxFit.cover, // make it cover full background
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ready for today's journey, $_userName",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Stats Row 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _StatCard(
                                  value: '$_dayAtSea',
                                  label: 'Day is the Sea',
                                  color: const Color(0xFF3498DB),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  value: _destination,
                                  label: 'Destination',
                                  color: const Color(0xFF2ECC71),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 1),

                  // Horizontal Calendar
                    const HorizontalCalendar(), 
                ],
              ),
            ),
          ),
  
          // Sticky Tab Bar
          SliverPersistentHeader(
            delegate: _StickyTabBarDelegate(
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF3498DB),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Know'),
                    Tab(text: 'Grow'),
                    Tab(text: 'Show'),
                  ],
                ),
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKnowContent(),
          _buildGrowContent(),
          _buildShowContent(),
        ],
      ),
    );
  }

  // Content methods for each tab
  Widget _buildKnowContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Knowledge Base',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),

            // SOAR Card Tile
            _buildSoarCardTile(),
            const SizedBox(height: 16),

            // Goals Tile
            _buildGoalsTile(),
            const SizedBox(height: 16),

            const Text(
              'Wellness Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            _buildWellnessTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowContent() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Chat with Shipmate Section
          Container(
            width: double.infinity,
            height: 125,
            alignment: Alignment.bottomRight,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('lib/assets/images/chat.png'),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Wave pattern background
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image.asset(
                      //   "lib/assets/images/cap.png", // ⚓ your image path
                      //   height: 50,
                      //   width: 50,
                      //   fit: BoxFit.contain,
                      // ),
                      const SizedBox(height: 8),
                      // const Text(
                      //   'Chat with Your',
                      //   style: TextStyle(
                      //     color: Colors.white70,
                      //     fontSize: 14,
                      //   ),
                      // ),
                      // const Text(
                      //   'SHIPMATE',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //     letterSpacing: 2,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    ),
                    child: Container(
                      height: 100,
                      width: 400,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 255, 153, 0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // child: ClipRRect(
                      //   borderRadius: BorderRadius.circular(8), // match container radius
                      //   child: Image.asset(
                      //     "lib/assets/images/avat.png", // your PNG path
                      //     fit: BoxFit.cover, // fills container
                      //   ),
                      // ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Activity Section
          const Text(
            'Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _ActivityCard(
                  title: 'Meditation',
                  imagePath: 'lib/assets/images/med.png',
                  backgroundColor: Colors.white,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GridCalmGame()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActivityCard(
                  title: 'Breathing',
                  imagePath: 'lib/assets/images/bre.png',
                  backgroundColor: Colors.white,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BreathingScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Academy Section
          const Text(
            'Academy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),

          // Consultation Card
          Container(
            width: double.infinity,
            height: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('lib/assets/images/consult.png'),
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Academy()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      'CONSULT WITH US!',
                      style: TextStyle(
                        color: Color.fromARGB(0, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Games Section
          const Text(
            'Games',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _EnhancedGameCard(
                  title: 'Tap To Calm',
                  subtitle: 'Tap for calmness',
                  backgroundColor: const Color(0xFF3498DB),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GridCalmGame()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EnhancedGameCard(
                  title: 'MEMORY',
                  subtitle: '',
                  backgroundColor: const Color(0xFF90EE90),
                  isMemoryGame: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MemoryGame()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Wellness Tips Section
          const Text(
            'Wellness Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),

          Column(
            children: [
              _WellnessTipCard(
                title: 'Find Your Space',
                description: 'Choose a quiet spot on deck or in your cabin where you won\'t be disturbed',
                color: const Color(0xFF9B59B6),
              ),
              const SizedBox(height: 12),
              _WellnessTipCard(
                title: 'Deep Breathing',
                description: 'Practice breathing exercises to reduce stress and improve focus',
                color: const Color(0xFF3498DB),
              ),
              const SizedBox(height: 12),
              _WellnessTipCard(
                title: 'Stay Active',
                description: 'Regular movement helps maintain both physical and mental wellness',
                color: const Color(0xFF2ECC71),
              ),
              const SizedBox(height: 12),
              _WellnessTipCard(
                title: 'Connect with Others',
                description: 'Maintain social connections for emotional support and wellbeing',
                color: const Color(0xFFE67E22),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}


  Widget _buildShowContent() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Title
          const Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          

          // 🔹 Progress Feature Cards (Grid Style)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 1,
            childAspectRatio: 2.0,
            mainAxisSpacing: 12,

           children: [
                _buildFeatureCard("Journal", "lib/assets/images/resolu.png", '/journal'),
                _buildFeatureCard("Certificates", "lib/assets/images/certi.png", '/certificates'),
                _buildFeatureCard("Mood Analysis", "lib/assets/images/prog.png", '/mood-analytics'),
                _buildFeatureCard("Progress Report", "lib/assets/images/aly.png", '/report'),
              ],
          ),

          const SizedBox(height: 24),

          // 🔹 Wellness Tips Section
        const Text(
              'Wellness Tips',
              textAlign: TextAlign.center, // ✅ move here
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),

          const SizedBox(height: 12),

          Column(
            children: [
              _buildTipCard(
                title: "Find Your Space",
                description: "Choose a quiet spot on deck or in your cabin where you won’t disturbed",
                bgColor: Colors.green.shade50,
                textColor: Colors.green.shade800,
              ),
              _buildTipCard(
                title: "Steady Yourself",
                description: "Sit with your back against something stable to maintain balance with ship movement",
                bgColor: Colors.purple.shade50,
                textColor: Colors.purple,
              ),
              _buildTipCard(
                title: "Use Natural Sounds",
                description: "Let the sound of waves and wind become part of your meditation practice",
                bgColor: Colors.blue.shade50,
                textColor: Colors.blue,
              ),
              _buildTipCard(
                title: "Regular Practice",
                description: "Even 5 minutes daily can significantly reduce stress and improve focus.",
                bgColor: Colors.orange.shade50,
                textColor: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}



/// 🔹 Feature Card
Widget _buildFeatureCard(String title, String imagePath, String routeName) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, routeName);
    },
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 8, 121, 183).withOpacity(0.9),
                    const Color.fromARGB(0, 1, 1, 29),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 🔹 Wellness Tip Card
Widget _buildTipCard({
  required String title,
  required String description,
  required Color bgColor,
  required Color textColor,
}) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    ),
  );
}

  Widget _buildSoarCardTile() {
    return GestureDetector(
      onTap: () async {
        // Navigate to SOAR card screen
        final userEmail = await UserProfileService.getUserEmail();
        if (userEmail.isNotEmpty && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SoarDashboardPage(userEmail: userEmail),
            ),
          ).then((_) {
            // Refresh SOAR data when returning
            _loadSoarData();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Color(0xFF9B59B6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SOAR Assessment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        _loadingSoarData
                            ? 'Loading...'
                            : _soarAnswers.isEmpty
                            ? 'Complete your assessment'
                            : '${_soarAnswers.length} questions answered',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),

            if (!_loadingSoarData && _soarAnswers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Recent Answers:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              ...(_soarAnswers
                  .take(3)
                  .map(
                    (answer) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 8, right: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF9B59B6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  answer.questionText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2C3E50),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Answer: ${answer.answer}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9B59B6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              if (_soarAnswers.length > 3)
                Text(
                  'and ${_soarAnswers.length - 3} more...',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],

            if (!_loadingSoarData && _soarAnswers.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Take the SOAR assessment to understand your strengths and areas for growth.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9B59B6)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsTile() {
    return GestureDetector(
      onTap: () async {
        // Navigate to goal setting screen
        final userEmail = await UserProfileService.getUserEmail();
        if (userEmail.isNotEmpty && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalPage(userEmail: userEmail),
            ),
          ).then((_) {
            // Refresh goals data when returning
            _loadGoalsData();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Color(0xFF2ECC71),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Goal Setting',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        _loadingGoals
                            ? 'Loading...'
                            : _userGoals.isEmpty
                            ? 'Set your wellness goals'
                            : '${_userGoals.length} goals set',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),

            if (!_loadingGoals && _userGoals.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Your Goals:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              ...(_userGoals
                  .take(3)
                  .map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 8, right: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2ECC71),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal['goals'] ?? goal['goal'] ?? 'Goal',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (goal['notes'] != null &&
                                    goal['notes'].toString().isNotEmpty)
                                  Text(
                                    goal['notes'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              if (_userGoals.length > 3)
                Text(
                  'and ${_userGoals.length - 3} more goals...',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],

            if (!_loadingGoals && _userGoals.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Set your wellness goals to track your progress and stay motivated.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF2ECC71)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatWithAIButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3498DB).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chat with Buddy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Get personalized wellness guidance and support',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodAnalyticsButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoodAnalyticsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 109, 159, 223), Color.fromARGB(255, 97, 183, 226)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 109, 159, 223).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mood Analytics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track and analyze your mood patterns over time',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _GameCard(
          title: 'Meditation',
          icon: Icons.touch_app,
          color: const Color(0xFF9B59B6),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GridCalmGame()),
          ),
        ),
        _GameCard(
          title: 'Breathing',
          icon: Icons.air,
          color: const Color(0xFF1ABC9C),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BreathingScreen()),
          ),
        ),
        _GameCard(
          title: 'Memory Game',
          icon: Icons.psychology,
          color: const Color(0xFFE67E22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MemoryGame()),
          ),
        ),
        _GameCard(
          title: 'Journal',
          icon: Icons.book,
          color: const Color(0xFF34495E),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JournalScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildWellnessTips() {
    final tips = [
      {
        'title': 'Daily Breathing Exercise',
        'description':
            'Practice deep breathing for 5 minutes daily to reduce stress and anxiety.',
        'icon': Icons.air,
        'color': const Color(0xFF1ABC9C),
      },
      {
        'title': 'Stay Connected',
        'description':
            'Maintain regular contact with family and friends to combat loneliness.',
        'icon': Icons.people,
        'color': const Color(0xFF3498DB),
      },
      {
        'title': 'Physical Activity',
        'description':
            'Engage in regular exercise to boost mood and maintain physical health.',
        'icon': Icons.fitness_center,
        'color': const Color(0xFFE74C3C),
      },
      {
        'title': 'Mindful Eating',
        'description':
            'Pay attention to your meals and maintain a balanced diet for better wellness.',
        'icon': Icons.restaurant,
        'color': const Color(0xFFE67E22),
      },
      {
        'title': 'Quality Sleep',
        'description':
            'Maintain a regular sleep schedule for better mental and physical health.',
        'icon': Icons.bedtime,
        'color': const Color(0xFF9B59B6),
      },
      {
        'title': 'Express Yourself',
        'description':
            'Write in a journal or talk to someone about your feelings and experiences.',
        'icon': Icons.edit,
        'color': const Color(0xFF2ECC71),
      },
    ];

    return Column(
      children: tips
          .map(
            (tip) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (tip['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: tip['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMeditationTipsCard(){
    final tips = [
      {
        'title': 'Find a Quiet Space',
        'description':
            'Choose a quiet spot on deck or in your cabin where you wont be disturbed.',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF1ABC9C),
      },
      {
        'title': 'Use Natural Sounds',
        'description':
            'Let the sound of the ocean waves and wind enhance your meditation experience.',
        'icon': Icons.waves,
        'color': const Color.fromARGB(255, 64, 97, 231),
      },
      {
        'title': 'Steady Yourself',
        'description':
            'Sit with your back against something stable to maintain balance with ship movement',
        'icon': Icons.anchor,
        'color': const Color.fromARGB(255, 141, 63, 224),
      },
      {
        'title': 'Regular Practice',
        'description':
            'Even 5 minutes daily can significantly reduce stress and improve focus.',
        'icon': Icons.schedule,
        'color': const Color.fromARGB(255, 218, 114, 58),
      },
    ];

    return Column(
      children: tips
          .map(
            (tip) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(213, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (tip['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tip['icon'] as IconData,
                      color: tip['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildProgressCards() {
    return Column(
      children: [
        _ProgressCard(
          title: 'Daily Check-ins',
          value: '7/7',
          progress: 1.0,
          color: const Color(0xFF2ECC71),
        ),
        const SizedBox(height: 12),
        _ProgressCard(
          title: 'Breathing Sessions',
          value: '12/15',
          progress: 0.8,
          color: const Color(0xFF3498DB),
        ),
        const SizedBox(height: 12),
        _ProgressCard(
          title: 'Journal Entries',
          value: '5/7',
          progress: 0.7,
          color: const Color(0xFFE67E22),
        ),
      ],
    );
  }
}

// Activity Card Widget
class _ActivityCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.title,
    required this.imagePath,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Enhanced Game Card Widget
class _EnhancedGameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final bool isMemoryGame;
  final VoidCallback onTap;

  const _EnhancedGameCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    this.isMemoryGame = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isMemoryGame
            ? _buildMemoryGameContent()
            : _buildTapToCalmContent(),
      ),
    );
  }

  Widget _buildTapToCalmContent() {
  return Container(
    height: 150, // adjust height as needed
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: const DecorationImage(
        image: AssetImage('lib/assets/images/game1.png'), // your background PNG
        fit: BoxFit.cover,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 255, 255, 255),
                borderRadius: BorderRadius.circular(8),
              ),
              // child: Image.asset(
              //   'lib/assets/images/game1.png',
              //   height: 24,
              //   width: 24,
              //   fit: BoxFit.contain,
              // ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMemoryGameContent() {
  return Container(
    height: 150, // adjust height as needed
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: const DecorationImage(
        image: AssetImage('lib/assets/images/game2.png'), // single PNG background
        fit: BoxFit.cover,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'MEMORY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

}

// Wellness Tip Card Widget
class _WellnessTipCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const _WellnessTipCard({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sticky Tab Bar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate(this.child);

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFF8F9FA), child: child);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}