import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class SoarPdfGenerator {
  static const Map<String, Map<String, String>> scoreRanges = {
    "17-20": {
      "title": "Very Strong Resilience",
      "feedback": "You have shown remarkable strength in managing stress, staying composed, and using your personal abilities effectively at sea. This level of resilience suggests you can handle unexpected challenges with confidence, which benefits both you and your crew. I encourage you to keep reinforcing these healthy coping strategies, as they are protective factors against burnout and isolation."
    },
    "13-16": {
      "title": "Strong Resilience", 
      "feedback": "You demonstrate solid resilience skills that serve you well in challenging maritime environments. Your ability to manage stress and maintain composure shows strong personal capabilities. Continue building on these strengths while exploring additional coping strategies to further enhance your resilience."
    },
    "9-12": {
      "title": "Moderate Resilience",
      "feedback": "You have a good foundation of resilience skills with room for growth. Your current coping strategies are working, but there's potential to develop even stronger stress management and emotional regulation abilities. Focus on building additional tools and techniques to enhance your resilience further."
    },
    "5-8": {
      "title": "Developing Resilience",
      "feedback": "You're in the early stages of developing resilience skills. This is a great starting point, and with focused effort and practice, you can quickly build confidence and stronger coping abilities. Consider exploring new stress management techniques and building a support network to accelerate your growth."
    },
    "1-4": {
      "title": "Building Resilience",
      "feedback": "This area is at an early stage of development. With focus and practice, you can quickly build confidence and skill here. Every journey begins with awareness, and you're taking the important first steps toward developing stronger resilience capabilities."
    }
  };

  static String _getScoreRange(int percentage) {
    if (percentage >= 17) return "17-20";
    if (percentage >= 13) return "13-16";
    if (percentage >= 9) return "9-12";
    if (percentage >= 5) return "5-8";
    return "1-4";
  }

  static PdfColor _getProgressBarColor(int percentage) {
    if (percentage >= 80) return const PdfColor.fromInt(0xFF79FEFC);
    if (percentage >= 60) return const PdfColor.fromInt(0xFF239CD3);
    if (percentage >= 40) return const PdfColor.fromInt(0xFF5AADD3);
    if (percentage >= 20) return const PdfColor.fromInt(0xFF7BBDD3);
    return const PdfColor.fromInt(0xFF9CCDD3);
  }

  static String _getFeedbackText(int percentage) {
    if (percentage >= 80) return "Excellent performance!";
    if (percentage >= 60) return "Good progress, keep it up!";
    if (percentage >= 40) return "Focus on improving";
    if (percentage >= 20) return "Needs attention";
    return "Requires development";
  }

  static String _getOverallInsight(double avgScore) {
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

  static Map<String, dynamic> _getPerformanceLevel(int percentage) {
    if (percentage >= 80) {
      return {
        'title': 'Excellent',
        'description': 'Outstanding performance across all competencies',
        'color': const PdfColor.fromInt(0xFF4CAF50),
      };
    } else if (percentage >= 60) {
      return {
        'title': 'Good',
        'description': 'Strong foundation with areas for growth',
        'color': const PdfColor.fromInt(0xFF2196F3),
      };
    } else if (percentage >= 40) {
      return {
        'title': 'Developing',
        'description': 'Good progress with focused improvement needed',
        'color': const PdfColor.fromInt(0xFFFF9800),
      };
    } else {
      return {
        'title': 'Beginning',
        'description': 'Starting your development journey',
        'color': const PdfColor.fromInt(0xFFF44336),
      };
    }
  }

  static Future<void> generateAndDownloadPdf({
    required String userEmail,
    required List<Map<String, dynamic>> categoryWise,
    required List<double> overallAvg,
    required BuildContext context,
  }) async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        final permission = await Permission.storage.request();
        if (permission != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required to save PDF')),
          );
          return;
        }
      }

      final pdf = pw.Document();
      
      // Calculate overall metrics
      final avgScore = categoryWise.isNotEmpty
          ? categoryWise.map((e) => e["avg"] as double).reduce((a, b) => a + b) / categoryWise.length
          : 0.0;
      final maxValue = categoryWise.isNotEmpty
          ? categoryWise.map((e) => e["avg"] as double).reduce((a, b) => a > b ? a : b)
          : 0.0;
      final percentage = maxValue > 0 ? (avgScore / maxValue * 100).round() : 0;
      final level = _getPerformanceLevel(percentage);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              _buildPdfHeader(userEmail),
              pw.SizedBox(height: 30),
              
              // Overall Assessment Summary
              _buildOverallSummary(avgScore, maxValue, percentage, level),
              pw.SizedBox(height: 30),
              
              // Category-wise breakdown
              _buildCategoryBreakdown(categoryWise),
              pw.SizedBox(height: 30),
              
              // Detailed feedback for each category
              ..._buildDetailedFeedback(categoryWise),
              
              // Footer
              pw.SizedBox(height: 40),
              _buildPdfFooter(),
            ];
          },
        ),
      );

      // Save and share PDF
      await _savePdf(pdf, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  static pw.Widget _buildPdfHeader(String userEmail) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColor.fromInt(0xFF2196F3), PdfColor.fromInt(0xFF1976D2)],
        ),
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'SOAR Assessment Report',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Strength, Opportunities, Aspirations & Results',
            style: pw.TextStyle(
              fontSize: 16,
              color: const PdfColor.fromInt(0xFFE3F2FD),
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0x33FFFFFF),
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              'User: $userEmail',
              style: pw.TextStyle(
                fontSize: 14,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generated on: ${DateTime.now().toString().substring(0, 16)}',
            style: pw.TextStyle(
              fontSize: 12,
              color: const PdfColor.fromInt(0xFFE3F2FD),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOverallSummary(
    double avgScore, 
    double maxValue, 
    int percentage, 
    Map<String, dynamic> level
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  color: level['color'] as PdfColor,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '$percentage%',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Overall Performance: ${level['title']}',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      level['description'] as String,
                      style: const pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              _getOverallInsight(avgScore),
              style: const pw.TextStyle(
                fontSize: 14,
                color: PdfColors.blue800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCategoryBreakdown(List<Map<String, dynamic>> categoryWise) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Category Performance Overview',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: categoryWise.map((item) {
              final category = item["category"] as String;
              final score = item["avg"] as double;
              final percentage = score.round();
              
              return pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey200),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        category,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Stack(
                        children: [
                          pw.Container(
                            height: 8,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey200,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                          ),
                          pw.Container(
                            height: 8,
                            width: double.infinity * (percentage / 100),
                            decoration: pw.BoxDecoration(
                              color: _getProgressBarColor(percentage),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      '$percentage%',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  static List<pw.Widget> _buildDetailedFeedback(List<Map<String, dynamic>> categoryWise) {
    List<pw.Widget> widgets = [
      pw.Text(
        'Detailed Assessment Feedback',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 15),
    ];

    for (var item in categoryWise) {
      final category = item["category"] as String;
      final score = item["avg"] as double;
      final percentage = score.round();
      final scoreRange = _getScoreRange(percentage);
      final feedback = scoreRanges[scoreRange] ?? scoreRanges["1-4"]!;

      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 20),
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      color: _getProgressBarColor(percentage),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    category,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    '$percentage% - ${_getFeedbackText(percentage)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                feedback["title"]!,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue700,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                feedback["feedback"]!,
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                  lineSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  static pw.Widget _buildPdfFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Powered by StriveHigh',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'This assessment is designed to help you understand your current competency levels and identify areas for growth.',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Future<void> _savePdf(pw.Document pdf, BuildContext context) async {
    try {
      final output = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File("${output.path}/SOAR_Assessment_Report_$timestamp.pdf");
      await file.writeAsBytes(await pdf.save());

      // Show success message and share options
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('PDF generated successfully!'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => Share.shareXFiles([XFile(file.path)]),
          ),
        ),
      );

      // Also share directly
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My SOAR Assessment Report',
        subject: 'SOAR Assessment Report',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
    }
  }
}