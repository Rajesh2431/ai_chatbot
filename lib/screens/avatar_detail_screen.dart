import 'package:flutter/material.dart';
import '../routes/circular_reveal_route.dart';
import 'dashboard_screen.dart';

class AvatarDetailScreen extends StatelessWidget {
  final String imagePath;
  final String name;

  const AvatarDetailScreen({required this.imagePath, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi there, I am $name.',
                  style: const TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Image.asset(
              imagePath,
              height: 400,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final size = MediaQuery.of(context).size;
                final center = Offset(size.width / 2, size.height / 2);
                Navigator.of(context).pushReplacement(
                  CircularRevealRoute(
                    page: const DashboardScreen(),
                    centerAlignment: center,
                    startRadius: 0,
                    revealColor: Colors.lightBlue.shade200,
                  ),
                );
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
