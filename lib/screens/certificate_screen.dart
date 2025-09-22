import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' as services;
import 'package:open_file/open_file.dart';
import '../services/soar_card_service.dart';
import '../models/soar_card_answer.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
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
      final downloadDir = Directory('${directory?.path}/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      filePath = '${downloadDir.path}/SoarCardscore.pdf';

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
          // Example certificates - replace with actual data
          _buildCertificateCard(
            title: 'SOAR Assessment Completion',
            description:
                'Completed the Strength, Opportunities, Aspirations & Result assessment.',
            date: '2023-10-01',
            imagePath: 'lib/assets/images/certi.png',
            onTap: _downloadSoarCardPDF,
          ),
          const SizedBox(height: 16),
          _buildCertificateCard(
            title: 'Goal Setting Mastery',
            description:
                'Successfully set and tracked personal wellness goals.',
            date: '2023-10-15',
            imagePath: 'lib/assets/images/certi.png',
          ),
          const SizedBox(height: 16),
          _buildCertificateCard(
            title: 'Meditation Champion',
            description: 'Completed 30 days of daily meditation sessions.',
            date: '2023-11-01',
            imagePath: 'lib/assets/images/certi.png',
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard({
    required String title,
    required String description,
    required String date,
    required String imagePath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            Icon(
              onTap != null ? Icons.download : Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
