import 'dart:math';
import 'package:flutter/material.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  List<GameCard> cards = [];
  List<int> selectedCards = [];
  int matches = 0;
  bool isChecking = false;
  int moves = 0;

  // Animal emojis for the cards
  final List<String> animals = ['🐯', '🐼', '🐻', '🐵', '🦁', '🐸', '🐰', '🐨'];

  @override
  void initState() {
    super.initState();
    _initializeGame();

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    cards.clear();
    selectedCards.clear();
    matches = 0;
    moves = 0;
    isChecking = false;

    // Create pairs of cards
    List<String> gameAnimals = animals
        .take(6)
        .toList(); // Use 6 different animals
    List<String> cardValues = [...gameAnimals, ...gameAnimals]; // Create pairs
    cardValues.shuffle();

    for (int i = 0; i < cardValues.length; i++) {
      cards.add(
        GameCard(
          id: i,
          value: cardValues[i],
          isFlipped: false,
          isMatched: false,
        ),
      );
    }
    setState(() {});
  }

  void _onCardTap(int cardId) {
    if (isChecking ||
        cards[cardId].isFlipped ||
        cards[cardId].isMatched ||
        selectedCards.length >= 2) {
      return;
    }

    setState(() {
      cards[cardId].isFlipped = true;
      selectedCards.add(cardId);
    });

    if (selectedCards.length == 2) {
      moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    isChecking = true;

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      if (cards[selectedCards[0]].value == cards[selectedCards[1]].value) {
        // Match found
        setState(() {
          cards[selectedCards[0]].isMatched = true;
          cards[selectedCards[1]].isMatched = true;
          matches++;
        });

        if (matches == 6) {
          _showWinDialog();
        }
      } else {
        // No match, flip cards back
        setState(() {
          cards[selectedCards[0]].isFlipped = false;
          cards[selectedCards[1]].isFlipped = false;
        });
      }

      selectedCards.clear();
      setState(() {
        isChecking = false;
      });
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '🎉 Congratulations! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E8B57),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'You completed the memory game!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Text(
                'Moves: $moves',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20B2AA),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeGame();
              },
              child: const Text(
                'Play Again',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E8B57),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20B2AA),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF20B2AA), // Light Sea Green
              Color(0xFF2E8B57), // Sea Green
              Color(0xFF008B8B), // Dark Cyan
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _sparkleAnimation,
                      builder: (context, child) {
                        return Row(
                          children: [
                            Transform.rotate(
                              angle: _sparkleAnimation.value * 2 * pi,
                              child: const Text(
                                '✨',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Memory Game Cards',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: -_sparkleAnimation.value * 2 * pi,
                              child: const Text(
                                '✨',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Game Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(label: 'Moves', value: moves.toString()),
                    _StatCard(label: 'Matches', value: '$matches/6'),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Game Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return _GameCardWidget(
                        card: cards[index],
                        onTap: () => _onCardTap(index),
                      );
                    },
                  ),
                ),
              ),

              // Reset Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _initializeGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E8B57),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'New Game',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Decorative sparkles
              AnimatedBuilder(
                animation: _sparkleAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Transform.scale(
                        scale: 0.5 + _sparkleAnimation.value * 0.5,
                        child: const Text('✨', style: TextStyle(fontSize: 24)),
                      ),
                      Transform.scale(
                        scale: 1.0 - _sparkleAnimation.value * 0.3,
                        child: const Text('⭐', style: TextStyle(fontSize: 20)),
                      ),
                      Transform.scale(
                        scale: 0.7 + _sparkleAnimation.value * 0.3,
                        child: const Text('✨', style: TextStyle(fontSize: 24)),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCardWidget extends StatefulWidget {
  final GameCard card;
  final VoidCallback onTap;

  const _GameCardWidget({required this.card, required this.onTap});

  @override
  State<_GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<_GameCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_GameCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      if (widget.card.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * pi),
            child: Container(
              decoration: BoxDecoration(
                color: widget.card.isMatched
                    ? Colors.green.withValues(alpha: 0.3)
                    : (isShowingFront ? const Color(0xFF1E3A8A) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isShowingFront
                    ? const Text(
                        '?',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: Text(
                          widget.card.value,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GameCard {
  final int id;
  final String value;
  bool isFlipped;
  bool isMatched;

  GameCard({
    required this.id,
    required this.value,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
