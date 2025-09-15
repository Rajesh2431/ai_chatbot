import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'goal_settings.dart';
import 'soar_card_analysis.dart';
import '../services/soar_card_service.dart';
import '../services/user_profile_service.dart';
import '../models/soar_card_answer.dart';

class QuizPage extends StatefulWidget {
  final String? userEmail;

  const QuizPage({super.key, this.userEmail});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, dynamic>> _questions = [];
  Map<String, List<Map<String, dynamic>>> _questionsByCategory = {};
  List<String> _categories = [];
  Map<String, bool> _categorySubmitted = {};
  bool _isLoading = true;
  String? _error;

  final Map<String, String> _selectedAnswers = {};

  Map<String, List<GlobalKey>> _questionKeys = {};

  String userEmail = '';

  bool get _hasAtLeastOneAnswer =>
      _selectedAnswers.values.any((answer) => answer.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    userEmail = widget.userEmail ?? await UserProfileService.getUserEmail();
    print('Loaded userEmail: $userEmail');
    _fetchQuizDetails();
  }

  Future<void> _fetchQuizDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final url = Uri.parse('https://strivehigh.thirdvizion.com/api/quizdetails/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> questions = [];
        for (var item in data) {
          List<String> options = [];
          for (var opt in ['option_a', 'option_b', 'option_c', 'option_d', 'option_e']) {
            if (item[opt] != null && item[opt].toString().isNotEmpty) {
              options.add(item[opt].toString());
            }
          }
          questions.add({
            'id': item['id'].toString(),
            'category': item['category'] ?? 'Uncategorized',
            'text': item['question'] ?? '',
            'options': options,
          });
        }
        _questionsByCategory = {};
        for (var q in questions) {
          String category = q['category'] ?? 'Uncategorized';
          if (!_questionsByCategory.containsKey(category)) {
            _questionsByCategory[category] = [];
          }
          _questionsByCategory[category]!.add(q);
        }
        _categories = _questionsByCategory.keys.toList();
        _questionKeys = {};
        for (var category in _categories) {
          _questionKeys[category] = List.generate(
          _questionsByCategory[category]!.length,
          (index) => GlobalKey(),
          );
        }

        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load quiz data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching quiz data: $e';
        _isLoading = false;
      });
    }
  }

  void _handleAnswerSelected(String questionId, String answer) {
    setState(() {
      _selectedAnswers[questionId] = answer;
    });
    // After selecting an answer, move to next question or next category automatically
    _goToNextQuestionOrCategory(questionId);
  }

  void _goToNextQuestionOrCategory(String currentQuestionId) {
    String currentCategory = '';
    int currentQuestionIndex = -1;
    // Find current category and question index
    for (var category in _categories) {
      List<Map<String, dynamic>> questions = _questionsByCategory[category]!;
      for (int i = 0; i < questions.length; i++) {
        if (questions[i]['id'].toString() == currentQuestionId) {
          currentCategory = category;
          currentQuestionIndex = i;
          break;
        }
      }
      if (currentQuestionIndex != -1) break;
    }
    if (currentCategory.isEmpty) return;

    List<Map<String, dynamic>> questionsInCategory = _questionsByCategory[currentCategory]!;

    if (currentQuestionIndex < questionsInCategory.length - 1) {
      // Move to next question in the same category by scrolling the ListView
      Scrollable.ensureVisible(_questionKeys[currentCategory]![currentQuestionIndex + 1].currentContext!, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Last question in category, submit category and move to next category automatically
      _submitCategory(currentCategory);
      if (_currentPage < _categories.length - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    }
  }

  Future<void> _sendCategoryAverageToSubmitQuiz(String email, String category, double avg) async {
    final url = Uri.parse('https://strivehigh.thirdvizion.com/api/submitquiz/');
    final body = json.encode({
      'email': email,
      'category': category,
      'avg': avg,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Category average sent successfully to submitquiz');
      } else {
        print('Failed to send category average to submitquiz: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending category average to submitquiz: $e');
    }
  }

  Future<void> _submitCategory(String category) async {
    List<Map<String, dynamic>> questions = _questionsByCategory[category]!;
    List<int> scores = [];
    for (var q in questions) {
      String questionId = q['id'].toString();
      String answer = _selectedAnswers[questionId] ?? '';
      if (answer.isNotEmpty) {
        List<String> options = q['options'] as List<String>;
        int index = options.indexOf(answer);
        int score = (options.length - index) * 10; // First option 50, last 10 for 5 options
        if (score > 0) {
          scores.add(score);
        }
      }
    }
      if (scores.isNotEmpty) {
        double avg = scores.reduce((a, b) => a + b) / scores.length;
        await _sendCategoryAverageToSubmitQuiz(userEmail, category, avg);
        setState(() {
          _categorySubmitted[category] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category $category submitted successfully!')),
        );
        if (_categorySubmitted.length == _categories.length) {
            // Calculate and send overall average
            List<int> allScores = [];
            _selectedAnswers.forEach((questionId, answer) {
              for (var q in _questions) {
                if (q['id'].toString() == questionId) {
                  List<String> options = q['options'] as List<String>;
                  int index = options.indexOf(answer);
                  int score = (options.length - index) * 10; // First option 50, last 10 for 5 options
                  if (score > 0) {
                    allScores.add(score);
                  }
                  break;
                }
              }
            });
            if (allScores.isNotEmpty) {
              double overallAvg = allScores.reduce((a, b) => a + b) / allScores.length;
              // Use new API endpoint for overall average
              final url = Uri.parse('https://strivehigh.thirdvizion.com/api/quizansoverallstroe/');
              final body = json.encode({
                'email': userEmail,
                'overall_avg': overallAvg,
              });
              try {
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: body,
                );
                if (response.statusCode == 200 || response.statusCode == 201) {
                  print('Overall average sent successfully');
                } else {
                  print('Failed to send overall average: ${response.statusCode}');
                }
              } catch (e) {
                print('Error sending overall average: $e');
              }
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SoarDashboardPage(userEmail: userEmail),
              ),
            );
          }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No answers for this category.')),
        );
      }
  }

  Future<void> _submitAssessment() async {
    List<SoarCardAnswer> answers = [];
    Map<String, List<int>> categoryScores = {};
    _selectedAnswers.forEach((questionId, answer) {
      String questionText = '';
      String category = '';
      List<String> options = [];
      for (var q in _questions) {
        if (q['id'].toString() == questionId) {
          questionText = q['text'] ?? '';
          category = q['category'] ?? 'Uncategorized';
          options = q['options'] as List<String>;
          break;
        }
      }
      answers.add(SoarCardAnswer(
        questionId: questionId,
        questionText: questionText,
        answer: answer,
        createdAt: DateTime.now(),
      ));
      // Calculate score: (options.length - index) * 10, first option 50, last 10 for 5 options
      int index = options.indexOf(answer);
      int score = (options.length - index) * 10;
      if (score > 0) {
        if (!categoryScores.containsKey(category)) {
          categoryScores[category] = [];
        }
        categoryScores[category]!.add(score);
      }
    });

    Map<String, double> categoryAverages = {};
    categoryScores.forEach((category, scores) {
      if (scores.isNotEmpty) {
        double sum = scores.reduce((a, b) => a + b).toDouble();
        categoryAverages[category] = sum / scores.length;
      }
    });

    bool saved = await SoarCardService.saveSoarCardAnswers(answers);
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answers saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Send each category average to submitquiz API
      for (var entry in categoryAverages.entries) {
        await _sendCategoryAverageToSubmitQuiz(userEmail, entry.key, entry.value);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoalPage(userEmail: userEmail),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save answers.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.blue,
        image: DecorationImage(
          image: AssetImage('lib/assets/images/world.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),

      

      child: Column(
        children: const [
          const SizedBox(height: 20),
          Text(
            "Know",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            "SOAR Assessment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          SizedBox(height: 4),
          Text(
            "Strength, Opportunities, Aspirations & Recommendations",
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q, int qIndex, int totalQuestions, String selected, String category) {
    return Container(
      key: _questionKeys[category]![qIndex],
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Color.fromARGB(255, 218, 240, 255),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                q['category'] ?? "Uncategorized",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Question ${qIndex + 1} of $totalQuestions",
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              Text(q['text'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              ...q['options'].map<Widget>((option) {
                final isSelected = selected == option;
                return GestureDetector(
                  onTap: () => _handleAnswerSelected(q['id'].toString(), option),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade400, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(option, style: const TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Dot Indicator
          Row(
            children: List.generate(_categories.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.blue : Colors.grey.shade400,
                ),
              );
            }),
          ),
          // 🔹 Next / Submit Button
          FloatingActionButton(
            backgroundColor: Colors.blue,
            child: Icon(
              (_categorySubmitted[_categories[_currentPage]] ?? false)
                  ? (_currentPage < _categories.length - 1 ? Icons.arrow_forward : Icons.check)
                  : Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              String currentCategory = _categories[_currentPage];
              if (_categorySubmitted[currentCategory] ?? false) {
                if (_currentPage < _categories.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // All submitted, go to next screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SoarDashboardPage(userEmail: userEmail),
                    ),
                  );
                }
              } else {
                _submitCategory(currentCategory);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: _categories.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          String category = _categories[index];
                          List<Map<String, dynamic>> questions = _questionsByCategory[category]!;
                          return ListView.builder(
                            itemCount: questions.length,
                            itemBuilder: (context, qIndex) {
                              final q = questions[qIndex];
                              final selected = _selectedAnswers[q['id'].toString()] ?? '';
                              return _buildQuestionCard(q, qIndex, questions.length, selected, category);
                            },
                          );
                        },
                      ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }
}