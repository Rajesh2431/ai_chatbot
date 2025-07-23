import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedSection;
  int _currentQuestion = 0;
  int _score = 0;
  bool _showResult = false;
  bool _answered = false;
  int? _selectedAnswer;
  List<int?> _selectedAnswers = [];

  static const List<Map<String, dynamic>> _sections = [
    {
      'title': 'Mental Health Basics',
      'questions': [
        {
          'question': 'What is the definition of mental health?',
          'options': [
            'The absence of mental illness',
            'A state of well-being in which every individual realizes his or her own potential',
            'The ability to work hard',
            'Physical fitness',
          ],
          'answer': 1,
        },
        {
          'question': 'Which of the following is NOT a component of good mental health?',
          'options': [
            'Coping with normal stresses of life',
            'Working productively',
            'Ignoring emotions',
            'Contributing to the community',
          ],
          'answer': 2,
        },
        {
          'question': 'Mental health only refers to psychological well-being.',
          'options': [
            'True',
            'False',
          ],
          'answer': 1,
        },
        {
          'question': 'Which factors can affect mental health?',
          'options': [
            'Biological factors',
            'Life experiences',
            'Family history',
            'None of the above',
          ],
          'answer': 3,
        },
        {
          'question': 'Why is mental health important?',
          'options': [
            'It helps people realize their abilities',
            'It enables people to cope with stress',
            'It allows people to work productively',
            'All of the above',
          ],
          'answer': 3,
        },
        {
          'question': 'Which is a sign of good mental health?',
          'options': [
            'Ignoring problems',
            'Coping with stress',
            'Avoiding social contact',
            'Suppressing emotions',
          ],
          'answer': 1,
        },
        {
          'question': 'Mental health is only important for adults.',
          'options': [
            'True',
            'False',
          ],
          'answer': 1,
        },
        {
          'question': 'Which is NOT a way to support mental health?',
          'options': [
            'Regular exercise',
            'Healthy eating',
            'Isolation',
            'Seeking help when needed',
          ],
          'answer': 2,
        },
        {
          'question': 'Mental health problems are rare.',
          'options': [
            'True',
            'False',
          ],
          'answer': 1,
        },
        {
          'question': 'Which professional can help with mental health?',
          'options': [
            'Doctor',
            'Psychologist',
            'Teacher',
            'Engineer',
          ],
          'answer': 1,
        },
      ],
    },
    {
      'title': 'Advanced Mental Health',
      'questions': [
        {
          'question': 'Which hormone is most associated with stress?',
          'options': [
            'Insulin',
            'Cortisol',
            'Adrenaline',
            'Melatonin',
          ],
          'answer': 1,
        },
        {
          'question': 'Which therapy focuses on changing negative thought patterns?',
          'options': [
            'Physical therapy',
            'Cognitive Behavioral Therapy',
            'Occupational therapy',
            'Speech therapy',
          ],
          'answer': 1,
        },
        {
          'question': 'Which is a common symptom of anxiety?',
          'options': [
            'Rapid heartbeat',
            'Improved concentration',
            'Excessive happiness',
            'Increased appetite',
          ],
          'answer': 0,
        },
        {
          'question': 'Which is NOT a risk factor for depression?',
          'options': [
            'Family history',
            'Chronic illness',
            'Supportive relationships',
            'Substance abuse',
          ],
          'answer': 2,
        },
        {
          'question': 'Which is a healthy coping strategy?',
          'options': [
            'Avoiding problems',
            'Talking to friends',
            'Suppressing emotions',
            'Ignoring feelings',
          ],
          'answer': 1,
        },
        {
          'question': 'Which is NOT a type of mental disorder?',
          'options': [
            'Anxiety disorder',
            'Mood disorder',
            'Respiratory disorder',
            'Personality disorder',
          ],
          'answer': 2,
        },
        {
          'question': 'Which is a sign of burnout?',
          'options': [
            'High energy',
            'Chronic fatigue',
            'Motivation',
            'Optimism',
          ],
          'answer': 1,
        },
        {
          'question': 'Which is NOT a benefit of mindfulness?',
          'options': [
            'Reduced stress',
            'Improved focus',
            'Increased anxiety',
            'Better emotional regulation',
          ],
          'answer': 2,
        },
        {
          'question': 'Which is a stigma about mental health?',
          'options': [
            'It is a sign of weakness',
            'It can affect anyone',
            'It is treatable',
            'It is important',
          ],
          'answer': 0,
        },
        {
          'question': 'Which is a good way to support someone with mental health issues?',
          'options': [
            'Listen and offer support',
            'Judge them',
            'Ignore them',
            'Tell them to "snap out of it"',
          ],
          'answer': 0,
        },
      ],
    },
  ];

  void _startQuiz(int sectionIndex) {
    setState(() {
      _selectedSection = sectionIndex;
      _currentQuestion = 0;
      _score = 0;
      _showResult = false;
      _answered = false;
      _selectedAnswer = null;
      _selectedAnswers = List.filled(_sections[sectionIndex]['questions'].length, null);
    });
  }

  void _nextQuestion() {
    setState(() {
      _answered = false;
      _selectedAnswer = null;
      if (_currentQuestion < _sections[_selectedSection!]['questions'].length - 1) {
        _currentQuestion++;
      } else {
        _showResult = true;
        _score = _calculateScore();
      }
    });
  }

  int _calculateScore() {
    int score = 0;
    final questions = _sections[_selectedSection!]['questions'] as List;
    for (int i = 0; i < questions.length; i++) {
      if (_selectedAnswers[i] == questions[i]['answer']) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF97CAE4);

    if (_selectedSection == null) {
      // Section selection screen
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Only add space for status bar, no extra white box
            //SizedBox(height: MediaQuery.of(context).padding.top),
            // Improved header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.quiz, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      const Text(
                        "Quiz",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose a section to begin",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white.withOpacity(0.92),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _sections.length,
                itemBuilder: (context, idx) => Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                    title: Text(
                      _sections[idx]['title'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ),
                    onTap: () => _startQuiz(idx),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final questions = _sections[_selectedSection!]['questions'] as List;
    final currentQ = questions[_currentQuestion];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Add space for notification/status bar
          //SizedBox(height: MediaQuery.of(context).padding.top),
          // Custom header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                  onPressed: () {
                    setState(() {
                      _selectedSection = null;
                      _showResult = false;
                      _currentQuestion = 0;
                      _score = 0;
                      _selectedAnswers = [];
                      _answered = false;
                      _selectedAnswer = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _sections[_selectedSection!]['title'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_currentQuestion + 1}/${questions.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _nextQuestion,
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showResult
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: themeColor, size: 64),
                        const SizedBox(height: 18),
                        Text(
                          'Your Score: $_score / ${questions.length}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _showResult = false;
                              _currentQuestion = 0;
                              _score = 0;
                              _selectedAnswers = List.filled(questions.length, null);
                              _answered = false;
                              _selectedAnswer = null;
                            });
                          },
                          child: const Text('Restart Section', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedSection = null;
                              _showResult = false;
                              _currentQuestion = 0;
                              _score = 0;
                              _selectedAnswers = [];
                              _answered = false;
                              _selectedAnswer = null;
                            });
                          },
                          child: Text('Back to Sections', style: TextStyle(color: themeColor, fontSize: 16)),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Text(
                          currentQ['question'],
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Column(
                              children: List.generate(
                                (currentQ['options'] as List).length,
                                (idx) {
                                  Color? tileColor;
                                  IconData? icon;
                                  if (_answered) {
                                    if (idx == currentQ['answer']) {
                                      tileColor = Colors.green.shade100;
                                      icon = Icons.check_circle;
                                    } else if (idx == _selectedAnswer) {
                                      tileColor = Colors.red.shade100;
                                      icon = Icons.cancel;
                                    }
                                  }
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: tileColor ?? Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _selectedAnswer == idx
                                            ? themeColor
                                            : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        "${idx + 1}. ${currentQ['options'][idx]}",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: _answered
                                              ? (idx == currentQ['answer']
                                                  ? Colors.green
                                                  : idx == _selectedAnswer
                                                      ? Colors.red
                                                      : Colors.black)
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: icon != null
                                          ? Icon(icon,
                                              color: idx == currentQ['answer']
                                                  ? Colors.green
                                                  : Colors.red)
                                          : null,
                                      onTap: _answered
                                          ? null
                                          : () {
                                              setState(() {
                                                _selectedAnswer = idx;
                                                _selectedAnswers[_currentQuestion] = idx;
                                                _answered = true;
                                              });
                                            },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentQuestion > 0)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _currentQuestion--;
                                    _answered = false;
                                    _selectedAnswer = _selectedAnswers[_currentQuestion];
                                  });
                                },
                                child: Text('Back', style: TextStyle(color: themeColor, fontSize: 16)),
                              ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              ),
                              onPressed: _answered ? _nextQuestion : null,
                              child: Text(
                                _currentQuestion == questions.length - 1 ? 'Submit' : 'Next',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}