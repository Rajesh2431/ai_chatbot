import 'package:flutter/material.dart';
import 'avatar_detail_screen.dart';
import '../routes/circular_reveal_route.dart';

class AvatarSelectionScreen extends StatelessWidget {
  final List<Map<String, dynamic>> avatars = [
    {
      "name": "Saira",
      "image": "lib/assets/avatar/saira.png",
    },
    {
      "name": "Kael",
      "image": "lib/assets/avatar/kael.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Center(
              child: RichText(
                text: const TextSpan(
                  text: 'Choose ',
                  style: TextStyle(fontSize: 24, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: 'Avatar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: avatars.map((avatar) {
                  return GestureDetector(
                    onTapDown: (TapDownDetails details) {
                      final Offset tapPosition = details.globalPosition;

                      Navigator.of(context).push(
                        CircularRevealRoute(
                          page: AvatarDetailScreen(imagePath: avatar['image'], name: avatar['name']),
                          centerAlignment: tapPosition,
                          startRadius: 80.0,
                          revealColor: const Color(0xFF52B3E0),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF52B3E0),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              avatar['image'],
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          avatar['name'],
                          style: const TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
