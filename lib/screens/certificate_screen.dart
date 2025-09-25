import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart' as services;
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/soar_card_service.dart';
import '../models/soar_card_answer.dart';
import '../services/user_profile_service.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  List<dynamic> _certificates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get user email from profile service
      final userEmail = await UserProfileService.getUserEmail();

      if (userEmail.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User email not found. Please complete your profile.';
        });
        return;
      }

      // Call the API to get certificates
      final response = await http.get(
        Uri.parse(
          'https://strivehigh.thirdvizion.com/api/getcertificate/$userEmail/',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _certificates = data is List ? data : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load certificates. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading certificates: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildCertificateContent()),
        ],
      ),
    );
  }

  Future<void> _downloadSoarCardPDF() async {
    try {
      // Load the static SOAR card PDF from assets
      final ByteData data = await services.rootBundle.load(
        'lib/assets/doc/SoarCardscore.pdf',
      );
      final List<int> bytes = data.buffer.asUint8List();

      // Get the directory to save the file (prefer external storage Download, fallback to documents)
      Directory? directory = await getExternalStorageDirectory();
      String filePath;
      if (directory != null) {
        final downloadDir = Directory('${directory.path}/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        filePath = '${downloadDir.path}/SoarCardscore.pdf';
      } else {
        directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/SoarCardscore.pdf';
      }

      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      // Show success message and open the PDF file
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOAR Card PDF successfully saved. Opening now...'),
          ),
        );
        // Open the PDF file
        await OpenFile.open(filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save PDF: $e')));
      }
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
          Text(
            "Certificates",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Your Achievements",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Celebrate your progress and milestones",
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading your certificates...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'You not have any Certificates!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCertificates,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_certificates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.workspace_premium,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Certificates Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete courses and assessments to earn your first certificate!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earned Certificates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          // Display certificates from API
          ..._certificates.map((certificate) {
            // Extract certificate information from the API response
            String certificatePath = certificate['certificate'] ?? '';
            String fullImageUrl = certificatePath.startsWith('http')
                ? certificatePath
                : 'https://strivehigh.thirdvizion.com$certificatePath';

            // Extract certificate name from the filename
            String certificateName = 'Certificate';
            if (certificatePath.contains('_')) {
              certificateName = certificatePath
                  .split('_')
                  .last
                  .split('.')
                  .first
                  .replaceAll('%20', ' ');
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCertificateCard(
                title: certificateName,
                description:
                    'Achievement earned through dedication and hard work',
                date: DateTime.now().toString().split(
                  ' ',
                )[0], // Use current date as fallback
                imagePath: fullImageUrl,
                certificate: certificate,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCertificateCard({
    required String title,
    required String description,
    required String date,
    required String imagePath,
    required Map<String, dynamic> certificate,
  }) {
    // Extract category information
    String category =
        certificate['category'] ?? certificate['type'] ?? 'General';
    String certificateType = certificate['type'] ?? 'certificate';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image and basic info
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.workspace_premium,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        'lib/assets/images/certi.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.workspace_premium,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Earned on: $date',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3498DB),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.visibility,
                label: 'View',
                onTap: () => _viewCertificate(certificate),
              ),
              _buildActionButton(
                icon: Icons.download,
                label: 'Download',
                onTap: () => _downloadCertificate(certificate),
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () => _shareCertificate(certificate),
              ),
              _buildActionButton(
                icon: Icons.link,
                label: 'Drive',
                onTap: () => _shareToGoogleDrive(certificate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'soar':
        return Colors.purple;
      case 'course':
        return Colors.blue;
      case 'assessment':
        return Colors.green;
      case 'achievement':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewCertificate(Map<String, dynamic> certificate) async {
    String certificatePath = certificate['certificate'] ?? '';
    String fullImageUrl = certificatePath.startsWith('http')
        ? certificatePath
        : 'https://strivehigh.thirdvizion.com$certificatePath';

    // Extract certificate name from the filename
    String certificateName = 'Certificate';
    if (certificatePath.contains('_')) {
      certificateName = certificatePath
          .split('_')
          .last
          .split('.')
          .first
          .replaceAll('%20', ' ');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        certificateName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Certificate image
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: certificatePath.startsWith('http')
                        ? Image.network(
                            fullImageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.workspace_premium,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Certificate image not available',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Certificate image not available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                // Footer with certificate info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Achievement earned through dedication and hard work',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Earned: ${DateTime.now().toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadCertificate(Map<String, dynamic> certificate) async {
    String certificatePath = certificate['certificate'] ?? '';

    if (certificatePath.toLowerCase().contains('soar')) {
      await _downloadSoarCardPDF();
    } else {
      // For other certificate types, download the actual certificate image
      try {
        String fullImageUrl = certificatePath.startsWith('http')
            ? certificatePath
            : 'https://strivehigh.thirdvizion.com$certificatePath';

        // Get the directory to save the file
        Directory? directory = await getExternalStorageDirectory();
        String filePath;
        if (directory != null) {
          final downloadDir = Directory('${directory.path}/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          String fileName = certificatePath.split('/').last;
          filePath = '${downloadDir.path}/$fileName';
        } else {
          directory = await getApplicationDocumentsDirectory();
          String fileName = certificatePath.split('/').last;
          filePath = '${directory.path}/$fileName';
        }

        // Download the file
        final response = await http.get(Uri.parse(fullImageUrl));
        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes, flush: true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Certificate downloaded successfully to $filePath',
                ),
              ),
            );
            // Open the downloaded file
            await OpenFile.open(filePath);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to download certificate. Please try again.',
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading certificate: $e')),
          );
        }
      }
    }
  }

  Future<void> _shareCertificate(Map<String, dynamic> certificate) async {
    String certificatePath = certificate['certificate'] ?? '';
    String fullImageUrl = certificatePath.startsWith('http')
        ? certificatePath
        : 'https://strivehigh.thirdvizion.com$certificatePath';

    // Extract certificate name from the filename
    String certificateName = 'Certificate';
    if (certificatePath.contains('_')) {
      certificateName = certificatePath
          .split('_')
          .last
          .split('.')
          .first
          .replaceAll('%20', ' ');
    }

    try {
      // Download the certificate image
      final response = await http.get(Uri.parse(fullImageUrl));
      if (response.statusCode == 200) {
        // Get temporary directory to save the image temporarily
        final tempDir = await getTemporaryDirectory();
        String fileName = certificatePath.split('/').last;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes, flush: true);

        // Share the image file
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'Check out my certificate: $certificateName - Achievement earned through dedication and hard work!',
        );
      } else {
        // If image download fails, share text only
        String shareText =
            'Check out my certificate: $certificateName - Achievement earned through dedication and hard work!';
        await Share.share(shareText);
      }
    } catch (e) {
      // If there's an error, share text only
      String shareText =
          'Check out my certificate: $certificateName - Achievement earned through dedication and hard work!';
      await Share.share(shareText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sharing certificate image...')),
        );
      }
    }
  }

  Future<void> _shareToGoogleDrive(Map<String, dynamic> certificate) async {
    String title = certificate['title'] ?? certificate['name'] ?? 'Certificate';
    String description = certificate['description'] ?? 'Achievement earned';

    // Create a simple text file with certificate information
    String content =
        '''
Certificate Information
=====================

Title: $title
Description: $description
Category: ${certificate['category'] ?? certificate['type'] ?? 'General'}
Earned Date: ${certificate['date'] ?? certificate['earned_date'] ?? 'N/A'}

This certificate was earned through dedication and hard work.
''';

    // For now, we'll share the text content
    // In a full implementation, you would upload to Google Drive
    await Share.share(content, subject: 'My Certificate: $title');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Drive integration will be available in the full version!',
          ),
        ),
      );
    }
  }
}
