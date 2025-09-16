import 'package:flutter/material.dart';
import '../../../models/user_models.dart';

class PersonalInfoStep extends StatefulWidget {
  final PersonalInformation? initialData;
  final Function(PersonalInformation?) onDataChanged;

  const PersonalInfoStep({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _documentNumberController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDate;
  String? _selectedNationality;
  String _selectedDocumentType = 'passport';

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _nationalities = [
    'Indian',
    'American',
    'British',
    'Canadian',
    'Australian',
    'German',
    'French',
    'Japanese',
    'Chinese',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _fullNameController.text = widget.initialData!.fullName;
      _selectedGender = widget.initialData!.gender;
      _selectedDate = widget.initialData!.dateOfBirth;
      _selectedNationality = widget.initialData!.nationality;
      _selectedDocumentType = widget.initialData!.documentType;
      _documentNumberController.text = widget.initialData!.documentNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Personal Details'),
            SizedBox(height: 16),

            // Full Name
            _buildTextFormField(
              controller: _fullNameController,
              label: 'Full Name *',
              hint: 'Enter your full name as per passport/Aadhaar',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Gender
            _buildDropdownField(
              label: 'Gender *',
              value: _selectedGender,
              items: _genders,
              icon: Icons.wc,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
                _updateData();
              },
            ),

            SizedBox(height: 16),

            // Date of Birth
            _buildDateField(),

            SizedBox(height: 16),

            // Nationality
            _buildDropdownField(
              label: 'Nationality *',
              value: _selectedNationality,
              items: _nationalities,
              icon: Icons.flag,
              onChanged: (value) {
                setState(() {
                  _selectedNationality = value;
                });
                _updateData();
              },
            ),

            SizedBox(height: 24),
            _buildSectionTitle('Identity Document'),
            SizedBox(height: 16),

            // Document Type
            _buildDocumentTypeSelector(),

            SizedBox(height: 16),

            // Document Number
            _buildTextFormField(
              controller: _documentNumberController,
              label:
                  '${_selectedDocumentType == 'passport' ? 'Passport' : 'Aadhaar'} Number *',
              hint: _selectedDocumentType == 'passport'
                  ? 'Enter passport number'
                  : 'Enter 12-digit Aadhaar number',
              icon: Icons.credit_card,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Document number is required';
                }
                if (_selectedDocumentType == 'aadhaar') {
                  if (value.length != 12 ||
                      !RegExp(r'^\d{12}$').hasMatch(value)) {
                    return 'Aadhaar number must be 12 digits';
                  }
                } else {
                  if (value.length < 6) {
                    return 'Passport number must be at least 6 characters';
                  }
                }
                return null;
              },
            ),

            SizedBox(height: 24),
            _buildInfoCard(),
          ],
        ),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      onChanged: (value) => _updateData(),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth *',
          prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'Select date of birth',
          style: TextStyle(
            color: _selectedDate != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDocumentTypeCard('passport', 'Passport', Icons.book),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDocumentTypeCard(
                'aadhaar',
                'Aadhaar',
                Icons.credit_card,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentTypeCard(String type, String label, IconData icon) {
    final isSelected = _selectedDocumentType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDocumentType = type;
          _documentNumberController.clear();
        });
        _updateData();
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue[700] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your personal information will be securely stored and used for identity verification and emergency purposes only.',
              style: TextStyle(color: Colors.blue[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(
        Duration(days: 6570),
      ), // Must be at least 18
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue[700]!),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateData();
    }
  }

  void _updateData() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_fullNameController.text.isNotEmpty &&
          _selectedGender != null &&
          _selectedDate != null &&
          _selectedNationality != null &&
          _documentNumberController.text.isNotEmpty) {
        final personalInfo = PersonalInformation(
          fullName: _fullNameController.text.trim(),
          gender: _selectedGender!,
          dateOfBirth: _selectedDate!,
          nationality: _selectedNationality!,
          documentType: _selectedDocumentType,
          documentNumber: _documentNumberController.text.trim(),
        );

        widget.onDataChanged(personalInfo);
      } else {
        widget.onDataChanged(null);
      }
    } else {
      widget.onDataChanged(null);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }
}
