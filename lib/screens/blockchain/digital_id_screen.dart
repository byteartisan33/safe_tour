// Digital Tourist ID Detail Screen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/blockchain_models.dart';

class DigitalIdScreen extends StatefulWidget {
  final DigitalTouristID digitalId;
  final String selectedLanguage;

  const DigitalIdScreen({
    super.key,
    required this.digitalId,
    required this.selectedLanguage,
  });

  @override
  State<DigitalIdScreen> createState() => _DigitalIdScreenState();
}

class _DigitalIdScreenState extends State<DigitalIdScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Digital Tourist ID',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _getStatusColor(widget.digitalId.status),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _shareDigitalId,
            icon: Icon(Icons.share, color: Colors.white),
            tooltip: 'Share Digital ID',
          ),
          IconButton(
            onPressed: _copyToClipboard,
            icon: Icon(Icons.copy, color: Colors.white),
            tooltip: 'Copy ID',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: [
            Tab(text: 'Identity', icon: Icon(Icons.person)),
            Tab(text: 'Credentials', icon: Icon(Icons.verified)),
            Tab(text: 'Audit Trail', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Digital ID Card
            _buildDigitalIdCard(),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildIdentityTab(),
                  _buildCredentialsTab(),
                  _buildAuditTrailTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalIdCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(widget.digitalId.status),
            _getStatusColor(widget.digitalId.status).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(
              widget.digitalId.status,
            ).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.verified_user, color: Colors.white, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Digital Tourist ID',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getStatusText(widget.digitalId.status),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),

          SizedBox(height: 20),

          // Tourist Information
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.digitalId.touristName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.digitalId.nationality,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${widget.digitalId.documentType}: ${widget.digitalId.documentNumber}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // QR Code
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.qr_code,
                  color: _getStatusColor(widget.digitalId.status),
                  size: 60,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Blockchain Info
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.link, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blockchain Address',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${widget.digitalId.blockchainAddress.substring(0, 20)}...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _copyToClipboard(widget.digitalId.blockchainAddress),
                  icon: Icon(Icons.copy, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Personal Information', Icons.person, [
            _buildInfoRow('Full Name', widget.digitalId.touristName),
            _buildInfoRow('Nationality', widget.digitalId.nationality),
            _buildInfoRow('Document Type', widget.digitalId.documentType),
            _buildInfoRow('Document Number', widget.digitalId.documentNumber),
          ]),

          SizedBox(height: 16),

          _buildInfoCard('Blockchain Details', Icons.link, [
            _buildInfoRow('Digital ID', widget.digitalId.id),
            _buildInfoRow(
              'Blockchain Address',
              widget.digitalId.blockchainAddress,
            ),
            _buildInfoRow(
              'Issued Date',
              _formatDate(widget.digitalId.issuedDate),
            ),
            _buildInfoRow(
              'Expiry Date',
              _formatDate(widget.digitalId.expiryDate),
            ),
            _buildInfoRow('Issuer Authority', widget.digitalId.issuerAuthority),
          ]),
        ],
      ),
    );
  }

  Widget _buildCredentialsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.digitalId.credentials.isEmpty)
            _buildEmptyState(
              Icons.verified,
              'No Credentials',
              'Credentials will appear here as they are added to your Digital ID',
            )
          else
            ...widget.digitalId.credentials.map(
              (credential) => _buildCredentialCard(credential),
            ),
        ],
      ),
    );
  }

  Widget _buildAuditTrailTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.digitalId.auditTrail.isEmpty)
            _buildEmptyState(
              Icons.history,
              'No Audit Trail',
              'Blockchain transaction history will appear here',
            )
          else
            ...widget.digitalId.auditTrail.map(
              (entry) => _buildAuditTrailCard(entry),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600]),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialCard(CredentialRecord credential) {
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
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: credential.isValid ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: credential.isValid
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    credential.isValid ? Icons.verified : Icons.error,
                    color: credential.isValid
                        ? Colors.green[600]
                        : Colors.red[600],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.type,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Issued by ${credential.issuer}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  credential.isValid ? 'Valid' : 'Invalid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: credential.isValid
                        ? Colors.green[600]
                        : Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow('Credential ID', credential.id),
                _buildInfoRow(
                  'Issued Date',
                  _formatDate(credential.issuedDate),
                ),
                if (credential.expiryDate != null)
                  _buildInfoRow(
                    'Expiry Date',
                    _formatDate(credential.expiryDate!),
                  ),
                _buildInfoRow(
                  'Transaction Hash',
                  '${credential.transactionHash.substring(0, 20)}...',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTrailCard(AuditTrailEntry entry) {
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.history, color: Colors.blue[600], size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.action,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'by ${entry.actor}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDateTime(entry.timestamp),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow(
              'Transaction Hash',
              '${entry.transactionHash.substring(0, 20)}...',
            ),
            _buildInfoRow(
              'Block Hash',
              '${entry.blockHash.substring(0, 20)}...',
            ),
            if (entry.details.isNotEmpty)
              ...entry.details.entries.map(
                (detail) => _buildInfoRow(detail.key, detail.value.toString()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Icon(icon, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(widget.digitalId.status),
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            _getStatusText(widget.digitalId.status),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(BlockchainStatus status) {
    switch (status) {
      case BlockchainStatus.verified:
      case BlockchainStatus.active:
        return Colors.green[600]!;
      case BlockchainStatus.pending:
        return Colors.orange[600]!;
      case BlockchainStatus.expired:
      case BlockchainStatus.revoked:
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getStatusIcon(BlockchainStatus status) {
    switch (status) {
      case BlockchainStatus.verified:
      case BlockchainStatus.active:
        return Icons.verified;
      case BlockchainStatus.pending:
        return Icons.hourglass_empty;
      case BlockchainStatus.expired:
        return Icons.error;
      case BlockchainStatus.revoked:
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(BlockchainStatus status) {
    switch (status) {
      case BlockchainStatus.verified:
        return 'Verified';
      case BlockchainStatus.pending:
        return 'Pending';
      case BlockchainStatus.active:
        return 'Active';
      case BlockchainStatus.expired:
        return 'Expired';
      case BlockchainStatus.revoked:
        return 'Revoked';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareDigitalId() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Digital ID sharing feature coming soon'),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  void _copyToClipboard([String? text]) {
    final textToCopy = text ?? widget.digitalId.id;
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: Colors.green[600],
      ),
    );
  }
}
