import 'package:flutter/material.dart';
import '../../../models/user_models.dart';

class EmergencyContactsStep extends StatefulWidget {
  final List<EmergencyContact> initialData;
  final Function(List<EmergencyContact>) onDataChanged;

  const EmergencyContactsStep({
    super.key,
    required this.initialData,
    required this.onDataChanged,
  });

  @override
  State<EmergencyContactsStep> createState() => _EmergencyContactsStepState();
}

class _EmergencyContactsStepState extends State<EmergencyContactsStep> {
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _contacts = List.from(widget.initialData);
    if (_contacts.isEmpty) {
      // Add default primary contact
      _contacts.add(
        EmergencyContact(
          name: '',
          relationship: '',
          phoneNumber: '',
          email: '',
          isPrimary: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Emergency Contacts'),
          SizedBox(height: 8),
          _buildInfoCard(),
          SizedBox(height: 24),

          // Contacts List
          ..._contacts.asMap().entries.map((entry) {
            final index = entry.key;
            final contact = entry.value;
            return _buildContactCard(contact, index);
          }),

          SizedBox(height: 16),

          // Add Contact Button
          if (_contacts.length < 3) _buildAddContactButton(),

          SizedBox(height: 24),
          _buildEmergencyInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[700],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.emergency, color: Colors.red[700]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add at least one emergency contact. These contacts will be notified in case of emergency situations during your trip.',
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact, int index) {
    final isPrimary = contact.isPrimary;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary ? Colors.blue[300]! : Colors.grey[300]!,
          width: isPrimary ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isPrimary ? Icons.star : Icons.person,
                color: isPrimary ? Colors.blue[700] : Colors.grey[600],
              ),
              SizedBox(width: 8),
              Text(
                isPrimary
                    ? 'Primary Emergency Contact'
                    : 'Secondary Emergency Contact',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.blue[700] : Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              Spacer(),
              if (!isPrimary && _contacts.length > 1)
                IconButton(
                  onPressed: () => _removeContact(index),
                  icon: Icon(Icons.delete, color: Colors.red[600]),
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          SizedBox(height: 16),

          // Name Field
          TextFormField(
            initialValue: contact.name,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter contact\'s full name',
              prefixIcon: Icon(Icons.person, color: Colors.blue[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => _updateContact(index, name: value),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Name is required' : null,
          ),

          SizedBox(height: 12),

          // Relationship Field
          DropdownButtonFormField<String>(
            initialValue: contact.relationship.isEmpty
                ? null
                : contact.relationship,
            decoration: InputDecoration(
              labelText: 'Relationship *',
              prefixIcon: Icon(Icons.family_restroom, color: Colors.blue[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items:
                [
                      'Parent',
                      'Spouse',
                      'Sibling',
                      'Child',
                      'Friend',
                      'Colleague',
                      'Relative',
                      'Guardian',
                      'Other',
                    ]
                    .map(
                      (relationship) => DropdownMenuItem(
                        value: relationship,
                        child: Text(relationship),
                      ),
                    )
                    .toList(),
            onChanged: (value) =>
                _updateContact(index, relationship: value ?? ''),
            validator: (value) =>
                value == null ? 'Relationship is required' : null,
          ),

          SizedBox(height: 12),

          // Phone Number Field
          TextFormField(
            initialValue: contact.phoneNumber,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              hintText: '+91 9876543210',
              prefixIcon: Icon(Icons.phone, color: Colors.blue[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => _updateContact(index, phoneNumber: value),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Phone number is required';
              if (value!.length < 10) return 'Enter valid phone number';
              return null;
            },
          ),

          SizedBox(height: 12),

          // Email Field (Optional)
          TextFormField(
            initialValue: contact.email,
            decoration: InputDecoration(
              labelText: 'Email (Optional)',
              hintText: 'contact@example.com',
              prefixIcon: Icon(Icons.email, color: Colors.blue[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => _updateContact(index, email: value),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Enter valid email address';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactButton() {
    return InkWell(
      onTap: _addContact,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, size: 32, color: Colors.grey[600]),
            SizedBox(height: 8),
            Text(
              'Add Secondary Contact',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Add up to 2 additional emergency contacts',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Emergency Contact Information',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Primary contact will be notified first in emergencies\n'
            '• Ensure all phone numbers are active and reachable\n'
            '• Include country code for international numbers\n'
            '• Contacts will receive location updates during emergencies',
            style: TextStyle(color: Colors.orange[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _addContact() {
    if (_contacts.length < 3) {
      setState(() {
        _contacts.add(
          EmergencyContact(
            name: '',
            relationship: '',
            phoneNumber: '',
            email: '',
            isPrimary: false,
          ),
        );
      });
    }
  }

  void _removeContact(int index) {
    if (_contacts.length > 1 && !_contacts[index].isPrimary) {
      setState(() {
        _contacts.removeAt(index);
      });
      _updateData();
    }
  }

  void _updateContact(
    int index, {
    String? name,
    String? relationship,
    String? phoneNumber,
    String? email,
  }) {
    setState(() {
      final contact = _contacts[index];
      _contacts[index] = EmergencyContact(
        name: name ?? contact.name,
        relationship: relationship ?? contact.relationship,
        phoneNumber: phoneNumber ?? contact.phoneNumber,
        email: email ?? contact.email,
        isPrimary: contact.isPrimary,
      );
    });
    _updateData();
  }

  void _updateData() {
    // Filter out incomplete contacts
    final validContacts = _contacts.where((contact) {
      return contact.name.isNotEmpty &&
          contact.relationship.isNotEmpty &&
          contact.phoneNumber.isNotEmpty;
    }).toList();

    widget.onDataChanged(validContacts);
  }
}
