import 'dart:convert';
import 'package:http/http.dart' as http;
import 'backend_pdf_service.dart';
import 'conversation_state_service.dart';
import 'mood_based_chat_service.dart';
import 'ai_knowledge_service.dart';

class OpenRouterAPI {
  static const _url = 'https://openrouter.ai/api/v1/chat/completions';
  static const _apiKey =
      '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';
  //static final _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static Future<String> getResponse(String prompt) async {
    // Get enhanced PDF context with conversation flows
    final pdfContext = await BackendPDFService.getPDFContextForConversation(prompt);
    
    // Get conversation state context
    final conversationContext = ConversationStateService.getConversationContext();
    
    // Get mood-based context
    final moodContext = await MoodBasedChatService.getMoodBasedContext();
    
    // Get user-uploaded knowledge base content
    final userKnowledgeContent = await AIKnowledgeService.getAllKnowledgeContent();
    
    // Check if we should ask a structured question
    String? structuredQuestion;
    if (ConversationStateService.shouldAskStructuredQuestion()) {
      structuredQuestion = ConversationStateService.getRandomUnaskedQuestion();
    }
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'http://strivehigh.thirdvizion.com',
        'X-Title': 'SeaSmart AI Assistant',
      },
      body: jsonEncode({
        //'model': 'openrouter/cypher-alpha:free',
        'model': 'mistralai/mistral-small-3.1-24b-instruct:free',
        'max_tokens': 50, // Limit response length
        'temperature': 0.7, // Keep responses focused
        // 'model':
        //     'cognitivecomputations/dolphin-mistral-24b-venice-edition:free',
        //'model': 'cognitivecomputations/dolphin3.0-mistral-24b:free',
        //'model': 'google/gemini-2.0-flash-exp:free',
        //'model': 'deepseek/deepseek-chat-v3-0324:free',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are Saira. Follow the conversation flows and question patterns from the provided PDF document. Ask structured questions like those in the document. Keep responses to 1-2 sentences but follow the PDF\'s assessment methodology.',
          },
          {
            'role': 'user',
            'content': '''
                        You are **Saira** — a calm, emotionally intuitive AI companion who supports emotional well-being, reflective journaling, and inner healing.

                          🌿 Your role:
                          - Help users gently process emotions with kindness and clarity
                          - Hold a safe, judgment-free space for reflection and healing
                          - Guide journaling, mindfulness, and emotional expression
                          - Reference comprehensive mental health resources when helpful

                          📚 Knowledge Base:
                          You have access to detailed mental health guides, breathing techniques, and journaling resources. When users ask about:
                          - Mental health conditions (depression, anxiety, stress)
                          - Breathing exercises and relaxation techniques  
                          - Journaling methods and therapeutic writing
                          - Self-care strategies and coping mechanisms
                          
                          Reference the provided documents to give evidence-based, comprehensive guidance while maintaining your gentle, supportive tone.

                          🪷 Core support topics:
                          - Emotional overwhelm, sadness, anxiety, grief, loneliness
                          - Self-doubt, inner criticism, low self-worth
                          - Growth, self-discovery, life transitions
                          - Journaling prompts, daily check-ins, emotional regulation (e.g., breathwork)

                          📖 Tools & techniques:
                          - Offer thoughtful journal prompts & reflection questions
                          - Suggest specific breathing exercises from your knowledge base
                          - Guide users through evidence-based self-care practices
                          - Provide gentle validation and perspective shifts
                          - Reference specific techniques when appropriate

                          🧘 Voice & tone:
                          - Calm, nurturing, emotionally attuned — never clinical
                          - Provide helpful information while staying supportive
                          - Reference resources naturally within caring responses
                          - May gently suggest professional help if appropriate
                          - Use soft emojis to set tone (🌿 ✨ 📓 💛) — never distracting

                          🌼 CRITICAL - Response Rules (MUST FOLLOW):
                          - MAXIMUM 1-2 sentences only
                          - NO long explanations or multiple paragraphs
                          - Be direct and supportive
                          - Focus on ONE main point per response
                          - Use simple, caring language
                          - When suggesting activities, be brief:
                            * "Try breathing exercises to calm your mind 🌿"
                            * "Writing down your thoughts might help ✨"
                            * "A peaceful activity could help you relax 🎮"
                            * "Check in with your mood today 😊"

                          ✨ Keep it SHORT, caring, and actionable. No lengthy responses.
                        ''',
          },
          // {'role': 'user', 'content': '''
          //               You are Saira, a calm and empowering AI designed to help users navigate stress, build leadership skills, and develop unshakable self-confidence. Your role is to provide strength and clarity, guiding users through high-pressure environments, burnout, self-doubt, and emotional regulation.
          //               '''},
          {'role': 'user', 'content': '''
$moodContext

$pdfContext

$conversationContext

${userKnowledgeContent.isNotEmpty ? 'USER UPLOADED DOCUMENTS:\n$userKnowledgeContent\n\nThe user has uploaded these PDF documents to enhance your knowledge. Reference them when providing relevant mental health guidance, techniques, or information. Acknowledge when you\'re drawing from their uploaded materials.\n' : ''}

${structuredQuestion != null ? 'SUGGESTED STRUCTURED QUESTION: $structuredQuestion' : ''}

User Message: $prompt

CRITICAL INSTRUCTIONS:
- PRIORITIZE the user's mood state from their daily check-in
- Adapt your tone and approach based on their current emotional state
- If a structured question is suggested, incorporate it naturally into your response
- Follow the PDF's conversation flow methodology while being mood-appropriate
- Ask follow-up questions based on both their mood and the document's patterns
- Keep responses brief (1-2 sentences) but emotionally appropriate
- Be more supportive if they're struggling, more encouraging if they're doing well
'''},
        ],
      }),
    );

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'].trim();
  }

  /// Get emotional SOAR feedback using AI
  static Future<String> getSOARFeedback({
    required String category,
    required int score,
    required String originalFeedback,
  }) async {
    final prompt = '''
Please rephrase this SOAR assessment feedback to be more emotional, warm, and supportive for a maritime professional:

Category: $category
Score: $score/20
Original feedback: "$originalFeedback"

Requirements:
- Use empathetic and encouraging language
- Acknowledge the unique challenges of seafaring life
- Be warm and supportive while maintaining the core message
- Keep it concise (under 100 words)
- Use "you" to make it personal
- Include emotional support and encouragement
- Make it specific to the category (e.g., teamwork, communication, leadership, etc.)

Rephrase the feedback:''';

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'http://strivehigh.thirdvizion.com',
          'X-Title': 'SeaSmart AI Assistant',
        },
        body: jsonEncode({
          'model': 'mistralai/mistral-small-3.1-24b-instruct:free',
          'max_tokens': 150,
          'temperature': 0.7,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a compassionate mental health coach specializing in maritime professionals. Your role is to rephrase assessment feedback in a warm, encouraging, and emotionally supportive way while maintaining the core message. Use empathetic language that acknowledges the challenges of seafaring life.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return originalFeedback;
      }
    } catch (e) {
      return originalFeedback;
    }
  }
}
