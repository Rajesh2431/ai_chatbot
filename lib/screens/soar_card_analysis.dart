import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'goal_settings.dart';

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

  // Category descriptions for improvement suggestions
  final Map<String, String> categoryDescriptions = {
    "Teamwork": "This area is at an early stage of development. With focus and practice, you can quickly build confidence and skill here.",
    "Communication & influencing (Emotional Openness )": "You demonstrate a balanced level of competence. With consistent practice, you can elevate this strength further.",
    "Situation Awareness": "This area is at an early stage of development. With focus and practice, you can quickly build confidence and skill here.",
    "Decision making": "This area is at an early stage of development. With focus and practice, you can quickly build confidence and skill here.",
    "Result Focus (Professional Development & Compliance)": "This area is at an early stage of development. With focus and practice, you can quickly build confidence and skill here.",
    "Leadership": "This area is at an early stage of development. With focus and practice, you can quickly build confidence and skill here.",
    "Stress management": "You demonstrate a balanced level of competence. With consistent practice, you can elevate this strength further.",
    "Crew Relationships": "You show some awareness in this area. Continued effort and small adjustments will help you grow steadily.",
    "Help-Seeking": "You demonstrate a balanced level of competence. With consistent practice, you can elevate this strength further.",
    "Empathy": "You show some awareness in this area. Continued effort and small adjustments will help you grow steadily.",
    "Command Pressure": "This area is at an early stage of development. With focus and practice, you can quickly build confidence and skill here.",
  };

  @override
  void initState() {
    super.initState();
    _fetchSoarCardDetails();
  }

  Future<void> _fetchSoarCardDetails() async {
    try {
      final url = Uri.parse(
          "https://strivehigh.thirdvizion.com/api/soarcarddetails/${widget.userEmail}/");
      debugPrint("Fetching SoarCard details from: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          overallAvg = (data['overall_avg'] as List<dynamic>)
              .map((e) => double.tryParse(e.toString()) ?? 0.0)
              .toList();

          categoryWise = (data['category_wise_avgs'] as List<dynamic>)
              .map((e) => {
                    "category": e['category'].toString(),
                    "avg": double.tryParse(e['avg'].toString()) ?? 0.0
                  })
              .where((e) => e["category"].toString().isNotEmpty)
              .toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isLoading = false;
      });
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
      child: const SizedBox(height: 120),
    );
  }

  /// 🔹 Soar Card (bars with integer values, X-axis 1..n)
  Widget _buildSoarCard() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.lightGreen,
      Colors.blue,
      Colors.indigo
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Soar Card",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: (overallAvg.isNotEmpty
                          ? overallAvg.reduce((a, b) => a > b ? a : b)
                          : 10) +
                      2,
                  barTouchData: BarTouchData(enabled: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < overallAvg.length) {
                            return Text(
                              "${idx + 1}", // ✅ show 1..n
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  barGroups: overallAvg.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value.toInt(); // ✅ integer values

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: value.toDouble(),
                          width: 20,
                          borderRadius: BorderRadius.circular(6),
                          color: colors[index % colors.length],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Competency Card (progress bars with percentage labels)
  Widget _buildCompetencyCard() {
    // Find the category with the lowest avg
    Map<String, dynamic>? lowestCategory;
    double lowestAvg = double.infinity;
    for (var item in categoryWise) {
      final avg = item["avg"] ?? 0.0;
      if (avg < lowestAvg) {
        lowestAvg = avg;
        lowestCategory = item;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Competency Development Over Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: categoryWise.map((item) {
                final percent = item["avg"] ?? 0.0;
                final isLowest = item == lowestCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["category"],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isLowest ? FontWeight.bold : FontWeight.normal,
                                  color: isLowest ? Colors.red : Colors.black,
                                )),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percent / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                color: isLowest ? Colors.redAccent : Colors.lightBlueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("${percent.toInt()}%", // ✅ integer %
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isLowest ? Colors.red : Colors.black,
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (lowestCategory != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Focus on improving: ${lowestCategory["category"]} (${lowestCategory["avg"].toInt()}%)",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categoryDescriptions[lowestCategory["category"]] ?? "Focus on improving this category.",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
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
                    : ListView(
                        children: [
                          _buildSoarCard(),
                          _buildCompetencyCard(),
                        ],
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GoalPage(userEmail: widget.userEmail),
                  ),
                );
              },
              child: const Text('Proceed to Goal Settings'),
            ),
          ),
        ],
      ),
    );
  }
}