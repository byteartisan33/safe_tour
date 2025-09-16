# 🔗 Blockchain Backend Setup Guide
## Real-time Hyperledger Network Integration

This guide provides comprehensive instructions for setting up the backend infrastructure to connect your Smart Tourist Safety App with a real Hyperledger blockchain network.

## 📋 Prerequisites

### 1. System Requirements
- **Node.js** v16+ and npm
- **Docker** and Docker Compose
- **Go** v1.19+ (for Hyperledger Fabric)
- **Python** 3.8+ (for blockchain APIs)
- **PostgreSQL** or **MongoDB** (for off-chain data)

### 2. Hyperledger Fabric Network
```bash
# Install Hyperledger Fabric binaries
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.4.7 1.5.2

# Set environment variables
export PATH=$PATH:$PWD/fabric-samples/bin
export FABRIC_CFG_PATH=$PWD/fabric-samples/config
```

## 🏗️ Backend Architecture

### 1. Network Components
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   API Gateway   │    │ Hyperledger     │
│                 │◄──►│                 │◄──►│ Fabric Network  │
│ Digital Tourist │    │ REST/WebSocket  │    │                 │
│ ID Management   │    │ Authentication  │    │ Smart Contracts │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         │              │   Database      │              │
         └──────────────►│ PostgreSQL/     │◄─────────────┘
                        │ MongoDB         │
                        │ Off-chain Data  │
                        └─────────────────┘
```

### 2. Smart Contract (Chaincode) Structure
```go
// tourist-identity-chaincode/main.go
package main

import (
    "encoding/json"
    "fmt"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type TouristIdentityContract struct {
    contractapi.Contract
}

type DigitalTouristID struct {
    ID              string   `json:"id"`
    UserID          string   `json:"userId"`
    BlockchainAddr  string   `json:"blockchainAddress"`
    PersonalInfo    string   `json:"personalInfo"`
    Credentials     []string `json:"credentials"`
    IssuedAt        string   `json:"issuedAt"`
    ExpiresAt       string   `json:"expiresAt"`
    Status          string   `json:"status"`
}

func (t *TouristIdentityContract) IssueDigitalID(ctx contractapi.TransactionContextInterface, 
    id string, userId string, personalInfo string) error {
    
    digitalID := DigitalTouristID{
        ID:             id,
        UserID:         userId,
        PersonalInfo:   personalInfo,
        Credentials:    []string{},
        IssuedAt:       time.Now().Format(time.RFC3339),
        Status:         "active",
    }
    
    digitalIDJSON, err := json.Marshal(digitalID)
    if err != nil {
        return err
    }
    
    return ctx.GetStub().PutState(id, digitalIDJSON)
}

func (t *TouristIdentityContract) GetDigitalID(ctx contractapi.TransactionContextInterface, 
    id string) (*DigitalTouristID, error) {
    
    digitalIDJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return nil, fmt.Errorf("failed to read from world state: %v", err)
    }
    
    var digitalID DigitalTouristID
    err = json.Unmarshal(digitalIDJSON, &digitalID)
    if err != nil {
        return nil, err
    }
    
    return &digitalID, nil
}
```

## 🚀 Backend API Server Setup

### 1. Node.js Express Server
```javascript
// server/app.js
const express = require('express');
const WebSocket = require('ws');
const { Gateway, Wallets } = require('fabric-network');
const path = require('path');

const app = express();
const server = require('http').createServer(app);
const wss = new WebSocket.Server({ server });

// Middleware
app.use(express.json());
app.use(cors());

// Hyperledger Fabric connection
async function connectToFabric() {
    const ccpPath = path.resolve(__dirname, 'connection-profile.json');
    const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));
    
    const walletPath = path.join(process.cwd(), 'wallet');
    const wallet = await Wallets.newFileSystemWallet(walletPath);
    
    const gateway = new Gateway();
    await gateway.connect(ccp, {
        wallet,
        identity: 'appUser',
        discovery: { enabled: true, asLocalhost: true }
    });
    
    return gateway;
}

// API Routes
app.post('/api/digital-id/issue', async (req, res) => {
    try {
        const gateway = await connectToFabric();
        const network = await gateway.getNetwork('tourist-channel');
        const contract = network.getContract('tourist-identity');
        
        const result = await contract.submitTransaction(
            'IssueDigitalID',
            req.body.id,
            req.body.userId,
            JSON.stringify(req.body.personalInfo)
        );
        
        // Broadcast to WebSocket clients
        broadcastToClients({
            type: 'digital_id_issued',
            data: JSON.parse(result.toString())
        });
        
        res.json({ success: true, data: JSON.parse(result.toString()) });
        
        await gateway.disconnect();
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/digital-id/:id', async (req, res) => {
    try {
        const gateway = await connectToFabric();
        const network = await gateway.getNetwork('tourist-channel');
        const contract = network.getContract('tourist-identity');
        
        const result = await contract.evaluateTransaction('GetDigitalID', req.params.id);
        
        res.json({ success: true, data: JSON.parse(result.toString()) });
        
        await gateway.disconnect();
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// WebSocket for real-time updates
wss.on('connection', (ws) => {
    console.log('Client connected');
    
    ws.on('message', (message) => {
        const data = JSON.parse(message);
        console.log('Received:', data);
    });
    
    ws.on('close', () => {
        console.log('Client disconnected');
    });
});

function broadcastToClients(data) {
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(data));
        }
    });
}

server.listen(3000, () => {
    console.log('Blockchain API server running on port 3000');
});
```

### 2. Connection Profile Configuration
```json
// connection-profile.json
{
    "name": "tourist-network",
    "version": "1.0.0",
    "client": {
        "organization": "TouristOrg",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300"
                }
            }
        }
    },
    "organizations": {
        "TouristOrg": {
            "mspid": "TouristOrgMSP",
            "peers": ["peer0.touristorg.example.com"],
            "certificateAuthorities": ["ca.touristorg.example.com"]
        }
    },
    "peers": {
        "peer0.touristorg.example.com": {
            "url": "grpcs://localhost:7051",
            "tlsCACerts": {
                "path": "crypto-config/peerOrganizations/touristorg.example.com/tlsca/tlsca.touristorg.example.com-cert.pem"
            },
            "grpcOptions": {
                "ssl-target-name-override": "peer0.touristorg.example.com"
            }
        }
    },
    "certificateAuthorities": {
        "ca.touristorg.example.com": {
            "url": "https://localhost:7054",
            "caName": "ca-touristorg",
            "tlsCACerts": {
                "path": "crypto-config/peerOrganizations/touristorg.example.com/ca/ca.touristorg.example.com-cert.pem"
            }
        }
    }
}
```

## 🔄 Real-time Integration

### 1. Flutter WebSocket Client
```dart
// lib/services/websocket_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Stream<dynamic>? _stream;

  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _stream = _channel!.stream.asBroadcastStream();
      
      print('WebSocket connected to $url');
    } catch (e) {
      print('WebSocket connection error: $e');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  Stream<dynamic>? get stream => _stream;

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _stream = null;
  }
}
```

### 2. Update Blockchain Service for Real Network
```dart
// Update lib/services/blockchain_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'websocket_service.dart';

class BlockchainService {
  static const String API_BASE_URL = 'https://your-api-server.com/api';
  static const String WS_URL = 'wss://your-api-server.com/ws';
  
  final WebSocketService _wsService = WebSocketService();
  
  Future<bool> initialize() async {
    try {
      // Connect to WebSocket for real-time updates
      await _wsService.connect(WS_URL);
      
      // Listen for blockchain events
      _wsService.stream?.listen((data) {
        final message = jsonDecode(data);
        _handleBlockchainEvent(message);
      });
      
      _isConnected = true;
      return true;
    } catch (e) {
      print('Blockchain initialization error: $e');
      return false;
    }
  }

  Future<DigitalTouristID?> issueDigitalTouristID(UserData userData) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/digital-id/issue'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': _generateId(),
          'userId': userData.personalInfo.fullName,
          'personalInfo': userData.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DigitalTouristID.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error issuing digital ID: $e');
      return null;
    }
  }

  void _handleBlockchainEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'digital_id_issued':
        _digitalIdController.add(DigitalTouristID.fromJson(event['data']));
        break;
      case 'credential_updated':
        // Handle credential updates
        break;
      case 'consent_recorded':
        // Handle consent updates
        break;
    }
  }
}
```

## 🐳 Docker Deployment

### 1. Docker Compose Configuration
```yaml
# docker-compose.yml
version: '3.8'

services:
  api-server:
    build: ./server
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - DB_PORT=5432
    depends_on:
      - postgres
      - fabric-peer

  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: tourist_blockchain
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  fabric-peer:
    image: hyperledger/fabric-peer:2.4.7
    environment:
      - CORE_PEER_ID=peer0.touristorg.example.com
      - CORE_PEER_ADDRESS=peer0.touristorg.example.com:7051
      - CORE_PEER_LOCALMSPID=TouristOrgMSP
    volumes:
      - ./crypto-config:/etc/hyperledger/fabric/crypto-config
    ports:
      - "7051:7051"

volumes:
  postgres_data:
```

## 🔐 Security Configuration

### 1. Authentication & Authorization
```javascript
// server/middleware/auth.js
const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.sendStatus(401);
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
};

module.exports = { authenticateToken };
```

### 2. Environment Variables
```bash
# .env
NODE_ENV=production
JWT_SECRET=your-super-secure-jwt-secret
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tourist_blockchain
DB_USER=admin
DB_PASSWORD=secure_password

FABRIC_NETWORK_URL=grpcs://localhost:7051
FABRIC_CA_URL=https://localhost:7054
FABRIC_WALLET_PATH=./wallet
FABRIC_USER_ID=appUser
```

## 📊 Monitoring & Analytics

### 1. Blockchain Transaction Monitoring
```javascript
// server/services/monitoring.js
const { Gateway } = require('fabric-network');

class BlockchainMonitor {
    async startMonitoring() {
        const gateway = await connectToFabric();
        const network = await gateway.getNetwork('tourist-channel');
        
        // Listen for block events
        const listener = await network.addBlockListener(
            'block-listener',
            (error, block) => {
                if (error) {
                    console.error('Block listener error:', error);
                    return;
                }
                
                console.log(`New block: ${block.header.number}`);
                this.processBlockTransactions(block);
            }
        );
    }

    processBlockTransactions(block) {
        block.data.data.forEach((transaction, index) => {
            // Process each transaction
            console.log(`Transaction ${index}:`, transaction);
        });
    }
}
```

## 🚀 Deployment Steps

### 1. Local Development
```bash
# 1. Start Hyperledger Fabric network
cd fabric-samples/test-network
./network.sh up createChannel -ca

# 2. Deploy chaincode
./network.sh deployCC -ccn tourist-identity -ccp ../chaincode/tourist-identity -ccl go

# 3. Start API server
cd ../../server
npm install
npm start

# 4. Run Flutter app
cd ../flutter-app
flutter run -d chrome
```

### 2. Production Deployment
```bash
# 1. Build and deploy with Docker
docker-compose up -d

# 2. Initialize blockchain network
docker exec -it fabric-peer peer chaincode invoke \
  -o orderer.example.com:7050 \
  -C tourist-channel \
  -n tourist-identity \
  -c '{"function":"InitLedger","Args":[]}'

# 3. Verify deployment
curl https://your-api-server.com/api/health
```

## 📱 Flutter App Configuration

Update your Flutter app's blockchain service to use the real backend:

```dart
// lib/config/blockchain_config.dart
class BlockchainConfig {
  static const String API_BASE_URL = 'https://your-api-server.com/api';
  static const String WS_URL = 'wss://your-api-server.com/ws';
  static const bool USE_MOCK_DATA = false; // Set to false for production
}
```

## ✅ Testing & Validation

### 1. Integration Tests
```bash
# Test API endpoints
curl -X POST https://your-api-server.com/api/digital-id/issue \
  -H "Content-Type: application/json" \
  -d '{"userId":"test-user","personalInfo":{"name":"Test User"}}'

# Test WebSocket connection
wscat -c wss://your-api-server.com/ws
```

### 2. Load Testing
```bash
# Install artillery for load testing
npm install -g artillery

# Run load tests
artillery run load-test-config.yml
```

This comprehensive setup guide provides everything needed to connect your Smart Tourist Safety App to a real Hyperledger blockchain network with real-time capabilities!
