import 'package:flutter/material.dart';
import 'notification_settings_screen.dart';
import 'mood_analytics_screen.dart';
import 'ai_knowledge_base_screen.dart';
import '../services/auth_service.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  

  final List<Map<String, dynamic>> settings = [
    {
      "icon": Icons.insert_chart,
      "label": "Analytics",
      "color": Colors.deepPurpleAccent,
    },
    {
      "icon": Icons.color_lens,
      "label": "Theme",
      "color": Colors.teal,
      "isToggle": true,
    },
    {
      "icon": Icons.wallpaper,
      "label": "Wallpaper",
      "color": Colors.lightBlue,
    },
    {
      "icon": Icons.psychology,
      "label": "AI Knowledge Base",
      "color": Colors.deepOrange,
    },
    {
      "icon": Icons.notifications,
      "label": "Notification",
      "color": Colors.orange,
    },
    {
      "icon": Icons.language,
      "label": "Language",
      "color": Colors.purple,
    },
    {
      "icon": Icons.help_center,
      "label": "Help Center",
      "color": Colors.green,
    },
    {
      "icon": Icons.privacy_tip,
      "label": "Terms & Privacy Policy",
      "color": Colors.lightBlue,
    },
    {
      "icon": Icons.phone_iphone,
      "label": "App Version",
      "color": Colors.teal,
    },
    {
      "icon": Icons.logout,
      "label": "Logout",
      "color": Colors.red,
    },
  ];

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
    // You can add additional logic here to persist the theme preference or notify other parts of the app
  }

  void _handleSettingTap(BuildContext context, String label) {
    switch (label) {
      case 'Analytics':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MoodAnalyticsScreen(),
          ),
        );
        break;
      case 'AI Knowledge Base':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AIKnowledgeBaseScreen(),
          ),
        );
        break;
      case 'Notification':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationSettingsScreen(),
          ),
        );
        break;
      case 'Help Center':
        _showHelpDialog(context);
        break;
      case 'Terms & Privacy Policy':
        _showPrivacyDialog(context);
        break;
      case 'App Version':
        _showVersionDialog(context);
        break;
      case 'Logout':
        _showLogoutDialog(context);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label feature coming soon!'),
            backgroundColor: Colors.blue,
          ),
        );
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: const Text(
          'SeaSmart is your AI-powered mental health companion. '
          'Use the daily check-in to track your mood, chat with our AI assistant, '
          'and explore relaxation activities.\n\n'
          'For additional support, please contact your healthcare provider.',
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

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'SeaSmart Privacy Policy\n\n'
            '• Your data is stored locally on your device\n'
            '• We do not share personal information with third parties\n'
            '• Chat conversations are processed securely\n'
            '• You can delete your data anytime from the app\n\n'
            'Terms of Service\n\n'
            '• This app is for wellness support, not medical diagnosis\n'
            '• Always consult healthcare professionals for serious concerns\n'
            '• Use responsibly and as part of a comprehensive wellness plan',
          ),
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

  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Version'),
        content: const Text(
          'SeaSmart v1.0.0\n\n'
          'Your AI-powered mental health companion\n'
          'Built with Flutter & powered by AI',
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              // Logout user
              await AuthService.logout();
              
              if (context.mounted) {
                // Navigate to login screen and clear all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Removed CircleAvatar with eye icon
                  // Removed CircleAvatar with profile image
                ],
              ),
            ),

            /// Settings Title
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),

            /// Settings List
            Expanded(
              child: ListView.builder(
                itemCount: settings.length,
                itemBuilder: (context, index) {
                  final item = settings[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item['color'].withOpacity(0.2),
                      child: Icon(item['icon'], color: item['color']),
                    ),
                    title: Text(
                      item['label'],
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    trailing: item['isToggle'] == true
                        ? Switch(
                            value: isDarkMode,
                            onChanged: toggleTheme,
                          )
                        : null,
                    onTap: () {
                      _handleSettingTap(context, item['label']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}