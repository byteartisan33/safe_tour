import 'package:flutter/material.dart';
import '../models/user_models.dart';
import '../models/emergency_models.dart';

class EmergencyContactsWidget extends StatelessWidget {
  final List<EmergencyContact> contacts;
  final List<PoliceStation> policeStations;
  final List<HospitalService> hospitals;
  final Function(EmergencyContact)? onContactTap;
  final Function(PoliceStation)? onPoliceStationTap;
  final Function(HospitalService)? onHospitalTap;

  const EmergencyContactsWidget({
    super.key,
    required this.contacts,
    this.policeStations = const [],
    this.hospitals = const [],
    this.onContactTap,
    this.onPoliceStationTap,
    this.onHospitalTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Emergency Contacts
        if (contacts.isNotEmpty) ...[
          _buildSectionHeader(
            'Personal Emergency Contacts',
            Icons.contacts,
            Colors.blue,
          ),
          SizedBox(height: 12),
          ...contacts.map((contact) => _buildContactCard(
            context,
            contact.name,
            '${contact.relationship} • ${contact.phoneNumber}',
            Icons.person,
            Colors.blue,
            () => onContactTap?.call(contact),
          )),
          SizedBox(height: 24),
        ],

        // Police Stations
        if (policeStations.isNotEmpty) ...[
          _buildSectionHeader(
            'Nearby Police Stations',
            Icons.local_police,
            Colors.red,
          ),
          SizedBox(height: 12),
          ...policeStations.map((station) => _buildContactCard(
            context,
            station.name,
            '${station.address} • ${station.distance.toStringAsFixed(1)}km',
            Icons.local_police,
            Colors.red,
            () => onPoliceStationTap?.call(station),
            phoneNumber: station.phoneNumber,
          )),
          SizedBox(height: 24),
        ],

        // Hospitals
        if (hospitals.isNotEmpty) ...[
          _buildSectionHeader(
            'Nearby Hospitals',
            Icons.local_hospital,
            Colors.green,
          ),
          SizedBox(height: 12),
          ...hospitals.map((hospital) => _buildContactCard(
            context,
            hospital.name,
            '${hospital.address} • ${hospital.distance.toStringAsFixed(1)}km',
            Icons.local_hospital,
            Colors.green,
            () => onHospitalTap?.call(hospital),
            phoneNumber: hospital.emergencyNumber,
            subtitle2: hospital.hasEmergencyServices ? 'Emergency Services Available' : null,
          )),
          SizedBox(height: 24),
        ],

        // Default Emergency Numbers
        _buildSectionHeader(
          'Emergency Helplines',
          Icons.phone,
          Colors.orange,
        ),
        SizedBox(height: 12),
        _buildContactCard(
          context,
          'Police Emergency',
          'Immediate police assistance',
          Icons.shield,
          Colors.red,
          null,
          phoneNumber: '100',
        ),
        _buildContactCard(
          context,
          'Medical Emergency',
          'Ambulance and medical assistance',
          Icons.medical_services,
          Colors.green,
          null,
          phoneNumber: '108',
        ),
        _buildContactCard(
          context,
          'Fire Brigade',
          'Fire emergency services',
          Icons.fire_truck,
          Colors.orange,
          null,
          phoneNumber: '101',
        ),
        _buildContactCard(
          context,
          'Tourist Helpline',
          '24/7 tourist assistance',
          Icons.support_agent,
          Colors.blue,
          null,
          phoneNumber: '1363',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    String name,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    String? phoneNumber,
    String? subtitle2,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                
                SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (subtitle2 != null) ...[
                        SizedBox(height: 2),
                        Text(
                          subtitle2,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Phone number and call button
                if (phoneNumber != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmergencyContactSummaryWidget extends StatelessWidget {
  final List<EmergencyContact> contacts;
  final int maxDisplay;
  final VoidCallback? onViewAll;

  const EmergencyContactSummaryWidget({
    super.key,
    required this.contacts,
    this.maxDisplay = 3,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayContacts = contacts.take(maxDisplay).toList();
    final remainingCount = contacts.length - maxDisplay;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contacts, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Spacer(),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text('View All'),
                ),
            ],
          ),
          
          SizedBox(height: 12),
          
          if (contacts.isEmpty) ...[
            Text(
              'No emergency contacts added',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            ...displayContacts.map((contact) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[500]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${contact.name} (${contact.relationship})',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Text(
                    contact.phoneNumber,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            
            if (remainingCount > 0)
              Text(
                '+$remainingCount more contacts',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
