import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/avatar_selection_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/daily_checkin_screen.dart';
import 'screens/login_screen.dart';
import 'providers/journal_entries_provider.dart';
import 'services/backend_pdf_service.dart';
import 'services/notification_service.dart';
import 'services/user_profile_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await BackendPDFService.loadPDFFromAssets();
  await NotificationService.initialize();

  // Enable notifications by default (compulsory)
  await NotificationService.enableDefaultNotifications();

  runApp(const App());
}

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
        title: 'SeaSmart - AI Mental Health Assistant',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/avatar-selection': (context) => const AvatarSelectionScreen(),
          '/daily-checkin': (context) => const DailyCheckinScreen(),
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
    await Future.delayed(const Duration(seconds: 3)); // Reduced splash time

    if (!mounted) return;

    // Check if user is logged in
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!isLoggedIn) {
      // User not logged in - go to login screen
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // User is logged in - check if this is their first time
    final isFirstTime = await UserProfileService.isFirstTime();

    if (isFirstTime) {
      // First time user - go to onboarding
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      // Returning user - check if they need daily check-in
      final needsDailyCheckin = await UserProfileService.needsDailyCheckin();

      if (needsDailyCheckin) {
        // User needs to do daily check-in
        Navigator.pushReplacementNamed(context, '/daily-checkin');
      } else {
        // User already did daily check-in - go to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'lib/assets/videos/splash1.gif',
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
                  'SeaSmart',
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

class AuthService {
  // Existing methods and properties

  static Future<bool> isLoggedIn() async {
    // TODO: Implement actual login check logic
    // For now, return false or true as placeholder
    return false;
  }
}
