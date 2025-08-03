import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/mood_service.dart';
import 'dashboard_screen.dart';

class DailyCheckinScreen extends StatefulWidget {
  final String avatarName;
  final String avatarImage;

  const DailyCheckinScreen({
    super.key,
    required this.avatarName,
    required this.avatarImage,
  });

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];
  int currentQuestionIndex = 0;
  bool isTyping = false;
  bool isCompleted = false;
  bool showOptions = false; // Add this to control when options appear

  final List<DailyQuestion> questions = [
    DailyQuestion(
      question: "Good morning! How are you feeling today?",
      options: [
        MoodOption("Excellent", "😄", 5),
        MoodOption("Great", "😊", 4),
        MoodOption("Good", "🙂", 3),
        MoodOption("Okay", "😐", 2),
      ],
    ),
    DailyQuestion(
      question: "How well did you sleep last night?",
      options: [
        MoodOption("Excellent", "😴", 5),
        MoodOption("Very well", "😊", 4),
        MoodOption("Good", "🙂", 3),
        MoodOption("Average", "😐", 2),
      ],
    ),
    DailyQuestion(
      question: "What's your energy level right now?",
      options: [
        MoodOption("Very high", "⚡", 5),
        MoodOption("High", "💪", 4),
        MoodOption("Good", "🔋", 3),
        MoodOption("Moderate", "😐", 2),
      ],
    ),
    DailyQuestion(
      question: "How stressed do you feel today?",
      options: [
        MoodOption("Very calm", "😌", 5),
        MoodOption("Calm", "🙂", 4),
        MoodOption("Slightly tense", "😊", 3),
        MoodOption("Moderate stress", "😐", 2),
      ],
    ),
    DailyQuestion(
      question: "How optimistic are you feeling about today?",
      options: [
        MoodOption("Very optimistic", "🌟", 5),
        MoodOption("Optimistic", "😊", 4),
        MoodOption("Positive", "🙂", 3),
        MoodOption("Neutral", "😐", 2),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _startCheckin();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startCheckin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addAIMessage(
      "Hello! I'm ${widget.avatarName}, your daily companion. Let's do a quick check-in to see how you're doing today! 😊",
    );

    await Future.delayed(const Duration(milliseconds: 3000));
    _askNextQuestion();
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

  void _addAIMessage(String message) {
    setState(() {
      messages.add(
        ChatMessage(message: message, isUser: false, timestamp: DateTime.now()),
      );
    });
    _fadeController.forward();
    _scrollToBottom();
  }

  void _addUserMessage(String message, int score) {
    setState(() {
      messages.add(
        ChatMessage(
          message: message,
          isUser: true,
          timestamp: DateTime.now(),
          moodScore: score,
        ),
      );
    });
    _scrollToBottom();
  }

  void _askNextQuestion() {
    if (currentQuestionIndex < questions.length) {
      setState(() {
        isTyping = true;
        showOptions = false; // Hide options while typing
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          isTyping = false;
        });
        _addAIMessage(questions[currentQuestionIndex].question);

        // Show options after AI message is added and a brief delay
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            showOptions = true;
          });
        });
      });
    } else {
      _completeCheckin();
    }
  }

  void _handleOptionSelected(MoodOption option) async {
    // Hide options immediately when one is selected
    setState(() {
      showOptions = false;
    });

    _addUserMessage(option.text, option.score);

    // Store the mood score
    await MoodService.storeDailyMoodScore(
      questions[currentQuestionIndex].question,
      option.score,
    );

    currentQuestionIndex++;

    // Add encouraging response with typing indicator
    setState(() {
      isTyping = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      isTyping = false;
    });

    _addAIMessage(_getEncouragingResponse(option.score));

    await Future.delayed(const Duration(milliseconds: 2000));
    _askNextQuestion();
  }

  String _getEncouragingResponse(int score) {
    if (score == 5) {
      final responses = [
        "That's wonderful to hear! 🌟",
        "I'm so glad you're feeling excellent! 😊",
        "That's fantastic! Keep up the positive energy! ✨",
        "Amazing! You're doing great! 💪",
      ];
      return responses[Random().nextInt(responses.length)];
    } else if (score == 4) {
      final responses = [
        "That's great to hear! 😊",
        "I'm happy you're feeling good! 💙",
        "That's wonderful! Keep it up! ✨",
        "Nice! You're doing well! 👍",
      ];
      return responses[Random().nextInt(responses.length)];
    } else if (score == 3) {
      final responses = [
        "That's perfectly okay! Every day is different. 🤗",
        "Thanks for being honest with me! 💙",
        "That's completely normal! 😊",
        "I appreciate you sharing that with me! 🌸",
      ];
      return responses[Random().nextInt(responses.length)];
    } else {
      // score == 2
      final responses = [
        "I'm here for you. Remember, every day is a new opportunity! 💙",
        "Thank you for sharing. You're not alone in this! 🤗",
        "I understand. Let's work together to make today better! 🌈",
        "It's okay to have challenging moments. I'm here to support you! 💚",
      ];
      return responses[Random().nextInt(responses.length)];
    }
  }

  void _completeCheckin() async {
    setState(() {
      isCompleted = true;
    });

    // Calculate overall mood score
    double totalScore = 0;
    int scoreCount = 0;
    for (var message in messages) {
      if (message.moodScore != null) {
        totalScore += message.moodScore!;
        scoreCount++;
      }
    }

    double averageScore = scoreCount > 0 ? totalScore / scoreCount : 3.0;

    // Store overall daily mood
    await MoodService.storeDailyOverallMood(averageScore);

    // Mark daily check-in as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_checkin_date',
      DateTime.now().toIso8601String().split('T')[0],
    );

    _addAIMessage(
      "Thank you for sharing with me today! 🙏 Based on our chat, I can see how you're feeling. Remember, I'm always here when you need support!",
    );

    await Future.delayed(const Duration(milliseconds: 2000));
    _addAIMessage(
      "Let's head to your dashboard where you can explore activities that might help brighten your day! 🌟",
    );

    await Future.delayed(const Duration(milliseconds: 3000));
    _navigateToDashboard();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFF0F8FF), // Alice blue
              Color(0xFFF5F5F5), // Light gray
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with avatar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue[300]!, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          widget.avatarImage,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade300,
                                    Colors.blue.shade100,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.avatarName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Text(
                            'Daily Check-in Assistant',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Decorative elements
                    const Text('✨', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),

              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0 && isTyping) {
                      return _buildTypingIndicator();
                    }

                    final messageIndex = isTyping ? index - 1 : index;
                    final reversedIndex = messages.length - 1 - messageIndex;
                    final message = messages[reversedIndex];
                    return _buildMessageBubble(message);
                  },
                ),
              ),

              // Options (only show when showOptions is true)
              if (showOptions &&
                  currentQuestionIndex < questions.length &&
                  !isTyping &&
                  !isCompleted)
                _buildOptionsPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: message.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment:
              CrossAxisAlignment.start, // Changed from end to start
          children: [
            if (!message.isUser) ...[
              Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyan.shade200.withValues(alpha: 0.8),
                      Colors.cyan.shade100.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.avatarImage,
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.shade300,
                              Colors.cyan.shade100,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? Colors.blue[500]
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: message.isUser
                        ? const Radius.circular(20)
                        : const Radius.circular(4),
                    bottomRight: message.isUser
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (message.isUser) ...[
              const SizedBox(width: 12),
              Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to start
        children: [
          Container(
            width: 45,
            height: 45,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.cyan.shade200.withValues(alpha: 0.8),
                  Colors.cyan.shade100.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                widget.avatarImage,
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.cyan.shade300, Colors.cyan.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Typing...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: questions[currentQuestionIndex].options.asMap().entries.map((
          entry,
        ) {
          int index = entry.key;
          MoodOption option = entry.value;

          // Define colors for the four options based on score (5=green, 4=blue, 3=orange, 2=red)
          List<Color> buttonColors = [
            Colors.green, // Score 5 - Excellent/Best option
            Colors.blue, // Score 4 - Great/Good option
            Colors.orange, // Score 3 - Good/Moderate option
            Colors.red, // Score 2 - Okay/Lower option
          ];

          Color buttonColor = buttonColors[index];

          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: buttonColor.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => _handleOptionSelected(option),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.text,
                  style: TextStyle(color: buttonColor, fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(option.emoji, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final int? moodScore;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.moodScore,
  });
}

class DailyQuestion {
  final String question;
  final List<MoodOption> options;

  DailyQuestion({required this.question, required this.options});
}

class MoodOption {
  final String text;
  final String emoji;
  final int score;

  MoodOption(this.text, this.emoji, this.score);
}
