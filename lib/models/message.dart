import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isUser;
  final List<MessageAction>? actions;

  Message({
    required this.text, 
    required this.isUser,
    this.actions,
  });
}

class MessageAction {
  final String label;
  final String route;
  final IconData icon;
  final Map<String, String>? data; // Additional data for actions like video info

  MessageAction({
    required this.label,
    required this.route,
    required this.icon,
    this.data,
  });
}
