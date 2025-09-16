import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_models.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final List<EmergencyContact> emergencyContacts;
  final String selectedLanguage;

  const EmergencyContactsScreen({
    super.key,
    required this.emergencyContacts,
    required this.selectedLanguage,
  });

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<EmergencyContact> _contacts = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _contacts = List.from(widget.emergencyContacts);
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        elevation: 0,
        leading: IconButton(
          onPressed: _onBackPressed,
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveContacts,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            onPressed: _addContact,
            icon: Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Contact',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Info Card
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.red[600]),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'These contacts will be notified in case of emergency',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contacts List
            Expanded(
              child: _contacts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        return _buildContactCard(_contacts[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        backgroundColor: Colors.red[600],
        tooltip: 'Add Emergency Contact',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Emergency Contacts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add emergency contacts to notify in case of emergency',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addContact,
            icon: Icon(Icons.add),
            label: Text('Add Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Contact Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: contact.isPrimary ? Colors.red[50] : Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: contact.isPrimary
                        ? Colors.red[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    Icons.person,
                    color: contact.isPrimary
                        ? Colors.red[700]
                        : Colors.grey[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            contact.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (contact.isPrimary) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'PRIMARY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        contact.relationship,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleContactAction(value, index),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!contact.isPrimary)
                      PopupMenuItem(
                        value: 'makePrimary',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 18),
                            SizedBox(width: 8),
                            Text('Make Primary'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contact Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.blue[600], size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        contact.phoneNumber,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _callContact(contact.phoneNumber),
                      icon: Icon(Icons.call, color: Colors.green[600]),
                      tooltip: 'Call',
                    ),
                  ],
                ),
                if (contact.email != null && contact.email!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.orange[600], size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          contact.email!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _emailContact(contact.email!),
                        icon: Icon(Icons.mail, color: Colors.blue[600]),
                        tooltip: 'Email',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleContactAction(String action, int index) {
    switch (action) {
      case 'edit':
        _editContact(index);
        break;
      case 'makePrimary':
        _makePrimary(index);
        break;
      case 'delete':
        _deleteContact(index);
        break;
    }
  }

  void _addContact() {
    _showContactDialog();
  }

  void _editContact(int index) {
    _showContactDialog(contact: _contacts[index], index: index);
  }

  void _makePrimary(int index) {
    setState(() {
      // Remove primary status from all contacts
      for (int i = 0; i < _contacts.length; i++) {
        _contacts[i] = EmergencyContact(
          name: _contacts[i].name,
          relationship: _contacts[i].relationship,
          phoneNumber: _contacts[i].phoneNumber,
          email: _contacts[i].email,
          isPrimary: i == index,
        );
      }
      _hasChanges = true;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_contacts[index].name} is now the primary contact'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  void _deleteContact(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Contact'),
        content: Text(
          'Are you sure you want to delete ${_contacts[index].name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _contacts.removeAt(index);
                _hasChanges = true;
              });
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog({EmergencyContact? contact, int? index}) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final relationshipController = TextEditingController(
      text: contact?.relationship ?? '',
    );
    final phoneController = TextEditingController(
      text: contact?.phoneNumber ?? '',
    );
    final emailController = TextEditingController(text: contact?.email ?? '');
    bool isPrimary = contact?.isPrimary ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            contact == null
                ? 'Add Emergency Contact'
                : 'Edit Emergency Contact',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: relationshipController,
                  decoration: InputDecoration(
                    labelText: 'Relationship',
                    prefixIcon: Icon(Icons.family_restroom),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text('Primary Contact'),
                  subtitle: Text('This contact will be notified first'),
                  value: isPrimary,
                  onChanged: (value) {
                    setDialogState(() {
                      isPrimary = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    relationshipController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  final newContact = EmergencyContact(
                    name: nameController.text,
                    relationship: relationshipController.text,
                    phoneNumber: phoneController.text,
                    email: emailController.text.isEmpty
                        ? null
                        : emailController.text,
                    isPrimary: isPrimary,
                  );

                  setState(() {
                    if (index != null) {
                      _contacts[index] = newContact;
                    } else {
                      _contacts.add(newContact);
                    }

                    // If this is set as primary, remove primary from others
                    if (isPrimary) {
                      for (int i = 0; i < _contacts.length; i++) {
                        if (i != (index ?? _contacts.length - 1)) {
                          _contacts[i] = EmergencyContact(
                            name: _contacts[i].name,
                            relationship: _contacts[i].relationship,
                            phoneNumber: _contacts[i].phoneNumber,
                            email: _contacts[i].email,
                            isPrimary: false,
                          );
                        }
                      }
                    }

                    _hasChanges = true;
                  });

                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                }
              },
              child: Text(contact == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _callContact(String phoneNumber) {
    // TODO: Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $phoneNumber...'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  void _emailContact(String email) {
    // TODO: Implement email functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening email to $email...'),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  void _onBackPressed() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsaved Changes'),
          content: Text('You have unsaved changes. Do you want to save them?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Discard'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveContacts();
              },
              child: Text('Save'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _saveContacts() {
    Navigator.pop(context, _contacts);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergency contacts updated successfully'),
        backgroundColor: Colors.green[600],
      ),
    );
  }
}
