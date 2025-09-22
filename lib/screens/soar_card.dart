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
  final Map<String, bool> _categorySubmitted = {};
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
      final url = Uri.parse(
        'https://strivehigh.thirdvizion.com/api/quizdetails/',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> questions = [];
        for (var item in data) {
          List<String> options = [];
          for (var opt in [
            'option_a',
            'option_b',
            'option_c',
            'option_d',
            'option_e',
          ]) {
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

    List<Map<String, dynamic>> questionsInCategory =
        _questionsByCategory[currentCategory]!;

    if (currentQuestionIndex < questionsInCategory.length - 1) {
      // Move to next question in the same category by scrolling the ListView
      Scrollable.ensureVisible(
        _questionKeys[currentCategory]![currentQuestionIndex + 1]
            .currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last question in category, submit category and move to next category automatically
      _submitCategory(currentCategory);
      if (_currentPage < _categories.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> _sendCategoryAverageToSubmitQuiz(
    String email,
    String category,
    double avg,
  ) async {
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
        print(
          'Failed to send category average to submitquiz: ${response.statusCode}',
        );
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
        int score =
            (options.length - index) *
            10; // First option 50, last 10 for 5 options
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
              int score =
                  (options.length - index) *
                  10; // First option 50, last 10 for 5 options
              if (score > 0) {
                allScores.add(score);
              }
              break;
            }
          }
        });
        if (allScores.isNotEmpty) {
          double overallAvg =
              allScores.reduce((a, b) => a + b) / allScores.length;
          // Use new API endpoint for overall average
          final url = Uri.parse(
            'https://strivehigh.thirdvizion.com/api/quizansoverallstroe/',
          );
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
      answers.add(
        SoarCardAnswer(
          questionId: questionId,
          questionText: questionText,
          answer: answer,
          createdAt: DateTime.now(),
        ),
      );
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
        await _sendCategoryAverageToSubmitQuiz(
          userEmail,
          entry.key,
          entry.value,
        );
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GoalPage(userEmail: userEmail)),
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
          SizedBox(height: 20),
          Text(
            "Know",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "SOAR",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Assessment",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Strength, Opportunities, Aspirations & Result",
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    Map<String, dynamic> q,
    int qIndex,
    int totalQuestions,
    String selected,
    String category,
  ) {
    return Container(
      key: _questionKeys[category]![qIndex],
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [Colors.blue.shade50, Colors.blue.shade100],
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //     ),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Text(
              //     q['category'] ?? "Uncategorized",
              //     style: TextStyle(
              //       fontSize: 12,
              //       fontWeight: FontWeight.w600,
              //       color: Colors.blue.shade700,
              //       letterSpacing: 0.5,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16),
              // Progress indicator
              Row(
                children: [
                  Text(
                    "Question ${qIndex + 1}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (qIndex + 1) / totalQuestions,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$totalQuestions",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Question text
              Text(
                q['text'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 24),
              // Options
              ...q['options'].asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = selected == option;
                final optionLabels = ['A', 'B', 'C', 'D', 'E'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          _handleAnswerSelected(q['id'].toString(), option),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue.shade300
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Option letter
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade500
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  optionLabels[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Option text
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.blue.shade800
                                      : Colors.grey.shade700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            // Selection indicator
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Colors.blue.shade500,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
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
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Progress dots
          // Positioned(
          //   top: 20,
          //   left: 0,
          //   right: 0,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: List.generate(_categories.length, (index) {
          //       final bool active = _currentPage == index;
          //       final bool completed =
          //           _categorySubmitted[_categories[index]] ?? false;

          //       return Container(
          //         margin: const EdgeInsets.symmetric(horizontal: 6),
          //         child: AnimatedContainer(
          //           duration: const Duration(milliseconds: 300),
          //           width: active ? 12 : 8,
          //           height: active ? 12 : 8,
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: completed
          //                 ? Colors.green.shade500
          //                 : active
          //                 ? Colors.blue.shade500
          //                 : Colors.grey.shade300,
          //             boxShadow: active
          //                 ? [
          //                     BoxShadow(
          //                       color: Colors.blue.withOpacity(0.3),
          //                       blurRadius: 8,
          //                       spreadRadius: 2,
          //                     ),
          //                   ]
          //                 : null,
          //           ),
          //           child: completed
          //               ? Icon(Icons.check, size: 8, color: Colors.white)
          //               : null,
          //         ),
          //       );
          //     }),
          //   ),
          // ),
          // Next/Submit button
          Positioned(
            right: 20,
            top: 12,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade500, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    String currentCategory = _categories[_currentPage];
                    if (_categorySubmitted[currentCategory] ?? false) {
                      if (_currentPage < _categories.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SoarDashboardPage(userEmail: userEmail),
                          ),
                        );
                      }
                    } else {
                      _submitCategory(currentCategory);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (_categorySubmitted[_categories[_currentPage]] ??
                                  false)
                              ? (_currentPage < _categories.length - 1
                                    ? "Next"
                                    : "Complete")
                              : "Submit",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          (_categorySubmitted[_categories[_currentPage]] ??
                                  false)
                              ? (_currentPage < _categories.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.check)
                              : Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Category progress text
          Positioned(
            left: 20,
            top: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   _categories[_currentPage],
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w600,
                //     color: Colors.grey.shade700,
                //   ),
                // ),
                const SizedBox(height: 2),
                Text(
                  "Step ${_currentPage + 1} of ${_categories.length}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Powered by StriveHigh',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade500,
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Loading Assessment...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : _error != null
                ? Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _categories.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      String category = _categories[index];
                      List<Map<String, dynamic>> questions =
                          _questionsByCategory[category]!;
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: questions.length,
                        itemBuilder: (context, qIndex) {
                          final q = questions[qIndex];
                          final selected =
                              _selectedAnswers[q['id'].toString()] ?? '';
                          return _buildQuestionCard(
                            q,
                            qIndex,
                            questions.length,
                            selected,
                            category,
                          );
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
