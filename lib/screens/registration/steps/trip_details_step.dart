import 'package:flutter/material.dart';
import '../../../models/user_models.dart';

class TripDetailsStep extends StatefulWidget {
  final TripDetails? initialData;
  final Function(TripDetails?) onDataChanged;

  const TripDetailsStep({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<TripDetailsStep> createState() => _TripDetailsStepState();
}

class _TripDetailsStepState extends State<TripDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _entryPointController = TextEditingController();
  final _itineraryController = TextEditingController();
  final _placeController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _placesToVisit = [];

  final List<String> _popularEntryPoints = [
    'Delhi - Indira Gandhi International Airport',
    'Mumbai - Chhatrapati Shivaji International Airport',
    'Bangalore - Kempegowda International Airport',
    'Chennai - Chennai International Airport',
    'Kolkata - Netaji Subhas Chandra Bose International Airport',
    'Hyderabad - Rajiv Gandhi International Airport',
    'Goa - Dabolim Airport',
    'Kochi - Cochin International Airport',
    'Ahmedabad - Sardar Vallabhbhai Patel International Airport',
    'Pune - Pune Airport',
    'Land Border - Wagah Border (Pakistan)',
    'Land Border - Nathu La Pass (China)',
    'Seaport - Mumbai Port',
    'Seaport - Chennai Port',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _entryPointController.text = widget.initialData!.entryPoint;
      _startDate = widget.initialData!.tripStartDate;
      _endDate = widget.initialData!.tripEndDate;
      _itineraryController.text = widget.initialData!.detailedItinerary;
      _placesToVisit = List.from(widget.initialData!.placesToVisit);
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
            _buildSectionTitle('Trip Information'),
            SizedBox(height: 16),

            // Entry Point
            _buildEntryPointField(),
            SizedBox(height: 16),

            // Trip Dates
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Start Date',
                    _startDate,
                    _selectStartDate,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateField('End Date', _endDate, _selectEndDate),
                ),
              ],
            ),

            SizedBox(height: 24),
            _buildSectionTitle('Places to Visit'),
            SizedBox(height: 16),

            // Add Places to Visit
            _buildAddPlaceField(),
            SizedBox(height: 16),

            // Places List
            _buildPlacesList(),

            SizedBox(height: 24),
            _buildSectionTitle('Detailed Itinerary'),
            SizedBox(height: 16),

            // Detailed Itinerary
            _buildItineraryField(),

            SizedBox(height: 24),
            _buildTripInfoCard(),
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

  Widget _buildEntryPointField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Entry Point to India *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _entryPointController.text.isEmpty
              ? null
              : _entryPointController.text,
          decoration: InputDecoration(
            hintText: 'Select your entry point to India',
            prefixIcon: Icon(Icons.flight_land, color: Colors.blue[600]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _popularEntryPoints
              .map(
                (point) => DropdownMenuItem(
                  value: point,
                  child: Text(
                    point,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _entryPointController.text = value ?? '';
            });
            _updateData();
          },
          validator: (value) =>
              value == null ? 'Please select entry point' : null,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            child: Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Select $label',
              style: TextStyle(
                color: date != null ? Colors.black87 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPlaceField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _placeController,
            decoration: InputDecoration(
              labelText: 'Add Place to Visit',
              hintText: 'e.g., Taj Mahal, Agra',
              prefixIcon: Icon(Icons.location_on, color: Colors.blue[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onFieldSubmitted: _addPlace,
          ),
        ),
        SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _addPlace(_placeController.text),
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

  Widget _buildPlacesList() {
    if (_placesToVisit.isEmpty) {
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
            Text(
              'Add places you plan to visit during your trip',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _placesToVisit.asMap().entries.map((entry) {
        final index = entry.key;
        final place = entry.value;
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
              Icon(Icons.location_on, color: Colors.blue[600], size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  place,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removePlace(index),
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

  Widget _buildItineraryField() {
    return TextFormField(
      controller: _itineraryController,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: 'Detailed Itinerary *',
        hintText:
            'Describe your planned activities, accommodations, and travel routes...',
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 100),
          child: Icon(Icons.description, color: Colors.blue[600]),
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
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please provide detailed itinerary';
        }
        if (value.trim().length < 50) {
          return 'Please provide more detailed itinerary (minimum 50 characters)';
        }
        return null;
      },
      onChanged: (value) => _updateData(),
    );
  }

  Widget _buildTripInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.green[700]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Trip Planning Tips',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Include specific dates and locations in your itinerary\n'
            '• Mention accommodation details and contact information\n'
            '• Add emergency contact numbers for each location\n'
            '• Include transportation details between cities',
            style: TextStyle(color: Colors.green[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)), // 2 years from now
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue[700]!),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
      _updateData();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _endDate ??
          (_startDate?.add(Duration(days: 7)) ??
              DateTime.now().add(Duration(days: 7))),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blue[700]!),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _updateData();
    }
  }

  void _addPlace(String place) {
    if (place.trim().isNotEmpty && !_placesToVisit.contains(place.trim())) {
      setState(() {
        _placesToVisit.add(place.trim());
        _placeController.clear();
      });
      _updateData();
    }
  }

  void _removePlace(int index) {
    setState(() {
      _placesToVisit.removeAt(index);
    });
    _updateData();
  }

  void _updateData() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_entryPointController.text.isNotEmpty &&
          _startDate != null &&
          _endDate != null &&
          _itineraryController.text.trim().isNotEmpty &&
          _placesToVisit.isNotEmpty) {
        final tripDetails = TripDetails(
          entryPoint: _entryPointController.text,
          tripStartDate: _startDate!,
          tripEndDate: _endDate!,
          detailedItinerary: _itineraryController.text.trim(),
          placesToVisit: _placesToVisit,
        );

        widget.onDataChanged(tripDetails);
      } else {
        widget.onDataChanged(null);
      }
    } else {
      widget.onDataChanged(null);
    }
  }

  @override
  void dispose() {
    _entryPointController.dispose();
    _itineraryController.dispose();
    _placeController.dispose();
    super.dispose();
  }
}
