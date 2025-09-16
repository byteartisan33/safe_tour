import 'package:flutter/material.dart';

class LocationWidget extends StatelessWidget {
  final String currentLocation;
  final bool isLoading;
  final VoidCallback onLocationTap;

  const LocationWidget({
    super.key,
    required this.currentLocation,
    required this.isLoading,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onLocationTap,
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
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.green[600],
                    size: 20,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
              ],
            ),
            SizedBox(height: 12),
            
            // Location Text
            if (isLoading)
              _buildLoadingShimmer()
            else
              Text(
                currentLocation,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            SizedBox(height: 12),
            
            // Status Indicator
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.orange : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  isLoading ? 'Updating...' : 'Live',
                  style: TextStyle(
                    fontSize: 11,
                    color: isLoading ? Colors.orange[700] : Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Text(
                  'GPS Enabled',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: 100,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }
}
