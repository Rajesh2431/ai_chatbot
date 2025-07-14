import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(home: TimerScreen()));
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int initialTime = 60; // in seconds
  int remainingTime = initialTime;
  Timer? timer;
  bool isRunning = false;

  void startTimer() {
    if (isRunning) return;

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer?.cancel();
          isRunning = false;
        }
      });
    });
    setState(() {
      isRunning = true;
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      remainingTime = initialTime;
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatTime(remainingTime),
                style: TextStyle(
                  fontSize: 72,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton("Start", Colors.green, startTimer),
                  SizedBox(width: 20),
                  _buildButton("Pause", Colors.orange, pauseTimer),
                  SizedBox(width: 20),
                  _buildButton("Reset", Colors.red, resetTimer),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(label, style: TextStyle(fontSize: 18)),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
