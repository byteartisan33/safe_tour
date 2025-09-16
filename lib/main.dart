import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'services/firebase_auth_service.dart';
import 'services/realtime_sync_service.dart';
import 'services/firebase_messaging_service.dart';
import 'screens/registration/multi_step_registration.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await FirebaseConfig.initialize();

    // Initialize Firebase services
    await FirebaseAuthService().initialize();

    print('Firebase services initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(TouristSafetyApp());
}

class TouristSafetyApp extends StatelessWidget {
  const TouristSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Tourist Safety',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {'/': (context) => SplashWelcomeScreen()},
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/registration':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => MultiStepRegistrationScreen(
                selectedLanguage: args?['selectedLanguage'] ?? 'English',
              ),
            );
          case '/login':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => LoginScreen(
                selectedLanguage: args?['selectedLanguage'] ?? 'English',
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}

// Splash & Welcome Screen
class SplashWelcomeScreen extends StatefulWidget {
  const SplashWelcomeScreen({super.key});

  @override
  State<SplashWelcomeScreen> createState() => _SplashWelcomeScreenState();
}

class _SplashWelcomeScreenState extends State<SplashWelcomeScreen> {
  String selectedLanguage = 'English';

  // Enhanced language list with 5+ Indian languages, 5+ Global languages, and English
  final Map<String, List<String>> languageCategories = {
    'English': ['English'],
    'Indian Languages': [
      'Hindi (हिंदी)',
      'Bengali (বাংলা)',
      'Tamil (தமிழ்)',
      'Telugu (తెలుగు)',
      'Gujarati (ગુજરાતી)',
      'Marathi (मराठी)',
      'Punjabi (ਪੰਜਾਬੀ)',
      'Urdu (اردو)',
      'Kannada (ಕನ್ನಡ)',
      'Malayalam (മലയാളം)',
    ],
    'Global Languages': [
      'Spanish (Español)',
      'French (Français)',
      'German (Deutsch)',
      'Chinese (中文)',
      'Japanese (日本語)',
      'Arabic (العربية)',
      'Russian (Русский)',
      'Portuguese (Português)',
    ],
  };

  List<String> get allLanguages {
    List<String> languages = [];
    languageCategories.forEach((category, langs) {
      languages.addAll(langs);
    });
    return languages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon placeholder
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(Icons.security, size: 60, color: Colors.white),
                  ),
                  SizedBox(height: 32),

                  // App Title
                  Text(
                    'Smart Tourist Safety',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Monitoring & Incident Response System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),

                  // Language Selection
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                      color: Colors.white,
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedLanguage,
                      decoration: InputDecoration(
                        labelText: 'Select Your Preferred Language',
                        labelStyle: TextStyle(color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _buildLanguageDropdownItems(),
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value ?? 'English';
                        });
                      },
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 48),

                  // Navigation Buttons
                  Column(
                    children: [
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/registration',
                              arguments: {'selectedLanguage': selectedLanguage},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'New User - Register',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/login',
                              arguments: {'selectedLanguage': selectedLanguage},
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            side: BorderSide(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Existing User - Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Footer text
                  Text(
                    'Your safety is our priority',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildLanguageDropdownItems() {
    List<DropdownMenuItem<String>> items = [];

    languageCategories.forEach((category, languages) {
      // Add category header (disabled)
      items.add(
        DropdownMenuItem<String>(
          value: null,
          enabled: false,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              category.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      );

      // Add languages in this category
      for (String language in languages) {
        items.add(
          DropdownMenuItem<String>(
            value: language,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(language, style: TextStyle(fontSize: 16)),
            ),
          ),
        );
      }
    });

    return items;
  }
}
