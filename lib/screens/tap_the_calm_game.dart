import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../screens/game_selection.dart'; 


void main() => runApp(const GridCalmGame());

class GridCalmGame extends StatelessWidget {
  const GridCalmGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grid Tap Calm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.deepPurple,
      ),
      home: const GridGameScreen(),
    );
  }
}

class GridGameScreen extends StatefulWidget {
  const GridGameScreen({super.key});

  @override
  State<GridGameScreen> createState() => _GridGameScreenState();
}

class _GridGameScreenState extends State<GridGameScreen> {
  int _score = 0;
  int _bestScore = 0;
  bool _isPlaying = false;
  int _remainingTime = 30;
  Timer? _timer;
  int _targetIndex = -1;
  final int _gridCount = 16;
  final Random _random = Random();
  bool _showFeedback = false;
  Color _feedbackColor = Colors.greenAccent;

  final List<String> _emojis = [
    "🌱", "🌿", "🍀", "🌵", "🌲", "🌳", "🍃", "🪴",
    "🌼", "🌸", "🌺", "🍄", "🦋", "🐢", "🐸", "🦜"
  ];
  String _targetEmoji = "🌱";
  List<String> _gridEmojis = [];

  int _combo = 0;
  int _multiplier = 1;

  void _startGame() {
    setState(() {
      _score = 0;
      _remainingTime = 30;
      _isPlaying = true;
      _combo = 0;
      _multiplier = 1;
      _targetIndex = _random.nextInt(_gridCount);
      _targetEmoji = _emojis[_random.nextInt(_emojis.length)];
      _showFeedback = false;
      _generateGridEmojis();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime <= 1) {
        timer.cancel();
        setState(() => _isPlaying = false);
        if (_score > _bestScore) _bestScore = _score;
        _showResult();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  void _generateGridEmojis() {
    _gridEmojis = List.generate(_gridCount, (i) {
      if (i == _targetIndex) return _targetEmoji;
      String emoji;
      do {
        emoji = _emojis[_random.nextInt(_emojis.length)];
      } while (emoji == _targetEmoji);
      return emoji;
    });
  }

  void _handleTap(int index) {
    if (!_isPlaying) return;
    if (index == _targetIndex) {
      _combo++;
      _multiplier = (_combo ~/ 3) + 1;
      setState(() {
        _score += _multiplier;
        _targetIndex = _random.nextInt(_gridCount);
        _targetEmoji = _emojis[_random.nextInt(_emojis.length)];
        _showFeedback = true;
        _feedbackColor = Colors.tealAccent;
        _generateGridEmojis();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showFeedback = false);
      });
    } else {
      _combo = 0;
      _multiplier = 1;
      setState(() {
        _showFeedback = true;
        _feedbackColor = Colors.redAccent;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showFeedback = false);
      });
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.teal[900],
        title: const Text("Great Job!", style: TextStyle(color: Colors.tealAccent)),
        content: Text(
          "Score: $_score\nBest: $_bestScore\nStay relaxed & focused.",
          style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _startGame();
            },
            child: const Text("Restart", style: TextStyle(color: Colors.tealAccent)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const GameSelectionScreen()),
                  );
                }
              });
            },
            child: const Text("Menu", style: TextStyle(color: Colors.tealAccent)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Find the Emoji"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade900,
                  Colors.green.shade700,
                  Colors.tealAccent.shade100,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text("Time",
                              style: TextStyle(color: Colors.tealAccent, fontSize: 16)),
                          Text("$_remainingTime",
                              style: const TextStyle(
                                  color: Colors.tealAccent,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Score",
                              style: TextStyle(color: Colors.white70, fontSize: 16)),
                          Text("$_score",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Best",
                              style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
                          Text("$_bestScore",
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Combo", style: TextStyle(color: Colors.cyanAccent, fontSize: 16)),
                          Text("x$_multiplier",
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                        ),
                        itemCount: _gridCount,
                        itemBuilder: (context, index) {
                          final isTarget = _isPlaying && index == _targetIndex;
                          final emoji = _gridEmojis.isNotEmpty ? _gridEmojis[index] : "";

                          return GestureDetector(
                            onTap: () => _handleTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                color: isTarget
                                    ? Colors.tealAccent
                                    : Colors.teal.shade700,
                                boxShadow: isTarget
                                    ? [
                                        BoxShadow(
                                          color: Colors.tealAccent.withOpacity(0.6),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : [],
                                borderRadius: BorderRadius.circular(isTarget ? 18 : 12),
                                border: isTarget
                                    ? Border.all(color: Colors.greenAccent, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: TextStyle(
                                    fontSize: isTarget ? 38 : 28,
                                    shadows: isTarget
                                        ? [
                                            Shadow(
                                              color: Colors.greenAccent,
                                              blurRadius: 8,
                                            )
                                          ]
                                        : [],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (!_isPlaying)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: ElevatedButton.icon(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text("Start Game",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          if (_showFeedback)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: _feedbackColor.withOpacity(0.15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
