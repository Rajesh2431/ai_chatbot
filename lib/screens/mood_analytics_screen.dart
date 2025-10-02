import 'package:flutter/material.dart';
import '../services/mood_service.dart';
import '../services/user_avatar_service.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({super.key});

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  Map<String, dynamic> moodHistory = {};
  bool isLoading = true;
  String? avatarImagePath;
  String? currentMoodReply;

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
    _loadAvatarInfo();
  }

  // Enhanced device type detection
  DeviceType _getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (size.shortestSide < 600) {
      return DeviceType.mobile;
    } else if (size.shortestSide < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.largeTablet;
    }
  }

  // Get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseMobile) {
    final deviceType = _getDeviceType(context);
    final width = MediaQuery.of(context).size.width;

    switch (deviceType) {
      case DeviceType.mobile:
        return baseMobile * (width / 375).clamp(0.85, 1.15);
      case DeviceType.tablet:
        return baseMobile * 1.3;
      case DeviceType.largeTablet:
        return baseMobile * 1.5;
    }
  }

  // Get responsive spacing
  double _getResponsiveSpacing(BuildContext context, double baseMobile) {
    final deviceType = _getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseMobile;
      case DeviceType.tablet:
        return baseMobile * 1.3;
      case DeviceType.largeTablet:
        return baseMobile * 1.6;
    }
  }

  Future<void> _loadMoodHistory() async {
    final history = await MoodService.getMoodHistory();
    setState(() {
      moodHistory = history;
      isLoading = false;
    });
  }

  Future<void> _loadAvatarInfo() async {
    final avatarPath = await UserAvatarService.getHalfAvatarImage();
    final todayScore = await MoodService.getTodaysMoodScore();
    final moodText = _getMoodText(todayScore);

    setState(() {
      avatarImagePath = avatarPath;
      currentMoodReply = UserAvatarService.getMoodResponse(
        moodText,
        todayScore.round(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final horizontalPadding = deviceType == DeviceType.mobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood Analytics',
          style: TextStyle(
            color: Colors.black87,
            fontSize: _getResponsiveFontSize(context, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(context),
                  SizedBox(height: _getResponsiveSpacing(context, 20)),
                  _buildWeeklyTrendCard(context),
                  SizedBox(height: _getResponsiveSpacing(context, 20)),
                  _buildDailyHistorySection(context),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final avatarSize = _getDeviceType(context) == DeviceType.mobile
        ? 60.0
        : 80.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Colors.white,
                size: _getResponsiveSpacing(context, 28),
              ),
              SizedBox(width: _getResponsiveSpacing(context, 12)),
              Text(
                'Your Mood Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _getResponsiveFontSize(context, 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveSpacing(context, 16)),
          if (avatarImagePath != null && currentMoodReply != null) ...[
            Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(avatarSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(avatarSize / 2),
                    child: Image.asset(avatarImagePath!, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: _getResponsiveSpacing(context, 16)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(_getResponsiveSpacing(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      currentMoodReply!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
          ],
          FutureBuilder<double>(
            future: MoodService.getTodaysMoodScore(),
            builder: (context, snapshot) {
              final todayScore = snapshot.data ?? 3.0;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Mood',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: _getResponsiveFontSize(context, 14),
                          ),
                        ),
                        SizedBox(height: _getResponsiveSpacing(context, 4)),
                        Text(
                          _getMoodText(todayScore),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _getResponsiveFontSize(context, 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getResponsiveSpacing(context, 16),
                      vertical: _getResponsiveSpacing(context, 8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${todayScore.toStringAsFixed(1)}/5.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: _getResponsiveSpacing(context, 12)),
          Text(
            'Total Check-ins: ${moodHistory.length}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: _getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Trend',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context, 16)),
          FutureBuilder<List<double>>(
            future: MoodService.getWeeklyMoodScores(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final weeklyScores = snapshot.data!;
              final graphHeight = _getDeviceType(context) == DeviceType.mobile
                  ? 180.0
                  : 220.0;

              return SizedBox(
                height: graphHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: LineGraphPainter(
                          scores: weeklyScores,
                          getMoodColor: _getMoodColor,
                        ),
                        child: Container(),
                      ),
                    ),
                    SizedBox(height: _getResponsiveSpacing(context, 12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        final day = DateTime.now().subtract(
                          Duration(days: 6 - index),
                        );
                        return Expanded(
                          child: Text(
                            _getDayName(day.weekday),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _getResponsiveFontSize(context, 12),
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHistorySection(BuildContext context) {
    if (moodHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(_getResponsiveSpacing(context, 40)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.mood,
              size: _getResponsiveSpacing(context, 60),
              color: Colors.grey,
            ),
            SizedBox(height: _getResponsiveSpacing(context, 16)),
            Text(
              'No Check-ins Yet',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: _getResponsiveSpacing(context, 8)),
            Text(
              'Complete your first daily check-in to see your mood analytics here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 14),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final sortedDates = moodHistory.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Check-in History',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context, 12)),
        ...sortedDates.map(
          (date) => _buildDailyHistoryCard(context, date, moodHistory[date]),
        ),
      ],
    );
  }

  Widget _buildDailyHistoryCard(
    BuildContext context,
    String date,
    Map<String, dynamic> dayData,
  ) {
    final overallScore = (dayData['overall_score'] as num).toDouble();
    final questions = dayData['questions'] as Map<String, dynamic>? ?? {};
    final timestamp = DateTime.parse(dayData['timestamp'] ?? date);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: _getResponsiveSpacing(context, 12)),
      padding: EdgeInsets.all(_getResponsiveSpacing(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(timestamp),
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _getResponsiveSpacing(context, 12),
                  vertical: _getResponsiveSpacing(context, 6),
                ),
                decoration: BoxDecoration(
                  color: _getMoodColor(overallScore).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMoodIcon(overallScore),
                      size: _getResponsiveSpacing(context, 16),
                      color: _getMoodColor(overallScore),
                    ),
                    SizedBox(width: _getResponsiveSpacing(context, 4)),
                    Text(
                      overallScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.bold,
                        color: _getMoodColor(overallScore),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveSpacing(context, 12)),
          Text(
            _getMoodText(overallScore),
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              color: Colors.black87,
            ),
          ),
          if (questions.isNotEmpty) ...[
            SizedBox(height: _getResponsiveSpacing(context, 8)),
            Text(
              'Answered ${questions.length} questions',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, 12),
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getMoodText(double score) {
    if (score >= 4.0) return 'Excellent!';
    if (score >= 3.0) return 'Good';
    if (score >= 2.5) return 'Okay';
    return 'Needs Support';
  }

  Color _getMoodColor(double score) {
    if (score >= 4.5) return Colors.green[400]!;
    if (score >= 4.0) return Colors.green[300]!;
    if (score >= 3.5) return Colors.yellow[600]!;
    if (score >= 3.0) return Colors.orange[400]!;
    if (score >= 2.0) return Colors.red[400]!;
    return Colors.red[600]!;
  }

  IconData _getMoodIcon(double score) {
    if (score >= 4.5) return Icons.sentiment_very_satisfied;
    if (score >= 4.0) return Icons.sentiment_satisfied;
    if (score >= 3.5) return Icons.sentiment_neutral;
    if (score >= 3.0) return Icons.sentiment_neutral;
    if (score >= 2.0) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

enum DeviceType { mobile, tablet, largeTablet }

class LineGraphPainter extends CustomPainter {
  final List<double> scores;
  final Color Function(double) getMoodColor;

  LineGraphPainter({required this.scores, required this.getMoodColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final pointPaint = Paint()..style = PaintingStyle.fill;

    final path = Path();
    final gradientPath = Path();
    final points = <Offset>[];

    // Calculate points
    for (int i = 0; i < scores.length; i++) {
      final x = (size.width / (scores.length - 1)) * i;
      final normalizedScore = (scores[i] / 5.0).clamp(0.0, 1.0);
      final y = size.height - (normalizedScore * size.height);
      points.add(Offset(x, y));
    }

    // Draw gradient fill
    if (points.isNotEmpty) {
      gradientPath.moveTo(points.first.dx, size.height);
      gradientPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        gradientPath.lineTo(points[i].dx, points[i].dy);
      }

      gradientPath.lineTo(points.last.dx, size.height);
      gradientPath.close();
      canvas.drawPath(gradientPath, gradientPaint);
    }

    // Draw line
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      paint.shader = LinearGradient(
        colors: [Colors.blue.shade300, Colors.blue.shade600],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, paint);
    }

    // Draw points
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final score = scores[i];

      pointPaint.color = Colors.white;
      canvas.drawCircle(point, 6, pointPaint);

      pointPaint.color = getMoodColor(score);
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = size.height - (i / 5.0) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(LineGraphPainter oldDelegate) {
    return oldDelegate.scores != scores;
  }
}