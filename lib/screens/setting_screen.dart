import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _themeSwitch = false;
  //int _fontSize = 3;

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
              Icon(Icons.circle, color: Colors.black, size: 28),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  'assets/icons/profile.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          // Mood Analytics & Theme
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Color(0xFFE0E0E0)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Mood Analytics',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Theme', style: TextStyle(fontSize: 16)),
                  trailing: Switch(
                    value: _themeSwitch,
                    activeColor: Color(0xFF19B5FE),
                    onChanged: (val) {
                      setState(() => _themeSwitch = val);
                    },
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                const Divider(),
                ListTile(
                  title: const Text('Language', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title: const Text('Theme', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onTap: () {},
                ),
                // const Divider(),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 8),
                //   child: Text(
                //     'Font Size',
                //     style: TextStyle(fontSize: 16, color: Colors.grey),
                //   ),
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: List.generate(4, (i) {
                //     final size = i + 1;
                //     return Column(
                //       children: [
                //         Radio<int>(
                //           value: size,
                //           groupValue: _fontSize,
                //           onChanged: (val) {
                //             setState(() => _fontSize = val!);
                //           },
                //         ),
                //         Text(
                //           '$size',
                //           style: TextStyle(
                //             fontSize: 14,
                //             color: _fontSize == size ? Colors.black : Colors.grey,
                //             fontWeight: _fontSize == size ? FontWeight.bold : FontWeight.normal,
                //           ),
                //         ),
                //       ],
                //     );
                //   }),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Help Center & Policy
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Color(0xFFE0E0E0)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Help Center', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title: const Text('Terms & Privacy Policy', style: TextStyle(fontSize: 16)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title: const Text('App Version', style: TextStyle(fontSize: 16)),
                  trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}