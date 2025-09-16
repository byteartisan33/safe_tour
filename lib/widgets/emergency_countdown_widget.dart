import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class EmergencyCountdownWidget extends StatefulWidget {
  final int countdownSeconds;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String title;
  final String message;

  const EmergencyCountdownWidget({
    super.key,
    required this.countdownSeconds,
    required this.onCancel,
    required this.onConfirm,
    this.title = 'Emergency Alert Confirmation',
    this.message =
        'Emergency services will be notified automatically unless you cancel.',
  });

  @override
  State<EmergencyCountdownWidget> createState() =>
      _EmergencyCountdownWidgetState();
}

class _EmergencyCountdownWidgetState extends State<EmergencyCountdownWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;
    _initializeAnimations();
    _startCountdown();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(seconds: widget.countdownSeconds),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
    _progressController.forward();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });

        // Haptic feedback for last 3 seconds
        if (_remainingSeconds <= 3 && _remainingSeconds > 0) {
          HapticFeedback.heavyImpact();
        }
      } else {
        timer.cancel();
        if (!_isConfirmed) {
          widget.onConfirm();
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with warning icon
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning, size: 48, color: Colors.red[600]),
                  SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Countdown Circle
            AnimatedBuilder(
              animation: Listenable.merge([
                _pulseAnimation,
                _progressAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress circle
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: _progressAnimation.value,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _remainingSeconds <= 3
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        // Countdown number
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_remainingSeconds',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _remainingSeconds <= 3
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                            ),
                            Text(
                              'seconds',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 24),

            // Message
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            // Additional warning
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.orange[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your location will be shared with emergency contacts and nearby police stations.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _isConfirmed = true;
                      _countdownTimer?.cancel();
                      widget.onCancel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 16),

                // Confirm Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _isConfirmed = true;
                      _countdownTimer?.cancel();
                      widget.onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emergency, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'CONFIRM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Auto-confirm notice
            Text(
              'Emergency will be activated automatically in $_remainingSeconds seconds',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
