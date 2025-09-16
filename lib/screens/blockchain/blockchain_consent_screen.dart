// Blockchain Consent Management Screen

import 'package:flutter/material.dart';
import '../../models/blockchain_models.dart';
import '../../services/blockchain_service.dart';

class BlockchainConsentScreen extends StatefulWidget {
  final String selectedLanguage;
  final String userId;

  const BlockchainConsentScreen({
    super.key,
    required this.selectedLanguage,
    required this.userId,
  });

  @override
  State<BlockchainConsentScreen> createState() =>
      _BlockchainConsentScreenState();
}

class _BlockchainConsentScreenState extends State<BlockchainConsentScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final BlockchainService _blockchainService = BlockchainService();

  // Consent categories
  Map<String, bool> _dataTypeConsents = {
    'Personal Information': false,
    'Location Data': false,
    'Travel History': false,
    'Emergency Contacts': false,
    'Health Information': false,
    'Document Images': false,
  };

  Map<String, bool> _purposeConsents = {
    'Identity Verification': false,
    'Safety Monitoring': false,
    'Emergency Response': false,
    'Travel Analytics': false,
    'Service Improvement': false,
    'Legal Compliance': false,
  };

  List<BlockchainConsent> _consentHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadConsentHistory();
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
          'Blockchain Data Consent',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _showConsentInfo,
            icon: Icon(Icons.info, color: Colors.white),
            tooltip: 'Consent Information',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              _buildHeaderInfo(),
              SizedBox(height: 24),

              // Data Types Section
              _buildConsentSection(
                'Data Types',
                'Select which types of data can be stored on blockchain',
                Icons.data_usage,
                _dataTypeConsents,
                (key, value) {
                  setState(() {
                    _dataTypeConsents[key] = value;
                  });
                },
              ),

              SizedBox(height: 24),

              // Purposes Section
              _buildConsentSection(
                'Usage Purposes',
                'Select approved purposes for blockchain data usage',
                Icons.assignment,
                _purposeConsents,
                (key, value) {
                  setState(() {
                    _purposeConsents[key] = value;
                  });
                },
              ),

              SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),

              SizedBox(height: 32),

              // Consent History
              _buildConsentHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.security, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blockchain Data Transparency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Control how your data is used on the blockchain',
                      style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          Text(
            'Your data privacy is our priority. This screen allows you to control exactly what information is stored on the blockchain and for what purposes. All consents are recorded on the blockchain for complete transparency and immutability.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentSection(
    String title,
    String description,
    IconData icon,
    Map<String, bool> consents,
    Function(String, bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Consent Items
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: consents.entries.map((entry) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: entry.value ? Colors.green[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: entry.value
                          ? Colors.green[200]!
                          : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Switch(
                        value: entry.value,
                        onChanged: (value) => onChanged(entry.key, value),
                        activeColor: Colors.green[600],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Consent Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveConsent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text(
                        'Save Consent to Blockchain',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: 12),

        // Revoke All Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _revokeAllConsent,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[600],
              side: BorderSide(color: Colors.red[600]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block),
                SizedBox(width: 8),
                Text(
                  'Revoke All Consent',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsentHistory() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.grey[600], size: 24),
                SizedBox(width: 12),
                Text(
                  'Consent History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: _consentHistory.isEmpty
                ? _buildEmptyHistory()
                : Column(
                    children: _consentHistory
                        .map((consent) => _buildConsentHistoryItem(consent))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.history, size: 48, color: Colors.grey[400]),
          SizedBox(height: 12),
          Text(
            'No Consent History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Your blockchain consent history will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentHistoryItem(BlockchainConsent consent) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: consent.isActive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: consent.isActive ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                consent.isActive ? Icons.check_circle : Icons.cancel,
                color: consent.isActive ? Colors.green[600] : Colors.red[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  consent.isActive ? 'Active Consent' : 'Revoked Consent',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: consent.isActive
                        ? Colors.green[800]
                        : Colors.red[800],
                  ),
                ),
              ),
              Text(
                _formatDateTime(consent.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            'Data Types: ${consent.dataTypes.join(', ')}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),

          SizedBox(height: 4),

          Text(
            'Purposes: ${consent.purposes.join(', ')}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.link, size: 14, color: Colors.grey[500]),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'TX: ${consent.transactionHash.substring(0, 20)}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Methods
  void _loadConsentHistory() async {
    // TODO: Load consent history from blockchain
    setState(() {
      _consentHistory = [];
    });
  }

  void _saveConsent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final approvedDataTypes = _dataTypeConsents.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final approvedPurposes = _purposeConsents.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (approvedDataTypes.isEmpty || approvedPurposes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select at least one data type and purpose'),
            backgroundColor: Colors.orange[600],
          ),
        );
        return;
      }

      final consent = await _blockchainService.recordConsent(
        widget.userId,
        approvedDataTypes,
        approvedPurposes,
      );

      if (consent != null) {
        setState(() {
          _consentHistory.insert(0, consent);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consent recorded on blockchain successfully'),
            backgroundColor: Colors.green[600],
          ),
        );
      } else {
        throw Exception('Failed to record consent');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording consent: $e'),
          backgroundColor: Colors.red[600],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _revokeAllConsent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Revoke All Consent'),
        content: Text(
          'Are you sure you want to revoke all blockchain data consent? '
          'This will be recorded on the blockchain and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRevokeAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Revoke All'),
          ),
        ],
      ),
    );
  }

  void _performRevokeAll() async {
    setState(() {
      _dataTypeConsents.updateAll((key, value) => false);
      _purposeConsents.updateAll((key, value) => false);
    });

    // Record revocation on blockchain
    final consent = await _blockchainService.recordConsent(
      widget.userId,
      [],
      [],
    );

    if (consent != null) {
      setState(() {
        _consentHistory.insert(0, consent);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All consent revoked and recorded on blockchain'),
        backgroundColor: Colors.orange[600],
      ),
    );
  }

  void _showConsentInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Blockchain Consent Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is Blockchain Consent?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Blockchain consent provides transparent, immutable records of your data usage permissions. '
                'Every consent decision is recorded on the blockchain, ensuring complete transparency and accountability.',
              ),
              SizedBox(height: 16),
              Text(
                'Your Rights:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• View all consent history\n'
                '• Modify consent at any time\n'
                '• Revoke consent completely\n'
                '• Audit trail of all changes\n'
                '• Tamper-proof records',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
