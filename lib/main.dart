import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/avatar_selection_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/journal_screen.dart';
import 'providers/journal_entries_provider.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalEntriesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shiro - AI Mental Health Assistant',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        home: const SplashScreen(),
        routes: {
          '/avatar-selection': (context) => const AvatarSelectionScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/chat': (context) => const ChatScreen(),
          '/journal': (context) => const JournalScreen(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 9));

    if (!mounted) return;

    // Always go to avatar selection screen after splash
    Navigator.pushReplacementNamed(context, '/avatar-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'lib/assets/videos/splashscreen.gif',
          width: 1080,
          height: 1920,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if GIF doesn't exist
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, size: 100, color: Colors.deepPurple),
                const SizedBox(height: 20),
                Text(
                  'Shiro',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your Mental Health Assistant',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
