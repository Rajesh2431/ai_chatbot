import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _text = '';
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _checkMicPermission();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    const welcome =
        "Hi, I’m Shiro. I’m here for you — whether you’re anxious, overwhelmed, or just need to talk. You’re not alone. Let’s take this step together.";
    setState(() {
      _messages.add(_ChatMessage(text: welcome, isUser: false));
    });
    _speak(welcome);
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  void _checkMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
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

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => setState(() {
        _isListening = _speech.isListening;
      }),
      // ignore: avoid_print
      onError: (val) => print('Error: $val'),
    );

    if (available) {
      _speech.listen(
        onResult: (val) async {
          setState(() {
            _text = val.recognizedWords;
            _controller.text = _text;
          });

          if (val.hasConfidenceRating && val.confidence > 0.5) {
            _sendMessage(_text);
          }
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    final reply = await OpenRouterAPI.getResponse(text);

    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false));
      _isTyping = false;
    });
    _scrollToBottom();
    _speak(reply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Voice Chat with AI'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text("Typing...", style: TextStyle(color: Colors.white54)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? Colors.redAccent.withAlpha(2)
                    : Colors.transparent,
              ),
              child: IconButton(
                iconSize: 48,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.redAccent : Colors.white,
                ),
                onPressed: () {
                  _isListening ? _stopListening() : _startListening();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
