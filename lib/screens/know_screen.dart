import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KnowScreen extends StatefulWidget {
  const KnowScreen({super.key});

  @override
  State<KnowScreen> createState() => _KnowScreenState();
}

class _KnowScreenState extends State<KnowScreen> {
  // For new goal input
  String _selectedGoalType = 'Long Term';
  String _selectedGoal = '';
  final TextEditingController _notesController = TextEditingController();

  final List<String> _goalOptions = [
    'Improve Communication',
    'Increase Productivity',
    'Enhance Wellbeing',
    'Build Confidence',
    'Other',
  ];

  // For displaying stored quiz Q&A and goals
  List<Map<String, String>> _quizAnswers = [];
  List<Map<String, String>> _userGoals = [];

  @override
  void initState() {
    super.initState();
    _loadQuizAnswers();
    _loadUserGoals();
  }

  Future<void> _loadQuizAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final quizString = prefs.getString('soar_card_answers');
    if (quizString != null && quizString.isNotEmpty) {
      final List<Map<String, String>> loaded = quizString.split('|').map((e) {
        final parts = e.split(';');
        return {
          'question': parts[0],
          'answer': parts.length > 1 ? parts[1] : '',
        };
      }).toList();
      setState(() {
        _quizAnswers = loaded;
      });
    }
  }

  Future<void> _loadUserGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getString('user_goals');
    if (goalsString != null && goalsString.isNotEmpty) {
      final List<Map<String, String>> loaded = goalsString.split('|').map((e) {
        final parts = e.split(';');
        return {
          'goal': parts[0],
          'type': parts.length > 1 ? parts[1] : '',
          'notes': parts.length > 2 ? parts[2] : '',
        };
      }).toList();
      setState(() {
        _userGoals = loaded;
      });
    }
  }

  Future<void> _saveNewGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final newGoal = {
      'goal': _selectedGoal,
      'type': _selectedGoalType,
      'notes': _notesController.text,
    };
    setState(() {
      _userGoals.add(newGoal);
    });
    final goalsString = _userGoals.map((g) => '${g['goal']};${g['type']};${g['notes']}').join('|');
    await prefs.setString('user_goals', goalsString);
    _selectedGoal = '';
    _notesController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                  _TabButton(label: 'Show', selected: false),
                  const SizedBox(width: 8),
                  _TabButton(label: 'Grow', selected: false),
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
                      color: Colors.grey.withOpacity(0.08),
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
                      style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (_quizAnswers.isEmpty)
                      const Text('No answers yet.', style: TextStyle(color: Colors.grey)),
                    ..._quizAnswers.map((qa) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            qa['question'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            qa['answer'] ?? '',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // New Goals Section
              Row(
                children: [
                  Text(
                    'New',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Goals',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Goal Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedGoal.isEmpty ? null : _selectedGoal,
                  hint: const Text('Set Goal'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _goalOptions.map((goal) {
                    return DropdownMenuItem(
                      value: goal,
                      child: Text(goal),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGoal = value ?? '';
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Goal Type Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoalTypeButton(
                    label: 'Long Term',
                    selected: _selectedGoalType == 'Long Term',
                    onTap: () {
                      setState(() => _selectedGoalType = 'Long Term');
                    },
                  ),
                  const SizedBox(width: 10),
                  _GoalTypeButton(
                    label: 'Mid Term',
                    selected: _selectedGoalType == 'Mid Term',
                    onTap: () {
                      setState(() => _selectedGoalType = 'Mid Term');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Notes Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Notes',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (_selectedGoal.isNotEmpty) {
                      _saveNewGoal();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Goal saved!')),
                      );
                    }
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              // Previous Goals Section
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
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
                      'Previous Goal Informations',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    if (_userGoals.isEmpty)
                      const Text('No goals yet.', style: TextStyle(color: Colors.grey)),
                    ..._userGoals.map((goal) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        '${goal['goal']} (${goal['type']})\nNotes: ${goal['notes']}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    )),
                  ],
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
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
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
                  color: Colors.blue.withOpacity(0.15),
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

class _GoalTypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _GoalTypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }
}