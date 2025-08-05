import 'package:flutter/material.dart';
import '../services/chat_history_service.dart';
import '../models/message.dart';

class ChatHistoryDrawer extends StatefulWidget {
  final Function(List<Message>) onHistorySelected;
  final VoidCallback onNewChat;

  const ChatHistoryDrawer({
    super.key,
    required this.onHistorySelected,
    required this.onNewChat,
  });

  @override
  State<ChatHistoryDrawer> createState() => _ChatHistoryDrawerState();
}

class _ChatHistoryDrawerState extends State<ChatHistoryDrawer> {
  List<String> _historyDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final dates = await ChatHistoryService.getChatHistoryDates();
      setState(() {
        _historyDates = dates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getMoodColor(double moodScore) {
    if (moodScore >= 4.0) return Colors.green;
    if (moodScore >= 3.0) return Colors.lightGreen;
    if (moodScore >= 2.0) return Colors.orange;
    return Colors.red;
  }

  void _showMoodDetails(
    BuildContext context,
    String date,
    Map<String, dynamic> summary,
  ) {
    final moodData = summary['moodData'] as Map<String, dynamic>?;
    final displayDate = ChatHistoryService.formatDateForDisplay(date);
    final moodScore = summary['moodScore'] as double? ?? 3.0;
    final moodDescription =
        summary['moodDescription'] as String? ?? 'No mood data';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('$displayDate Mood Details'),
            const Spacer(),
            Text(
              ChatHistoryService.getMoodEmoji(moodScore),
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Overall mood score
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMoodColor(moodScore).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getMoodColor(moodScore).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mood, color: _getMoodColor(moodScore)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Mood',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _getMoodColor(moodScore),
                          ),
                        ),
                        Text(
                          '$moodDescription (${moodScore.toStringAsFixed(1)}/5.0)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (moodData != null && moodData['questions'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Daily Check-in Details:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...((moodData['questions'] as Map<String, dynamic>).entries.map(
                  (entry) {
                    final question = entry.key;
                    final score = entry.value as int;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _getScoreColor(score),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                score.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _getScoreDescription(score),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getScoreColor(score),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList()),
              ] else ...[
                const SizedBox(height: 16),
                const Text(
                  'No daily check-in data available for this date.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadChatForDate(date);
            },
            child: const Text('View Chat'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    switch (score) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.lime;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getScoreDescription(int score) {
    switch (score) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Great';
      case 3:
        return 'Good';
      case 2:
        return 'Fair';
      case 1:
        return 'Poor';
      default:
        return 'Unknown';
    }
  }

  Future<void> _loadChatForDate(String date) async {
    try {
      final messages = await ChatHistoryService.getChatHistory(date);
      widget.onHistorySelected(messages);
      if (mounted) {
        Navigator.pop(context); // Close drawer
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chat history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteChatHistory(String date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat History'),
        content: Text(
          'Are you sure you want to delete the chat history for ${ChatHistoryService.formatDateForDisplay(date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ChatHistoryService.deleteChatHistory(date);
      _loadChatHistory(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Chat History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // New Chat Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onNewChat();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_comment, color: Colors.white, size: 20),
                label: const Text(
                  'New Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),

          const Divider(),

          // Chat History List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
                  )
                : _historyDates.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No chat history yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start a conversation to see your history here',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _historyDates.length,
                    itemBuilder: (context, index) {
                      final date = _historyDates[index];
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: ChatHistoryService.getChatSummary(date),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final summary = snapshot.data!;
                          final displayDate =
                              ChatHistoryService.formatDateForDisplay(date);
                          final messageCount = summary['messageCount'] as int;
                          final moodEmoji =
                              summary['moodEmoji'] as String? ?? '😐';
                          final moodDescription =
                              summary['moodDescription'] as String? ??
                              'No mood data';
                          final moodScore =
                              summary['moodScore'] as double? ?? 3.0;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _loadChatForDate(date),
                                onLongPress: () => _showMoodDetails(context, date, summary),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Avatar with mood emoji
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: _getMoodColor(moodScore),
                                            child: Text(
                                              displayDate == 'Today'
                                                  ? 'T'
                                                  : displayDate == 'Yesterday'
                                                  ? 'Y'
                                                  : date.split('-')[2],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                moodEmoji,
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(width: 16),
                                      
                                      // Content - structured vertically
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // 1. Day at the top
                                            Text(
                                              displayDate,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 4),
                                            
                                            // 2. Daily check-in mood below
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getMoodColor(moodScore).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  moodDescription,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _getMoodColor(moodScore),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 6),
                                            
                                            // 3. Mood score at the bottom
                                            Wrap(
                                              children: [
                                                Text(
                                                  '$messageCount messages',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                if (summary['moodData'] != null) ...[
                                                  const Text(
                                                    ' • ',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Mood Score: ${moodScore.toStringAsFixed(1)}/5.0',
                                                    style: TextStyle(
                                                      color: _getMoodColor(moodScore),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Menu button
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            _deleteChatHistory(date);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.delete, color: Colors.red, size: 18),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Footer
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear All History'),
                        content: const Text(
                          'Are you sure you want to delete all chat history? This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      await ChatHistoryService.clearAllChatHistory();
                      _loadChatHistory();
                    }
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text(
                    'Clear All',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
