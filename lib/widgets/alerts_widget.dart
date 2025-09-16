import 'package:flutter/material.dart';

class AlertsWidget extends StatelessWidget {
  final List<String> alerts;
  final Function(String) onAlertTap;

  const AlertsWidget({
    super.key,
    required this.alerts,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: alerts.isEmpty ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  alerts.isEmpty ? Icons.check_circle : Icons.warning,
                  color: alerts.isEmpty
                      ? Colors.green[600]
                      : Colors.orange[600],
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Safety Alerts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (alerts.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),

          // Alerts List or No Alerts Message
          if (alerts.isEmpty)
            _buildNoAlertsMessage()
          else
            ...alerts.map((alert) => _buildAlertItem(alert)),
        ],
      ),
    );
  }

  Widget _buildNoAlertsMessage() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Clear!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'No active safety alerts in your area',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String alert) {
    final alertType = _getAlertType(alert);
    final alertColor = _getAlertColor(alertType);
    final alertIcon = _getAlertIcon(alertType);

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onAlertTap(alert),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: alertColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: alertColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(alertIcon, color: alertColor, size: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _getAlertTime(alert),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  AlertType _getAlertType(String alert) {
    final lowerAlert = alert.toLowerCase();
    if (lowerAlert.contains('weather') ||
        lowerAlert.contains('rain') ||
        lowerAlert.contains('storm')) {
      return AlertType.weather;
    } else if (lowerAlert.contains('traffic') ||
        lowerAlert.contains('road') ||
        lowerAlert.contains('transport')) {
      return AlertType.traffic;
    } else if (lowerAlert.contains('security') ||
        lowerAlert.contains('police') ||
        lowerAlert.contains('crime')) {
      return AlertType.security;
    } else if (lowerAlert.contains('tourist') ||
        lowerAlert.contains('crowd') ||
        lowerAlert.contains('activity')) {
      return AlertType.tourist;
    } else {
      return AlertType.general;
    }
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.weather:
        return Colors.blue;
      case AlertType.traffic:
        return Colors.orange;
      case AlertType.security:
        return Colors.red;
      case AlertType.tourist:
        return Colors.green;
      case AlertType.general:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.weather:
        return Icons.cloud;
      case AlertType.traffic:
        return Icons.traffic;
      case AlertType.security:
        return Icons.security;
      case AlertType.tourist:
        return Icons.groups;
      case AlertType.general:
        return Icons.info;
    }
  }

  String _getAlertTime(String alert) {
    // Simulate different alert times
    final hash = alert.hashCode.abs();
    final minutes = (hash % 60) + 1;
    return '$minutes min ago';
  }
}

enum AlertType { weather, traffic, security, tourist, general }
