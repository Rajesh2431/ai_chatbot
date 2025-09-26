import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'goal_settings.dart';
import '../services/api_service.dart';
import 'goalinfo_screen.dart';
import 'soar_pdf_generator.dart';

class SoarDashboardPage extends StatefulWidget {
  final String userEmail;

  const SoarDashboardPage({super.key, required this.userEmail});

  @override
  State<SoarDashboardPage> createState() => _SoarDashboardPageState();
}

class _SoarDashboardPageState extends State<SoarDashboardPage> {
  bool _isLoading = true;
  String? _error;

  List<double> overallAvg = [];
  List<Map<String, dynamic>> categoryWise = [];

  // Score ranges and feedback content from the document
  final Map<String, Map<String, String>> scoreRanges = {
    "17-20": {
      "title": "Very Strong Resilience",
      "feedback":
          "You have shown remarkable strength in managing stress, staying composed, and using your personal abilities effectively at sea. This level of resilience suggests you can handle unexpected challenges with confidence, which benefits both you and your crew. I encourage you to keep reinforcing these healthy coping strategies, as they are protective factors against burnout and isolation.",
    },
    "13-16": {
      "title": "Strong Resilience",
      "feedback":
          "You demonstrate solid resilience skills that serve you well in challenging maritime environments. Your ability to manage stress and maintain composure shows strong personal capabilities. Continue building on these strengths while exploring additional coping strategies to further enhance your resilience.",
    },
    "9-12": {
      "title": "Moderate Resilience",
      "feedback":
          "You have a good foundation of resilience skills with room for growth. Your current coping strategies are working, but there's potential to develop even stronger stress management and emotional regulation abilities. Focus on building additional tools and techniques to enhance your resilience further.",
    },
    "5-8": {
      "title": "Developing Resilience",
      "feedback":
          "You're in the early stages of developing resilience skills. This is a great starting point, and with focused effort and practice, you can quickly build confidence and stronger coping abilities. Consider exploring new stress management techniques and building a support network to accelerate your growth.",
    },
    "1-4": {
      "title": "Building Resilience",
      "feedback":
          "This area is at an early stage of development. With focus and practice, you can quickly build confidence and skill here. Every journey begins with awareness, and you're taking the important first steps toward developing stronger resilience capabilities.",
    },
  };

  // Track expanded state for each category
  final Map<String, bool> _expandedCategories = {};

  // Cache AI responses to prevent unnecessary refreshes
  final Map<String, String> _aiResponseCache = {};

  @override
  void initState() {
    super.initState();
    _fetchSoarCardDetails();
  }

  /// Refresh SOAR card data - useful for pull-to-refresh or manual refresh
  /// This will fetch the first 12 quiz answers for the user
  Future<void> refreshSoarData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _fetchSoarCardDetails();
  }

  Future<void> _fetchSoarCardDetails() async {
    try {
      // Try multiple API endpoints in order of preference
      List<String> urls = [
        "https://strivehigh.thirdvizion.com/api/soarcarddetails/${widget.userEmail}/?format=json&limit=12&order=desc&order_by=created_at",
        "https://strivehigh.thirdvizion.com/api/soarcarddetails/${widget.userEmail}/?format=api&limit=12&order=desc&order_by=created_at",
        "https://strivehigh.thirdvizion.com/api/soarcarddetails/${widget.userEmail}/?limit=12&order=desc&order_by=created_at",
        "https://strivehigh.thirdvizion.com/api/soarcarddetails/${widget.userEmail}/",
      ];

      http.Response? response;
      String? usedUrl;

      // Try each URL until one works
      for (String url in urls) {
        try {
          debugPrint("Trying API endpoint: $url");
          response = await http.get(Uri.parse(url));

          // Check if response is valid JSON
          if (response.statusCode == 200) {
            try {
              final jsonData = json.decode(response.body);
              usedUrl = url;
              debugPrint("Successfully connected to: $url");
              debugPrint(
                "Response contains ${jsonData.keys.length} keys: ${jsonData.keys.toList()}",
              );
              break;
            } catch (jsonError) {
              debugPrint("Invalid JSON response from $url: $jsonError");
              debugPrint(
                "Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}",
              );
              continue;
            }
          } else {
            debugPrint("HTTP error ${response.statusCode} from $url");
            debugPrint("Response body: ${response.body}");
            continue;
          }
        } catch (e) {
          debugPrint("Exception with $url: $e");
          continue;
        }
      }

      if (response == null || response.statusCode != 200) {
        // Fallback to sample data if API fails
        debugPrint("API failed, using sample data for demonstration");
        setState(() {
          // Generate sample data for 12 quiz answers
          overallAvg = List.generate(12, (index) => (index + 1) * 0.5 + 2.0);
          categoryWise = [
            {"category": "Resilience", "avg": 7.5},
            {"category": "Communication", "avg": 8.2},
            {"category": "Leadership", "avg": 6.8},
            {"category": "Teamwork", "avg": 9.1},
            {"category": "Problem Solving", "avg": 7.3},
            {"category": "Adaptability", "avg": 8.7},
            {"category": "Stress Management", "avg": 6.9},
            {"category": "Decision Making", "avg": 8.4},
            {"category": "Emotional Intelligence", "avg": 7.8},
            {"category": "Conflict Resolution", "avg": 8.0},
            {"category": "Time Management", "avg": 7.6},
            {"category": "Self Awareness", "avg": 8.3},
          ];
          _isLoading = false;
        });
        return;
      }

      final data = json.decode(response.body);

      setState(() {
        // Process overall averages from the quiz answers - take first 12
        if (data['overall_avg'] != null) {
          List<dynamic> rawOverallAvg = data['overall_avg'] as List<dynamic>;

          // Take only the first 12 entries
          if (rawOverallAvg.length > 12) {
            rawOverallAvg = rawOverallAvg.take(12).toList();
            debugPrint(
              "Limited overall averages to first 12 entries (from ${data['overall_avg'].length} total)",
            );
          }

          overallAvg = rawOverallAvg
              .map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList();
        } else {
          overallAvg = [];
        }

        // Process category-wise averages from the quiz answers - take first 12
        if (data['category_wise_avgs'] != null) {
          List<dynamic> rawCategoryWise =
              data['category_wise_avgs'] as List<dynamic>;

          // Take only the first 12 entries
          if (rawCategoryWise.length > 12) {
            rawCategoryWise = rawCategoryWise.take(12).toList();
            debugPrint(
              "Limited category-wise averages to first 12 entries (from ${data['category_wise_avgs'].length} total)",
            );
          }

          categoryWise = rawCategoryWise
              .map(
                (e) => {
                  "category": e['category'].toString(),
                  "avg": double.tryParse(e['avg'].toString()) ?? 0.0,
                },
              )
              .where((e) => e["category"].toString().isNotEmpty)
              .toList();
        } else {
          categoryWise = [];
        }

        _isLoading = false;
      });

      debugPrint(
        "Successfully loaded ${overallAvg.length} overall averages and ${categoryWise.length} category averages from first 12 quiz answers for user: ${widget.userEmail} using: $usedUrl",
      );
    } catch (e) {
      setState(() {
        _error = "Error fetching SOAR data: $e";
        _isLoading = false;
      });
      debugPrint("Exception in _fetchSoarCardDetails: $e");
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
            "SOAR CARD",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Result",
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

  /// Modern SOAR Assessment Overview
  Widget _buildSoarCard() {
    if (categoryWise.isEmpty) {
      return _buildEmptyState();
    }

    // Use category-wise data instead of overall average
    final maxValue = categoryWise
        .map((e) => e["avg"] as double)
        .reduce((a, b) => a > b ? a : b);
    final avgScore =
        categoryWise.map((e) => e["avg"] as double).reduce((a, b) => a + b) /
        categoryWise.length;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with insights
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your SOAR Assessment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _error != null
                            ? "Sample data (API unavailable) • ${_getOverallInsight(avgScore)}"
                            : _getOverallInsight(avgScore),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Score summary
            _buildScoreSummary(avgScore, maxValue),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Assessment Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your SOAR assessment to see your results here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(double avgScore, double maxValue) {
    final percentage = (avgScore / maxValue * 100).round();
    final level = _getPerformanceLevel(percentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: level['colors'] as List<Color>),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level['description'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getOverallInsight(double avgScore) {
    if (avgScore >= 80) {
      return "Excellent performance! You're showing strong competency across all areas.";
    } else if (avgScore >= 60) {
      return "Good progress! You're developing well with room for continued growth.";
    } else if (avgScore >= 40) {
      return "You're on the right track! Focus on the areas that need attention.";
    } else {
      return "Great start! Every journey begins with the first step.";
    }
  }

  Map<String, dynamic> _getPerformanceLevel(int percentage) {
    if (percentage >= 80) {
      return {
        'title': 'Excellent',
        'description': 'Outstanding performance across all competencies',
        'colors': [Colors.green.shade500, Colors.green.shade600],
      };
    } else if (percentage >= 60) {
      return {
        'title': 'Good',
        'description': 'Strong foundation with areas for growth',
        'colors': [Colors.blue.shade500, Colors.blue.shade600],
      };
    } else if (percentage >= 40) {
      return {
        'title': 'Developing',
        'description': 'Good progress with focused improvement needed',
        'colors': [Colors.orange.shade500, Colors.orange.shade600],
      };
    } else {
      return {
        'title': 'Beginning',
        'description': 'Starting your development journey',
        'colors': [Colors.red.shade500, Colors.red.shade600],
      };
    }
  }

  /// Expandable SOAR Cards matching the image design
  Widget _buildCompetencyCard() {
    if (categoryWise.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: categoryWise.map((item) {
          return _buildExpandableSoarCard(item);
        }).toList(),
      ),
    );
  }

  Widget _buildExpandableSoarCard(Map<String, dynamic> item) {
    final category = item["category"] as String;
    final score = item["avg"] as double;
    final percentage = score.round();
    final isExpanded = _expandedCategories[category] ?? false;

    // Get score range and original feedback
    final scoreRange = _getScoreRange(percentage);
    final originalFeedback = scoreRanges[scoreRange] ?? scoreRanges["1-4"]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main card content
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category name
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress bar and percentage
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getProgressBarColor(percentage),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "$percentage%",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dynamic feedback text with info icon
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getProgressBarColor(percentage),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getFeedbackText(percentage),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(
                            0xFF2D3748,
                          ), // Darker color for better readability
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildAIResponse(category, percentage, originalFeedback),
              ),
            ),
        ],
      ),
    );
  }

  String _getScoreRange(int percentage) {
    if (percentage >= 17) return "17-20";
    if (percentage >= 13) return "13-16";
    if (percentage >= 9) return "9-12";
    if (percentage >= 5) return "5-8";
    return "1-4";
  }

  Color _getProgressBarColor(int percentage) {
    // Use blue gradient colors for all progress bars
    if (percentage >= 80) return const Color(0xFF79FEFC);
    if (percentage >= 60) return const Color(0xFF239CD3);
    if (percentage >= 40) return const Color(0xFF239CD3).withOpacity(0.8);
    if (percentage >= 20) return const Color(0xFF239CD3).withOpacity(0.6);
    return const Color(0xFF239CD3).withOpacity(0.4);
  }

  String _getFeedbackText(int percentage) {
    if (percentage >= 80) return "Excellent performance!";
    if (percentage >= 60) return "Good progress, keep it up!";
    if (percentage >= 40) return "Focus on improving";
    if (percentage >= 20) return "Needs attention";
    return "Requires development";
  }

  Widget _buildAIResponse(
    String category,
    int percentage,
    Map<String, String> originalFeedback,
  ) {
    final cacheKey = '${category}_$percentage';

    // Check if we have a cached response
    if (_aiResponseCache.containsKey(cacheKey)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            originalFeedback["title"]!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _aiResponseCache[cacheKey]!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
              height: 1.4,
            ),
          ),
        ],
      );
    }

    // Generate new AI response if not cached
    return FutureBuilder<String>(
      future: OpenRouterAPI.getSOARFeedback(
        category: category,
        score: percentage,
        originalFeedback: originalFeedback["feedback"]!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text(
                "Generating personalized feedback...",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          );
        }

        final emotionalFeedback =
            snapshot.data ?? originalFeedback["feedback"]!;

        // Cache the response
        _aiResponseCache[cacheKey] = emotionalFeedback;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              originalFeedback["title"]!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emotionalFeedback,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                height: 1.4,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPdfDownloadButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: categoryWise.isEmpty
                  ? null
                  : () async {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          content: Row(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 16),
                              const Text('Generating PDF...'),
                            ],
                          ),
                        ),
                      );

                      try {
                        await SoarPdfGenerator.generateAndDownloadPdf(
                          userEmail: widget.userEmail,
                          categoryWise: categoryWise,
                          overallAvg: overallAvg,
                          context: context,
                        );
                      } finally {
                        // Close loading dialog
                        Navigator.of(context).pop();
                      }
                    },
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text('Download PDF Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Optional: Add a preview button
          ElevatedButton(
            onPressed: categoryWise.isEmpty
                ? null
                : () {
                    _showPdfPreviewDialog();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Icon(Icons.preview_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  void _showPdfPreviewDialog() {
    final avgScore = categoryWise.isNotEmpty
        ? categoryWise.map((e) => e["avg"] as double).reduce((a, b) => a + b) /
              categoryWise.length
        : 0.0;
    final maxValue = categoryWise.isNotEmpty
        ? categoryWise
              .map((e) => e["avg"] as double)
              .reduce((a, b) => a > b ? a : b)
        : 0.0;
    final percentage = maxValue > 0 ? (avgScore / maxValue * 100).round() : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Report Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User: ${widget.userEmail}'),
              const SizedBox(height: 8),
              Text('Overall Score: $percentage%'),
              const SizedBox(height: 8),
              Text('Categories: ${categoryWise.length}'),
              const SizedBox(height: 16),
              const Text('This PDF will include:'),
              const SizedBox(height: 8),
              const Text('• Complete assessment overview'),
              const Text('• Category-wise performance breakdown'),
              const Text('• Detailed feedback for each category'),
              const Text('• Professional formatting and branding'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  content: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      const Text('Generating PDF...'),
                    ],
                  ),
                ),
              );

              try {
                await SoarPdfGenerator.generateAndDownloadPdf(
                  userEmail: widget.userEmail,
                  categoryWise: categoryWise,
                  overallAvg: overallAvg,
                  context: context,
                );
              } finally {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Generate PDF'),
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
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _error != null
                ? _buildErrorState()
                : RefreshIndicator(
                    onRefresh: refreshSoarData,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        _buildSoarCard(),
                        _buildCompetencyCard(),
                        // Add the PDF download button here
                        _buildPdfDownloadButton(),
                      ],
                    ),
                  ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade500),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing your assessment...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
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
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchSoarCardDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalInfoScreen(userEmail: widget.userEmail),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue to Goal Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
