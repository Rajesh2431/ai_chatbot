import 'dart:math';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/backend_pdf_service.dart';
import '../services/action_detector_service.dart';
import '../services/content_service.dart';
import '../services/mood_based_chat_service.dart';
import '../services/mood_service.dart';
import 'voicechat_screen.dart';
import 'breathing_timer.dart';
import 'journal_screen.dart';
import 'tap_the_calm_game.dart';

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

  // Message counting for forced suggestions
  int _messageCount = 0;
  bool _hasShownBreathingSuggestion = false;
  bool _hasShownJournalSuggestion = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _initializePDF();
  }

  void _initializePDF() async {
    // Load PDF content when chat screen initializes
    await BackendPDFService.loadPDFFromAssets();
  }

  Future<String> _getMoodIndicator() async {
    try {
      final hasCheckin = await MoodBasedChatService.hasCompletedDailyCheckin();
      if (!hasCheckin) {
        return "No Check-in";
      }

      final moodScore = await MoodService.getTodaysMoodScore();
      if (moodScore >= 3.5) return "😊 Good Mood";
      if (moodScore >= 2.5) return "😐 Okay Mood";
      return "😔 Needs Support";
    } catch (e) {
      return "Mood Unknown";
    }
  }

  Color _getMoodColor(String moodText) {
    if (moodText.contains("Good")) return Colors.green;
    if (moodText.contains("Okay")) return Colors.orange;
    if (moodText.contains("Support")) return Colors.red;
    return Colors.grey;
  }

  void _initializeChat() async {
    setState(() {
      _messages.add(
        Message(
          text: "Hi! I'm Saira, your mental health companion.",
          isUser: false,
        ),
      );
    });

    // Add mood-based greeting
    try {
      final moodGreeting = await MoodBasedChatService.getMoodBasedGreeting();
      setState(() {
        _messages.add(Message(text: moodGreeting, isUser: false));
      });
    } catch (e) {
      // Fallback greeting if mood service fails
      setState(() {
        _messages.add(
          Message(
            text:
                "I have access to mental health resources to help you. How are you feeling today? 😊",
            isUser: false,
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _sendMessage(String text) async {
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isTyping = true;
      _showEmotionButtons = false;
      _messageCount++; // Increment message count
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Check if we should force a suggestion
      final forcedSuggestion = await _getForcedSuggestion();

      String reply;
      List<MessageAction>? actions;

      if (forcedSuggestion != null) {
        // Use forced suggestion instead of AI response
        reply = forcedSuggestion;
        actions = ActionDetectorService.detectActions(reply);
      } else {
        // Get normal AI response
        reply = await OpenRouterAPI.getResponse(text);
        actions = ActionDetectorService.detectActions(reply);
      }

      // Always add a random video suggestion to every AI reply
      actions = _addRandomVideoAction(actions ?? []);

      if (mounted) {
        setState(() {
          _messages.add(Message(text: reply, isUser: false, actions: actions));
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

  /// Check if we should force breathing or journal suggestions
  Future<String?> _getForcedSuggestion() async {
    // Get mood-based suggestions
    try {
      final moodSuggestions =
          await MoodBasedChatService.getMoodBasedSuggestions();

      // Force breathing exercise after 3-4 messages (mood-appropriate)
      if (_messageCount >= 3 && !_hasShownBreathingSuggestion) {
        _hasShownBreathingSuggestion = true;
        return moodSuggestions.isNotEmpty
            ? moodSuggestions[0]
            : "Let's take a moment to breathe. Try breathing exercises to center yourself 🌿";
      }

      // Force journal suggestion after 6-7 messages (mood-appropriate)
      if (_messageCount >= 6 && !_hasShownJournalSuggestion) {
        _hasShownJournalSuggestion = true;
        return moodSuggestions.length > 1
            ? moodSuggestions[1]
            : "It might help to write down your thoughts. Try journaling to process your feelings ✨";
      }

      // Randomly suggest video or LMS content after 4-5 messages (30% chance)
      if (_messageCount >= 4 && _messageCount <= 8) {
        final random = Random();
        if (random.nextDouble() < 0.3) {
          // 30% chance
          if (random.nextBool()) {
            // Suggest video
            return ContentService.getVideoSuggestionText();
          } else {
            // Suggest LMS
            return ContentService.getLMSSuggestionText();
          }
        }
      }
    } catch (e) {
      // Fallback to original suggestions if mood service fails
      if (_messageCount >= 3 && !_hasShownBreathingSuggestion) {
        _hasShownBreathingSuggestion = true;
        return "Let's take a moment to breathe. Try breathing exercises to center yourself 🌿";
      }

      if (_messageCount >= 6 && !_hasShownJournalSuggestion) {
        _hasShownJournalSuggestion = true;
        return "It might help to write down your thoughts. Try journaling to process your feelings ✨";
      }
    }

    return null;
  }

  /// Reset forced suggestions (useful for testing or new sessions)
  void _resetForcedSuggestions() {
    setState(() {
      _messageCount = 0;
      _hasShownBreathingSuggestion = false;
      _hasShownJournalSuggestion = false;
    });
  }

  /// Check if a message is a forced suggestion
  bool _isMessageForced(String messageText) {
    return messageText.contains("Let's take a moment to breathe") ||
        messageText.contains("It might help to write down your thoughts");
  }

  /// Add a random video action to the actions list
  List<MessageAction> _addRandomVideoAction(
    List<MessageAction> existingActions,
  ) {
    final randomVideo = ContentService.getRandomVideo();

    final videoAction = MessageAction(
      label: "▶️ ${randomVideo['title']}",
      route: '/video',
      icon: Icons.play_circle_fill,
      data: {
        'url': randomVideo['url']!,
        'title': randomVideo['title']!,
        'description': randomVideo['description']!,
      },
    );

    // Add video action to existing actions (LMS is now in header)
    return [...existingActions, videoAction];
  }

  void _showResourceInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Available Resources',
          style: TextStyle(color: Color(0xFF4A90E2)),
        ),
        content: SingleChildScrollView(
          child: Text(
            BackendPDFService.getResourceSummary(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(MessageAction action) {
    return ElevatedButton.icon(
      onPressed: () => _handleActionTap(action),
      icon: Icon(action.icon, size: 18),
      label: Text(
        action.label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 3,
        shadowColor: Colors.blue.withValues(alpha: 0.3),
      ),
    );
  }

  void _handleActionTap(MessageAction action) async {
    switch (action.route) {
      case '/breathing':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BreathingScreen()),
        );
        break;
      case '/journal':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JournalScreen()),
        );
        break;
      case '/calm-game':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GridCalmGame()),
        );
        break;
      case '/video':
        // Launch YouTube video
        if (action.data != null && action.data!['url'] != null) {
          try {
            await ContentService.launchVideo(action.data!['url']!);
            _showVideoLaunchFeedback(action.data!['title'] ?? 'Video');
          } catch (e) {
            _showErrorFeedback(
              'Unable to open video. Please check if you have a browser or YouTube app installed.',
            );
          }
        }
        break;
      case '/lms':
        // Launch LMS website
        try {
          await ContentService.launchLMSWebsite();
          _showLMSLaunchFeedback();
        } catch (e) {
          _showErrorFeedback(
            'Unable to open website. Please check your internet connection and browser.',
          );
        }
        break;
      default:
        // Handle unknown routes
        break;
    }
  }

  void _showVideoLaunchFeedback(String videoTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening "$videoTitle" in YouTube...'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLMSLaunchFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${ContentService.lmsWebsiteName}...'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
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
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                              color: Colors.blue.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
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
                    'assets/icons/user.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: Colors.blue, size: 24),
                  ),
                ),
            ],
          ),
          // Action buttons for AI messages
          if (!isUser && message.actions != null && message.actions!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12, left: 42),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Quick Actions:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      // Learn More text button in top right corner
                      GestureDetector(
                        onTap: () {
                          ContentService.launchLMSWebsite();
                          _showLMSLaunchFeedback();
                        },
                        child: const Text(
                          'Learn More',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      // Show indicator for forced suggestions
                      if (_isMessageForced(message.text))
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: const Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: message.actions!
                        .map((action) => _buildActionButton(action))
                        .toList(),
                  ),
                ],
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
                const Spacer(),
                // Mood indicator
                FutureBuilder<String>(
                  future: _getMoodIndicator(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getMoodColor(snapshot.data!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          snapshot.data!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF4A90E2),
                    size: 28,
                  ),
                  onPressed: _showResourceInfo,
                  tooltip: 'Available Resources',
                ),
                // IconButton(
                //   icon: const Icon(
                //     Icons.picture_as_pdf,
                //     color: Color(0xFF4A90E2),
                //     size: 28,
                //   ),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const PDFChatScreen(),
                //       ),
                //     );
                //   },
                //   tooltip: 'Chat with PDF',
                // ),
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
