import 'dart:async';

class LanguageService {
  static LanguageService? _instance;
  static LanguageService get instance => _instance ??= LanguageService._();
  LanguageService._();

  // Current language
  static String _currentLanguage = 'English';
  
  // Language change stream
  static final StreamController<String> _languageController =
      StreamController<String>.broadcast();

  // Available languages with their details
  static const Map<String, Map<String, String>> _availableLanguages = {
    // English
    'English': {
      'code': 'en',
      'nativeName': 'English',
      'flag': '🇺🇸',
      'category': 'Global',
    },
    
    // Indian Languages
    'Hindi': {
      'code': 'hi',
      'nativeName': 'हिन्दी',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Bengali': {
      'code': 'bn',
      'nativeName': 'বাংলা',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Telugu': {
      'code': 'te',
      'nativeName': 'తెలుగు',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Marathi': {
      'code': 'mr',
      'nativeName': 'मराठी',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Tamil': {
      'code': 'ta',
      'nativeName': 'தமிழ்',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Gujarati': {
      'code': 'gu',
      'nativeName': 'ગુજરાતી',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Urdu': {
      'code': 'ur',
      'nativeName': 'اردو',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Kannada': {
      'code': 'kn',
      'nativeName': 'ಕನ್ನಡ',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Odia': {
      'code': 'or',
      'nativeName': 'ଓଡ଼ିଆ',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    'Malayalam': {
      'code': 'ml',
      'nativeName': 'മലയാളം',
      'flag': '🇮🇳',
      'category': 'Indian',
    },
    
    // Global Languages
    'Spanish': {
      'code': 'es',
      'nativeName': 'Español',
      'flag': '🇪🇸',
      'category': 'Global',
    },
    'French': {
      'code': 'fr',
      'nativeName': 'Français',
      'flag': '🇫🇷',
      'category': 'Global',
    },
    'German': {
      'code': 'de',
      'nativeName': 'Deutsch',
      'flag': '🇩🇪',
      'category': 'Global',
    },
    'Italian': {
      'code': 'it',
      'nativeName': 'Italiano',
      'flag': '🇮🇹',
      'category': 'Global',
    },
    'Portuguese': {
      'code': 'pt',
      'nativeName': 'Português',
      'flag': '🇵🇹',
      'category': 'Global',
    },
    'Russian': {
      'code': 'ru',
      'nativeName': 'Русский',
      'flag': '🇷🇺',
      'category': 'Global',
    },
    'Japanese': {
      'code': 'ja',
      'nativeName': '日本語',
      'flag': '🇯🇵',
      'category': 'Global',
    },
    'Chinese': {
      'code': 'zh',
      'nativeName': '中文',
      'flag': '🇨🇳',
      'category': 'Global',
    },
  };

  // Stream for language changes
  static Stream<String> get languageStream => _languageController.stream;

  // Get current language
  static Future<String> getCurrentLanguage() async {
    return _currentLanguage;
  }

  // Set current language
  static Future<bool> setLanguage(String language) async {
    if (_availableLanguages.containsKey(language)) {
      _currentLanguage = language;
      _languageController.add(_currentLanguage);
      
      // Save to storage
      await _saveLanguageToStorage(language);
      
      return true;
    }
    return false;
  }

  // Get all available languages
  static Map<String, Map<String, String>> getAvailableLanguages() {
    return Map.from(_availableLanguages);
  }

  // Get languages by category
  static Map<String, Map<String, String>> getLanguagesByCategory(String category) {
    return Map.fromEntries(
      _availableLanguages.entries.where(
        (entry) => entry.value['category'] == category,
      ),
    );
  }

  // Get Indian languages
  static Map<String, Map<String, String>> getIndianLanguages() {
    return getLanguagesByCategory('Indian');
  }

  // Get global languages
  static Map<String, Map<String, String>> getGlobalLanguages() {
    return getLanguagesByCategory('Global');
  }

  // Get language details
  static Map<String, String>? getLanguageDetails(String language) {
    return _availableLanguages[language];
  }

  // Get language code
  static String getLanguageCode(String language) {
    return _availableLanguages[language]?['code'] ?? 'en';
  }

  // Get native name
  static String getNativeName(String language) {
    return _availableLanguages[language]?['nativeName'] ?? language;
  }

  // Get language flag
  static String getLanguageFlag(String language) {
    return _availableLanguages[language]?['flag'] ?? '🌐';
  }

  // Check if language is supported
  static bool isLanguageSupported(String language) {
    return _availableLanguages.containsKey(language);
  }

  // Get language from code
  static String? getLanguageFromCode(String code) {
    for (final entry in _availableLanguages.entries) {
      if (entry.value['code'] == code) {
        return entry.key;
      }
    }
    return null;
  }

  // Initialize language service
  static Future<void> initialize() async {
    // Load saved language from storage
    final savedLanguage = await _loadLanguageFromStorage();
    if (savedLanguage != null && isLanguageSupported(savedLanguage)) {
      _currentLanguage = savedLanguage;
    }
  }

  // Save language to storage (mock implementation)
  static Future<void> _saveLanguageToStorage(String language) async {
    // Simulate storage delay
    await Future.delayed(Duration(milliseconds: 100));
    
    // In a real app, this would save to:
    // - SharedPreferences
    // - Local database
    // - User preferences API
    
    print('Language saved: $language');
  }

  // Load language from storage (mock implementation)
  static Future<String?> _loadLanguageFromStorage() async {
    // Simulate storage delay
    await Future.delayed(Duration(milliseconds: 100));
    
    // In a real app, this would load from storage
    // For demo, return null to use default
    return null;
  }

  // Get localized text (basic implementation)
  static String getLocalizedText(String key, [String? defaultText]) {
    // In a real app, this would return localized text based on current language
    // For demo, return the key or default text
    return defaultText ?? key;
  }

  // Dispose resources
  static void dispose() {
    _languageController.close();
  }
}
