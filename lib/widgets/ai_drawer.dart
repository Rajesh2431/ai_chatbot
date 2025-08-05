import 'package:flutter/material.dart';
import '../screens/avatar_selection_screen.dart';
import '../screens/ai_knowledge_base_screen.dart';
import '../services/avatar_service.dart';

class AIDrawer extends StatefulWidget {
  const AIDrawer({super.key});

  @override
  State<AIDrawer> createState() => _AIDrawerState();
}

class _AIDrawerState extends State<AIDrawer> {
  String _avatarName = 'Saira';
  String _avatarImage = 'lib/assets/avatar/saira.png';

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final selectedAvatar = await AvatarService.getSelectedAvatar();
      if (selectedAvatar != null && mounted) {
        setState(() {
          _avatarName = selectedAvatar['name']!;
          _avatarImage = selectedAvatar['image']!;
        });
      }
    } catch (e) {
      // Use default avatar if loading fails
      debugPrint('Error loading avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header with blue gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4A90E2), // Light blue
                  Color(0xFF357ABD), // Medium blue
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    // AI Avatar with golden background circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF5BA7F7), // Light blue background
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipOval(
                          child: Image.asset(
                            _avatarImage,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/icons/profile.png',
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.smart_toy,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _avatarName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI Mental Health Companion',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildSimpleMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'AI Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      _showNotificationsDialog();
                    },
                  ),
                  
                  _buildSimpleMenuItem(
                    icon: Icons.rate_review_outlined,
                    title: 'AI Knowledge Base',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIKnowledgeBaseScreen(),
                        ),
                      );
                    },
                  ),
                  
                  _buildSimpleMenuItem(
                    icon: Icons.face_outlined,
                    title: 'Change Avatar',
                    onTap: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvatarSelectionScreen(
                            isChangingAvatar: true,
                          ),
                        ),
                      );
                      if (result == true) {
                        _loadAvatar();
                      }
                    },
                  ),
                  
                  _buildSimpleMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'AI Settings',
                    onTap: () {
                      Navigator.pop(context);
                      _showAISettingsDialog();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey[600],
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_outlined, color: Color(0xFF4A90E2)),
            SizedBox(width: 8),
            Text('AI Notifications'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your AI companion notifications:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('• Daily check-in reminders'),
            Text('• Mood tracking alerts'),
            Text('• Breathing exercise suggestions'),
            Text('• Personalized wellness tips'),
            SizedBox(height: 16),
            Text(
              'Notification settings coming soon!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAISettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings_outlined, color: Color(0xFF4A90E2)),
            SizedBox(width: 8),
            Text('AI Settings'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure your AI companion:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('• Response style preferences'),
            Text('• Conversation personality'),
            Text('• Learning preferences'),
            Text('• Privacy controls'),
            SizedBox(height: 16),
            Text(
              'Advanced settings coming soon!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}