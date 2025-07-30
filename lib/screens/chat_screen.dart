import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import 'voicechat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isTyping = false;
  bool _showEmotionButtons = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    setState(() {
      _messages.add(Message(text: "Hi", isUser: false));
      _messages.add(
        Message(text: "How are you feeling today? 😊", isUser: false),
      );
    });
    _scrollToBottom();
  }

  void _sendMessage(String text) async {
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isTyping = true;
      _showEmotionButtons = false;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await OpenRouterAPI.getResponse(text);
      if (mounted) {
        setState(() {
          _messages.add(Message(text: reply, isUser: false));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            Message(
              text: "Sorry, I'm having trouble connecting. Please try again.",
              isUser: false,
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _sendEmotionResponse(String emotion) {
    _sendMessage("I'm feeling $emotion");
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // For reverse: true, scroll to top (which is the bottom of the chat)
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildEmotionButtons() {
    if (!_showEmotionButtons) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildEmotionButton("Happy", "😊", Colors.green),
          _buildEmotionButton("Sad", "😢", Colors.blue),
          _buildEmotionButton("Depressed", "😔", Colors.orange),
          _buildEmotionButton("Frustrated", "😤", Colors.red),
        ],
      ),
    );
  }

  Widget _buildEmotionButton(String emotion, String emoji, Color color) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () => _sendEmotionResponse(emotion.toLowerCase()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emotion, style: TextStyle(color: color, fontSize: 16)),
          const SizedBox(width: 6),
          Text(emoji, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFB3E5FC),
              child: Image.asset(
                'assets/icons/profile.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: Colors.deepOrange,
                  size: 24,
                ),
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF4A90E2)
                    : const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isUser ? 22 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 22),
                ),
                boxShadow: isUser
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 20,
                  color: isUser ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFB3E5FC),
              child: Image.asset(
                'assets/icons/user.png', // Use your user avatar image path
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: Colors.blue, size: 24),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: "Ask for anything?",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: const Icon(Icons.graphic_eq, color: Color(0xFF4A90E2)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceChatScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isTyping
                  ? null
                  : () => _sendMessage(_controller.text.trim()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get status bar height for proper top spacing
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top row with menu icon and status bar space
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + 16, // Add status bar height
              left: 16,
              right: 16,
              bottom: 4,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xFF4A90E2),
                    size: 32,
                  ),
                  onPressed: () {
                    // Add menu logic here
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              reverse: true,
              children: [
                const SizedBox(height: 8),
                ..._messages.reversed.map((msg) => _buildMessageBubble(msg)),
              ],
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFB3E5FC),
                    child: Image.asset(
                      'assets/icons/profile.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        color: Colors.deepOrange,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Typing...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          _buildEmotionButtons(),
          _buildInputBar(),
        ],
      ),
    );
  }
}
