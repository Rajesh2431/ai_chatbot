import 'dart:math';
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

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  late AnimationController _waveController;
  late AnimationController _pulseController;

  bool _isListening = false;
  bool _isProcessing = false;
  String _statusText = "Tap to start";
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _checkMicPermission();
    _initializeTTS();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeTTS() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setPitch(1.0);
      await _tts.setVolume(0.8);
      await _tts.setSpeechRate(0.5);

      // Set up completion handler
      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusText = "Tap to start";
            _currentText = '';
          });
        }
      });

      // Set up error handler
      _tts.setErrorHandler((msg) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusText = "Speech error occurred";
            _currentText = '';
          });
        }
      });
    } catch (e) {
      print('TTS initialization error: $e');
    }
  }

  Future<void> _speak(String text) async {
    try {
      if (text.trim().isEmpty) return;

      // Stop any current speech
      await _tts.stop();

      // Start speaking
      var result = await _tts.speak(text);

      if (result == 1) {
        print('TTS started successfully');
      } else {
        print('TTS failed to start');
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _statusText = "Speech failed";
            _currentText = '';
          });
        }
      }
    } catch (e) {
      print('TTS speak error: $e');
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = "Speech error";
          _currentText = '';
        });
      }
    }
  }

  void _checkMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        setState(() {
          _isListening = _speech.isListening;
          if (_isListening) {
            _statusText = "Now listening";
            _waveController.repeat();
            _pulseController.repeat();
          } else {
            _statusText = "Processing...";
            _waveController.stop();
            _pulseController.stop();
          }
        });
      },
      onError: (val) {
        setState(() {
          _statusText = "Error occurred";
          _isListening = false;
          _waveController.stop();
          _pulseController.stop();
        });
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _statusText = "Now listening";
      });

      _waveController.repeat();
      _pulseController.repeat();

      _speech.listen(
        onResult: (val) async {
          setState(() {
            _currentText = val.recognizedWords;
          });

          if (val.finalResult) {
            _stopListening();
            if (_currentText.isNotEmpty) {
              await _processMessage(_currentText);
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _statusText = "Processing...";
    });
    _waveController.stop();
    _pulseController.stop();
  }

  Future<void> _processMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _statusText = "Thinking...";
    });

    try {
      final reply = await OpenRouterAPI.getResponse(text);

      setState(() {
        _statusText = "Speaking...";
      });

      await _speak(reply);

      // Note: State will be reset by TTS completion handler
    } catch (e) {
      print('Process message error: $e');
      setState(() {
        _isProcessing = false;
        _statusText = "Error occurred";
        _currentText = '';
      });
    }
  }

  void _cancelListening() {
    _speech.cancel();
    setState(() {
      _isListening = false;
      _isProcessing = false;
      _statusText = "Cancelled";
      _currentText = '';
    });
    _waveController.stop();
    _pulseController.stop();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _statusText = "Tap to start";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 24),
                    color: Colors.black87,
                  ),
                  IconButton(
                    onPressed: () {
                      // Test TTS functionality
                      _speak(
                        "Hello, this is a test of the text to speech system.",
                      );
                    },
                    icon: const Icon(Icons.volume_up, size: 24),
                    color: Colors.black87,
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Voice visualization circle
                    GestureDetector(
                      onTap: _isProcessing
                          ? null
                          : (_isListening ? _stopListening : _startListening),
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 200 + (_pulseController.value * 20),
                            height: 200 + (_pulseController.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF4F7DF3),
                              boxShadow: _isListening
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF4F7DF3,
                                        ).withValues(alpha: 0.3),
                                        blurRadius:
                                            20 + (_pulseController.value * 10),
                                        spreadRadius:
                                            5 + (_pulseController.value * 5),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(child: _buildWaveform()),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Current text display
                    if (_currentText.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _currentText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom control bar
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pause/Play button
                  IconButton(
                    onPressed: _isListening ? _stopListening : null,
                    icon: Icon(
                      _isListening ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                  // Status text
                  Expanded(
                    child: Text(
                      _statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Cancel button
                  IconButton(
                    onPressed: (_isListening || _isProcessing)
                        ? _cancelListening
                        : null,
                    icon: const Icon(Icons.close, color: Colors.red, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(120, 60),
          painter: WaveformPainter(
            animationValue: _waveController.value,
            isActive: _isListening,
          ),
        );
      },
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double animationValue;
  final bool isActive;

  WaveformPainter({required this.animationValue, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = 4.0;
    final barSpacing = 8.0;
    final totalBars = 9;
    final totalWidth = (totalBars * barWidth) + ((totalBars - 1) * barSpacing);
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < totalBars; i++) {
      final x = startX + (i * (barWidth + barSpacing));

      double height;
      if (isActive) {
        // Create animated waveform effect
        final phase = (animationValue * 2 * pi) + (i * 0.5);
        height =
            (sin(phase) * 0.5 + 0.5) * (size.height * 0.8) +
            (size.height * 0.2);
      } else {
        // Static waveform when not active
        final staticHeights = [0.3, 0.7, 0.5, 0.9, 1.0, 0.9, 0.5, 0.7, 0.3];
        height = staticHeights[i] * size.height * 0.6 + (size.height * 0.2);
      }

      canvas.drawLine(
        Offset(x + barWidth / 2, centerY - height / 2),
        Offset(x + barWidth / 2, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
