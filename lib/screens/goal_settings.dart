import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import '../services/soar_card_service.dart';
import '../models/goal_data.dart';
//import 'dashboard_screen.dart';
import 'grow_screen.dart';
import 'daily_checkin_screen.dart';

class GoalPage extends StatefulWidget {
  final String? userEmail;

  const GoalPage({super.key, this.userEmail});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> with SingleTickerProviderStateMixin {
  String? selectedGoal;
  String? selectedCategory;
  GoalPeriod? selectedPeriod;
  final TextEditingController notesController = TextEditingController();
  final List<Map<String, dynamic>> userGoals = [];
  final List<GoalData> recommendedGoals = [];
  bool isLoadingRecommendedGoals = false;

  late TabController _tabController;

  // Modern color scheme
  final Color primaryBlue = const Color(0xFF3B82F6);
  final Color secondaryBlue = const Color(0xFF60A5FA);
  final Color accentBlue = const Color(0xFFDBEAFE);

  // Goal categories with icons
  final List<Map<String, dynamic>> goalCategories = [
    {"name": "Fitness & Health", "icon": Icons.fitness_center, "color": Colors.red},
    {"name": "Learning & Study", "icon": Icons.school, "color": Colors.blue},
    {"name": "Career & Professional", "icon": Icons.work, "color": Colors.green},
    {"name": "Finance & Money", "icon": Icons.account_balance_wallet, "color": Colors.orange},
    {"name": "Relationships", "icon": Icons.people, "color": Colors.purple},
    {"name": "Personal Growth", "icon": Icons.psychology, "color": Colors.teal},
    {"name": "Hobbies & Skills", "icon": Icons.palette, "color": Colors.pink},
    {"name": "Mental Health", "icon": Icons.self_improvement, "color": Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, animationDuration: Duration(milliseconds: 500));
    _loadUserGoals();
    _loadRecommendedGoals();
  }

  Future<void> _loadRecommendedGoals() async {
    setState(() => isLoadingRecommendedGoals = true);
    
    try {
      // Load SOAR assessment results to generate recommendations
      final soarAnswers = await SoarCardService.loadSoarCardAnswers();
      
      // Generate recommended goals based on SOAR results
      final recommendations = _generateRecommendedGoals(soarAnswers);
      
      setState(() {
        recommendedGoals.clear();
        recommendedGoals.addAll(recommendations);
        isLoadingRecommendedGoals = false;
      });
    } catch (e) {
      setState(() => isLoadingRecommendedGoals = false);
      print('Error loading recommended goals: $e');
    }
  }

  List<GoalData> _generateRecommendedGoals(List<dynamic> soarAnswers) {
    // This is a simplified recommendation system
    // In a real app, you'd analyze SOAR results more thoroughly
    final recommendations = <GoalData>[];
    
    // Default recommendations based on common SOAR categories
    recommendations.addAll([
      GoalData(
        id: 'rec_1',
        goal: 'Improve Teamwork Skills',
        category: 'Personal Growth',
        notes: 'Focus on collaborative communication and building stronger team relationships',
        period: GoalPeriod.midterm,
        createdAt: DateTime.now(),
        isRecommended: true,
        recommendationReason: 'Based on your SOAR assessment, teamwork is an area for growth', type: '',
      ),
      GoalData(
        id: 'rec_2',
        goal: 'Develop Stress Management Techniques',
        category: 'Mental Health',
        notes: 'Learn and practice daily stress reduction methods like meditation or breathing exercises',
        period: GoalPeriod.midterm,
        createdAt: DateTime.now(),
        isRecommended: true,
        recommendationReason: 'Your assessment suggests focusing on stress management', type: '',
      ),
      GoalData(
        id: 'rec_3',
        goal: 'Enhance Decision Making Skills',
        category: 'Career & Professional',
        notes: 'Practice making decisions under pressure and improve analytical thinking',
        period: GoalPeriod.longterm,
        createdAt: DateTime.now(),
        isRecommended: true,
        recommendationReason: 'Decision making is a key leadership skill to develop', type: '',
      ),
    ]);
    
    return recommendations;
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Modern Header
          Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
                colors: [primaryBlue, secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
          children: [
                    Row(
              children: [
                        IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          "Goal Settings",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.help_outline, color: Colors.white),
                          onPressed: () => _showHelpDialog(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Set your goals and track your progress",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Modern Tab Bar
               Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
              borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue, secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorPadding: const EdgeInsets.all(4),
                    labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    tabs: const [
                Tab(text: "Recommended"),
                Tab(text: "Create New"),
                Tab(text: "My Goals"),
                    ],
                  ),
),

          // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                _buildRecommendedGoalsTab(),
                _buildCreateGoalTab(),
                _buildMyGoalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Tab Builders
  Widget _buildRecommendedGoalsTab() {
    if (isLoadingRecommendedGoals) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (recommendedGoals.isEmpty) {
      return Center(
                        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No recommendations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your SOAR assessment to get personalized goal recommendations',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: recommendedGoals.length,
      itemBuilder: (context, index) => _buildRecommendedGoalCard(recommendedGoals[index]),
    );
  }

  Widget _buildCreateGoalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Selection
          Text(
            'Choose Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryGrid(),
          const SizedBox(height: 24),

          // Goal Input
          Text(
            'Describe Your Goal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
          _buildModernInputCard(
            child: TextField(
              onChanged: (value) => setState(() => selectedGoal = value),
              decoration: const InputDecoration(
                hintText: "What do you want to achieve?",
                border: InputBorder.none,
              ),
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 24),

          // Period Selection
          Text(
            'Goal Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildPeriodSelector(),
          const SizedBox(height: 24),

          // Notes
          Text(
            'Additional Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
                            ),
                            const SizedBox(height: 12),
          _buildModernInputCard(
                              child: TextField(
                                controller: notesController,
              maxLines: 4,
                                decoration: const InputDecoration(
                hintText: "Add any specific details, milestones, or thoughts...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
          const SizedBox(height: 32),

          // Create Button
                            SizedBox(
                              width: double.infinity,
            child: _buildModernButton(
              text: 'Create Goal',
              onPressed: _createGoal,
              isEnabled: selectedGoal != null && selectedCategory != null && selectedPeriod != null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyGoalsTab() {
    if (userGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first goal to start tracking your progress',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildModernButton(
              text: 'Create Goal',
              onPressed: () => _tabController.animateTo(1),
            ),
          ],
                                      ),
                                    );
                                  }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: userGoals.length,
      itemBuilder: (context, index) => _buildModernGoalCard(userGoals[index]),
    );
  }

  // Modern Card Builder
  Widget _buildModernInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
                            ),
                          ],
                        ),
      child: child,
    );
  }

  // Helper Methods
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: goalCategories.length,
      itemBuilder: (context, index) {
        final category = goalCategories[index];
        final isSelected = selectedCategory == category['name'];
        
        return GestureDetector(
          onTap: () => setState(() => selectedCategory = category['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? (category['color'] as Color).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? category['color'] as Color : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: isSelected ? category['color'] as Color : Colors.grey.shade600,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? category['color'] as Color : Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildPeriodButton(
            period: GoalPeriod.midterm,
            title: 'Mid-term',
            subtitle: '3-12 months',
            icon: Icons.schedule,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPeriodButton(
            period: GoalPeriod.longterm,
            title: 'Long-term',
            subtitle: '1+ years',
            icon: Icons.timeline,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton({
    required GoalPeriod period,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedPeriod == period;
    
    return GestureDetector(
      onTap: () => setState(() => selectedPeriod = period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
          color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryBlue : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? primaryBlue : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? primaryBlue.withOpacity(0.7) : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                colors: [primaryBlue, secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isEnabled ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedGoalCard(GoalData goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with recommendation badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: Colors.orange.shade600,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended for you',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        goal.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _addRecommendedGoal(goal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Add Goal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.goal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  goal.notes,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: goal.period == GoalPeriod.midterm 
                        ? Colors.blue.shade50 
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.period == GoalPeriod.midterm 
                        ? 'Mid-term (3-12 months)' 
                        : 'Long-term (1+ years)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: goal.period == GoalPeriod.midterm 
                          ? Colors.blue.shade700 
                          : Colors.purple.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernGoalCard(Map<String, dynamic> goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal['goal'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal['duration'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: goal['progress'],
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${(goal['progress'] * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                "Created ${goal['created']}",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Goal Settings Help'),
        content: const Text(
          '• Recommended: Goals suggested based on your SOAR assessment\n'
          '• Create New: Set up your own custom goals\n'
          '• My Goals: View and track your existing goals',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _createGoal() async {
    if (selectedGoal == null || selectedCategory == null || selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await GoalService.createGoal(
      terms: selectedPeriod == GoalPeriod.midterm 
          ? 'Mid-term (3-12 months)' 
          : 'Long-term (1+ years)',
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
      setState(() {
        selectedGoal = null;
        selectedCategory = null;
        selectedPeriod = null;
        notesController.clear();
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DailyCheckinScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addRecommendedGoal(GoalData goal) async {
    final result = await GoalService.createGoal(
      terms: goal.period == GoalPeriod.midterm 
          ? 'Mid-term (3-12 months)' 
          : 'Long-term (1+ years)',
      goals: goal.goal,
      notes: goal.notes,
    );

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DailyCheckinScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}