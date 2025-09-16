import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_models.dart';
import '../../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserRegistrationData? userData;
  final String selectedLanguage;

  const EditProfileScreen({
    super.key,
    this.userData,
    required this.selectedLanguage,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _nationalityController;
  late TextEditingController _documentNumberController;
  late TextEditingController _entryPointController;
  late TextEditingController _itineraryController;

  // Form data
  String _selectedGender = 'Male';
  String _selectedDocumentType = 'Passport';
  DateTime? _dateOfBirth;
  DateTime? _documentExpiryDate;
  DateTime? _tripStartDate;
  DateTime? _tripEndDate;
  List<String> _placesToVisit = [];

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _nationalityController = TextEditingController();
    _documentNumberController = TextEditingController();
    _entryPointController = TextEditingController();
    _itineraryController = TextEditingController();

    // Add listeners to detect changes
    _nameController.addListener(_onFormChanged);
    _nationalityController.addListener(_onFormChanged);
    _documentNumberController.addListener(_onFormChanged);
    _entryPointController.addListener(_onFormChanged);
    _itineraryController.addListener(_onFormChanged);
  }

  void _loadUserData() {
    if (widget.userData != null) {
      final userData = widget.userData!;

      // Personal Information
      _nameController.text = userData.personalInfo.fullName;
      _nationalityController.text = userData.personalInfo.nationality;
      _documentNumberController.text = userData.personalInfo.documentNumber;
      _selectedGender = userData.personalInfo.gender;
      _selectedDocumentType = userData.personalInfo.documentType;
      _dateOfBirth = userData.personalInfo.dateOfBirth;
      _documentExpiryDate = userData.personalInfo.documentExpiryDate != null
          ? DateTime.tryParse(userData.personalInfo.documentExpiryDate!)
          : null;

      // Trip Details
      _entryPointController.text = userData.tripDetails.entryPoint;
      _itineraryController.text = userData.tripDetails.detailedItinerary;
      _tripStartDate = userData.tripDetails.tripStartDate;
      _tripEndDate = userData.tripDetails.tripEndDate;
      _placesToVisit = List.from(userData.tripDetails.placesToVisit);
    }
  }

  void _onFormChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _nationalityController.dispose();
    _documentNumberController.dispose();
    _entryPointController.dispose();
    _itineraryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          onPressed: _onBackPressed,
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Personal'),
            Tab(text: 'Documents'),
            Tab(text: 'Trip Details'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPersonalInfoTab(),
            _buildDocumentsTab(),
            _buildTripDetailsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information'),
          SizedBox(height: 16),

          // Full Name
          _buildTextFormField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          // Gender Selection
          _buildDropdownField(
            label: 'Gender',
            icon: Icons.wc,
            value: _selectedGender,
            items: ['Male', 'Female', 'Other'],
            onChanged: (value) {
              setState(() {
                _selectedGender = value!;
                _hasChanges = true;
              });
            },
          ),

          SizedBox(height: 16),

          // Date of Birth
          _buildDateField(
            label: 'Date of Birth',
            icon: Icons.cake,
            selectedDate: _dateOfBirth,
            onDateSelected: (date) {
              setState(() {
                _dateOfBirth = date;
                _hasChanges = true;
              });
            },
          ),

          SizedBox(height: 16),

          // Nationality
          _buildTextFormField(
            controller: _nationalityController,
            label: 'Nationality',
            icon: Icons.flag,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your nationality';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Identity Documents'),
          SizedBox(height: 16),

          // Document Type
          _buildDropdownField(
            label: 'Document Type',
            icon: Icons.description,
            value: _selectedDocumentType,
            items: [
              'Passport',
              'Aadhaar Card',
              'Driver License',
              'National ID',
            ],
            onChanged: (value) {
              setState(() {
                _selectedDocumentType = value!;
                _hasChanges = true;
              });
            },
          ),

          SizedBox(height: 16),

          // Document Number
          _buildTextFormField(
            controller: _documentNumberController,
            label: 'Document Number',
            icon: Icons.numbers,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter document number';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          // Document Expiry Date
          _buildDateField(
            label: 'Document Expiry Date',
            icon: Icons.event,
            selectedDate: _documentExpiryDate,
            onDateSelected: (date) {
              setState(() {
                _documentExpiryDate = date;
                _hasChanges = true;
              });
            },
          ),

          SizedBox(height: 24),

          // Document Upload Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload, size: 48, color: Colors.blue[600]),
                SizedBox(height: 8),
                Text(
                  'Upload Document Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Take a clear photo of your document',
                  style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _uploadDocument,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Trip Information'),
          SizedBox(height: 16),

          // Entry Point
          _buildTextFormField(
            controller: _entryPointController,
            label: 'Entry Point',
            icon: Icons.flight_land,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter entry point';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          // Trip Start Date
          _buildDateField(
            label: 'Trip Start Date',
            icon: Icons.date_range,
            selectedDate: _tripStartDate,
            onDateSelected: (date) {
              setState(() {
                _tripStartDate = date;
                _hasChanges = true;
              });
            },
          ),

          SizedBox(height: 16),

          // Trip End Date
          _buildDateField(
            label: 'Trip End Date',
            icon: Icons.date_range,
            selectedDate: _tripEndDate,
            onDateSelected: (date) {
              setState(() {
                _tripEndDate = date;
                _hasChanges = true;
              });
            },
          ),

          SizedBox(height: 16),

          // Detailed Itinerary
          _buildTextFormField(
            controller: _itineraryController,
            label: 'Detailed Itinerary',
            icon: Icons.map,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your itinerary';
              }
              return null;
            },
          ),

          SizedBox(height: 16),

          // Places to Visit
          _buildPlacesToVisitSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () => _selectDate(context, selectedDate, onDateSelected),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[600]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null
                          ? Colors.black
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesToVisitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Places to Visit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            IconButton(
              onPressed: _addPlace,
              icon: Icon(Icons.add_circle, color: Colors.blue[600]),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (_placesToVisit.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No places added yet. Tap + to add places.',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...List.generate(_placesToVisit.length, (index) {
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.place, color: Colors.blue[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _placesToVisit[index],
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removePlace(index),
                    icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // Helper methods
  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    void Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  void _addPlace() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add Place to Visit'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter place name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _placesToVisit.add(controller.text);
                    _hasChanges = true;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removePlace(int index) {
    setState(() {
      _placesToVisit.removeAt(index);
      _hasChanges = true;
    });
  }

  void _uploadDocument() {
    // TODO: Implement document upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document upload feature coming soon'),
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
                _saveChanges();
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated user data
      final updatedPersonalInfo = PersonalInformation(
        fullName: _nameController.text,
        gender: _selectedGender,
        dateOfBirth: _dateOfBirth ?? DateTime.now(),
        nationality: _nationalityController.text,
        documentType: _selectedDocumentType,
        documentNumber: _documentNumberController.text,
      );

      final updatedTripDetails = TripDetails(
        entryPoint: _entryPointController.text,
        tripStartDate: _tripStartDate ?? DateTime.now(),
        tripEndDate: _tripEndDate ?? DateTime.now(),
        detailedItinerary: _itineraryController.text,
        placesToVisit: _placesToVisit,
      );

      final updatedUserData = widget.userData!.copyWith(
        personalInfo: updatedPersonalInfo,
        tripDetails: updatedTripDetails,
      );

      // Save to service
      final success = await ProfileService.updateUserProfile(updatedUserData);

      if (success) {
        setState(() {
          _hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green[600],
          ),
        );

        Navigator.pop(context, updatedUserData);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
