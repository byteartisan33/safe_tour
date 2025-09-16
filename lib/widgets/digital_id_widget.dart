// Digital Tourist ID Widget for Dashboard

import 'package:flutter/material.dart';
import '../models/blockchain_models.dart';

class DigitalIdWidget extends StatefulWidget {
  final DigitalTouristID? digitalId;
  final VoidCallback? onTap;

  const DigitalIdWidget({
    super.key,
    this.digitalId,
    this.onTap,
  });

  @override
  State<DigitalIdWidget> createState() => _DigitalIdWidgetState();
}

class _DigitalIdWidgetState extends State<DigitalIdWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    if (widget.digitalId?.status == BlockchainStatus.verified) {
      _pulseController.repeat(reverse: true);
    }
    
    if (widget.digitalId?.status == BlockchainStatus.pending) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.digitalId == null) {
      return _buildNoIdCard();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: _getStatusGradient(widget.digitalId!.status),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(widget.digitalId!.status).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect for pending status
                  if (widget.digitalId!.status == BlockchainStatus.pending)
                    _buildShimmerEffect(),
                  
                  // Main content
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Digital Tourist ID',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    _getStatusText(widget.digitalId!.status),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusIcon(widget.digitalId!.status),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Tourist Info
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.digitalId!.touristName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.digitalId!.nationality,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // QR Code placeholder
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.qr_code,
                                color: _getStatusColor(widget.digitalId!.status),
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        // ID Details
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${widget.digitalId!.id.substring(0, 8)}...',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Expires: ${_formatDate(widget.digitalId!.expiryDate)}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Blockchain indicator
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Blockchain',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
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
        },
      ),
    );
  }

  Widget _buildNoIdCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12),
          Text(
            'Digital Tourist ID',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Complete registration to get your blockchain-verified ID',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: widget.onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Get Digital ID'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ],
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(BlockchainStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case BlockchainStatus.verified:
        icon = Icons.verified;
        color = Colors.white;
        break;
      case BlockchainStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.white.withValues(alpha: 0.8);
        break;
      case BlockchainStatus.active:
        icon = Icons.check_circle;
        color = Colors.white;
        break;
      case BlockchainStatus.expired:
        icon = Icons.error;
        color = Colors.white.withValues(alpha: 0.8);
        break;
      default:
        icon = Icons.help;
        color = Colors.white.withValues(alpha: 0.8);
    }
    
    return Icon(icon, color: color, size: 20);
  }

  LinearGradient _getStatusGradient(BlockchainStatus status) {
    switch (status) {
      case BlockchainStatus.verified:
      case BlockchainStatus.active:
        return LinearGradient(
          colors: [Colors.green[600]!, Colors.green[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case BlockchainStatus.pending:
        return LinearGradient(
          colors: [Colors.orange[600]!, Colors.orange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case BlockchainStatus.expired:
      case BlockchainStatus.revoked:
        return LinearGradient(
          colors: [Colors.red[600]!, Colors.red[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.grey[600]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getStatusColor(BlockchainStatus status) {
    switch (status) {
      case BlockchainStatus.verified:
      case BlockchainStatus.active:
        return Colors.green[600]!;
      case BlockchainStatus.pending:
        return Colors.orange[600]!;
      case BlockchainStatus.expired:
      case BlockchainStatus.revoked:
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _getStatusText(BlockchainStatus status) {
    switch (status) {
      case BlockchainStatus.verified:
        return 'Blockchain Verified';
      case BlockchainStatus.pending:
        return 'Verification Pending';
      case BlockchainStatus.active:
        return 'Active & Verified';
      case BlockchainStatus.expired:
        return 'Expired';
      case BlockchainStatus.revoked:
        return 'Revoked';
      default:
        return 'Unknown Status';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
