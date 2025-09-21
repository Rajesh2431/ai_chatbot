import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/mood_service.dart';
import '../services/user_profile_service.dart';
import 'grow_screen.dart';

class DailyCheckinScreen extends StatefulWidget {
  final String? avatarName;
  final String? avatarImage;

  const DailyCheckinScreen({super.key, this.avatarName, this.avatarImage});

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  int currentQuestionIndex = 0;
  bool isTyping = false;
  bool isCompleted = false;
  bool showOptions = false; // Add this to control when options appear
  int? selectedOptionIndex; // Track which option is selected

  final List<DailyQuestion> questions = [
    DailyQuestion(
      question: "Good Morning How are you Feeling Today",
      options: [
        MoodOption("Fantastic", "😁", 5),
        MoodOption("Pretty Good", "🙂", 4),
        MoodOption("Alright", "😊", 3),
        MoodOption("Just Okay", "😐", 2),
        MoodOption("Balanced", "😊", 3),
      ],
    ),
    DailyQuestion(
      question: "How well did you sleep last night?",
      options: [
        MoodOption("Excellent", "😴", 5),
        MoodOption("Very well", "😊", 4),
        MoodOption("Good", "🙂", 3),
        MoodOption("Average", "😐", 2),
        MoodOption("Restless", "😵", 1),
      ],
    ),
    DailyQuestion(
      question: "What's your energy level right now?",
      options: [
        MoodOption("Very high", "⚡", 5),
        MoodOption("High", "💪", 4),
        MoodOption("Good", "🔋", 3),
        MoodOption("Moderate", "😐", 2),
        MoodOption("Low", "😴", 1),
      ],
    ),
    DailyQuestion(
      question: "How stressed do you feel today?",
      options: [
        MoodOption("Very calm", "😌", 5),
        MoodOption("Calm", "🙂", 4),
        MoodOption("Slightly tense", "😊", 3),
        MoodOption("Moderate stress", "😐", 2),
        MoodOption("Very stressed", "😰", 1),
      ],
    ),
    DailyQuestion(
      question: "How optimistic are you feeling about today?",
      options: [
        MoodOption("Very optimistic", "🌟", 5),
        MoodOption("Optimistic", "😊", 4),
        MoodOption("Positive", "🙂", 3),
        MoodOption("Neutral", "😐", 2),
        MoodOption("Concerned", "😟", 1),
      ],
    ),
  ];

  late String _avatarImage;

  @override
  void initState() {
    super.initState();
    _avatarImage = widget.avatarImage ?? 'lib/assets/avatar/Siara_half.png';

    _startCheckin();
  }

  void _startCheckin() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _askNextQuestion();
  }



  void _askNextQuestion() {
    if (currentQuestionIndex < questions.length) {
      setState(() {
        isTyping = true;
        showOptions = false; // Hide options while typing
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        setState(() {
          isTyping = false;
          showOptions = true; // Show options after typing
        });
      });
    } else {
      _completeCheckin();
    }
  }

  void _handleOptionSelected(MoodOption option, int optionIndex) async {
    // Set the selected option index for visual feedback
    setState(() {
      selectedOptionIndex = optionIndex;
    });

    // Brief delay to show the selection
    await Future.delayed(const Duration(milliseconds: 500));

    // Hide options and reset selection
    setState(() {
      showOptions = false;
      selectedOptionIndex = null;
    });

    // Store the mood score
    await MoodService.storeDailyMoodScore(
      questions[currentQuestionIndex].question,
      option.score,
    );

    currentQuestionIndex++;

    // Brief delay before showing next question
    await Future.delayed(const Duration(milliseconds: 1000));
    
    _askNextQuestion();
  }


  void _completeCheckin() async {
    setState(() {
      isCompleted = true;
    });

    // Calculate overall mood score from stored scores
    double totalScore = 0;
    int scoreCount = 0;
    
    // We'll calculate from the questions answered
    for (int i = 0; i < currentQuestionIndex; i++) {
      // Get the stored score for each question
      // For now, we'll use a default calculation
      totalScore += 3.0; // Default middle score
      scoreCount++;
    }

    double averageScore = scoreCount > 0 ? totalScore / scoreCount : 3.0;

    // Store overall daily mood
    await MoodService.storeDailyOverallMood(averageScore);

    // Mark daily check-in as completed
    await UserProfileService.markDailyCheckinComplete();

    // Send data to backend
    final email = await UserProfileService.getUserEmail();
    final percentage = (averageScore * 20).toInt(); // Convert 1-5 scale to percentage 0-100
    final date = DateFormat('dd-MM-yyyy').format(DateTime.now()); // dd-MM-yyyy format
    await MoodService.sendDailyCheckinData(email, percentage, date);

    // Brief delay before navigating to dashboard
    await Future.delayed(const Duration(milliseconds: 2000));
    _navigateToDashboard();
  }

  void _navigateToDashboard() {
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => GrowScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20B2AA), // Teal-blue background
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
          child: Column(
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  'Mood Analysis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Large Avatar
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _avatarImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF20B2AA),
                                  Color(0xFF48CAE4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 60,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // Question Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  currentQuestionIndex < questions.length 
                      ? questions[currentQuestionIndex].question
                      : "Thank you for completing your mood analysis!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
              
              // Mood Selection Grid
              if (showOptions && currentQuestionIndex < questions.length && !isCompleted)
                Expanded(
                  flex: 4,
                  child: _buildMoodGrid(),
                ),
              
              // Progress indicator
              if (currentQuestionIndex < questions.length)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(questions.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= currentQuestionIndex 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodGrid() {
    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion.options;
    
    // Define colors for each mood option to match the image
    final List<Color> moodColors = [
      const Color(0xFF90EE90), // Light green for Fantastic
      const Color(0xFFFFB366), // Light orange for Pretty Good
      const Color(0xFF87CEEB), // Light blue for Alright
      const Color(0xFFFFB6C1), // Light pink for Just Okay
      const Color(0xFFFFF8DC), // Light yellow for Balanced
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.8, // Adjusted for better fit
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final color = moodColors[index % moodColors.length];
          final isSelected = selectedOptionIndex == index;
          
          return GestureDetector(
            onTap: () => _handleOptionSelected(option, index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white, // Fill with color when selected
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class DailyQuestion {
  final String question;
  final List<MoodOption> options;

  DailyQuestion({required this.question, required this.options});
}

class MoodOption {
  final String text;
  final String emoji;
  final int score;

  MoodOption(this.text, this.emoji, this.score);
}