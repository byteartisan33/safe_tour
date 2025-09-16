import 'package:flutter/material.dart';
import '../models/user_models.dart';

class TripSummaryWidget extends StatelessWidget {
  final TripDetails tripDetails;
  final VoidCallback onTap;

  const TripSummaryWidget({
    super.key,
    required this.tripDetails,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysRemaining = tripDetails.tripEndDate.difference(DateTime.now()).inDays;
    final totalDays = tripDetails.tripEndDate.difference(tripDetails.tripStartDate).inDays;
    final progress = totalDays > 0 ? (totalDays - daysRemaining) / totalDays : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trip_origin,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trip Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Trip Duration
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    daysRemaining > 0 
                        ? '$daysRemaining days remaining'
                        : daysRemaining == 0 
                            ? 'Last day of trip'
                            : 'Trip completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: daysRemaining > 0 ? Colors.blue[700] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Progress Bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: daysRemaining > 0 ? Colors.blue[600] : Colors.green[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            
            // Places Count
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 14,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 6),
                Text(
                  '${tripDetails.placesToVisit.length} places to visit',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTripStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getTripStatus(),
                    style: TextStyle(
                      fontSize: 9,
                      color: _getTripStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTripStatus() {
    final now = DateTime.now();
    if (now.isBefore(tripDetails.tripStartDate)) {
      return 'UPCOMING';
    } else if (now.isAfter(tripDetails.tripEndDate)) {
      return 'COMPLETED';
    } else {
      return 'ACTIVE';
    }
  }

  Color _getTripStatusColor() {
    final now = DateTime.now();
    if (now.isBefore(tripDetails.tripStartDate)) {
      return Colors.orange;
    } else if (now.isAfter(tripDetails.tripEndDate)) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
}
