import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/accessibility_service.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  final String selectedLanguage;

  const AccessibilitySettingsScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  AccessibilitySettings _currentSettings = AccessibilitySettings();
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentSettings = AccessibilityService.getCurrentSettings();
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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Accessibility Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple[700],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveSettings,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? _buildLoadingView()
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accessibility Overview Card
                    _buildOverviewCard(),
                    SizedBox(height: 24),

                    // Visual Settings
                    _buildSettingsSection(
                      'Visual Settings',
                      Icons.visibility,
                      Colors.blue,
                      [
                        _buildFontSizeSelector(),
                        _buildContrastModeSelector(),
                        _buildLargeButtonsToggle(),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Motion & Animation Settings
                    _buildSettingsSection(
                      'Motion & Animation',
                      Icons.animation,
                      Colors.green,
                      [
                        _buildMotionPreferenceSelector(),
                        _buildSimplifiedUIToggle(),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Audio & Feedback Settings
                    _buildSettingsSection(
                      'Audio & Feedback',
                      Icons.volume_up,
                      Colors.orange,
                      [
                        _buildScreenReaderToggle(),
                        _buildHapticFeedbackToggle(),
                        _buildSoundEffectsToggle(),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Advanced Settings
                    _buildSettingsSection(
                      'Advanced Settings',
                      Icons.settings,
                      Colors.purple,
                      [_buildTextScaleFactorSlider()],
                    ),

                    SizedBox(height: 32),

                    // Reset Button
                    _buildResetButton(),

                    SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
          ),
          SizedBox(height: 16),
          Text(
            'Updating accessibility settings...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.accessibility, size: 48, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Accessibility Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Customize the app to meet your accessibility needs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        Container(
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildFontSizeSelector() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Font Size',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: FontSize.values.map((fontSize) {
              final isSelected = _currentSettings.fontSize == fontSize;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _updateFontSize(fontSize),
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue[600]!
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      AccessibilityService.getFontSizeName(fontSize),
                      style: TextStyle(
                        fontSize: _getFontSizePreview(fontSize),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.blue[800] : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildContrastModeSelector() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'High Contrast Mode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Improves text readability',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch(
            value: _currentSettings.contrastMode == ContrastMode.high,
            onChanged: (value) => _updateContrastMode(
              value ? ContrastMode.high : ContrastMode.normal,
            ),
            activeThumbColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeButtonsToggle() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Large Buttons',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Easier to tap and interact with',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch(
            value: _currentSettings.largeButtonsEnabled,
            onChanged: _updateLargeButtons,
            activeThumbColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  Widget _buildMotionPreferenceSelector() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reduce Motion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Minimizes animations and transitions',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch(
            value:
                _currentSettings.motionPreference == MotionPreference.reduced,
            onChanged: (value) => _updateMotionPreference(
              value ? MotionPreference.reduced : MotionPreference.normal,
            ),
            activeThumbColor: Colors.green[600],
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedUIToggle() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simplified Interface',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Cleaner, less cluttered design',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch(
            value: _currentSettings.simplifiedUIEnabled,
            onChanged: _updateSimplifiedUI,
            activeThumbColor: Colors.green[600],
          ),
        ],
      ),
    );
  }

  Widget _buildScreenReaderToggle() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Screen Reader Support',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Enhanced accessibility labels',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch(
            value: _currentSettings.screenReaderEnabled,
            onChanged: _updateScreenReader,
            activeThumbColor: Colors.orange[600],
          ),
        ],
      ),
    );
  }

  Widget _buildHapticFeedbackToggle() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Haptic Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Vibration for button presses',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch(
            value: _currentSettings.hapticFeedbackEnabled,
            onChanged: _updateHapticFeedback,
            activeThumbColor: Colors.orange[600],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundEffectsToggle() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sound Effects',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'Audio feedback for interactions',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Switch(
            value: _currentSettings.soundEffectsEnabled,
            onChanged: _updateSoundEffects,
            activeThumbColor: Colors.orange[600],
          ),
        ],
      ),
    );
  }

  Widget _buildTextScaleFactorSlider() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text Scale Factor: ${_currentSettings.textScaleFactor.toStringAsFixed(1)}x',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fine-tune text size beyond font size settings',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 12),
          Slider(
            value: _currentSettings.textScaleFactor,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            label: '${_currentSettings.textScaleFactor.toStringAsFixed(1)}x',
            onChanged: _updateTextScaleFactor,
            activeColor: Colors.purple[600],
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _resetToDefaults,
        icon: Icon(Icons.restore, color: Colors.red[600]),
        label: Text(
          'Reset to Defaults',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red[600],
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.red[600]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Helper methods
  double _getFontSizePreview(FontSize fontSize) {
    switch (fontSize) {
      case FontSize.small:
        return 12;
      case FontSize.medium:
        return 14;
      case FontSize.large:
        return 16;
      case FontSize.extraLarge:
        return 18;
    }
  }

  void _updateFontSize(FontSize fontSize) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSettings = _currentSettings.copyWith(fontSize: fontSize);
      _hasChanges = true;
    });
  }

  void _updateContrastMode(ContrastMode contrastMode) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSettings = _currentSettings.copyWith(contrastMode: contrastMode);
      _hasChanges = true;
    });
  }

  void _updateLargeButtons(bool enabled) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSettings = _currentSettings.copyWith(
        largeButtonsEnabled: enabled,
      );
      _hasChanges = true;
    });
  }

  void _updateMotionPreference(MotionPreference motionPreference) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSettings = _currentSettings.copyWith(
        motionPreference: motionPreference,
      );
      _hasChanges = true;
    });
  }

  void _updateSimplifiedUI(bool enabled) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSettings = _currentSettings.copyWith(
        simplifiedUIEnabled: enabled,
      );
      _hasChanges = true;
    });
  }

  void _updateScreenReader(bool enabled) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSettings = _currentSettings.copyWith(
        screenReaderEnabled: enabled,
      );
      _hasChanges = true;
    });
  }

  void _updateHapticFeedback(bool enabled) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSettings = _currentSettings.copyWith(
        hapticFeedbackEnabled: enabled,
      );
      _hasChanges = true;
    });
  }

  void _updateSoundEffects(bool enabled) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentSettings = _currentSettings.copyWith(
        soundEffectsEnabled: enabled,
      );
      _hasChanges = true;
    });
  }

  void _updateTextScaleFactor(double scaleFactor) {
    setState(() {
      _currentSettings = _currentSettings.copyWith(
        textScaleFactor: scaleFactor,
      );
      _hasChanges = true;
    });
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Accessibility Settings'),
        content: Text(
          'This will reset all accessibility settings to their default values. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _currentSettings = AccessibilitySettings();
        _hasChanges = true;
      });

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accessibility settings reset to defaults'),
            backgroundColor: Colors.orange[600],
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AccessibilityService.updateSettings(
        _currentSettings,
      );

      if (success && mounted) {
        setState(() {
          _hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accessibility settings saved successfully'),
            backgroundColor: Colors.green[600],
          ),
        );
      } else {
        throw Exception('Failed to save accessibility settings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
