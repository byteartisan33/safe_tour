import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/safety_score_service.dart';

class SafetyScoreWidget extends StatefulWidget {
  final int score;
  final VoidCallback onTap;

  const SafetyScoreWidget({
    super.key,
    required this.score,
    required this.onTap,
  });

  @override
  State<SafetyScoreWidget> createState() => _SafetyScoreWidgetState();
}

class _SafetyScoreWidgetState extends State<SafetyScoreWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score / 100.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SafetyScoreService.getSafetyScoreColor(widget.score).withValues(alpha: 0.1),
              SafetyScoreService.getSafetyScoreColor(widget.score).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SafetyScoreService.getSafetyScoreColor(widget.score).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: SafetyScoreService.getSafetyScoreColor(widget.score).withValues(alpha: 0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Progress Indicator
            SizedBox(
              width: 80,
              height: 80,
              child: AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CircularScorePainter(
                      progress: _scoreAnimation.value,
                      color: SafetyScoreService.getSafetyScoreColor(widget.score),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_scoreAnimation.value * 100).toInt()}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: SafetyScoreService.getSafetyScoreColor(widget.score),
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 20),
            
            // Score Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: SafetyScoreService.getSafetyScoreColor(widget.score),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tourist Safety Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    SafetyScoreService.getSafetyScoreDescription(widget.score),
                    style: TextStyle(
                      fontSize: 14,
                      color: SafetyScoreService.getSafetyScoreColor(widget.score),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Based on location, travel behavior, and area risks',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Updated 2 min ago',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CircularScorePainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularScorePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow effect for high scores
    if (progress > 0.8) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularScorePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
