import 'package:flutter/material.dart';
import '../screens/grow_screen.dart';

/// Demo widget to showcase the Grow screen
class GrowScreenDemo extends StatelessWidget {
  const GrowScreenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grow Screen Demo'),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, size: 80, color: Color(0xFF3498DB)),
              const SizedBox(height: 20),
              const Text(
                'Grow Screen',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A comprehensive wellness dashboard with user stats, games, and wellness tips.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Features list
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      '📊',
                      'User Statistics (Days at sea, destination, etc.)',
                    ),
                    _buildFeatureItem(
                      '💪',
                      'Wellness Score with progress tracking',
                    ),
                    _buildFeatureItem('🎮', 'Interactive games and activities'),
                    _buildFeatureItem(
                      '💡',
                      'Wellness tips and recommendations',
                    ),
                    _buildFeatureItem('📈', 'Progress tracking and analytics'),
                    _buildFeatureItem('🎯', 'Three tabs: Know, Grow, Show'),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Launch button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GrowScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Open Grow Screen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
            ),
          ),
        ],
      ),
    );
  }
}
