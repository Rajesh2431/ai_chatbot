import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  String _statusText = "Inhale";

  Duration _remainingTime = Duration.zero;

  // Motivational quotes
  final List<String> _motivationalQuotes = [
    "Breathe in peace, breathe out stress 🌸",
    "Every breath is a new beginning ✨",
    "Calm mind brings inner strength 🧘‍♀️",
    "Inhale confidence, exhale doubt 💫",
    "Peace comes from within 🕊️",
    "Breathe deeply and let go 🌊",
    "Find your center, find your calm 🎯",
    "Each breath brings you closer to peace 🌿",
    "Stillness is the key to clarity 🔑",
    "Breathe in love, breathe out fear ❤️",
  ];

  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _radiusAnimation = Tween<double>(begin: 80, end: 160).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Select a random motivational quote
    _currentQuote =
        _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
  }

  @override
  void dispose() {
    _breathController.dispose();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startBreathing(Duration duration) {
    setState(() {
      _remainingTime = duration;
      _hasStarted = true;
      _isRunning = true;
      _statusText = "Inhale";
    });

    _breathController.repeat(reverse: true);

    // Add listener to change text with animation
    _breathController.addStatusListener((status) {
      if (!_isRunning) return;
      setState(() {
        _statusText = status == AnimationStatus.forward ? "Inhale" : "Exhale";
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
      _hasStarted = false;
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
        color: Colors.blue.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: opacity * 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome text
          const Text(
            'Breathing Exercise',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Choose your session duration',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 50),

          // Duration buttons
          Column(
            children: [
              _durationButton(
                "1 Minute",
                const Duration(minutes: 1),
                Icons.looks_one,
              ),
              const SizedBox(height: 16),
              _durationButton(
                "3 Minutes",
                const Duration(minutes: 3),
                Icons.looks_3,
              ),
              const SizedBox(height: 16),
              _durationButton(
                "5 Minutes",
                const Duration(minutes: 5),
                Icons.looks_5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _durationButton(String label, Duration duration, IconData icon) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: () => _startBreathing(duration),
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.blue.shade200),
          ),
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
      ),
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
            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF), Color(0xFFDEE2E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 📱 HEADER - Time Display
              _buildHeader(),

              // 🧘 MIDDLE - Breathing Animation (Expanded to take remaining space)
              Expanded(
                child: !_hasStarted
                    ? _buildDurationPanel()
                    : _buildBreathingAnimation(),
              ),

              // 💬 FOOTER - Motivational Quote
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Top row with back button and timer
          Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: 28,
                ),
                onPressed: _goBack,
              ),

              const Spacer(),

              // Time display
              if (_hasStarted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_remainingTime),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Placeholder for symmetry
              const SizedBox(width: 56),
            ],
          ),

          // Inhale/Exhale text
          if (_hasStarted) ...[
            const SizedBox(height: 20),
            Text(
              _statusText,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced breathing animation
          AnimatedBuilder(
            animation: _radiusAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow rings
                  _buildRing(2.2, 0.05),
                  _buildRing(1.9, 0.08),
                  _buildRing(1.6, 0.12),
                  _buildRing(1.3, 0.18),

                  // Main breathing circle
                  Container(
                    width: _radiusAnimation.value,
                    height: _radiusAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue.withValues(alpha: 0.8),
                          Colors.blue.withValues(alpha: 0.5),
                          Colors.blue.withValues(alpha: 0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  // Center dot
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Stop button (only during active session)
          if (_hasStarted) ...[
            ElevatedButton.icon(
              onPressed: _stopBreathing,
              icon: const Icon(Icons.stop, size: 20),
              label: const Text("Stop Session"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Motivational quote
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              _currentQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
