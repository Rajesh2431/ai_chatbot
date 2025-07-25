import 'package:flutter/material.dart';


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
  ];

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
    // You can add additional logic here to persist the theme preference or notify other parts of the app
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
                      // Handle tap
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