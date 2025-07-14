import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: const DashboardScreen(), // ✅ Set the dashboard as entry point
      routes: {
        '/chat': (context) => const ChatScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
