import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InnerCourse extends StatefulWidget {
  final String courseTitle;
  final String? userEmail;

  const InnerCourse({super.key, required this.courseTitle, this.userEmail});

  @override
  State<InnerCourse> createState() => _InnerCourseState();
}

class _InnerCourseState extends State<InnerCourse> {
  Future<void> _generateCertificate() async {
    // Debug: Print the data being passed
    print('DEBUG: Course Title: ${widget.courseTitle}');
    print('DEBUG: User Email: ${widget.userEmail}');

    if (widget.userEmail == null || widget.userEmail!.isEmpty) {
      print('DEBUG: User email is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User email not found. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Generating certificate..."),
              ],
            ),
          );
        },
      );

      // Try multiple possible API endpoints for certificate generation
      final endpoints = [
        'https://strivehigh.thirdvizion.com/api/certificate/',
        'https://strivehigh.thirdvizion.com/api/coursecomplete/',
        'https://strivehigh.thirdvizion.com/api/generatecertificate/',
        'https://strivehigh.thirdvizion.com/api/submitcourse/',
        'https://strivehigh.thirdvizion.com/api/coursecompletion/',
        'https://strivehigh.thirdvizion.com/api/certificates/',
        'https://strivehigh.thirdvizion.com/api/certificate/generate/',
        'https://strivehigh.thirdvizion.com/api/course/complete/',
      ];

      bool success = false;
      dynamic responseData;

      for (final endpoint in endpoints) {
        try {
          print('DEBUG: Trying endpoint: $endpoint');

          final requestData = {
            'course_title': widget.courseTitle,
            'email': widget.userEmail,
            'completion_date': DateTime.now().toIso8601String(),
          };

          print('DEBUG: Request data: $requestData');

          final response = await http.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestData),
          );

          print('DEBUG: Response status: ${response.statusCode}');
          print('DEBUG: Response body: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            try {
              responseData = json.decode(response.body);
              success = true;
              print('DEBUG: Success with endpoint: $endpoint');
              break;
            } catch (e) {
              print('DEBUG: Failed to parse response: $e');
              continue;
            }
          } else {
            print('DEBUG: Failed with status: ${response.statusCode}');
            continue;
          }
        } catch (e) {
          print('DEBUG: Error with endpoint $endpoint: $e');
          continue;
        }
      }

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Show success dialog with certificate info
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Certificate Generated!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course: ${widget.courseTitle}'),
                  Text('Email: ${widget.userEmail}'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[50]!, Colors.blue[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: 48,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Certificate of Completion',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This is to certify that',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.userEmail!.split(
                            '@',
                          )[0], // Use email username as name
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'has successfully completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.courseTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Completed on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    responseData != null && responseData['message'] != null
                        ? responseData['message']
                        : 'Your certificate has been generated successfully! You can download it from your profile or check your email for the certificate link.',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Certificate Generation Failed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course: ${widget.courseTitle}'),
                  Text('Email: ${widget.userEmail}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to generate certificate. Please try again later or contact support if the issue persists.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      Navigator.of(context).pop();

      print('DEBUG: Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating certificate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          widget.courseTitle,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.school, size: 60, color: Colors.blue.shade700),
                    const SizedBox(height: 16),
                    Text(
                      widget.courseTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Course Content",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Course Description
              const Text(
                "Course Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Welcome to the ${widget.courseTitle} course. This comprehensive course will help you understand and develop skills in this important area. Our expert-designed curriculum covers all the essential topics and provides practical knowledge you can apply immediately.",
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _generateCertificate,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        "Completed",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Additional Resources
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Additional Resources",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildResourceItem("Course Materials", Icons.download),
                    _buildResourceItem("Discussion Forum", Icons.forum),
                    _buildResourceItem("Help & Support", Icons.help),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
