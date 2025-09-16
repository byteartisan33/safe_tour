import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanicButtonWidget extends StatefulWidget {
  final bool isPanicMode;
  final VoidCallback onPanicPressed;

  const PanicButtonWidget({
    super.key,
    required this.isPanicMode,
    required this.onPanicPressed,
  });

  @override
  State<PanicButtonWidget> createState() => _PanicButtonWidgetState();
}

class _PanicButtonWidgetState extends State<PanicButtonWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));

    if (widget.isPanicMode) {
      _startPulseAnimation();
    }
  }

  @override
  void didUpdateWidget(PanicButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPanicMode != oldWidget.isPanicMode) {
      if (widget.isPanicMode) {
        _startPulseAnimation();
      } else {
        _stopPulseAnimation();
      }
    }
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulseAnimation() {
    _pulseController.stop();
    _pulseController.reset();
  }

  void _onPanicButtonPressed() {
    HapticFeedback.heavyImpact();
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
    widget.onPanicPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.isPanicMode 
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: widget.isPanicMode ? 15 : 10,
            offset: Offset(0, widget.isPanicMode ? 6 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.emergency,
                color: Colors.red[600],
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                widget.isPanicMode ? 'PANIC MODE ACTIVE' : 'Emergency Panic Button',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isPanicMode ? Colors.red[700] : Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Panic Button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value * 10 * (0.5 - (DateTime.now().millisecond % 100) / 100),
                      0,
                    ),
                    child: Transform.scale(
                      scale: widget.isPanicMode ? _pulseAnimation.value : 1.0,
                      child: GestureDetector(
                        onTap: _onPanicButtonPressed,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: widget.isPanicMode
                                  ? [Colors.red[400]!, Colors.red[700]!]
                                  : [Colors.red[500]!, Colors.red[700]!],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.4),
                                blurRadius: widget.isPanicMode ? 20 : 15,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isPanicMode ? Icons.stop : Icons.warning,
                                color: Colors.white,
                                size: 40,
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.isPanicMode ? 'STOP' : 'PANIC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
          
          SizedBox(height: 20),
          
          // Status Text
          Text(
            widget.isPanicMode
                ? 'Emergency contacts have been notified\nLocation is being shared continuously'
                : 'Press and hold to activate emergency mode\nYour location will be shared with emergency contacts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: widget.isPanicMode ? Colors.red[700] : Colors.grey[600],
              height: 1.4,
            ),
          ),
          
          if (widget.isPanicMode) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'LIVE TRACKING ACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          SizedBox(height: 16),
          
          // Quick Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                icon: Icons.phone,
                label: 'Call 100',
                color: Colors.blue,
                onTap: () => _makeEmergencyCall('100'),
              ),
              _buildQuickActionButton(
                icon: Icons.local_hospital,
                label: 'Call 108',
                color: Colors.green,
                onTap: () => _makeEmergencyCall('108'),
              ),
              _buildQuickActionButton(
                icon: Icons.help,
                label: 'Tourist Help',
                color: Colors.orange,
                onTap: () => _makeEmergencyCall('1363'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makeEmergencyCall(String number) {
    // TODO: Implement actual phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $number...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
