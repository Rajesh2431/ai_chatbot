import 'package:flutter/material.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  Set<int> completedModules = <int>{};
  final GlobalKey _certificateKey = GlobalKey();

  final Map<String, dynamic> courseData = {
    'title': 'Advanced Flutter Development',
    'description': 'Master Flutter app development with advanced concepts and best practices',
    'duration': '12 weeks',
    'students': '3,245',
    'instructor': 'Dr. Sarah Johnson',
    'modules': [
      {
        'id': 1,
        'title': 'Flutter Fundamentals',
        'duration': '3 hours',
        'description': 'Dart basics, widgets, and app structure'
      },
      {
        'id': 2,
        'title': 'Layout & Navigation',
        'duration': '4 hours',
        'description': 'Building responsive layouts and navigation'
      },
      {
        'id': 3,
        'title': 'State Management',
        'duration': '5 hours',
        'description': 'Provider, Bloc, and Riverpod patterns'
      },
      {
        'id': 4,
        'title': 'Networking & APIs',
        'duration': '4 hours',
        'description': 'HTTP requests, JSON parsing, and error handling'
      },
      {
        'id': 5,
        'title': 'Database Integration',
        'duration': '3 hours',
        'description': 'SQLite, Hive, and cloud databases'
      },
      {
        'id': 6,
        'title': 'Authentication & Security',
        'duration': '4 hours',
        'description': 'Firebase Auth, biometrics, and secure storage'
      },
      {
        'id': 7,
        'title': 'Testing & Debugging',
        'duration': '3 hours',
        'description': 'Unit tests, widget tests, and debugging tools'
      },
      {
        'id': 8,
        'title': 'Deployment & Distribution',
        'duration': '2 hours',
        'description': 'App store deployment and CI/CD'
      }
    ]
  };

  bool get isComplete => completedModules.length == courseData['modules'].length;
  
  double get progressPercentage => 
      (completedModules.length / courseData['modules'].length) * 100;

  void toggleModuleCompletion(int moduleId) {
    setState(() {
      if (completedModules.contains(moduleId)) {
        completedModules.remove(moduleId);
      } else {
        completedModules.add(moduleId);
      }
    });
  }

  Future<void> downloadCertificate() async {
    try {
      // Show certificate dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => CertificateDialog(
          courseTitle: courseData['title'],
          studentName: 'John Doe', // This would come from user data
          completionDate: DateTime.now(),
          onDownload: () async {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Certificate downloaded successfully!'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'VIEW',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading certificate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Course Progress'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isComplete)
            IconButton(
              icon: Icon(Icons.download, color: Colors.green),
              onPressed: downloadCertificate,
              tooltip: 'Download Certificate',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseData['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    courseData['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(Icons.schedule, courseData['duration']),
                      SizedBox(width: 12),
                      _buildInfoChip(Icons.people, '${courseData['students']} students'),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Progress Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Course Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${completedModules.length}/${courseData['modules'].length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isComplete ? Colors.green : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progressPercentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? Colors.green : Colors.blue,
                    ),
                    minHeight: 8,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${progressPercentage.toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Modules List
            Text(
              'Course Modules',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: courseData['modules'].length,
              itemBuilder: (context, index) {
                final module = courseData['modules'][index];
                final isCompleted = completedModules.contains(module['id']);
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.grey[200]!,
                      width: isCompleted ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: GestureDetector(
                      onTap: () => toggleModuleCompletion(module['id']),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? Colors.green : Colors.grey[200],
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.play_arrow,
                          color: isCompleted ? Colors.white : Colors.grey[600],
                          size: 18,
                        ),
                      ),
                    ),
                    title: Text(
                      module['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          module['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                            SizedBox(width: 4),
                            Text(
                              module['duration'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: isCompleted
                        ? Icon(Icons.check_circle, color: Colors.green, size: 24)
                        : Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            // Certificate Button
            if (isComplete)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: downloadCertificate,
                  icon: Icon(Icons.file_download, size: 20),
                  label: Text(
                    'Download Certificate',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CertificateDialog extends StatelessWidget {
  final String courseTitle;
  final String studentName;
  final DateTime completionDate;
  final VoidCallback onDownload;

  const CertificateDialog({
    super.key,
    required this.courseTitle,
    required this.studentName,
    required this.completionDate,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Certificate Preview
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
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
                  SizedBox(height: 16),
                  Text(
                    'Certificate of Completion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'This is to certify that',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    studentName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'has successfully completed',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    courseTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Completed on ${completionDate.day}/${completionDate.month}/${completionDate.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDownload,
                    icon: Icon(Icons.download, size: 18),
                    label: Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Usage in your app:
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CourseScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}