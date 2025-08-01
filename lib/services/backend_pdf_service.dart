import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class BackendPDFService {
  static String? _pdfContent;
  static bool _isLoaded = false;

  /// Load PDF content from assets
  static Future<void> loadPDFFromAssets() async {
    if (_isLoaded) return;
    
    try {
      // Load PDF from assets
      final ByteData data = await rootBundle.load('lib/assets/sources/source.pdf');
      final bytes = data.buffer.asUint8List();
      
      // Extract text from PDF
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String extractedText = '';
      
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        extractedText += '$pageText\n';
      }
      
      document.dispose();
      _pdfContent = extractedText.trim();
      _isLoaded = true;
      print('PDF loaded successfully. Content length: ${_pdfContent?.length}');
    } catch (e) {
      print('Error loading PDF: $e');
      // Set a flag that PDF failed to load
      _pdfContent = null;
      _isLoaded = false;
    }
  }

  /// Get PDF content for AI context
  static Future<String> getPDFContextForTopic(String userMessage) async {
    // Ensure PDF is loaded
    await loadPDFFromAssets();
    
    if (_pdfContent == null || _pdfContent!.isEmpty) {
      return '';
    }

    // Return relevant portion of PDF content
    return '''
REFERENCE DOCUMENT:
$_pdfContent

INSTRUCTIONS: 
- Keep responses SHORT and RELEVANT (2-3 sentences max)
- Only reference the document when directly relevant to the user's question
- Focus on the most important points from the document
- Be conversational and supportive, not clinical
''';
  }

  /// Check if PDF is loaded
  static bool get isPDFLoaded => _isLoaded && _pdfContent != null;

  /// Get PDF content summary
  static String getPDFSummary() {
    if (_pdfContent == null) return 'PDF not loaded';
    
    final wordCount = _pdfContent!.split(' ').length;
    return 'Document loaded: $wordCount words';
  }

  /// Get available resources info
  static String getResourceSummary() {
    return '''
I have access to a comprehensive mental health resource document that covers:

📚 Mental health topics and guidance
🧠 Emotional well-being strategies  
💡 Practical tips and techniques
🆘 Support and coping methods

I'll reference this document to give you relevant, evidence-based responses while keeping them short and helpful.
''';
  }
}