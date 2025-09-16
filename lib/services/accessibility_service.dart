import 'dart:async';
import 'package:flutter/material.dart';

enum FontSize { small, medium, large, extraLarge }
enum ContrastMode { normal, high }
enum MotionPreference { normal, reduced }

class AccessibilitySettings {
  final FontSize fontSize;
  final ContrastMode contrastMode;
  final MotionPreference motionPreference;
  final bool screenReaderEnabled;
  final bool hapticFeedbackEnabled;
  final bool soundEffectsEnabled;
  final bool largeButtonsEnabled;
  final bool simplifiedUIEnabled;
  final double textScaleFactor;

  const AccessibilitySettings({
    this.fontSize = FontSize.medium,
    this.contrastMode = ContrastMode.normal,
    this.motionPreference = MotionPreference.normal,
    this.screenReaderEnabled = false,
    this.hapticFeedbackEnabled = true,
    this.soundEffectsEnabled = true,
    this.largeButtonsEnabled = false,
    this.simplifiedUIEnabled = false,
    this.textScaleFactor = 1.0,
  });

  AccessibilitySettings copyWith({
    FontSize? fontSize,
    ContrastMode? contrastMode,
    MotionPreference? motionPreference,
    bool? screenReaderEnabled,
    bool? hapticFeedbackEnabled,
    bool? soundEffectsEnabled,
    bool? largeButtonsEnabled,
    bool? simplifiedUIEnabled,
    double? textScaleFactor,
  }) {
    return AccessibilitySettings(
      fontSize: fontSize ?? this.fontSize,
      contrastMode: contrastMode ?? this.contrastMode,
      motionPreference: motionPreference ?? this.motionPreference,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      largeButtonsEnabled: largeButtonsEnabled ?? this.largeButtonsEnabled,
      simplifiedUIEnabled: simplifiedUIEnabled ?? this.simplifiedUIEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize.index,
      'contrastMode': contrastMode.index,
      'motionPreference': motionPreference.index,
      'screenReaderEnabled': screenReaderEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'soundEffectsEnabled': soundEffectsEnabled,
      'largeButtonsEnabled': largeButtonsEnabled,
      'simplifiedUIEnabled': simplifiedUIEnabled,
      'textScaleFactor': textScaleFactor,
    };
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      fontSize: FontSize.values[json['fontSize'] ?? 1],
      contrastMode: ContrastMode.values[json['contrastMode'] ?? 0],
      motionPreference: MotionPreference.values[json['motionPreference'] ?? 0],
      screenReaderEnabled: json['screenReaderEnabled'] ?? false,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      soundEffectsEnabled: json['soundEffectsEnabled'] ?? true,
      largeButtonsEnabled: json['largeButtonsEnabled'] ?? false,
      simplifiedUIEnabled: json['simplifiedUIEnabled'] ?? false,
      textScaleFactor: json['textScaleFactor']?.toDouble() ?? 1.0,
    );
  }
}

class AccessibilityService {
  static AccessibilityService? _instance;
  static AccessibilityService get instance => _instance ??= AccessibilityService._();
  AccessibilityService._();

  // Current accessibility settings
  static AccessibilitySettings _currentSettings = AccessibilitySettings();
  
  // Settings change stream
  static final StreamController<AccessibilitySettings> _settingsController =
      StreamController<AccessibilitySettings>.broadcast();

  // Stream for settings changes
  static Stream<AccessibilitySettings> get settingsStream => _settingsController.stream;

  // Get current accessibility settings
  static AccessibilitySettings getCurrentSettings() {
    return _currentSettings;
  }

  // Update accessibility settings
  static Future<bool> updateSettings(AccessibilitySettings settings) async {
    try {
      _currentSettings = settings;
      _settingsController.add(_currentSettings);
      
      // Save to storage
      await _saveSettingsToStorage(settings);
      
      return true;
    } catch (e) {
      print('Error updating accessibility settings: $e');
      return false;
    }
  }

  // Update font size
  static Future<bool> updateFontSize(FontSize fontSize) async {
    final updatedSettings = _currentSettings.copyWith(fontSize: fontSize);
    return await updateSettings(updatedSettings);
  }

  // Update contrast mode
  static Future<bool> updateContrastMode(ContrastMode contrastMode) async {
    final updatedSettings = _currentSettings.copyWith(contrastMode: contrastMode);
    return await updateSettings(updatedSettings);
  }

  // Update motion preference
  static Future<bool> updateMotionPreference(MotionPreference motionPreference) async {
    final updatedSettings = _currentSettings.copyWith(motionPreference: motionPreference);
    return await updateSettings(updatedSettings);
  }

  // Toggle screen reader
  static Future<bool> toggleScreenReader(bool enabled) async {
    final updatedSettings = _currentSettings.copyWith(screenReaderEnabled: enabled);
    return await updateSettings(updatedSettings);
  }

  // Toggle haptic feedback
  static Future<bool> toggleHapticFeedback(bool enabled) async {
    final updatedSettings = _currentSettings.copyWith(hapticFeedbackEnabled: enabled);
    return await updateSettings(updatedSettings);
  }

  // Toggle sound effects
  static Future<bool> toggleSoundEffects(bool enabled) async {
    final updatedSettings = _currentSettings.copyWith(soundEffectsEnabled: enabled);
    return await updateSettings(updatedSettings);
  }

  // Toggle large buttons
  static Future<bool> toggleLargeButtons(bool enabled) async {
    final updatedSettings = _currentSettings.copyWith(largeButtonsEnabled: enabled);
    return await updateSettings(updatedSettings);
  }

  // Toggle simplified UI
  static Future<bool> toggleSimplifiedUI(bool enabled) async {
    final updatedSettings = _currentSettings.copyWith(simplifiedUIEnabled: enabled);
    return await updateSettings(updatedSettings);
  }

  // Update text scale factor
  static Future<bool> updateTextScaleFactor(double scaleFactor) async {
    final updatedSettings = _currentSettings.copyWith(textScaleFactor: scaleFactor);
    return await updateSettings(updatedSettings);
  }

  // Get text scale factor for font size
  static double getTextScaleFactorForFontSize(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return 0.85;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.2;
      case FontSize.extraLarge:
        return 1.5;
    }
  }

  // Get theme data based on accessibility settings
  static ThemeData getAccessibleThemeData(ThemeData baseTheme) {
    final settings = _currentSettings;
    
    // Adjust text scale factor
    double textScaleFactor = getTextScaleFactorForFontSize(settings.fontSize);
    if (settings.textScaleFactor != 1.0) {
      textScaleFactor *= settings.textScaleFactor;
    }

    // High contrast colors
    ColorScheme colorScheme = baseTheme.colorScheme;
    if (settings.contrastMode == ContrastMode.high) {
      colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: baseTheme.brightness,
      ).copyWith(
        primary: Colors.black,
        onPrimary: Colors.white,
        secondary: Colors.white,
        onSecondary: Colors.black,
        surface: Colors.white,
        onSurface: Colors.black,
      );
    }

    return baseTheme.copyWith(
      colorScheme: colorScheme,
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: textScaleFactor,
      ),
      // Larger buttons if enabled
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: settings.largeButtonsEnabled 
              ? Size(120, 60) 
              : Size(88, 48),
          textStyle: TextStyle(
            fontSize: settings.largeButtonsEnabled ? 18 : 14,
          ),
        ),
      ),
    );
  }

  // Get font size name
  static String getFontSizeName(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return 'Small';
      case FontSize.medium:
        return 'Medium';
      case FontSize.large:
        return 'Large';
      case FontSize.extraLarge:
        return 'Extra Large';
    }
  }

  // Get contrast mode name
  static String getContrastModeName(ContrastMode contrastMode) {
    switch (contrastMode) {
      case ContrastMode.normal:
        return 'Normal';
      case ContrastMode.high:
        return 'High Contrast';
    }
  }

  // Get motion preference name
  static String getMotionPreferenceName(MotionPreference motionPreference) {
    switch (motionPreference) {
      case MotionPreference.normal:
        return 'Normal';
      case MotionPreference.reduced:
        return 'Reduced Motion';
    }
  }

  // Initialize accessibility service
  static Future<void> initialize() async {
    // Load saved settings from storage
    final savedSettings = await _loadSettingsFromStorage();
    if (savedSettings != null) {
      _currentSettings = savedSettings;
    }
  }

  // Save settings to storage (mock implementation)
  static Future<void> _saveSettingsToStorage(AccessibilitySettings settings) async {
    // Simulate storage delay
    await Future.delayed(Duration(milliseconds: 100));
    
    // In a real app, this would save to:
    // - SharedPreferences
    // - Local database
    // - User preferences API
    
    print('Accessibility settings saved');
  }

  // Load settings from storage (mock implementation)
  static Future<AccessibilitySettings?> _loadSettingsFromStorage() async {
    // Simulate storage delay
    await Future.delayed(Duration(milliseconds: 100));
    
    // In a real app, this would load from storage
    // For demo, return null to use defaults
    return null;
  }

  // Reset to default settings
  static Future<bool> resetToDefaults() async {
    return await updateSettings(AccessibilitySettings());
  }

  // Dispose resources
  static void dispose() {
    _settingsController.close();
  }
}
