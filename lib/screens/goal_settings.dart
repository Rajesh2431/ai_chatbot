import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import 'avatar_selection_screen.dart'; // Import your next page here

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> with SingleTickerProviderStateMixin {
  String? selectedGoal;
  final List<String> goalOptions = ["Fitness", "Study", "Career", "Finance", "Health", "Relationships", "Personal Growth"];
  String? selectedDuration;
  final List<String> durationOptions = ["Short Term (1-3 months)", "Mid Term (3-12 months)", "Long Term (1+ years)"];
  
  late TabController _tabController;
  final TextEditingController notesController = TextEditingController();
  final List<Map<String, dynamic>> userGoals = [
    {'goal': 'Fitness', 'duration': 'Mid Term', 'progress': 0.6, 'created': '2 weeks ago'},
    {'goal': 'Study', 'duration': 'Short Term', 'progress': 0.3, 'created': '1 week ago'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserGoals();
  }

  Future<void> _loadUserGoals() async {
    final result = await GoalService.getUserGoals();
    if (result['success'] == true) {
      setState(() {
        userGoals.clear();
        // Convert API response to the format expected by the UI
        final apiGoals = result['goals'] as List<dynamic>? ?? [];
        for (var goal in apiGoals) {
          userGoals.add({
            'goal': goal['goals'] ?? 'Unknown Goal',
            'duration': goal['terms'] ?? 'Unknown Duration',
            'progress': 0.0, // Progress would need to be calculated or stored separately
            'created': _formatDate(goal['date_created']),
          });
        }
      });
    }
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
      backgroundColor: Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Goal Settings",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Toggle Tabs with modern design
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFF64748B),
                labelStyle: TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: " New Goal"),
                  Tab(text: " My Goals"),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ---------------- New Goal Tab ----------------
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Goal Selection Card
                        _buildInputCard(
                          title: "Choose Your Goal",
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedGoal,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Select a goal category",
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            items: goalOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGoal = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Duration Selection Card
                        _buildInputCard(
                          title: "Goal Duration",
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedDuration,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Select duration",
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            items: durationOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedDuration = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Notes Card
                        _buildInputCard(
                          title: "Additional Notes",
                          child: TextField(
                            controller: notesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Describe your goal, motivation, or specific targets...",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Badges Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFBFDBFE), width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Earn badges as you progress towards your goals!",
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              if (selectedGoal != null && selectedDuration != null) {
                                // Call the API to create goal
                                final result = await GoalService.createGoal(
                                  terms: selectedDuration!,
                                  goals: selectedGoal!,
                                  notes: notesController.text,
                                );

                                if (result['success'] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message']),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // Clear form
                                  setState(() {
                                    selectedGoal = null;
                                    selectedDuration = null;
                                    notesController.clear();
                                  });

                                  // Refresh goals list
                                  await _loadUserGoals();

                                  // 🚀 Redirect to next page after success
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AvatarSelectionScreen(), // <- your next page
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message']),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select both goal category and duration'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              "Create Goal",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )

                      ],
                    ),
                  ),

                  // ---------------- Goals Tab ----------------
                  userGoals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emoji_events, size: 64, color: Color(0xFFCBD5E1)),
                              const SizedBox(height: 16),
                              Text(
                                "No goals yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Create your first goal to get started!",
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: userGoals.length,
                          itemBuilder: (context, index) {
                            final goal = userGoals[index];
                            return _buildGoalCard(goal);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
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

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
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
                    color: Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flag, color: Color(0xFF667EEA), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal['goal'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    goal['duration'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Color(0xFF667EEA),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: goal['progress'],
              backgroundColor: Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(goal['progress'] * 100).toStringAsFixed(0)}% Complete",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Created ${goal['created']}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


