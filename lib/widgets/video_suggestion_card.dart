import 'package:flutter/material.dart';
import '../services/content_service.dart';

/// Widget to display video suggestions in chat
class VideoSuggestionCard extends StatelessWidget {
  final Map<String, String> video;
  final VoidCallback? onTap;

  const VideoSuggestionCard({
    super.key,
    required this.video,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => _launchVideo(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Video icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Video info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video['title'] ?? 'Recommended Video',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video['description'] ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.video_library,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to watch',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchVideo(BuildContext context) async {
    try {
      await ContentService.launchVideo(video['url'] ?? '');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Enhanced message bubble that can include video suggestions
class EnhancedMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final Map<String, String>? suggestedVideo;
  final List<String> detectedEmotions;

  const EnhancedMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.suggestedVideo,
    this.detectedEmotions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Regular message bubble
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF2196F3) : Colors.grey[200],
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        
        // Video suggestion (only for AI messages)
        if (!isUser && suggestedVideo != null)
          VideoSuggestionCard(video: suggestedVideo!),
        
        // Emotion indicators (for debugging/analytics)
        if (!isUser && detectedEmotions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 16, top: 4),
            child: Wrap(
              spacing: 4,
              children: detectedEmotions.map((emotion) => 
                Chip(
                  label: Text(
                    emotion,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.blue[100],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ).toList(),
            ),
          ),
      ],
    );
  }
}

/// Example usage in chat screen
class ChatScreenExample extends StatefulWidget {
  const ChatScreenExample({super.key});

  @override
  State<ChatScreenExample> createState() => _ChatScreenExampleState();
}

class _ChatScreenExampleState extends State<ChatScreenExample> {
  final List<EnhancedMessageBubble> messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      // Add user message
      messages.add(EnhancedMessageBubble(
        message: userMessage,
        isUser: true,
      ));

      // Analyze message and create AI response
      final analysis = ContentService.analyzeMessageAndSuggestVideo(userMessage);
      final emotions = ContentService.analyzeMessageSentiment(userMessage);
      final contextualResponse = ContentService.getContextualResponse(userMessage);

      // Add AI response with video suggestion
      messages.add(EnhancedMessageBubble(
        message: contextualResponse,
        isUser: false,
        suggestedVideo: analysis,
        detectedEmotions: emotions,
      ));
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat with Video Suggestions'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => messages[index],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF2196F3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}