import 'package:SeaSmart/screens/grow_screen.dart';
import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import 'daily_checkin_screen.dart';

class GoalPage extends StatefulWidget {
  final String? userEmail;

  const GoalPage({super.key, this.userEmail});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> with SingleTickerProviderStateMixin {
  String? selectedGoal;
  final List<String> goalOptions = [
    "Fitness", "Study", "Career", "Finance", "Health", "Relationships", "Personal Growth"
  ];
  String? selectedDuration;
  final List<String> durationOptions = [
    "Mid Term (3-12 months)", "Long Term (1+ years)"
  ];

  late TabController _tabController;
  final TextEditingController notesController = TextEditingController();
  final List<Map<String, dynamic>> userGoals = [];

  // Custom blue color (manual RGBA)
  final Color primaryBlue = const Color.fromRGBO(14, 165, 233, 1); // #0EA5E9

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, animationDuration: Duration(milliseconds: 500));
    _loadUserGoals();
  }

  Future<void> _loadUserGoals() async {
    final result = await GoalService.getUserGoals();
    if (result['success'] == true) {
      setState(() {
        userGoals.clear();
        final apiGoals = result['goals'] as List<dynamic>? ?? [];
        for (var goal in apiGoals) {
          userGoals.add({
            'goal': goal['goals'] ?? 'Unknown Goal',
            'duration': goal['terms'] ?? 'Unknown Duration',
            'progress': 0.0,
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
      // ✅ Gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(224, 242, 254, 1), // light blue
              Color.fromRGBO(240, 249, 255, 1), // even lighter
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Main content column
            Column(
              children: [
                // ✅ AppBar
                SafeArea(
                  child: AppBar(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    toolbarHeight: 100, // Increased height for head area
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text(
                      "Goal",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                  ),
                ),

                const SizedBox(height: 40), // Increased gap between heading and content

                // ✅ Tab Switcher
               Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(

                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(70),


                    ),
                    indicatorPadding: EdgeInsets.symmetric(horizontal: -60),
                    labelColor: Colors.white,
                    unselectedLabelColor: primaryBlue,
                    tabs: const [
                      Tab(text: "New Goal"),
                      Tab(text: "Goals"),
                    ],
                  ),
),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ---------------- New Goal ----------------
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInputCard(
                              child: DropdownButtonFormField<String>(
                                value: selectedGoal,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Set Goal",
                                ),
                                items: goalOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => selectedGoal = value),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildHoverButton(
                                    isSelected: selectedDuration == "Mid Term (3-12 months)",
                                    text: "Mid Term",
                                    onPressed: () => setState(() => selectedDuration = "Mid Term (3-12 months)"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildHoverButton(
                                    isSelected: selectedDuration == "Long Term (1+ years)",
                                    text: "Long Term",
                                    onPressed: () => setState(() => selectedDuration = "Long Term (1+ years)"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInputCard(
                              child: TextField(
                                controller: notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: "Notes",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  if (selectedGoal != null && selectedDuration != null) {
                                    final result = await GoalService.createGoal(
                                      terms: selectedDuration!,
                                      goals: selectedGoal!,
                                      notes: notesController.text,
                                    );

                                    if (result['success'] == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
                                      );
                                      setState(() {
                                        selectedGoal = null;
                                        selectedDuration = null;
                                        notesController.clear();
                                      });
                                      _loadUserGoals();
                                      Navigator.push(context,MaterialPageRoute(builder: (_) => const DailyCheckinScreen()));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
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
                                  "Confirm",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ---------------- Goals ----------------
                      userGoals.isEmpty
                          ? const Center(
                              child: Text("No goals yet", style: TextStyle(color: Colors.grey)),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: userGoals.length,
                              itemBuilder: (context, index) => _buildGoalCard(userGoals[index]),
                            ),
                    ],
                  ),
                ),
              ],
            ),

            // Absolutely positioned circular container
            Positioned(
              top: 81, // Adjust this value to move vertically
              right: 190, // Adjust this value to move horizontally
              child: Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white .withOpacity(0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Card Builder with Shadow
  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goal['goal'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primaryBlue)),
          const SizedBox(height: 6),
          Text(goal['duration'], style: TextStyle(color: primaryBlue.withOpacity(0.7))),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: goal['progress'],
            backgroundColor: primaryBlue.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
            minHeight: 6,
          ),
          const SizedBox(height: 6),
          Text("Created ${goal['created']}",
              style: TextStyle(color: primaryBlue.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHoverButton({
    required bool isSelected,
    required String text,
    required VoidCallback onPressed,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected
                  ? primaryBlue
                  : isHovered
                      ? primaryBlue.withOpacity(0.1)
                      : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isSelected ? BorderSide.none : BorderSide(color: primaryBlue.withOpacity(0.2)),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : primaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}