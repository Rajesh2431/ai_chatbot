import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];

  List<Message> get messages => _messages;

  void addUserMessage(String text) {
    _messages.add(Message(text: text, isUser: true));
    notifyListeners();
    // Simulate AI reply
    Future.delayed(Duration(milliseconds: 500), () {
      _messages.add(Message(text: "AI response to: $text", isUser: false));
      notifyListeners();
    });
  }
}
