import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/user_profile_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _userEmail;

  // Self-reflection questions
  final List<String> _selfReflectionQuestions = [
    "What has been your most significant area of personal growth during this journey?",
    "How has your emotional intelligence improved, and in what situations did you notice it most?",
    "What challenges did you face, and what strategies helped you overcome them?",
    "How did you manage stress or pressure while staying focused on your duties?",
    "What achievements or milestones are you most proud of, big or small?",
    "How have you contributed to teamwork and crew harmony during this voyage?",
    "What feedback did you receive from others, and how has it shaped you?",
    "How have your values, ethics, or integrity guided your actions on board?",
    "In what ways will you apply these learnings and skills in your future maritime career?",
    "What one personal habit or practice will you continue to strengthen after this journey?",
  ];

  // General experience questions
  final List<String> _generalExperienceQuestions = [
    "How easy was it to use the app?",
    "Did you face any issues while navigating the app?",
    "How satisfied are you with the overall app experience?",
  ];

  // Controllers for self-reflection answers
  final Map<String, TextEditingController> _selfReflectionControllers = {};

  // Controllers/variables for general experience answers
  String? _appEaseAnswer;
  String? _navigationIssueAnswer;
  String? _navigationIssueDescription;
  int? _appSatisfactionRating;

  @override
  void initState() {
    super.initState();
    for (var q in _selfReflectionQuestions) {
      _selfReflectionControllers[q] = TextEditingController();
    }
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    _userEmail = await UserProfileService.getUserEmail();
    setState(() {});
  }

  @override
  void dispose() {
    for (var c in _selfReflectionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    if (_appEaseAnswer == null) {
      _showSnackBar("Please answer: How easy was it to use the app?");
      return;
    }
    if (_navigationIssueAnswer == null) {
      _showSnackBar("Please answer: Did you face any issues while navigating the app?");
      return;
    }
    if (_appSatisfactionRating == null) {
      _showSnackBar("Please rate your satisfaction with the overall app experience.");
      return;
    }

    setState(() => _isLoading = true);

    // Prepare self-reflection feedback list for old API
    final selfReflectionFeedbackList = _selfReflectionQuestions.map((q) {
      return {
        "email": _userEmail ?? "anonymous@example.com",
        "question": q,
        "content": _selfReflectionControllers[q]!.text.trim(),
      };
    }).toList();

    // Prepare general experience feedback list for new API
    final generalExperienceFeedbackList = [
      {
        "question": "How easy was it to use the app?",
        "content": _appEaseAnswer!,
        "comments": "",
      },
      {
        "question": "Did you face any issues while navigating the app?",
        "content": _navigationIssueAnswer!,
        "comments": _navigationIssueDescription ?? "",
      },
      {
        "question": "How satisfied are you with the overall app experience?",
        "content": _appSatisfactionRating.toString(),
        "comments": "",
      },
    ];

    try {
      // Send self-reflection feedback to old API
      final oldApiUrl = Uri.parse("https://strivehigh.thirdvizion.com/api/submitfeedback/");
      final oldApiResponse = await http.post(
        oldApiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode(selfReflectionFeedbackList),
      );

      if (oldApiResponse.statusCode != 201 && oldApiResponse.statusCode != 200) {
        throw Exception("Failed to submit self-reflection feedback: ${oldApiResponse.body}");
      }

      // Send general experience feedback to new API
      final newApiUrl = Uri.parse("https://strivehigh.thirdvizion.com/api/gfeedbackpost/");
      final newApiResponse = await http.post(
        newApiUrl,
        headers: {"Content-Type": "application/json"},
        body: json.encode(generalExperienceFeedbackList),
      );

      if (newApiResponse.statusCode != 201 && newApiResponse.statusCode != 200) {
        throw Exception("Failed to submit general experience feedback: ${newApiResponse.body}");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thank you for your reflections!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error submitting feedback: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error submitting feedback: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildGeneralExperienceQuestion1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How easy was it to use the app?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _appEaseAnswer,
          items: const [
            DropdownMenuItem(value: "Very Easy", child: Text("Very Easy")),
            DropdownMenuItem(value: "Easy", child: Text("Easy")),
            DropdownMenuItem(value: "Okay", child: Text("Okay")),
            DropdownMenuItem(value: "Difficult", child: Text("Difficult")),
          ],
          onChanged: (value) {
            setState(() {
              _appEaseAnswer = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select an option.";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGeneralExperienceQuestion2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Did you face any issues while navigating the app?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _navigationIssueAnswer,
          items: const [
            DropdownMenuItem(value: "No", child: Text("No")),
            DropdownMenuItem(value: "Yes", child: Text("Yes")),
          ],
          onChanged: (value) {
            setState(() {
              _navigationIssueAnswer = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select an option.";
            }
            return null;
          },
        ),
        if (_navigationIssueAnswer == "Yes") ...[
          const SizedBox(height: 8),
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "If yes, please describe the issues...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _navigationIssueDescription = value;
              });
            },
            validator: (value) {
              if (_navigationIssueAnswer == "Yes" && (value == null || value.trim().isEmpty)) {
                return "Please describe the issues you faced.";
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildGeneralExperienceQuestion3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How satisfied are you with the overall app experience?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _appSatisfactionRating,
          items: List.generate(5, (index) {
            final rating = index + 1;
            return DropdownMenuItem(
              value: rating,
              child: Row(
                children: List.generate(rating, (_) => const Icon(Icons.star, color: Colors.amber, size: 20)),
              ),
            );
          }),
          onChanged: (value) {
            setState(() {
              _appSatisfactionRating = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null) {
              return "Please select a rating.";
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Self Reflection",
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Self-Reflection Questions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),

              // Generate self-reflection question + text field
              ..._selfReflectionQuestions.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _selfReflectionControllers[q],
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Type your answer here...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF4A90E2), width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Please answer this question.";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 30),

              const Text(
                "General Experience",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),

              // General experience questions widgets
              _buildGeneralExperienceQuestion1(),
              const SizedBox(height: 24),
              _buildGeneralExperienceQuestion2(),
              const SizedBox(height: 24),
              _buildGeneralExperienceQuestion3(),

              const SizedBox(height: 30),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Submit Feedback",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}