import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ConversationFlow {
  final String id;
  final String title;
  final List<String> questions;
  final Map<String, String> responses;
  final String? nextFlow;

  ConversationFlow({
    required this.id,
    required this.title,
    required this.questions,
    required this.responses,
    this.nextFlow,
  });
}

class BackendPDFService {
  static String? _pdfContent;
  static bool _isLoaded = false;
  static List<ConversationFlow> _conversationFlows = [];
  static List<String> _questions = [];

  /// Load PDF content from assets
  static Future<void> loadPDFFromAssets() async {
    if (_isLoaded) return;
    
    try {
      // Load PDF from assets
      final ByteData data = await rootBundle.load('lib/assets/sources/MentalHealth.pdf');
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
      
      // Parse conversation flows and questions from PDF
      _parseConversationFlows(_pdfContent!);
      _extractQuestions(_pdfContent!);
      
      _isLoaded = true;
      print('PDF loaded successfully. Content length: ${_pdfContent?.length}');
      print('Extracted ${_conversationFlows.length} conversation flows');
      print('Extracted ${_questions.length} questions');
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

  /// Parse conversation flows from PDF content
  static void _parseConversationFlows(String content) {
    _conversationFlows.clear();
    
    // Look for structured conversation patterns in the PDF
    // This is a basic parser - you may need to adjust based on your PDF format
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Look for flow indicators (adjust patterns based on your PDF)
      if (line.toLowerCase().contains('flow') || 
          line.toLowerCase().contains('conversation') ||
          line.toLowerCase().contains('assessment')) {
        
        final flowQuestions = <String>[];
        final flowResponses = <String, String>{};
        
        // Extract questions from the next few lines
        for (int j = i + 1; j < lines.length && j < i + 10; j++) {
          final nextLine = lines[j].trim();
          if (nextLine.contains('?')) {
            flowQuestions.add(nextLine);
          }
          if (nextLine.isEmpty) break;
        }
        
        if (flowQuestions.isNotEmpty) {
          _conversationFlows.add(ConversationFlow(
            id: 'flow_${_conversationFlows.length}',
            title: line,
            questions: flowQuestions,
            responses: flowResponses,
          ));
        }
      }
    }
  }

  /// Extract all questions from PDF content
  static void _extractQuestions(String content) {
    _questions.clear();
    
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.contains('?') && trimmed.length > 10) {
        _questions.add(trimmed);
      }
    }
  }

  /// Get a random question from the PDF
  static String? getRandomQuestion() {
    if (_questions.isEmpty) return null;
    _questions.shuffle();
    return _questions.first;
  }

  /// Get conversation flow context for AI
  static String getConversationFlowContext() {
    if (_conversationFlows.isEmpty) return '';
    
    final flowContext = _conversationFlows.map((flow) => 
      'Flow: ${flow.title}\nQuestions: ${flow.questions.join(", ")}'
    ).join('\n\n');
    
    return '''
CONVERSATION FLOWS FROM DOCUMENT:
$flowContext

AVAILABLE QUESTIONS:
${_questions.take(10).join('\n')}
''';
  }

  /// Get enhanced PDF context that includes conversation flows
  static Future<String> getPDFContextForConversation(String userMessage) async {
    await loadPDFFromAssets();
    
    if (_pdfContent == null || _pdfContent!.isEmpty) {
      return '';
    }

    final flowContext = getConversationFlowContext();
    final randomQuestion = getRandomQuestion();

    return '''
REFERENCE DOCUMENT:
$_pdfContent

$flowContext

INSTRUCTIONS FOR AI:
- Follow the conversation flows and question patterns from the document
- Ask structured questions similar to those in the PDF
- Use the document's approach to mental health assessment
- Keep responses SHORT (1-2 sentences) but follow the PDF's methodology
- When appropriate, ask follow-up questions from the document
${randomQuestion != null ? '\nSUGGESTED QUESTION TO ASK: $randomQuestion' : ''}

CONVERSATION STYLE:
- Act like the structured assessment/conversation flow in the PDF
- Ask relevant questions from the document based on user responses
- Guide the conversation following the PDF's framework
''';
  }

  /// Get conversation flows
  static List<ConversationFlow> getConversationFlows() => _conversationFlows;

  /// Get all questions
  static List<String> getQuestions() => _questions;

  /// Get available resources info
  static String getResourceSummary() {
    return '''
I have access to a comprehensive mental health resource document that covers:

📚 Mental health topics and guidance
🧠 Emotional well-being strategies  
💡 Practical tips and techniques
🆘 Support and coping methods
🔄 Structured conversation flows (${_conversationFlows.length} flows loaded)
❓ Assessment questions (${_questions.length} questions loaded)

I'll follow the document's conversation flows and ask structured questions to guide our discussion.
''';
  }
}