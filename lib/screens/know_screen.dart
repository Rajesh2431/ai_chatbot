import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/soar_card_service.dart';
import '../services/goal_service.dart';
import '../models/soar_card_answer.dart';
import '../models/goal_data.dart';

class KnowScreen extends StatefulWidget {
  const KnowScreen({super.key});

  @override
  State<KnowScreen> createState() => _KnowScreenState();
}

class _KnowScreenState extends State<KnowScreen> {
  // For new goal input - using same structure as goal_settings.dart
  String? _selectedGoal;
  String? _selectedGoalType;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _goalOptions = [
    'Fitness',
    'Study',
    'Career',
    'Finance',
    'Health',
    'Relationships',
    'Personal Growth',
  ];

  final List<String> _goalTypeOptions = [
    'Short Term (1-3 months)',
    'Mid Term (3-12 months)',
    'Long Term (1+ years)',
  ];

  // For displaying stored data
  List<SoarCardAnswer> _soarCardAnswers = [];
  List<GoalData> _userGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    await Future.wait([_loadSoarCardAnswers(), _loadUserGoals()]);

    setState(() => _isLoading = false);
  }

  Future<void> _loadSoarCardAnswers() async {
    try {
      final answers = await SoarCardService.loadSoarCardAnswers();
      setState(() {
        _soarCardAnswers = answers;
      });
    } catch (e) {
      debugPrint('Error loading SOAR card answers: $e');
    }
  }

  Future<void> _loadUserGoals() async {
    try {
      // Load from API first
      final result = await GoalService.getUserGoals();
      if (result['success'] == true) {
        final apiGoals = result['goals'] as List<dynamic>? ?? [];
        final goals = apiGoals
            .map(
              (goal) => GoalData(
                goal: goal['goals'] ?? 'Unknown Goal',
                type: goal['terms'] ?? 'Unknown Duration',
                notes: goal['notes'] ?? '',
                createdAt:
                    DateTime.tryParse(goal['date_created'] ?? '') ??
                    DateTime.now(),
                progress:
                    0.0, id: '', category: '', period: GoalPeriod.midterm, // Progress would need to be calculated separately
              ),
            )
            .toList();

        setState(() {
          _userGoals = goals;
        });
      } else {
        // Fallback to local storage if API fails
        await _loadUserGoalsFromLocal();
      }
    } catch (e) {
      debugPrint('Error loading goals from API: $e');
      // Fallback to local storage
      await _loadUserGoalsFromLocal();
    }
  }

  Future<void> _loadUserGoalsFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsString = prefs.getString('user_goals');
      if (goalsString != null && goalsString.isNotEmpty) {
        final goals = goalsString.split('|').map((e) {
          final parts = e.split(';');
          return GoalData(
            goal: parts[0],
            type: parts.length > 1 ? parts[1] : '',
            notes: parts.length > 2 ? parts[2] : '',
            createdAt: DateTime.now(), id: '', category: '', period: GoalPeriod.midterm,
          );
        }).toList();

        setState(() {
          _userGoals = goals;
        });
      }
    } catch (e) {
      debugPrint('Error loading goals from local storage: $e');
    }
  }

  Future<void> _saveNewGoal() async {
    if (_selectedGoal == null || _selectedGoalType == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both goal category and duration'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // Call the API to create goal
      final result = await GoalService.createGoal(
        terms: _selectedGoalType!,
        goals: _selectedGoal!,
        notes: _notesController.text,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Clear form
        setState(() {
          _selectedGoal = null;
          _selectedGoalType = null;
          _notesController.clear();
        });

        // Refresh goals list
        await _loadUserGoals();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving goal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save goal. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGoalPanel({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInputCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalData goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Color(0xFF667EEA),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal.goal,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.type,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (goal.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                goal.notes,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(goal.createdAt.toIso8601String()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'recently';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'just now';
      }
    } catch (e) {
      return 'recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    // Top bar with avatar and placeholder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[300],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Tab buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TabButton(label: 'Know', selected: true),
                        const SizedBox(width: 8),
                        _TabButton(label: 'Grow', selected: false),
                        const SizedBox(width: 8),
                        _TabButton(label: 'Show', selected: false),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // SOAR Card Panel with Q&A
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Soar Card',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_soarCardAnswers.isEmpty)
                            const Text(
                              'No answers yet.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ..._soarCardAnswers.map(
                            (answer) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    answer.questionText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    answer.answer,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    // New Goals Panel
                    _buildGoalPanel(
                      title: 'New',
                      subtitle: 'Goals',
                      child: Column(
                        children: [
                          // Goal Selection Dropdown
                          _buildInputCard(
                            title: 'Choose Your Goal',
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedGoal,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Select a goal category',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              items: _goalOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGoal = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Goal Duration Dropdown
                          _buildInputCard(
                            title: 'Goal Duration',
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedGoalType,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Select duration',
                                hintStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              items: _goalTypeOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGoalType = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Notes Field
                          _buildInputCard(
                            title: 'Additional Notes',
                            child: TextField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText:
                                    'Describe your goal, motivation, or specific targets...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey[600]),
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Create Goal Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667EEA),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: _saveNewGoal,
                              child: const Text(
                                'Create Goal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Existing Goals Panel
                    _buildGoalPanel(
                      title: 'Goals',
                      subtitle: '',
                      child: _userGoals.isEmpty
                          ? Column(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No goals yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create your first goal above!',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: _userGoals
                                  .map((goal) => _buildGoalCard(goal))
                                  .toList(),
                            ),
                    ),
                    // Collected Badges Section
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Collected Badges',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 54,
                          height: 54,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Collected Badges displayed With out border line',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  const _TabButton({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? Colors.blue[600] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
        border: Border.all(
          color: selected ? Colors.blue[600]! : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.blue[600],
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
