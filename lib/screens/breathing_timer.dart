import 'package:flutter/material.dart';
import 'dart:async';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _radiusAnimation;
  Timer? _sessionTimer;

  bool _isRunning = false;
  bool _hasStarted = false;
  String _statusText = "Select Duration";

  Duration _selectedDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _radiusAnimation = Tween<double>(begin: 60, end: 140).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startBreathing(Duration duration) {
    setState(() {
      _selectedDuration = duration;
      _remainingTime = duration;
      _hasStarted = true;
      _isRunning = true;
      _statusText = "Breathe In";
    });

    _breathController.repeat(reverse: true);

    _breathController.addStatusListener((status) {
      if (!_isRunning) return;
      setState(() {
        _statusText =
            status == AnimationStatus.forward ? "Breathe In" : "Breathe Out";
      });
    });

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 1) {
        _stopBreathing();
        timer.cancel();
      } else {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopBreathing() {
    setState(() {
      _isRunning = false;
      _statusText = "Session Complete";
    });
    _breathController.stop();
    _sessionTimer?.cancel();
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Widget _buildRing(double scale, double opacity) {
    return Container(
      width: _radiusAnimation.value * scale,
      height: _radiusAnimation.value * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _buildDurationPanel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Duration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              children: [
                _durationButton("1 min", const Duration(minutes: 1)),
                _durationButton("2 min", const Duration(minutes: 2)),
                _durationButton("5 min", const Duration(minutes: 5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationButton(String label, Duration duration) {
    return ElevatedButton(
      onPressed: () => _startBreathing(duration),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2EBF2), Color(0xFF81D4FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 🔙 Back button
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _goBack,
                ),
              ),

              // 🧘 Center content
              Center(
                child: !_hasStarted
                    ? _buildDurationPanel()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ⏳ Static Countdown
                          Text(
                            _formatDuration(_remainingTime),
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 🌊 Breathing Animation
                          AnimatedBuilder(
                            animation: _radiusAnimation,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  _buildRing(1.8, 0.08),
                                  _buildRing(1.5, 0.12),
                                  _buildRing(1.2, 0.16),
                                  _buildRing(1.0, 0.20),
                                  _buildRing(0.7, 1.0),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // 💬 Static Status Text
                          Text(
                            _statusText,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),

              // 🛑 Static Stop Button
              if (_hasStarted)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _stopBreathing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Stop", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
