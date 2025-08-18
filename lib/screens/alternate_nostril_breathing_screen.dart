import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class AlternateNostrilBreathingScreen extends StatefulWidget {
  const AlternateNostrilBreathingScreen({super.key});

  @override
  State<AlternateNostrilBreathingScreen> createState() => _AlternateNostrilBreathingScreenState();
}

class _AlternateNostrilBreathingScreenState extends State<AlternateNostrilBreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _pulseController;
  late Animation<double> _radiusAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _sessionTimer;
  Timer? _phaseTimer;

  bool _isRunning = false;
  bool _hasStarted = false;
  String _statusText = "Left nostril in";
  int _currentPhaseIndex = 0;
  Duration _remainingTime = Duration.zero;

  // Alternate nostril breathing specific data
  final List<String> _phases = [
    "Left nostril in",
    "Hold",
    "Right nostril out",
    "Right nostril in",
    "Hold",
    "Left nostril out",
  ];
  final List<int> _durations = [4, 2, 4, 4, 2, 4];
  final Color _primaryColor = const Color(0xFF29B6F6);
  final Color _secondaryColor = const Color(0xFFE0F2F1);

  final List<String> _motivationalQuotes = [
    "Ancient yogic technique for perfect balance 🌬️",
    "Harmonize your left and right brain ✨",
    "Alternate breathing, alternate awareness 🧘‍♀️",
    "Balance your nervous system naturally 💫",
    "Pranayama brings inner peace 🕊️",
  ];

  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _currentQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startBreathing(Duration duration) {
    setState(() {
      _remainingTime = duration;
      _hasStarted = true;
      _isRunning = true;
      _currentPhaseIndex = 0;
      _statusText = _phases[0];
    });

    _pulseController.stop();
    _pulseController.reset();
    _startPhaseTimer();

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

  void _startPhaseTimer() {
    final phaseDuration = _durations[_currentPhaseIndex];
    final currentPhase = _phases[_currentPhaseIndex].toLowerCase();

    _breathController.duration = Duration(seconds: phaseDuration);
    
    if (currentPhase.contains('in')) {
      _breathController.reset();
      _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
        CurvedAnimation(parent: _breathController, curve: Curves.easeIn),
      );
      _breathController.forward();
    } else if (currentPhase.contains('out')) {
      _breathController.reset();
      _radiusAnimation = Tween<double>(begin: 180, end: 60).animate(
        CurvedAnimation(parent: _breathController, curve: Curves.easeOut),
      );
      _breathController.forward();
    } else if (currentPhase.contains('hold')) {
      _breathController.stop();
      final currentRadius = _radiusAnimation.value;
      
      _pulseController.duration = Duration(milliseconds: 800);
      _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );
      _pulseController.repeat(reverse: true);
      
      _radiusAnimation = Tween<double>(begin: currentRadius, end: currentRadius)
          .animate(_breathController);
    }

    _phaseTimer = Timer(Duration(seconds: phaseDuration), () {
      if (!_isRunning) return;

      setState(() {
        _currentPhaseIndex = (_currentPhaseIndex + 1) % _phases.length;
        _statusText = _phases[_currentPhaseIndex];
      });

      _startPhaseTimer();
    });
  }

  void _stopBreathing() {
    setState(() {
      _isRunning = false;
      _hasStarted = false;
      _statusText = "Session Complete";
    });
    
    _breathController.stop();
    _pulseController.stop();
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    
    _breathController.reset();
    _pulseController.duration = const Duration(seconds: 2);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    _pulseController.repeat(reverse: true);
  }

  Widget _buildRing(double scale, double opacity, Color color) {
    return Container(
      width: _radiusAnimation.value * scale,
      height: _radiusAnimation.value * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _durationButton(String label, Duration duration, IconData icon) {
    return SizedBox(
      width: 220,
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
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: _primaryColor.withValues(alpha: 0.3)),
          ),
          elevation: 8,
          shadowColor: _primaryColor.withValues(alpha: 0.3),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _secondaryColor,
              _primaryColor.withValues(alpha: 0.3),
              _primaryColor.withValues(alpha: 0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    if (_hasStarted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer, color: _primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(_remainingTime),
                              style: TextStyle(
                                fontSize: 20,
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Text(
                        'Alternate Nostril Breathing',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.0,
                        ),
                      ),
                    const Spacer(),
                    const SizedBox(width: 56),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: !_hasStarted ? _buildDurationPanel() : _buildBreathingAnimation(),
              ),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.air, size: 48, color: _primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Alternate Nostril Breathing',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ancient yogic technique to balance mind and body',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Choose your session duration',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 30),
          Column(
            children: [
              _durationButton("1 Minute", const Duration(minutes: 1), Icons.looks_one),
              const SizedBox(height: 16),
              _durationButton("3 Minutes", const Duration(minutes: 3), Icons.looks_3),
              const SizedBox(height: 16),
              _durationButton("5 Minutes", const Duration(minutes: 5), Icons.looks_5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              _statusText,
              style: TextStyle(
                fontSize: 24,
                color: _primaryColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 60),
          AnimatedBuilder(
            animation: Listenable.merge([_radiusAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildRing(2.8, 0.02, _primaryColor),
                    _buildRing(2.4, 0.04, _primaryColor),
                    _buildRing(2.0, 0.06, _primaryColor),
                    _buildRing(1.6, 0.10, _primaryColor),
                    _buildRing(1.3, 0.15, _primaryColor),
                    Container(
                      width: _radiusAnimation.value,
                      height: _radiusAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _primaryColor.withValues(alpha: 0.95),
                            _primaryColor.withValues(alpha: 0.7),
                            _primaryColor.withValues(alpha: 0.4),
                            _primaryColor.withValues(alpha: 0.15),
                            _primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withValues(alpha: 0.5),
                            blurRadius: _radiusAnimation.value * 0.3,
                            spreadRadius: _radiusAnimation.value * 0.1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.95),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(Icons.air, color: _primaryColor, size: 30),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Phase ${_currentPhaseIndex + 1} of 6',
              style: TextStyle(
                fontSize: 14,
                color: _primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasStarted) ...[
            ElevatedButton.icon(
              onPressed: _stopBreathing,
              icon: const Icon(Icons.stop, size: 18),
              label: const Text("Stop Session"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                foregroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            _currentQuote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}