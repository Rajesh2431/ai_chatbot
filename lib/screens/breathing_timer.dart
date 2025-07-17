import 'dart:async';
import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  final int durationSeconds;
  const BreathingExerciseScreen({super.key, required this.durationSeconds});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  bool _isInhale = true;
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds % 8 == 0) {
          _isInhale = !_isInhale;
        }
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _animationController.stop();
          _showCompletionDialog();
        }
      });
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text("Exercise Complete", style: TextStyle(color: Colors.white)),
        content: const Text("You’ve completed your breathing exercise.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ok", style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    ).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _isInhale ? "Inhale" : "Exhale";
    final color = _isInhale ? Colors.tealAccent : Colors.deepOrangeAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Breathing Exercise"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Text(
              "$_remainingSeconds s",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.2).animate(
                CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
              ),
              child: Container(
                height: 240,
                width: 240,
                decoration: BoxDecoration(
                  color: color.withAlpha(2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(5),
                      blurRadius: 24,
                      spreadRadius: 6,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
