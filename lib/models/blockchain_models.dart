// Blockchain and Digital Identity Models

/// Digital Tourist ID stored on blockchain
class DigitalTouristID {
  final String id;
  final String blockchainAddress;
  final String touristName;
  final String nationality;
  final String documentType;
  final String documentNumber;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String issuerAuthority;
  final BlockchainStatus status;
  final String qrCode;
  final List<CredentialRecord> credentials;
  final List<AuditTrailEntry> auditTrail;

  DigitalTouristID({
    required this.id,
    required this.blockchainAddress,
    required this.touristName,
    required this.nationality,
    required this.documentType,
    required this.documentNumber,
    required this.issuedDate,
    required this.expiryDate,
    required this.issuerAuthority,
    required this.status,
    required this.qrCode,
    required this.credentials,
    required this.auditTrail,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blockchainAddress': blockchainAddress,
      'touristName': touristName,
      'nationality': nationality,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'issuerAuthority': issuerAuthority,
      'status': status.toString(),
      'qrCode': qrCode,
      'credentials': credentials.map((c) => c.toJson()).toList(),
      'auditTrail': auditTrail.map((a) => a.toJson()).toList(),
    };
  }

  factory DigitalTouristID.fromJson(Map<String, dynamic> json) {
    return DigitalTouristID(
      id: json['id'],
      blockchainAddress: json['blockchainAddress'],
      touristName: json['touristName'],
      nationality: json['nationality'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      issuedDate: DateTime.parse(json['issuedDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      issuerAuthority: json['issuerAuthority'],
      status: BlockchainStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      qrCode: json['qrCode'],
      credentials: (json['credentials'] as List)
          .map((c) => CredentialRecord.fromJson(c))
          .toList(),
      auditTrail: (json['auditTrail'] as List)
          .map((a) => AuditTrailEntry.fromJson(a))
          .toList(),
    );
  }
}

/// Blockchain status enumeration
enum BlockchainStatus { pending, verified, active, suspended, expired, revoked }

/// Individual credential record on blockchain
class CredentialRecord {
  final String id;
  final String type;
  final String issuer;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final Map<String, dynamic> data;
  final String transactionHash;
  final bool isValid;

  CredentialRecord({
    required this.id,
    required this.type,
    required this.issuer,
    required this.issuedDate,
    this.expiryDate,
    required this.data,
    required this.transactionHash,
    required this.isValid,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'issuer': issuer,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'data': data,
      'transactionHash': transactionHash,
      'isValid': isValid,
    };
  }

  factory CredentialRecord.fromJson(Map<String, dynamic> json) {
    return CredentialRecord(
      id: json['id'],
      type: json['type'],
      issuer: json['issuer'],
      issuedDate: DateTime.parse(json['issuedDate']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      data: json['data'],
      transactionHash: json['transactionHash'],
      isValid: json['isValid'],
    );
  }
}

/// Blockchain audit trail entry
class AuditTrailEntry {
  final String id;
  final String action;
  final String actor;
  final DateTime timestamp;
  final String transactionHash;
  final String blockHash;
  final Map<String, dynamic> details;

  AuditTrailEntry({
    required this.id,
    required this.action,
    required this.actor,
    required this.timestamp,
    required this.transactionHash,
    required this.blockHash,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'actor': actor,
      'timestamp': timestamp.toIso8601String(),
      'transactionHash': transactionHash,
      'blockHash': blockHash,
      'details': details,
    };
  }

  factory AuditTrailEntry.fromJson(Map<String, dynamic> json) {
    return AuditTrailEntry(
      id: json['id'],
      action: json['action'],
      actor: json['actor'],
      timestamp: DateTime.parse(json['timestamp']),
      transactionHash: json['transactionHash'],
      blockHash: json['blockHash'],
      details: json['details'],
    );
  }
}

/// Blockchain transaction result
class BlockchainTransaction {
  final String transactionHash;
  final String blockHash;
  final int blockNumber;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? errorMessage;
  final Map<String, dynamic> data;

  BlockchainTransaction({
    required this.transactionHash,
    required this.blockHash,
    required this.blockNumber,
    required this.timestamp,
    required this.status,
    this.errorMessage,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionHash': transactionHash,
      'blockHash': blockHash,
      'blockNumber': blockNumber,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(),
      'errorMessage': errorMessage,
      'data': data,
    };
  }

  factory BlockchainTransaction.fromJson(Map<String, dynamic> json) {
    return BlockchainTransaction(
      transactionHash: json['transactionHash'],
      blockHash: json['blockHash'],
      blockNumber: json['blockNumber'],
      timestamp: DateTime.parse(json['timestamp']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      errorMessage: json['errorMessage'],
      data: json['data'],
    );
  }
}

/// Transaction status enumeration
enum TransactionStatus { pending, confirmed, failed, rejected }

/// Blockchain consent record
class BlockchainConsent {
  final String id;
  final String userId;
  final DateTime timestamp;
  final List<String> dataTypes;
  final List<String> purposes;
  final bool isActive;
  final String transactionHash;

  BlockchainConsent({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.dataTypes,
    required this.purposes,
    required this.isActive,
    required this.transactionHash,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'dataTypes': dataTypes,
      'purposes': purposes,
      'isActive': isActive,
      'transactionHash': transactionHash,
    };
  }

  factory BlockchainConsent.fromJson(Map<String, dynamic> json) {
    return BlockchainConsent(
      id: json['id'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      dataTypes: List<String>.from(json['dataTypes']),
      purposes: List<String>.from(json['purposes']),
      isActive: json['isActive'],
      transactionHash: json['transactionHash'],
    );
  }
}
