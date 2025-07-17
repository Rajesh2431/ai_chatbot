import 'package:flutter/material.dart';
import '../widget/message_bubble.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/depression_service.dart';
import '../widget/option_bubble.dart';
import '../screens/breathing_timer.dart'; // 👈 Import breathing screen

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
  bool _isQuestionnaireActive = false;
  int _currentQuestionIndex = 0;
  int _totalScore = 0;
  bool _awaitingPostExerciseFeedback = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final welcome = DepressionService.getRandomWelcomeMessage();
    setState(() {
      _messages.add(Message(text: welcome, isUser: false));
      _isQuestionnaireActive = true;
    });
    _scrollToBottom();
    await Future.delayed(Duration(seconds: 1));
    _askNextQuestion();
  }

  void _askNextQuestion() {
    if (_currentQuestionIndex < DepressionService.questions.length) {
      final q = DepressionService.questions[_currentQuestionIndex];
      setState(() {
        _messages.add(Message(text: q.text, isUser: false));
      });
      _scrollToBottom();
    } else {
      final result = DepressionService.getResultMessage(_totalScore);
      final activities = DepressionService.getRecommendedActivities(result);
      setState(() {
        _messages.add(
          Message(text: "Your depression level: $result", isUser: false),
        );
        _messages.add(Message(text: activities, isUser: false));
        _messages.add(
          Message(
            text:
                "Here’s a task to start with: Try one of the listed activities today and write about how it made you feel. Tap below to start a breathing exercise.",
            isUser: false,
          ),
        );
        _isQuestionnaireActive = false;
      });
      _scrollToBottom();

      Future.delayed(Duration(seconds: 1), () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          backgroundColor: Colors.black87,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Start Breathing Exercise", style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final completed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreathingExerciseScreen(durationSeconds: 60),
                      ),
                    );
                    if (completed == true) {
                      setState(() {
                        _messages.add(Message(
                          text: "How do you feel after the breathing exercise?",
                          isUser: false,
                        ));
                        _awaitingPostExerciseFeedback = true;
                      });
                      _scrollToBottom();
                    }
                  },
                  child: Text("1 Minute"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final completed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BreathingExerciseScreen(durationSeconds: 120),
                      ),
                    );
                    if (completed == true) {
                      setState(() {
                        _messages.add(Message(
                          text: "How do you feel after the breathing exercise?",
                          isUser: false,
                        ));
                        _awaitingPostExerciseFeedback = true;
                      });
                      _scrollToBottom();
                    }
                  },
                  child: Text("2 Minutes"),
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  void _submitAnswer(int score) {
    final currentQuestion = DepressionService.questions[_currentQuestionIndex];
    final selectedOption = currentQuestion.options[
        currentQuestion.scores.indexOf(score)];
    setState(() {
      _messages.add(Message(text: selectedOption, isUser: true));
    });
    _totalScore += score;
    _currentQuestionIndex++;
    _askNextQuestion();
  }

  void _sendMessage(String text) async {
    if (text.isEmpty || _isTyping || _isQuestionnaireActive) return;
    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    String reply;
    if (_awaitingPostExerciseFeedback) {
      reply = "Thank you for sharing. Remember, it’s okay to feel what you feel. Let's keep exploring ways to feel better.";
      _awaitingPostExerciseFeedback = false;
    } else {
      reply = await OpenRouterAPI.getResponse(text);
    }

    setState(() {
      _messages.add(Message(text: reply, isUser: false));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildInputBar() {
    final sendEnabled = !_isTyping && !_isQuestionnaireActive;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: Colors.white70),
            const SizedBox(width: 8),
            const Icon(Icons.tune, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Ask anything",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onSubmitted: sendEnabled ? (text) => _sendMessage(text) : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.white70),
              onPressed: sendEnabled ? () {} : null,
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: sendEnabled ? Colors.white70 : Colors.white24,
              ),
              onPressed: sendEnabled
                  ? () => _sendMessage(_controller.text.trim())
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Text(
          "Mental Health AI",
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 0),
              children: [
                if (_messages.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white24),
                  ),
                ..._messages.map(
                  (msg) => MessageBubble(text: msg.text, isUser: msg.isUser),
                ),
                if (_isQuestionnaireActive &&
                    _currentQuestionIndex <
                        DepressionService.questions.length)
                  Wrap(
                    children: List.generate(
                      DepressionService
                          .questions[_currentQuestionIndex]
                          .options
                          .length,
                      (i) => OptionBubble(
                        label: DepressionService
                            .questions[_currentQuestionIndex]
                            .options[i],
                        onTap: () => _submitAnswer(
                          DepressionService
                              .questions[_currentQuestionIndex]
                              .scores[i],
                        ),
                      ),
                    ),
                  ),
                if (_isTyping)
                  const Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 12),
                    child: Text(
                      "Typing...",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
              ],
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }
}
