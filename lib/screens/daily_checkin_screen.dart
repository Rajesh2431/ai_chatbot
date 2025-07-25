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
  
  List<ChatMessage> messages = [];
  int currentQuestionIndex = 0;
  bool isTyping = false;
  bool isCompleted = false;
  
  final List<DailyQuestion> questions = [
    DailyQuestion(
      question: "Good morning! How are you feeling today?",
      options: [
        MoodOption("😊 Great! I'm feeling amazing", 5),
        MoodOption("🙂 Pretty good, thanks for asking", 4),
        MoodOption("😐 Okay, just a normal day", 3),
        MoodOption("😔 Not so great today", 2),
        MoodOption("😞 Having a tough day", 1),
      ],
    ),
    DailyQuestion(
      question: "How well did you sleep last night?",
      options: [
        MoodOption("😴 Slept like a baby, very refreshed", 5),
        MoodOption("😊 Good sleep, feeling rested", 4),
        MoodOption("😐 Average sleep, could be better", 3),
        MoodOption("😪 Restless night, feeling tired", 2),
        MoodOption("😵 Barely slept, exhausted", 1),
      ],
    ),
    DailyQuestion(
      question: "What's your energy level right now?",
      options: [
        MoodOption("⚡ Full of energy and ready to go!", 5),
        MoodOption("💪 Good energy, feeling motivated", 4),
        MoodOption("🔋 Moderate energy, doing okay", 3),
        MoodOption("🪫 Low energy, feeling drained", 2),
        MoodOption("😴 Very low energy, need rest", 1),
      ],
    ),
    DailyQuestion(
      question: "How stressed do you feel today?",
      options: [
        MoodOption("😌 Very relaxed and calm", 5),
        MoodOption("🙂 Mostly calm with minor stress", 4),
        MoodOption("😐 Moderate stress levels", 3),
        MoodOption("😰 Quite stressed about things", 2),
        MoodOption("😫 Very stressed and overwhelmed", 1),
      ],
    ),
    DailyQuestion(
      question: "How optimistic are you feeling about today?",
      options: [
        MoodOption("🌟 Very optimistic and excited!", 5),
        MoodOption("😊 Pretty positive about today", 4),
        MoodOption("😐 Neutral, we'll see how it goes", 3),
        MoodOption("😕 Not very optimistic", 2),
        MoodOption("😞 Feeling quite pessimistic", 1),
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _startCheckin();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _startCheckin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addAIMessage("Hello! I'm ${widget.avatarName}, your daily companion. Let's do a quick check-in to see how you're doing today! 😊");
    
    await Future.delayed(const Duration(milliseconds: 2000));
    _askNextQuestion();
  }

  void _addAIMessage(String message) {
    setState(() {
      messages.add(ChatMessage(
        message: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _fadeController.forward();
  }

  void _addUserMessage(String message, int score) {
    setState(() {
      messages.add(ChatMessage(
        message: message,
        isUser: true,
        timestamp: DateTime.now(),
        moodScore: score,
      ));
    });
  }

  void _askNextQuestion() {
    if (currentQuestionIndex < questions.length) {
      setState(() {
        isTyping = true;
      });
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          isTyping = false;
        });
        _addAIMessage(questions[currentQuestionIndex].question);
      });
    } else {
      _completeCheckin();
    }
  }

  void _handleOptionSelected(MoodOption option) async {
    _addUserMessage(option.text, option.score);
    
    // Store the mood score
    await MoodService.storeDailyMoodScore(
      questions[currentQuestionIndex].question,
      option.score,
    );
    
    currentQuestionIndex++;
    
    // Add encouraging response
    await Future.delayed(const Duration(milliseconds: 1000));
    _addAIMessage(_getEncouragingResponse(option.score));
    
    await Future.delayed(const Duration(milliseconds: 2000));
    _askNextQuestion();
  }

  String _getEncouragingResponse(int score) {
    if (score >= 4) {
      final responses = [
        "That's wonderful to hear! 🌟",
        "I'm so glad you're feeling good! 😊",
        "That's fantastic! Keep up the positive energy! ✨",
        "Amazing! You're doing great! 💪",
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
      final responses = [
        "I'm here for you. Remember, tough days don't last! 💙",
        "Thank you for sharing. You're not alone in this! 🤗",
        "I understand. Let's work together to make today better! 🌈",
        "It's okay to have difficult days. I'm here to support you! 💚",
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
    await prefs.setString('last_checkin_date', DateTime.now().toIso8601String().split('T')[0]);
    
    _addAIMessage("Thank you for sharing with me today! 🙏 Based on our chat, I can see how you're feeling. Remember, I'm always here when you need support!");
    
    await Future.delayed(const Duration(milliseconds: 2000));
    _addAIMessage("Let's head to your dashboard where you can explore activities that might help brighten your day! 🌟");
    
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
                          fit: BoxFit.cover,
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
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isTyping) {
                      return _buildTypingIndicator();
                    }
                    
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),

              // Options (only show for current question)
              if (currentQuestionIndex < questions.length && 
                  messages.isNotEmpty && 
                  !messages.last.isUser && 
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.avatarImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: message.isUser 
                      ? Colors.blue[500] 
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
                    bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[600],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
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
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: ClipOval(
              child: Image.asset(
                widget.avatarImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Typing', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: questions[currentQuestionIndex].options.map((option) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: () => _handleOptionSelected(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue[200]!),
                ),
                elevation: 0,
              ),
              child: Text(
                option.text,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.left,
              ),
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

  DailyQuestion({
    required this.question,
    required this.options,
  });
}

class MoodOption {
  final String text;
  final int score;

  MoodOption(this.text, this.score);
}