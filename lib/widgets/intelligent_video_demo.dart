import 'package:flutter/material.dart';
import '../services/content_service.dart';

/// Demo widget to showcase intelligent video suggestions
class IntelligentVideoDemo extends StatefulWidget {
  const IntelligentVideoDemo({super.key});

  @override
  State<IntelligentVideoDemo> createState() => _IntelligentVideoDemoState();
}

class _IntelligentVideoDemoState extends State<IntelligentVideoDemo> {
  final TextEditingController _messageController = TextEditingController();
  Map<String, String>? _suggestedVideo;
  List<String> _detectedEmotions = [];
  String _analysisResult = '';

  final List<String> _exampleMessages = [
    "I'm feeling really anxious about work",
    "I feel so lonely on this ship",
    "Can't express my feelings properly",
    "Having cultural conflicts with crew",
    "Need help with stress management",
    "Feeling homesick and missing family",
    "Want to connect with others better",
  ];

  void _analyzeMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _suggestedVideo = ContentService.analyzeMessageAndSuggestVideo(message);
      _detectedEmotions = ContentService.analyzeMessageSentiment(message);
      _analysisResult = ContentService.getContextualResponse(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligent Video Suggestions Demo'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Message Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message to analyze...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _analyzeMessage(_messageController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Analyze'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _messageController.clear();
                              _suggestedVideo = null;
                              _detectedEmotions = [];
                              _analysisResult = '';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Example messages
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Try These Example Messages:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _exampleMessages.map((message) => 
                        GestureDetector(
                          onTap: () {
                            _messageController.text = message;
                            _analyzeMessage(message);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              message,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Detected emotions
                    if (_detectedEmotions.isNotEmpty)
                      Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.psychology, color: Colors.orange[700]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Detected Emotions:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _detectedEmotions.map((emotion) => 
                                  Chip(
                                    label: Text(emotion),
                                    backgroundColor: Colors.orange[100],
                                  ),
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Suggested video
                    if (_suggestedVideo != null)
                      Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.recommend, color: Colors.green[700]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Recommended Video:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green[400]!, Colors.green[600]!],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _suggestedVideo!['title'] ?? 'Video',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _suggestedVideo!['description'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await ContentService.launchVideo(
                                            _suggestedVideo!['url']!,
                                          );
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.green[700],
                                      ),
                                      child: const Text('Watch Video'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_messageController.text.isNotEmpty && _analysisResult.isNotEmpty)
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'No Specific Match Found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'The system will show a random helpful video instead.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // AI response
                    if (_analysisResult.isNotEmpty)
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.chat, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'AI Response:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _analysisResult,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}