
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'goal_settings.Dart'; // Import goal settings page
import '../services/soar_card_service.dart';
import '../models/soar_card_answer.dart';

class QuizPage extends StatefulWidget {
  final String userEmail;
  
  const QuizPage({super.key, required this.userEmail});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _sections = [];
  final Map<String, TextEditingController> _answerControllers = {};
  late final String _userEmail; // Will be set from widget.userEmail

  @override
  void initState() {
    super.initState();
    _userEmail = widget.userEmail;
    fetchQuizDetails();
  }

  Future<void> fetchQuizDetails() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/quizdetails/');
    try {
      final response = await http.get(url);
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed Data: $data');
        
        // Check if data is a list
        if (data is List) {
          // Split questions into two sections: first 7 questions, then remaining 8
          final firstSectionQuestions = data.take(7).map((q) => {
            'text': q['question'] ?? 'No question text',
            'id': q['id']
          }).toList();
          
          final secondSectionQuestions = data.skip(7).take(8).map((q) => {
            'text': q['question'] ?? 'No question text',
            'id': q['id']
          }).toList();
          
          // Create two sections
          final sections = [
            {
              'title': 'Section 1 (Questions 1-7)',
              'questions': firstSectionQuestions
            },
            {
              'title': 'Section 2 (Questions 8-15)',
              'questions': secondSectionQuestions
            }
          ];
          
          // Initialize text controllers for each question
          for (final section in sections) {
            final questionsList = section['questions'] as List<dynamic>;
            for (final question in questionsList) {
              final questionId = question['id'].toString();
              _answerControllers[questionId] = TextEditingController();
            }
          }
          
          setState(() {
            _sections = sections;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid API response format: Expected a list';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load quiz details: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching quiz details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> submitQuizAnswers() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/submitquiz/');
    
    // Collect all answers for local storage
    List<SoarCardAnswer> localAnswers = [];
    
    // Collect all answers and submit them individually
    int successCount = 0;
    int failureCount = 0;
    List<String> errorMessages = [];
    
    for (final section in _sections) {
      final questions = section['questions'] as List<dynamic>;
      for (final question in questions) {
        final questionId = question['id'].toString();
        final questionText = question['text'] ?? '';
        final answerText = _answerControllers[questionId]?.text ?? '';
        
        if (answerText.isNotEmpty) {
          // Add to local answers list
          localAnswers.add(SoarCardAnswer(
            questionId: questionId,
            questionText: questionText,
            answer: answerText,
            createdAt: DateTime.now(),
          ));

          try {
            final response = await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'email': _userEmail,
                'question': questionId,
                'ans': answerText,
              }),
            );

            if (response.statusCode == 200 || response.statusCode == 201) {
              successCount++;
              final responseData = json.decode(response.body);
              final successMessage = responseData['message'] ?? 'Answer submitted successfully';
              print('Success for question $questionId: $successMessage');
            } else {
              failureCount++;
              final errorMessage = 'Question $questionId: Failed with status ${response.statusCode}';
              print(errorMessage);
              try {
                final errorData = json.decode(response.body);
                final backendMessage = errorData['error'] ?? errorData['message'] ?? 'Unknown error';
                errorMessages.add('Question $questionId: $backendMessage');
              } catch (e) {
                errorMessages.add(errorMessage);
              }
            }
          } catch (e) {
            failureCount++;
            final errorMessage = 'Question $questionId: Error - $e';
            print(errorMessage);
            errorMessages.add(errorMessage);
          }
        }
      }
    }

    // Save answers locally regardless of API success/failure
    if (localAnswers.isNotEmpty) {
      await SoarCardService.saveSoarCardAnswers(localAnswers);
    }

    if (successCount > 0 && failureCount == 0) {
      // All answers succeeded
      _showSuccessSnackBar('Your answers have been submitted successfully!');
      // Redirect to goal settings page after success
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GoalPage()),
        );
      });
    } else if (successCount > 0 && failureCount > 0) {
      // Some answers succeeded, some failed
      final errorSummary = errorMessages.join('\n\n');
      _showErrorSnackBar('Some answers were submitted successfully, but there were issues:\n\n$errorSummary');
    } else if (failureCount > 0) {
      // All submissions failed
      final errorSummary = errorMessages.join('\n\n');
      _showErrorSnackBar('Failed to submit your answers:\n\n$errorSummary');
    } else {
      // No answers provided
      _showErrorSnackBar('Please answer at least one question before submitting.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up all TextEditingController instances
    for (final controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int _currentSectionIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(child: Text(_errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with step indicator and star background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                image: const DecorationImage(
                  image: AssetImage('assets/images/.png'),
                  fit: BoxFit.cover,
                  opacity: 0.3, // Adjust opacity to make it subtle
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Questions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for better contrast
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_sections.length, (index) {
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: index == _currentSectionIndex ? Colors.lightBlue : Colors.white,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index == _currentSectionIndex ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          if (index != _sections.length - 1)
                            Container(
                              width: 40,
                              height: 2,
                              color: Colors.grey,
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),

            // Section + Questions with PageView for swiping
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _sections.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentSectionIndex = index;
                  });
                },
                itemBuilder: (context, sectionIndex) {
                  final section = _sections[sectionIndex];
                  final questions = section['questions'] as List<dynamic>? ?? [];

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            section['title'] ?? 'Section ${sectionIndex + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Questions inside each section
                        Expanded(
                          child: ListView.builder(
                            itemCount: questions.length,
                            itemBuilder: (context, qIndex) {
                              final question = questions[qIndex];
                              final questionText = question['text'] ?? 'Question ${qIndex + 1}';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${qIndex + 1}. $questionText',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _answerControllers[question['id'].toString()],
                                      decoration: InputDecoration(
                                        hintText: "Type Here",
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons and Confirm Button
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _currentSectionIndex > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        child: const Text(
                          "Previous",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _currentSectionIndex < _sections.length - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        child: const Text(
                          "Next",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm Button (only show on last section)
                  if (_currentSectionIndex == _sections.length - 1)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          submitQuizAnswers();
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
