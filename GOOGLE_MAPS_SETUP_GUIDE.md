# Google Maps Integration Setup Guide
## Smart Tourist Safety App - Real-World Mapping & Location Services

This guide will help you set up Google Maps Platform integration for your Smart Tourist Safety App with the provided API key.

## 🔑 **API Key Information**
- **Google Maps API Key**: `AIzaSyBwYP-T4OrdoXoaOBMtEA1nzlm0R6wSiXY`
- **Project ID**: `safetourgit-91468817`
- **Project Name**: Safe Tour Git

## 📋 **Prerequisites**

### 1. Google Cloud Console Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project `safetourgit-91468817` or create if it doesn't exist
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Maps JavaScript API
   - Places API
   - Geocoding API
   - Directions API
   - Distance Matrix API

### 2. API Key Configuration
Your API key is already configured in the app at:
- `lib/config/firebase_config.dart`
- Google Maps API Key: `AIzaSyBwYP-T4OrdoXoaOBMtEA1nzlm0R6wSiXY`

## 🔧 **Platform-Specific Setup**

### Android Configuration

1. **Add API Key to Android Manifest**
   
   Edit `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <application
       android:label="safe_tour"
       android:name="${applicationName}"
       android:icon="@mipmap/ic_launcher">
       
       <!-- Google Maps API Key -->
       <meta-data
           android:name="com.google.android.geo.API_KEY"
           android:value="AIzaSyBwYP-T4OrdoXoaOBMtEA1nzlm0R6wSiXY"/>
       
       <activity
           android:name=".MainActivity"
           android:exported="true"
           android:launchMode="singleTop"
           android:theme="@style/LaunchTheme"
           android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
           android:hardwareAccelerated="true"
           android:windowSoftInputMode="adjustResize">
   ```

2. **Update Android Permissions**
   
   Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
   ```

3. **Update Minimum SDK Version**
   
   Edit `android/app/build.gradle`:
   ```gradle
   android {
       compileSdkVersion 34
       
       defaultConfig {
           minSdkVersion 21  // Required for Google Maps
           targetSdkVersion 34
       }
   }
   ```

### iOS Configuration

1. **Add API Key to iOS**
   
   Edit `ios/Runner/AppDelegate.swift`:
   ```swift
   import UIKit
   import Flutter
   import GoogleMaps

   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
       GMSServices.provideAPIKey("AIzaSyBwYP-T4OrdoXoaOBMtEA1nzlm0R6wSiXY")
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }
   }
   ```

2. **Update iOS Permissions**
   
   Edit `ios/Runner/Info.plist`:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs location access to provide safety features and emergency services.</string>
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>This app needs location access to provide safety features and emergency services.</string>
   <key>NSLocationAlwaysUsageDescription</key>
   <string>This app needs location access to provide safety features and emergency services.</string>
   ```

3. **Update iOS Deployment Target**
   
   Edit `ios/Podfile`:
   ```ruby
   platform :ios, '12.0'  # Required for Google Maps
   ```

### Web Configuration

1. **Add API Key to Web**
   
   Edit `web/index.html`:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
     <meta charset="UTF-8">
     <meta content="IE=Edge" http-equiv="X-UA-Compatible">
     <meta name="description" content="Smart Tourist Safety App">
     <meta name="apple-mobile-web-app-capable" content="yes">
     <meta name="apple-mobile-web-app-status-bar-style" content="black">
     <meta name="apple-mobile-web-app-title" content="safe_tour">
     <link rel="apple-touch-icon" href="icons/Icon-192.png">
     <link rel="icon" type="image/png" href="favicon.png"/>
     <title>Smart Tourist Safety App</title>
     <link rel="manifest" href="manifest.json">
     
     <!-- Google Maps JavaScript API -->
     <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBwYP-T4OrdoXoaOBMtEA1nzlm0R6wSiXY&libraries=places"></script>
   </head>
   <body>
     <script>
       window.addEventListener('load', function(ev) {
         _flutter.loader.loadEntrypoint({
           serviceWorker: {
             serviceWorkerVersion: serviceWorkerVersion,
           }
         });
       });
     </script>
   </body>
   </html>
   ```

## 🚀 **Features Implemented**

### 1. **Google Maps Service** (`lib/services/google_maps_service.dart`)
- **Geocoding**: Convert addresses to coordinates and vice versa
- **Places Search**: Find nearby hospitals, police stations, tourist attractions
- **Directions**: Get turn-by-turn directions between locations
- **Distance Matrix**: Calculate distances and travel times
- **Safety Assessment**: Evaluate location safety based on nearby services

### 2. **Interactive Map Widget** (`lib/widgets/google_maps_widget.dart`)
- **Real-time Location Tracking**: Shows current user location
- **Emergency Services Markers**: Hospitals, police stations, fire stations
- **Tourist Attractions**: Museums, parks, points of interest
- **Safety Zones**: Color-coded areas based on safety assessment
- **Interactive Markers**: Tap for detailed information

### 3. **Interactive Map Screen** (`lib/screens/maps/interactive_map_screen.dart`)
- **Full-screen Map Experience**: Complete mapping interface
- **Layer Controls**: Toggle different marker types
- **Quick Actions**: Find nearby services instantly
- **Place Details**: Comprehensive information about locations
- **Safety Indicators**: Real-time safety score display

## 🎯 **Usage Examples**

### Basic Map Display
```dart
GoogleMapsWidget(
  showCurrentLocation: true,
  showEmergencyServices: true,
  showTouristAttractions: false,
  showSafetyZones: true,
)
```

### Find Nearby Places
```dart
final places = await GoogleMapsService.instance.findNearbyPlaces(
  latitude: 37.7749,
  longitude: -122.4194,
  type: 'hospital',
  radius: 5000,
);
```

### Safety Assessment
```dart
final assessment = await GoogleMapsService.instance.assessLocationSafety(
  latitude: 37.7749,
  longitude: -122.4194,
);
print('Safety Score: ${assessment.safetyScore}%');
```

## 🔒 **Security Best Practices**

### 1. **API Key Restrictions**
In Google Cloud Console, restrict your API key:
- **Application restrictions**: Set to Android/iOS apps
- **API restrictions**: Enable only required APIs
- **Referrer restrictions**: Add your app's package name

### 2. **Usage Monitoring**
- Monitor API usage in Google Cloud Console
- Set up billing alerts
- Implement caching to reduce API calls

### 3. **Error Handling**
All services include comprehensive error handling:
- Network connectivity issues
- API quota exceeded
- Invalid coordinates
- Service unavailable

## 📱 **Testing**

### 1. **Run the App**
```bash
flutter pub get
flutter run -d android  # For Android
flutter run -d ios      # For iOS
```

### 2. **Test Features**
1. **Location Tracking**: Verify current location appears on map
2. **Emergency Services**: Check nearby hospitals and police stations
3. **Safety Assessment**: Confirm safety scores are calculated
4. **Place Search**: Test finding restaurants, gas stations, etc.
5. **Directions**: Verify navigation functionality

### 3. **Debug Issues**
- Check API key is correctly configured
- Verify all required APIs are enabled
- Ensure location permissions are granted
- Monitor console for error messages

## 🌐 **Production Deployment**

### 1. **API Key Security**
- Use separate API keys for development and production
- Implement server-side proxy for sensitive operations
- Regularly rotate API keys

### 2. **Performance Optimization**
- Implement marker clustering for large datasets
- Cache frequently accessed place data
- Optimize map tile loading

### 3. **Monitoring**
- Set up Google Cloud Monitoring
- Track API usage and costs
- Monitor app performance metrics

## 🎉 **Success!**

Your Smart Tourist Safety App now has comprehensive Google Maps integration with:
- ✅ **Real-time Location Tracking**
- ✅ **Emergency Services Locator**
- ✅ **Safety Zone Assessment**
- ✅ **Interactive Mapping Interface**
- ✅ **Tourist Attraction Discovery**
- ✅ **Turn-by-turn Directions**

The app is ready for real-world testing and deployment with professional-grade mapping capabilities!
