import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

enum BreathingTechnique { bellyBreathing, boxBreathing, alternateNostril }

class BreathingTechniqueData {
  final String name;
  final String description;
  final IconData icon;
  final List<String> phases;
  final List<int> durations; // in seconds
  final Color primaryColor;
  final Color secondaryColor;

  BreathingTechniqueData({
    required this.name,
    required this.description,
    required this.icon,
    required this.phases,
    required this.durations,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

class BreathingScreen extends StatefulWidget {
  final String? initialTechnique;
  
  const BreathingScreen({super.key, this.initialTechnique});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _pulseController;
  late Animation<double> _radiusAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _sessionTimer;
  Timer? _phaseTimer;

  bool _isRunning = false;
  bool _hasStarted = false;
  bool _showTechniques = true;
  String _statusText = "Inhale";
  int _currentPhaseIndex = 0;

  Duration _remainingTime = Duration.zero;
  BreathingTechnique? _selectedTechnique;

  // Breathing techniques data
  final Map<BreathingTechnique, BreathingTechniqueData> _techniques = {
    BreathingTechnique.bellyBreathing: BreathingTechniqueData(
      name: "Belly Breathing",
      description: "Deep diaphragmatic breathing to reduce stress and anxiety",
      icon: Icons.favorite,
      phases: ["Inhale slowly", "Hold gently", "Exhale slowly"],
      durations: [4, 2, 6],
      primaryColor: const Color(0xFF64B5F6),
      secondaryColor: const Color(0xFFE3F2FD),
    ),
    BreathingTechnique.boxBreathing: BreathingTechniqueData(
      name: "Box Breathing",
      description: "4-4-4-4 pattern used by Navy SEALs for focus and calm",
      icon: Icons.crop_square,
      phases: ["Inhale", "Hold", "Exhale", "Hold"],
      durations: [4, 4, 4, 4],
      primaryColor: const Color(0xFF42A5F5),
      secondaryColor: const Color(0xFFE1F5FE),
    ),
    BreathingTechnique.alternateNostril: BreathingTechniqueData(
      name: "Alternate Nostril",
      description: "Ancient yogic technique to balance mind and body",
      icon: Icons.air,
      phases: [
        "Left nostril in",
        "Hold",
        "Right nostril out",
        "Right nostril in",
        "Hold",
        "Left nostril out",
      ],
      durations: [4, 2, 4, 4, 2, 4],
      primaryColor: const Color(0xFF29B6F6),
      secondaryColor: const Color(0xFFE0F2F1),
    ),
  };

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

    // Select a random motivational quote
    _currentQuote =
        _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];

    // Start subtle pulse animation
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

  void _selectTechnique(BreathingTechnique technique) {
    setState(() {
      _selectedTechnique = technique;
      _showTechniques = false;
    });
  }

  void _startBreathing(Duration duration) {
    if (_selectedTechnique == null) return;

    final techniqueData = _techniques[_selectedTechnique!]!;

    setState(() {
      _remainingTime = duration;
      _hasStarted = true;
      _isRunning = true;
      _currentPhaseIndex = 0;
      _statusText = techniqueData.phases[0];
    });

    // Stop the idle pulse animation
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
    if (_selectedTechnique == null) return;

    final techniqueData = _techniques[_selectedTechnique!]!;
    final phaseDuration = techniqueData.durations[_currentPhaseIndex];
    final currentPhase = techniqueData.phases[_currentPhaseIndex].toLowerCase();

    // Reset and configure animation for current phase
    _breathController.duration = Duration(seconds: phaseDuration);
    
    // Determine animation type and curve based on phase
    if (currentPhase.contains('inhale') || currentPhase.contains('in')) {
      // Inhale: smooth expansion with gentle ease-in curve
      _breathController.reset();
      _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
        CurvedAnimation(
          parent: _breathController, 
          curve: Curves.easeIn,
        ),
      );
      _breathController.forward();
    } else if (currentPhase.contains('exhale') || currentPhase.contains('out')) {
      // Exhale: smooth contraction with gentle ease-out curve
      _breathController.reset();
      _radiusAnimation = Tween<double>(begin: 180, end: 60).animate(
        CurvedAnimation(
          parent: _breathController, 
          curve: Curves.easeOut,
        ),
      );
      _breathController.forward();
    } else if (currentPhase.contains('hold')) {
      // Hold: maintain current size with subtle pulse
      _breathController.stop();
      final currentRadius = _radiusAnimation.value;
      
      // Create a subtle pulsing effect during hold
      _pulseController.duration = Duration(milliseconds: 800);
      _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(
          parent: _pulseController, 
          curve: Curves.easeInOut,
        ),
      );
      _pulseController.repeat(reverse: true);
      
      // Keep radius constant during hold
      _radiusAnimation = Tween<double>(
        begin: currentRadius, 
        end: currentRadius,
      ).animate(_breathController);
    } else {
      // Default case: gentle expansion
      _breathController.reset();
      _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
        CurvedAnimation(
          parent: _breathController, 
          curve: Curves.easeInOut,
        ),
      );
      _breathController.forward();
    }

    _phaseTimer = Timer(Duration(seconds: phaseDuration), () {
      if (!_isRunning) return;

      setState(() {
        _currentPhaseIndex =
            (_currentPhaseIndex + 1) % techniqueData.phases.length;
        _statusText = techniqueData.phases[_currentPhaseIndex];
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
    
    // Stop all animations
    _breathController.stop();
    _pulseController.stop();
    
    // Cancel timers
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    
    // Reset to idle state
    _breathController.reset();
    _pulseController.duration = const Duration(seconds: 2);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _radiusAnimation = Tween<double>(begin: 60, end: 180).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    // Restart idle pulse
    _pulseController.repeat(reverse: true);
  }

  void _goBack() {
    if (_hasStarted) {
      _stopBreathing();
    }
    if (_showTechniques) {
      Navigator.pop(context);
    } else {
      setState(() {
        _showTechniques = true;
        _selectedTechnique = null;
      });
    }
  }

  Widget _buildTechniqueSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Choose Your Breathing Technique',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a technique that resonates with you',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              children: _techniques.entries.map((entry) {
                return _buildTechniqueCard(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueCard(
    BreathingTechnique technique,
    BreathingTechniqueData data,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectTechnique(technique),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: data.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: data.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        data.icon,
                        color: data.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: data.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: data.primaryColor,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.phases.asMap().entries.map((entry) {
                    final index = entry.key;
                    final phase = entry.value;
                    final duration = data.durations[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: data.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: data.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '$phase (${duration}s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: data.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildDurationPanel() {
    final techniqueData = _techniques[_selectedTechnique!]!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Technique info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: techniqueData.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  techniqueData.icon,
                  size: 48,
                  color: techniqueData.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  techniqueData.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: techniqueData.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  techniqueData.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
    final techniqueData = _techniques[_selectedTechnique!]!;

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
          foregroundColor: techniqueData.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: techniqueData.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          elevation: 8,
          shadowColor: techniqueData.primaryColor.withValues(alpha: 0.3),
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
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFBBDEFB), // Slightly deeper light blue
              Color(0xFF90CAF9), // Medium light blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Main content
              Expanded(
                child: _showTechniques
                    ? _buildTechniqueSelection()
                    : (!_hasStarted
                          ? _buildDurationPanel()
                          : _buildBreathingAnimation()),
              ),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final techniqueData = _selectedTechnique != null
        ? _techniques[_selectedTechnique!]!
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: _goBack,
          ),

          const Spacer(),

          // Title or Timer
          if (_showTechniques)
            const Text(
              'Breathing Techniques',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.0,
              ),
            )
          else if (_hasStarted && techniqueData != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: techniqueData.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: techniqueData.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_remainingTime),
                    style: TextStyle(
                      fontSize: 20,
                      color: techniqueData.primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            )
          else if (techniqueData != null)
            Text(
              techniqueData.name,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.0,
              ),
            ),

          const Spacer(),

          // Placeholder for symmetry
          const SizedBox(width: 56),
        ],
      ),
    );
  }

  Widget _buildBreathingAnimation() {
    final techniqueData = _techniques[_selectedTechnique!]!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Breathing instruction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: techniqueData.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              _statusText,
              style: TextStyle(
                fontSize: 24,
                color: techniqueData.primaryColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Enhanced breathing animation
          AnimatedBuilder(
            animation: Listenable.merge([_radiusAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow rings - responsive to breathing
                    _buildRing(2.8, 0.02, techniqueData.primaryColor),
                    _buildRing(2.4, 0.04, techniqueData.primaryColor),
                    _buildRing(2.0, 0.06, techniqueData.primaryColor),
                    _buildRing(1.6, 0.10, techniqueData.primaryColor),
                    _buildRing(1.3, 0.15, techniqueData.primaryColor),

                    // Main breathing circle
                    Container(
                      width: _radiusAnimation.value,
                      height: _radiusAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            techniqueData.primaryColor.withValues(alpha: 0.95),
                            techniqueData.primaryColor.withValues(alpha: 0.7),
                            techniqueData.primaryColor.withValues(alpha: 0.4),
                            techniqueData.primaryColor.withValues(alpha: 0.15),
                            techniqueData.primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: techniqueData.primaryColor.withValues(alpha: 0.5),
                            blurRadius: _radiusAnimation.value * 0.3,
                            spreadRadius: _radiusAnimation.value * 0.1,
                          ),
                        ],
                      ),
                    ),

                    // Center icon with breathing effect
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.95),
                        boxShadow: [
                          BoxShadow(
                            color: techniqueData.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        techniqueData.icon,
                        color: techniqueData.primaryColor,
                        size: 30,
                      ),
                    ),

                    // Breathing phase indicator ring for hold phases
                    if (_statusText.toLowerCase().contains('hold'))
                      Container(
                        width: _radiusAnimation.value + 20,
                        height: _radiusAnimation.value + 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: techniqueData.primaryColor.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Phase indicator for complex techniques
          if (techniqueData.phases.length > 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Phase ${_currentPhaseIndex + 1} of ${techniqueData.phases.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: techniqueData.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final techniqueData = _selectedTechnique != null
        ? _techniques[_selectedTechnique!]!
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stop button (only during active session)
          if (_hasStarted && techniqueData != null) ...[
            ElevatedButton.icon(
              onPressed: _stopBreathing,
              icon: const Icon(Icons.stop, size: 18),
              label: const Text("Stop Session"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                foregroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: Colors.red.shade300),
                ),
                elevation: 8,
                shadowColor: Colors.red.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Motivational quote
          if (!_showTechniques)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                _currentQuote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: techniqueData?.primaryColor ?? Colors.blue.shade700,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
