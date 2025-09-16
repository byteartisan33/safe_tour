import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_models.dart';

class KYCDocumentsStep extends StatefulWidget {
  final KYCDocuments? initialData;
  final Function(KYCDocuments?) onDataChanged;

  const KYCDocumentsStep({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<KYCDocumentsStep> createState() => _KYCDocumentsStepState();
}

class _KYCDocumentsStepState extends State<KYCDocumentsStep> {
  final ImagePicker _picker = ImagePicker();

  String? _passportImagePath;
  String? _aadhaarFrontPath;
  String? _aadhaarBackPath;
  String _selectedDocumentType = 'passport';

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _passportImagePath = widget.initialData!.passportImagePath;
      _aadhaarFrontPath = widget.initialData!.aadhaarFrontPath;
      _aadhaarBackPath = widget.initialData!.aadhaarBackPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Upload KYC Documents'),
          SizedBox(height: 8),
          _buildInfoCard(),
          SizedBox(height: 24),

          // Document Type Selector
          _buildDocumentTypeSelector(),
          SizedBox(height: 24),

          // Document Upload Section
          if (_selectedDocumentType == 'passport')
            _buildPassportUploadSection()
          else
            _buildAadhaarUploadSection(),

          SizedBox(height: 24),
          _buildSecurityInfo(),
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
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please upload clear, high-quality images of your identity documents. Ensure all text is readable and the document is not expired.',
              style: TextStyle(color: Colors.amber[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Document Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDocumentTypeCard(
                'passport',
                'Passport',
                Icons.book,
                'Upload passport photo page',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildDocumentTypeCard(
                'aadhaar',
                'Aadhaar Card',
                Icons.credit_card,
                'Upload front & back sides',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentTypeCard(
    String type,
    String label,
    IconData icon,
    String description,
  ) {
    final isSelected = _selectedDocumentType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDocumentType = type;
          // Clear previous uploads when switching document type
          _passportImagePath = null;
          _aadhaarFrontPath = null;
          _aadhaarBackPath = null;
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
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passport Photo Page *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        _buildImageUploadCard(
          title: 'Upload Passport Photo Page',
          description: 'Clear photo of the page with your photo and details',
          imagePath: _passportImagePath,
          onTap: () => _pickImage('passport'),
        ),
      ],
    );
  }

  Widget _buildAadhaarUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aadhaar Card Images *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        _buildImageUploadCard(
          title: 'Upload Aadhaar Front Side',
          description: 'Front side with photo and details',
          imagePath: _aadhaarFrontPath,
          onTap: () => _pickImage('aadhaar_front'),
        ),
        SizedBox(height: 16),
        _buildImageUploadCard(
          title: 'Upload Aadhaar Back Side',
          description: 'Back side with address details',
          imagePath: _aadhaarBackPath,
          onTap: () => _pickImage('aadhaar_back'),
        ),
      ],
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required String description,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    final hasImage = imagePath != null;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasImage ? Colors.green[50] : Colors.grey[50],
          border: Border.all(
            color: hasImage ? Colors.green[300]! : Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (hasImage) ...[
              // Show uploaded image preview (for web, we'll show a placeholder)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Image Uploaded',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to change',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Colors.grey[600],
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tap to Upload',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.blue[700]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Document Security',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Your documents are encrypted and stored securely\n'
            '• Images are used only for identity verification\n'
            '• Documents are processed using blockchain technology\n'
            '• You can delete your documents anytime from settings',
            style: TextStyle(color: Colors.blue[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(String documentType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          switch (documentType) {
            case 'passport':
              _passportImagePath = image.path;
              break;
            case 'aadhaar_front':
              _aadhaarFrontPath = image.path;
              break;
            case 'aadhaar_back':
              _aadhaarBackPath = image.path;
              break;
          }
        });
        _updateData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document uploaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _updateData() {
    bool hasRequiredDocuments = false;

    if (_selectedDocumentType == 'passport') {
      hasRequiredDocuments = _passportImagePath != null;
    } else {
      hasRequiredDocuments =
          _aadhaarFrontPath != null && _aadhaarBackPath != null;
    }

    if (hasRequiredDocuments) {
      final kycDocuments = KYCDocuments(
        passportImagePath: _passportImagePath,
        aadhaarFrontPath: _aadhaarFrontPath,
        aadhaarBackPath: _aadhaarBackPath,
        isVerified: false, // Will be verified by backend
      );
      widget.onDataChanged(kycDocuments);
    } else {
      widget.onDataChanged(null);
    }
  }
}
