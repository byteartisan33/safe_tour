// Blockchain Service for Hyperledger Integration

import 'dart:async';
import 'dart:math';
import '../models/blockchain_models.dart';
import '../models/user_models.dart';

class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  // Stream controllers for real-time updates
  final StreamController<DigitalTouristID> _digitalIdController =
      StreamController<DigitalTouristID>.broadcast();
  final StreamController<BlockchainTransaction> _transactionController =
      StreamController<BlockchainTransaction>.broadcast();
  final StreamController<List<AuditTrailEntry>> _auditTrailController =
      StreamController<List<AuditTrailEntry>>.broadcast();

  // Getters for streams
  Stream<DigitalTouristID> get digitalIdStream => _digitalIdController.stream;
  Stream<BlockchainTransaction> get transactionStream =>
      _transactionController.stream;
  Stream<List<AuditTrailEntry>> get auditTrailStream =>
      _auditTrailController.stream;

  // Current state
  DigitalTouristID? _currentDigitalId;
  final List<BlockchainTransaction> _transactionHistory = [];
  bool _isConnected = false;

  // Hyperledger connection configuration
  final String _networkUrl = 'https://api.hyperledger-network.example.com';
  final String _channelName = 'tourist-channel';
  final String _chaincodeName = 'tourist-identity';

  /// Initialize blockchain connection
  Future<bool> initialize() async {
    try {
      print('Initializing blockchain connection...');

      // Simulate connection to Hyperledger network
      await Future.delayed(Duration(seconds: 2));

      _isConnected = true;
      print('Blockchain connection established');

      // Start real-time monitoring
      _startRealTimeMonitoring();

      return true;
    } catch (e) {
      print('Failed to initialize blockchain: $e');
      return false;
    }
  }

  /// Issue new Digital Tourist ID on blockchain
  Future<DigitalTouristID?> issueDigitalTouristID(
    UserRegistrationData userData,
  ) async {
    try {
      print('Issuing Digital Tourist ID on blockchain...');

      // Generate blockchain address
      final blockchainAddress = _generateBlockchainAddress();

      // Create digital ID
      final digitalId = DigitalTouristID(
        id: _generateUniqueId(),
        blockchainAddress: blockchainAddress,
        touristName: userData.personalInfo.fullName,
        nationality: userData.personalInfo.nationality,
        documentType: userData.personalInfo.documentType,
        documentNumber: userData.personalInfo.documentNumber,
        issuedDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 365)),
        issuerAuthority: 'Digital Tourism Authority',
        status: BlockchainStatus.pending,
        qrCode: _generateQRCode(blockchainAddress),
        credentials: [],
        auditTrail: [],
      );

      // Submit to blockchain (simulated)
      final transaction = await _submitToBlockchain(
        'issueDigitalID',
        digitalId.toJson(),
      );

      if (transaction.status == TransactionStatus.confirmed) {
        // Update status to verified
        final verifiedId = DigitalTouristID(
          id: digitalId.id,
          blockchainAddress: digitalId.blockchainAddress,
          touristName: digitalId.touristName,
          nationality: digitalId.nationality,
          documentType: digitalId.documentType,
          documentNumber: digitalId.documentNumber,
          issuedDate: digitalId.issuedDate,
          expiryDate: digitalId.expiryDate,
          issuerAuthority: digitalId.issuerAuthority,
          status: BlockchainStatus.verified,
          qrCode: digitalId.qrCode,
          credentials: digitalId.credentials,
          auditTrail: [
            AuditTrailEntry(
              id: _generateUniqueId(),
              action: 'Digital ID Issued',
              actor: 'System',
              timestamp: DateTime.now(),
              transactionHash: transaction.transactionHash,
              blockHash: transaction.blockHash,
              details: {'issuer': 'Digital Tourism Authority'},
            ),
          ],
        );

        _currentDigitalId = verifiedId;
        _digitalIdController.add(verifiedId);

        print('Digital Tourist ID issued successfully');
        return verifiedId;
      }

      return null;
    } catch (e) {
      print('Failed to issue Digital Tourist ID: $e');
      return null;
    }
  }

  /// Validate Digital Tourist ID
  Future<bool> validateDigitalID(String digitalIdAddress) async {
    try {
      print('Validating Digital Tourist ID: $digitalIdAddress');

      // Query blockchain for ID validation
      await Future.delayed(Duration(seconds: 1));

      // Simulate validation result
      final isValid =
          digitalIdAddress.isNotEmpty && digitalIdAddress.length > 10;

      if (isValid) {
        // Add audit trail entry
        await _addAuditTrailEntry('ID Validated', 'Validation Service', {
          'validatedBy': 'System',
          'result': 'Valid',
        });
      }

      return isValid;
    } catch (e) {
      print('Failed to validate Digital ID: $e');
      return false;
    }
  }

  /// Add credential to Digital Tourist ID
  Future<bool> addCredential(
    String credentialType,
    String issuer,
    Map<String, dynamic> credentialData,
  ) async {
    try {
      if (_currentDigitalId == null) return false;

      print('Adding credential: $credentialType');

      final credential = CredentialRecord(
        id: _generateUniqueId(),
        type: credentialType,
        issuer: issuer,
        issuedDate: DateTime.now(),
        expiryDate: DateTime.now().add(Duration(days: 90)),
        data: credentialData,
        transactionHash: _generateTransactionHash(),
        isValid: true,
      );

      // Submit to blockchain
      final transaction = await _submitToBlockchain(
        'addCredential',
        credential.toJson(),
      );

      if (transaction.status == TransactionStatus.confirmed) {
        // Update current digital ID
        final updatedCredentials = List<CredentialRecord>.from(
          _currentDigitalId!.credentials,
        )..add(credential);

        final updatedId = DigitalTouristID(
          id: _currentDigitalId!.id,
          blockchainAddress: _currentDigitalId!.blockchainAddress,
          touristName: _currentDigitalId!.touristName,
          nationality: _currentDigitalId!.nationality,
          documentType: _currentDigitalId!.documentType,
          documentNumber: _currentDigitalId!.documentNumber,
          issuedDate: _currentDigitalId!.issuedDate,
          expiryDate: _currentDigitalId!.expiryDate,
          issuerAuthority: _currentDigitalId!.issuerAuthority,
          status: _currentDigitalId!.status,
          qrCode: _currentDigitalId!.qrCode,
          credentials: updatedCredentials,
          auditTrail: _currentDigitalId!.auditTrail,
        );

        _currentDigitalId = updatedId;
        _digitalIdController.add(updatedId);

        await _addAuditTrailEntry('Credential Added', issuer, {
          'credentialType': credentialType,
          'transactionHash': transaction.transactionHash,
        });

        return true;
      }

      return false;
    } catch (e) {
      print('Failed to add credential: $e');
      return false;
    }
  }

  /// Record blockchain consent
  Future<BlockchainConsent?> recordConsent(
    String userId,
    List<String> dataTypes,
    List<String> purposes,
  ) async {
    try {
      print('Recording blockchain consent...');

      final consent = BlockchainConsent(
        id: _generateUniqueId(),
        userId: userId,
        timestamp: DateTime.now(),
        dataTypes: dataTypes,
        purposes: purposes,
        isActive: true,
        transactionHash: _generateTransactionHash(),
      );

      // Submit to blockchain
      final transaction = await _submitToBlockchain(
        'recordConsent',
        consent.toJson(),
      );

      if (transaction.status == TransactionStatus.confirmed) {
        await _addAuditTrailEntry('Consent Recorded', 'User', {
          'consentId': consent.id,
          'dataTypes': dataTypes.join(', '),
        });

        return consent;
      }

      return null;
    } catch (e) {
      print('Failed to record consent: $e');
      return null;
    }
  }

  /// Get current Digital Tourist ID
  DigitalTouristID? getCurrentDigitalID() {
    return _currentDigitalId;
  }

  /// Get transaction history
  List<BlockchainTransaction> getTransactionHistory() {
    return List.unmodifiable(_transactionHistory);
  }

  /// Check if blockchain is connected
  bool isConnected() {
    return _isConnected;
  }

  /// Private helper methods

  String _generateBlockchainAddress() {
    final random = Random();
    final bytes = List<int>.generate(20, (i) => random.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  String _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(10000).toString();
  }

  String _generateQRCode(String address) {
    return 'TOURIST_ID:$address:${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateTransactionHash() {
    final random = Random();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<BlockchainTransaction> _submitToBlockchain(
    String operation,
    Map<String, dynamic> data,
  ) async {
    // Simulate blockchain transaction
    await Future.delayed(Duration(seconds: 2));

    final transaction = BlockchainTransaction(
      transactionHash: _generateTransactionHash(),
      blockHash: _generateTransactionHash(),
      blockNumber: Random().nextInt(1000000) + 1000000,
      timestamp: DateTime.now(),
      status: TransactionStatus.confirmed,
      data: data,
    );

    _transactionHistory.add(transaction);
    _transactionController.add(transaction);

    return transaction;
  }

  Future<void> _addAuditTrailEntry(
    String action,
    String actor,
    Map<String, dynamic> details,
  ) async {
    if (_currentDigitalId == null) return;

    final entry = AuditTrailEntry(
      id: _generateUniqueId(),
      action: action,
      actor: actor,
      timestamp: DateTime.now(),
      transactionHash: _generateTransactionHash(),
      blockHash: _generateTransactionHash(),
      details: details,
    );

    final updatedAuditTrail = List<AuditTrailEntry>.from(
      _currentDigitalId!.auditTrail,
    )..add(entry);

    _auditTrailController.add(updatedAuditTrail);
  }

  void _startRealTimeMonitoring() {
    // Simulate real-time blockchain monitoring
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected && _currentDigitalId != null) {
        // Simulate periodic status updates
        print('Monitoring blockchain for updates...');
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _digitalIdController.close();
    _transactionController.close();
    _auditTrailController.close();
  }
}
