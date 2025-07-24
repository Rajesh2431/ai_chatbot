import 'package:flutter/material.dart';
import 'tap_the_calm_game.dart'; // Make sure this file exists

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Play Games', style: TextStyle(color: Colors.orangeAccent)),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Relaxing Games',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildGameCard(
                    context,
                    title: 'Tap the Calm',
                    description: 'Tap relaxing bubbles to ease your mind.',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GridCalmGame()),
                    ),
                  ),
                  // Add more _buildGameCard for future games
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context,
      {required String title, required String description, required VoidCallback onTap}) {
    return Card(
      color: const Color.fromARGB(255, 88, 2, 2),
      margin: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: const TextStyle(color: Colors.orange, fontSize: 18)),
        subtitle: Text(description, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.play_arrow, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
