import 'package:flutter/material.dart';
import 'chat_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? selectedAvatar;

  void _selectAvatar(String avatar) async {
    setState(() => selectedAvatar = avatar);
    await Future.delayed(const Duration(milliseconds: 400));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          selectedAvatar == null ? Colors.white : const Color(0xFF97CAE4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(36),
        child: AppBar(
          backgroundColor: const Color(0xFFD6D6D6),
          elevation: 0,
          toolbarHeight: 36,
          automaticallyImplyLeading: false,
        ),
      ),
      body: Center(
        child: selectedAvatar == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Choose ",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: "Avatar",
                          style: const TextStyle(
                            color: Color(0xFF6EC1E4),
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAvatarOption(
                        'lib/assets/avatar/saira.gif', // Updated to GIF
                        'Saira',
                        () => _selectAvatar('saira'),
                      ),
                      const SizedBox(width: 32),
                      _buildAvatarOption(
                        'lib/assets/avatar/kael.gif', // Updated to GIF
                        'Kael',
                        () => _selectAvatar('kael'),
                      ),
                    ],
                  ),
                ],
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: selectedAvatar == 'saira'
                    ? _buildFullAvatar('lib/assets/avatar/saira.gif')
                    : _buildFullAvatar('lib/assets/avatar/kael.gif'),
              ),
      ),
    );
  }

  Widget _buildAvatarOption(String imgPath, String name, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 54,
            backgroundColor: const Color(0xFF97CAE4),
            backgroundImage: AssetImage(imgPath),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF6EC1E4),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFullAvatar(String imgPath) {
    return Center(
      child: Image.asset(
        imgPath,
        width: 180,
        height: 320,
        fit: BoxFit.contain,
      ),
    );
  }
}
