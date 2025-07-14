import 'package:flutter/material.dart';
import '../widget/action_card.dart';
import '../widget/single_wide_action_card.dart';
import '../screens/chat_screen.dart';
import '../screens/voicechat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: Colors.purple[100],
              backgroundImage: const AssetImage('lib/assets/icons/profile.png'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Well Come',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          'Captain.!',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('lib/assets/icons/ai.png', width: 80),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    icon: Icons.edit,
                    label: 'Chat with A.I',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionCard(
                    icon: Icons.headphones,
                    label: 'Speak with A.I',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VoiceChatScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleWideActionCard(
              icon: Icons.videogame_asset,
              label: 'Play Games',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              'History',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => _historyTile(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.headphones, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Today is so board',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Text('04:23', style: TextStyle(color: Colors.white38)),
          SizedBox(width: 8),
          Icon(Icons.more_vert, color: Colors.white38),
        ],
      ),
    );
  }
}
