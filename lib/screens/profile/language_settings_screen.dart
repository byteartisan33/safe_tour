import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/language_service.dart';

class LanguageSettingsScreen extends StatefulWidget {
  final String currentLanguage;

  const LanguageSettingsScreen({
    super.key,
    required this.currentLanguage,
  });

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
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
          'Language Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange[700],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          if (_selectedLanguage != widget.currentLanguage)
            TextButton(
              onPressed: _isLoading ? null : _saveLanguage,
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
                    // Current Language Card
                    _buildCurrentLanguageCard(),
                    SizedBox(height: 24),
                    
                    // Indian Languages Section
                    _buildLanguageSection(
                      'Indian Languages',
                      LanguageService.getIndianLanguages(),
                      Colors.orange,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Global Languages Section
                    _buildLanguageSection(
                      'Global Languages',
                      LanguageService.getGlobalLanguages(),
                      Colors.blue,
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Language Info Card
                    _buildLanguageInfoCard(),
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
          ),
          SizedBox(height: 16),
          Text(
            'Updating language...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLanguageCard() {
    final languageDetails = LanguageService.getLanguageDetails(_selectedLanguage);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[700]!, Colors.orange[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Language',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                languageDetails?['flag'] ?? '🌐',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedLanguage,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    languageDetails?['nativeName'] ?? _selectedLanguage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
    String title,
    Map<String, Map<String, String>> languages,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
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
          child: Column(
            children: languages.entries.map((entry) {
              final languageName = entry.key;
              final languageDetails = entry.value;
              final isSelected = languageName == _selectedLanguage;
              
              return _buildLanguageItem(
                languageName,
                languageDetails,
                color,
                isSelected,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageItem(
    String languageName,
    Map<String, String> languageDetails,
    Color color,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectLanguage(languageName),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Flag
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    languageDetails['flag'] ?? '🌐',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              
              SizedBox(width: 16),
              
              // Language Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      languageDetails['nativeName'] ?? languageName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection Indicator
              if (isSelected)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[600]),
              SizedBox(width: 8),
              Text(
                'Language Support',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• The app supports 19 languages including 11 Indian languages and 8 global languages',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Language changes will apply to the entire app interface',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Emergency services and safety alerts will be displayed in your selected language',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage(String language) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _saveLanguage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await LanguageService.setLanguage(_selectedLanguage);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language updated to $_selectedLanguage'),
            backgroundColor: Colors.green[600],
          ),
        );
        
        Navigator.pop(context, _selectedLanguage);
      } else {
        throw Exception('Failed to update language');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating language: $e'),
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
