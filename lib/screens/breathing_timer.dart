import 'package:flutter/material.dart';
import 'belly_breathing_screen.dart';
import 'box_breathing_screen.dart';
import 'alternate_nostril_breathing_screen.dart';

class BreathingTechniqueData {
  final String name;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget screen;

  BreathingTechniqueData({
    required this.name,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.screen,
  });
}

class BreathingScreen extends StatefulWidget {
  final String? initialTechnique;
  
  const BreathingScreen({super.key, this.initialTechnique});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  // Breathing techniques data
  final List<BreathingTechniqueData> _techniques = [
    BreathingTechniqueData(
      name: "Belly Breathing",
      description: "Deep diaphragmatic breathing to reduce stress and anxiety",
      icon: Icons.favorite,
      primaryColor: const Color(0xFF64B5F6),
      secondaryColor: const Color(0xFFE3F2FD),
      screen: const BellyBreathingScreen(),
    ),
    BreathingTechniqueData(
      name: "Box Breathing",
      description: "4-4-4-4 pattern used by Navy SEALs for focus and calm",
      icon: Icons.crop_square,
      primaryColor: const Color(0xFF42A5F5),
      secondaryColor: const Color(0xFFE1F5FE),
      screen: const BoxBreathingScreen(),
    ),
    BreathingTechniqueData(
      name: "Alternate Nostril",
      description: "Ancient yogic technique to balance mind and body",
      icon: Icons.air,
      primaryColor: const Color(0xFF29B6F6),
      secondaryColor: const Color(0xFFE0F2F1),
      screen: const AlternateNostrilBreathingScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Handle initial technique selection - navigate directly to specific screen
    if (widget.initialTechnique != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialTechnique();
      });
    }
  }

  void _handleInitialTechnique() {
    Widget? screen;
    switch (widget.initialTechnique) {
      case 'belly':
        screen = const BellyBreathingScreen();
        break;
      case 'box':
        screen = const BoxBreathingScreen();
        break;
      case 'nostril':
        screen = const AlternateNostrilBreathingScreen();
        break;
    }
    
    if (screen != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  void _selectTechnique(BreathingTechniqueData technique) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => technique.screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFBBDEFB), // Slightly deeper light blue
              Color(0xFF90CAF9), // Medium light blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      'Breathing Techniques',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 56),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: _buildTechniqueSelection(),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: const Text(
                  'Choose a breathing technique that resonates with you 🌿',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechniqueSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Choose Your Breathing Technique',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a technique that resonates with you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              children: _techniques.map((technique) {
                return _buildTechniqueCard(technique);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueCard(BreathingTechniqueData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectTechnique(data),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: data.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: data.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    data.icon,
                    color: data.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: data.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: data.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}