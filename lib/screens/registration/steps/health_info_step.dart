import 'package:flutter/material.dart';
import '../../../models/user_models.dart';

class HealthInfoStep extends StatefulWidget {
  final HealthInformation? initialData;
  final Function(HealthInformation?) onDataChanged;

  const HealthInfoStep({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<HealthInfoStep> createState() => _HealthInfoStepState();
}

class _HealthInfoStepState extends State<HealthInfoStep> {
  final _emergencyMedicalInfoController = TextEditingController();
  final _conditionController = TextEditingController();
  final _allergyController = TextEditingController();
  final _medicationController = TextEditingController();

  String? _selectedBloodGroup;
  List<String> _medicalConditions = [];
  List<String> _allergies = [];
  List<String> _medications = [];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  final List<String> _commonConditions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'Epilepsy',
    'Kidney Disease',
    'Liver Disease',
    'Thyroid Disorder',
    'Arthritis',
    'Mental Health Condition',
    'Other',
  ];

  final List<String> _commonAllergies = [
    'Food Allergies',
    'Drug Allergies',
    'Pollen',
    'Dust',
    'Pet Dander',
    'Latex',
    'Insect Stings',
    'Shellfish',
    'Nuts',
    'Dairy',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _selectedBloodGroup = widget.initialData!.bloodGroup;
      _medicalConditions = List.from(widget.initialData!.medicalConditions);
      _allergies = List.from(widget.initialData!.allergies);
      _medications = List.from(widget.initialData!.medications);
      _emergencyMedicalInfoController.text =
          widget.initialData!.emergencyMedicalInfo ?? '';
    }
    _updateData(); // Initialize with empty data
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Health Information'),
          SizedBox(height: 8),
          _buildInfoCard(),
          SizedBox(height: 24),

          // Blood Group
          _buildBloodGroupField(),
          SizedBox(height: 24),

          // Medical Conditions
          _buildSectionTitle('Medical Conditions (Optional)'),
          SizedBox(height: 16),
          _buildAddItemField(
            controller: _conditionController,
            hintText: 'Add medical condition',
            suggestions: _commonConditions,
            onAdd: _addMedicalCondition,
          ),
          SizedBox(height: 12),
          _buildItemsList(
            _medicalConditions,
            _removeMedicalCondition,
            'No medical conditions added',
          ),

          SizedBox(height: 24),

          // Allergies
          _buildSectionTitle('Allergies (Optional)'),
          SizedBox(height: 16),
          _buildAddItemField(
            controller: _allergyController,
            hintText: 'Add allergy',
            suggestions: _commonAllergies,
            onAdd: _addAllergy,
          ),
          SizedBox(height: 12),
          _buildItemsList(_allergies, _removeAllergy, 'No allergies added'),

          SizedBox(height: 24),

          // Current Medications
          _buildSectionTitle('Current Medications (Optional)'),
          SizedBox(height: 16),
          _buildAddItemField(
            controller: _medicationController,
            hintText: 'Add medication',
            suggestions: [],
            onAdd: _addMedication,
          ),
          SizedBox(height: 12),
          _buildItemsList(
            _medications,
            _removeMedication,
            'No medications added',
          ),

          SizedBox(height: 24),

          // Emergency Medical Information
          _buildEmergencyMedicalInfoField(),

          SizedBox(height: 24),
          _buildPrivacyCard(),
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
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.health_and_safety, color: Colors.green[700]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Health information is optional but recommended for emergency medical assistance. All information is kept confidential.',
              style: TextStyle(color: Colors.green[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Group (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedBloodGroup,
          decoration: InputDecoration(
            hintText: 'Select your blood group',
            prefixIcon: Icon(Icons.bloodtype, color: Colors.blue[600]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _bloodGroups
              .map(
                (group) => DropdownMenuItem(value: group, child: Text(group)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedBloodGroup = value;
            });
            _updateData();
          },
        ),
      ],
    );
  }

  Widget _buildAddItemField({
    required TextEditingController controller,
    required String hintText,
    required List<String> suggestions,
    required Function(String) onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: suggestions.isNotEmpty
              ? Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return suggestions.where((String option) {
                      return option.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (String selection) {
                    controller.text = selection;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: hintText,
                            prefixIcon: Icon(
                              Icons.add,
                              color: Colors.blue[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blue[700]!,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onFieldSubmitted: (value) => onAdd(value),
                        );
                      },
                )
              : TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    prefixIcon: Icon(Icons.add, color: Colors.blue[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue[700]!,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onFieldSubmitted: onAdd,
                ),
        ),
        SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => onAdd(controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            padding: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildItemsList(
    List<String> items,
    Function(int) onRemove,
    String emptyMessage,
  ) {
    if (items.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            SizedBox(width: 12),
            Text(emptyMessage, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue[600], size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onRemove(index),
                icon: Icon(Icons.close, color: Colors.red[600], size: 20),
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmergencyMedicalInfoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Medical Information (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _emergencyMedicalInfoController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Any critical medical information that emergency responders should know...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.emergency, color: Colors.blue[600]),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            alignLabelWithHint: true,
          ),
          onChanged: (value) => _updateData(),
        ),
      ],
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.purple[700]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Health Data Privacy',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Health information is encrypted and stored securely\n'
            '• Data is only accessible to authorized medical personnel\n'
            '• Information is used solely for emergency medical assistance\n'
            '• You can update or delete this information anytime',
            style: TextStyle(color: Colors.purple[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _addMedicalCondition(String condition) {
    if (condition.trim().isNotEmpty &&
        !_medicalConditions.contains(condition.trim())) {
      setState(() {
        _medicalConditions.add(condition.trim());
        _conditionController.clear();
      });
      _updateData();
    }
  }

  void _addAllergy(String allergy) {
    if (allergy.trim().isNotEmpty && !_allergies.contains(allergy.trim())) {
      setState(() {
        _allergies.add(allergy.trim());
        _allergyController.clear();
      });
      _updateData();
    }
  }

  void _addMedication(String medication) {
    if (medication.trim().isNotEmpty &&
        !_medications.contains(medication.trim())) {
      setState(() {
        _medications.add(medication.trim());
        _medicationController.clear();
      });
      _updateData();
    }
  }

  void _removeMedicalCondition(int index) {
    setState(() {
      _medicalConditions.removeAt(index);
    });
    _updateData();
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
    _updateData();
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
    _updateData();
  }

  void _updateData() {
    // Health information is optional, so we always create a valid object
    final healthInfo = HealthInformation(
      bloodGroup: _selectedBloodGroup,
      medicalConditions: _medicalConditions,
      allergies: _allergies,
      medications: _medications,
      emergencyMedicalInfo: _emergencyMedicalInfoController.text.trim().isEmpty
          ? null
          : _emergencyMedicalInfoController.text.trim(),
    );

    widget.onDataChanged(healthInfo);
  }

  @override
  void dispose() {
    _emergencyMedicalInfoController.dispose();
    _conditionController.dispose();
    _allergyController.dispose();
    _medicationController.dispose();
    super.dispose();
  }
}
