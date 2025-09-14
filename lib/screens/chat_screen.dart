import 'dart:math';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/backend_pdf_service.dart';
import '../services/action_detector_service.dart';
import '../services/content_service.dart';
import '../services/mood_based_chat_service.dart';
import '../services/avatar_service.dart';
import '../services/chat_history_service.dart';
import '../widgets/chat_history_drawer.dart';
import 'voicechat_screen.dart';
import 'breathing_timer.dart';
import 'belly_breathing_screen.dart';
import 'box_breathing_screen.dart';
import 'alternate_nostril_breathing_screen.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Message> _messages = [];
  bool _isTyping = false;
  bool _showEmotionButtons = true;

  // Message counting for forced suggestions
  int _messageCount = 0;
  bool _hasShownBreathingSuggestion = false;
  bool _hasShownJournalSuggestion = false;

  // Avatar information
  String _avatarName = 'Saira';
  String _avatarImage = 'lib/assets/avatar/saira.png';

  // Chat history state
  bool _isViewingHistory = false;
  String _historyDate = '';

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _initializeChat();
    _initializePDF();
  }

  @override
  void dispose() {
    // Save chat history when leaving the screen
    _saveChatHistory();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadAvatar() async {
    try {
      final selectedAvatar = await AvatarService.getSelectedAvatar();
      if (selectedAvatar != null) {
        setState(() {
          _avatarName = selectedAvatar['name']!;
          _avatarImage = selectedAvatar['image']!;
        });
      }
    } catch (e) {
      // Use default avatar if loading fails
      print('Error loading avatar: $e');
    }
  }

  void _initializePDF() async {
    // Load PDF content when chat screen initializes
    await BackendPDFService.loadPDFFromAssets();
  }

  /// Save current chat to history
  Future<void> _saveChatHistory() async {
    if (_messages.isNotEmpty) {
      final today = ChatHistoryService.getTodayDateString();
      await ChatHistoryService.saveChatHistory(today, _messages);
    }
  }

  /// Load chat history for a specific date
  void _loadChatHistory(List<Message> messages) {
    setState(() {
      _messages.clear();
      _messages.addAll(messages);
      _showEmotionButtons = false; // Hide emotion buttons for historical chats
      _isViewingHistory = true;
      _historyDate =
          ChatHistoryService.getTodayDateString(); // You might want to pass the actual date
    });
    _scrollToBottom();
  }

  /// Start a new chat session
  void _startNewChat() {
    setState(() {
      _messages.clear();
      _messageCount = 0;
      _hasShownBreathingSuggestion = false;
      _hasShownJournalSuggestion = false;
      _showEmotionButtons = true;
      _isViewingHistory = false;
      _historyDate = '';
    });
    _initializeChat();
  }

  void _initializeChat() async {
    // Wait a bit for avatar to load
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _messages.add(
        Message(
          text: "Hi! I'm $_avatarName, your mental health companion.",
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

      // Add intelligent video suggestion based on user message
      actions = _addIntelligentVideoAction(actions ?? [], text);

      // Always add a breathing exercise suggestion to every AI reply
      actions = _addBreathingExerciseAction(actions);

      if (mounted) {
        setState(() {
          _messages.add(Message(text: reply, isUser: false, actions: actions));
          _isTyping = false;
        });
        _scrollToBottom();

        // Save chat history after each exchange
        _saveChatHistory();
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

      // Force breathing exercise after 2-3 messages (mood-appropriate)
      if (_messageCount >= 2 && !_hasShownBreathingSuggestion) {
        _hasShownBreathingSuggestion = true;
        final techniques = [
          "Let's try some belly breathing to help you relax and center yourself 🌿",
          "How about some box breathing? It's a technique used by Navy SEALs for focus 🌿",
          "Try alternate nostril breathing - it's an ancient technique for balance 🌿",
        ];
        final randomTechnique = techniques[Random().nextInt(techniques.length)];
        return moodSuggestions.isNotEmpty
            ? moodSuggestions[0]
            : randomTechnique;
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
      if (_messageCount >= 2 && !_hasShownBreathingSuggestion) {
        _hasShownBreathingSuggestion = true;
        final techniques = [
          "Let's try some belly breathing to help you relax and center yourself 🌿",
          "How about some box breathing? It's a technique used by Navy SEALs for focus 🌿",
          "Try alternate nostril breathing - it's an ancient technique for balance 🌿",
        ];
        return techniques[Random().nextInt(techniques.length)];
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

  /// Add intelligent video suggestion based on user message
  List<MessageAction> _addIntelligentVideoAction(
    List<MessageAction> existingActions,
    String userMessage,
  ) {
    // Try to get a relevant video based on user message
    final suggestedVideo = ContentService.analyzeMessageAndSuggestVideo(userMessage);
    
    // If no relevant video found, use random video as fallback
    final videoToSuggest = suggestedVideo ?? ContentService.getRandomVideo();
    
    // Detect emotions to customize the label
    final emotions = ContentService.analyzeMessageSentiment(userMessage);
    
    String videoLabel = "▶️ ${videoToSuggest['title']}";
    
    // Customize label based on detected emotions or relevance
    if (suggestedVideo != null) {
      if (emotions.contains('anxiety')) {
        videoLabel = "🌿 ${videoToSuggest['title']} (For Anxiety)";
      } else if (emotions.contains('sadness') || emotions.contains('loneliness')) {
        videoLabel = "💙 ${videoToSuggest['title']} (For Support)";
      } else if (emotions.contains('anger')) {
        videoLabel = "🧘 ${videoToSuggest['title']} (For Calm)";
      } else {
        videoLabel = "🎯 ${videoToSuggest['title']} (Recommended)";
      }
    }

    final videoAction = MessageAction(
      label: videoLabel,
      route: '/video',
      icon: suggestedVideo != null ? Icons.recommend : Icons.play_circle_fill,
      data: {
        'url': videoToSuggest['url']!,
        'title': videoToSuggest['title']!,
        'description': videoToSuggest['description']!,
        'isRelevant': suggestedVideo != null ? 'true' : 'false',
        'detectedEmotions': emotions.join(', '),
      },
    );

    // Add video action to existing actions
    return [...existingActions, videoAction];
  }

  /// Add a random video action to the actions list (kept for backward compatibility)
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

  /// Add a random breathing exercise action to the actions list
  List<MessageAction> _addBreathingExerciseAction(
    List<MessageAction> existingActions,
  ) {
    final techniques = [
      {
        'name': 'Belly Breathing',
        'description': 'Deep diaphragmatic breathing to reduce stress',
        'icon': Icons.favorite,
        'route': '/belly-breathing',
        'emoji': '🫁',
        'screen': const BellyBreathingScreen(),
      },
      {
        'name': 'Box Breathing',
        'description': '4-4-4-4 pattern used by Navy SEALs',
        'icon': Icons.crop_square,
        'route': '/box-breathing',
        'emoji': '⬜',
        'screen': const BoxBreathingScreen(),
      },
      {
        'name': 'Alternate Nostril',
        'description': 'Ancient yogic technique for balance',
        'icon': Icons.air,
        'route': '/nostril-breathing',
        'emoji': '🌬️',
        'screen': const AlternateNostrilBreathingScreen(),
      },
    ];

    final randomTechnique = techniques[Random().nextInt(techniques.length)];

    final breathingAction = MessageAction(
      label: "${randomTechnique['emoji']} ${randomTechnique['name']}",
      route: randomTechnique['route'] as String,
      icon: randomTechnique['icon'] as IconData,
      data: {
        'description': randomTechnique['description'] as String,
        'name': randomTechnique['name'] as String,
      },
    );

    // Add breathing action to existing actions
    return [...existingActions, breathingAction];
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
    // Special styling for video actions
    if (action.route == '/video') {
      return _buildVideoActionButton(action);
    }
    
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

  Widget _buildVideoActionButton(MessageAction action) {
    final isRelevant = action.data?['isRelevant'] == 'true';
    final description = action.data?['description'] ?? '';
    final emotions = action.data?['detectedEmotions'] ?? '';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isRelevant 
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: (isRelevant ? Colors.green : Colors.red).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleActionTap(action),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isRelevant ? Icons.recommend : Icons.play_circle_fill,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        action.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isRelevant)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'MATCH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (isRelevant && emotions.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Detected: $emotions',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleActionTap(MessageAction action) async {
    switch (action.route) {
      case '/breathing':
        // Navigate to breathing selection screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BreathingScreen()),
        );
        break;
      case '/belly-breathing':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BellyBreathingScreen()),
        );
        break;
      case '/box-breathing':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BoxBreathingScreen()),
        );
        break;
      case '/nostril-breathing':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AlternateNostrilBreathingScreen(),
          ),
        );
        break;
      case '/breathing/belly':
      case '/breathing/box':
      case '/breathing/nostril':
        // Legacy support - navigate to breathing selection screen
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
        // Launch YouTube video with enhanced feedback
        if (action.data != null && action.data!['url'] != null) {
          try {
            await ContentService.launchVideo(action.data!['url']!);
            
            // Show enhanced feedback for relevant videos
            final isRelevant = action.data!['isRelevant'] == 'true';
            final emotions = action.data!['detectedEmotions'] ?? '';
            
            if (isRelevant && emotions.isNotEmpty) {
              _showRelevantVideoFeedback(
                action.data!['title'] ?? 'Video',
                emotions,
              );
            } else {
              _showVideoLaunchFeedback(action.data!['title'] ?? 'Video');
            }
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

  void _showRelevantVideoFeedback(String videoTitle, String emotions) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opening recommended video: "$videoTitle"',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Selected based on: $emotions',
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Great!',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                ClipOval(
                  child: Image.asset(
                    _avatarImage,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/icons/profile.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        color: Colors.deepOrange,
                        size: 24,
                      ),
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
                ClipOval(
                  child: Image.asset(
                    'assets/icons/user.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
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
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: ChatHistoryDrawer(
        onHistorySelected: _loadChatHistory,
        onNewChat: _startNewChat,
      ),
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
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                // Avatar name display with history indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _avatarName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    if (_isViewingHistory)
                      const Text(
                        'Chat History',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
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
                  ClipOval(
                    child: Image.asset(
                      _avatarImage,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/icons/profile.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: Colors.deepOrange,
                          size: 16,
                        ),
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
