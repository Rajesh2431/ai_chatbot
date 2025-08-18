import 'backend_pdf_service.dart';

class ConversationStateService {
  static String? _currentFlowId;
  static int _currentQuestionIndex = 0;
  static final Map<String, String> _userResponses = {};
  static final List<String> _askedQuestions = [];

  /// Start a new conversation flow
  static void startFlow(String flowId) {
    _currentFlowId = flowId;
    _currentQuestionIndex = 0;
    _userResponses.clear();
  }

  /// Get the current conversation flow
  static ConversationFlow? getCurrentFlow() {
    if (_currentFlowId == null) return null;

    try {
      return BackendPDFService.getConversationFlows().firstWhere(
        (flow) => flow.id == _currentFlowId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get the next question in the current flow
  static String? getNextQuestion() {
    final currentFlow = getCurrentFlow();
    if (currentFlow == null) return null;

    if (_currentQuestionIndex < currentFlow.questions.length) {
      final question = currentFlow.questions[_currentQuestionIndex];
      _currentQuestionIndex++;
      _askedQuestions.add(question);
      return question;
    }

    return null;
  }

  /// Record user response
  static void recordResponse(String question, String response) {
    _userResponses[question] = response;
  }

  /// Get conversation context for AI
  static String getConversationContext() {
    final currentFlow = getCurrentFlow();
    if (currentFlow == null) return '';

    final context = StringBuffer();
    context.writeln('CURRENT CONVERSATION FLOW: ${currentFlow.title}');
    context.writeln(
      'PROGRESS: Question $_currentQuestionIndex/${currentFlow.questions.length}',
    );

    if (_userResponses.isNotEmpty) {
      context.writeln('\nUSER RESPONSES SO FAR:');
      _userResponses.forEach((question, response) {
        context.writeln('Q: $question');
        context.writeln('A: $response\n');
      });
    }

    final nextQuestion = getNextQuestion();
    if (nextQuestion != null) {
      context.writeln('NEXT QUESTION TO ASK: $nextQuestion');
    }

    return context.toString();
  }

  /// Check if we should ask a structured question
  static bool shouldAskStructuredQuestion() {
    // Ask structured questions every 2-3 exchanges
    return _askedQuestions.length < 3 || _askedQuestions.length % 3 == 0;
  }

  /// Get a random question from PDF that hasn't been asked recently
  static String? getRandomUnaskedQuestion() {
    final allQuestions = BackendPDFService.getQuestions();
    final unaskedQuestions = allQuestions
        .where((q) => !_askedQuestions.contains(q))
        .toList();

    if (unaskedQuestions.isEmpty) return null;

    unaskedQuestions.shuffle();
    final question = unaskedQuestions.first;
    _askedQuestions.add(question);

    // Keep only last 10 asked questions to allow repetition after a while
    if (_askedQuestions.length > 10) {
      _askedQuestions.removeAt(0);
    }

    return question;
  }

  /// Reset conversation state
  static void reset() {
    _currentFlowId = null;
    _currentQuestionIndex = 0;
    _userResponses.clear();
    _askedQuestions.clear();
  }

  /// Get conversation summary
  static Map<String, dynamic> getConversationSummary() {
    return {
      'currentFlow': _currentFlowId,
      'questionIndex': _currentQuestionIndex,
      'totalResponses': _userResponses.length,
      'questionsAsked': _askedQuestions.length,
    };
  }
}
