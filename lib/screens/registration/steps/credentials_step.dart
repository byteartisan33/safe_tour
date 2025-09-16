import 'package:flutter/material.dart';
import '../../../models/user_models.dart';

class CredentialsStep extends StatefulWidget {
  final UserCredentials? initialData;
  final Function(UserCredentials?) onDataChanged;

  const CredentialsStep({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<CredentialsStep> createState() => _CredentialsStepState();
}

class _CredentialsStepState extends State<CredentialsStep> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _acceptedPrivacyPolicy = false;
  bool _acceptedBlockchainConsent = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _emailController.text = widget.initialData!.email;
      _passwordController.text = widget.initialData!.password;
      _confirmPasswordController.text = widget.initialData!.password;
      _acceptedTerms = widget.initialData!.acceptedTerms;
      _acceptedPrivacyPolicy = widget.initialData!.acceptedPrivacyPolicy;
      _acceptedBlockchainConsent =
          widget.initialData!.acceptedBlockchainConsent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Account Setup'),
            SizedBox(height: 16),

            // Email Field
            _buildEmailField(),
            SizedBox(height: 16),

            // Password Field
            _buildPasswordField(),
            SizedBox(height: 16),

            // Confirm Password Field
            _buildConfirmPasswordField(),
            SizedBox(height: 24),

            // Password Requirements
            _buildPasswordRequirements(),
            SizedBox(height: 24),

            // Terms and Conditions
            _buildSectionTitle('Terms & Conditions'),
            SizedBox(height: 16),
            _buildTermsCheckboxes(),

            SizedBox(height: 24),
            _buildSecurityInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue[700],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address *',
        hintText: 'Enter your email address',
        prefixIcon: Icon(Icons.email, color: Colors.blue[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        return null;
      },
      onChanged: (value) => _updateData(),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password *',
        hintText: 'Create a strong password',
        prefixIcon: Icon(Icons.lock, color: Colors.blue[600]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue[600],
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (!RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
        ).hasMatch(value)) {
          return 'Password must meet all requirements';
        }
        return null;
      },
      onChanged: (value) => _updateData(),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password *',
        hintText: 'Re-enter your password',
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[600]),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue[600],
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      onChanged: (value) => _updateData(),
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          _buildRequirementItem('At least 8 characters', password.length >= 8),
          _buildRequirementItem(
            'One uppercase letter',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _buildRequirementItem(
            'One lowercase letter',
            RegExp(r'[a-z]').hasMatch(password),
          ),
          _buildRequirementItem('One number', RegExp(r'\d').hasMatch(password)),
          _buildRequirementItem(
            'One special character (@\$!%*?&)',
            RegExp(r'[@$!%*?&]').hasMatch(password),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              color: isMet ? Colors.green[700] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckboxes() {
    return Column(
      children: [
        _buildCheckboxTile(
          title: 'Terms & Conditions',
          subtitle: 'I agree to the Terms & Conditions of Smart Tourist Safety',
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
            _updateData();
          },
          linkText: 'Read Terms & Conditions',
        ),
        SizedBox(height: 12),
        _buildCheckboxTile(
          title: 'Privacy Policy',
          subtitle: 'I agree to the Privacy Policy and data processing terms',
          value: _acceptedPrivacyPolicy,
          onChanged: (value) {
            setState(() {
              _acceptedPrivacyPolicy = value ?? false;
            });
            _updateData();
          },
          linkText: 'Read Privacy Policy',
        ),
        SizedBox(height: 12),
        _buildCheckboxTile(
          title: 'Blockchain Consent',
          subtitle:
              'I consent to storing my identity data on blockchain for security',
          value: _acceptedBlockchainConsent,
          onChanged: (value) {
            setState(() {
              _acceptedBlockchainConsent = value ?? false;
            });
            _updateData();
          },
          linkText: 'Learn about Blockchain Storage',
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool?) onChanged,
    required String linkText,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[700],
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Show terms/privacy/blockchain info dialog
                _showInfoDialog(title, subtitle);
              },
              child: Text(
                linkText,
                style: TextStyle(color: Colors.blue[700], fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.blue[700]),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Account Security',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Your password is encrypted and stored securely\n'
            '• Two-factor authentication will be enabled\n'
            '• Account activity is monitored for security\n'
            '• You can change your password anytime in settings',
            style: TextStyle(color: Colors.blue[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateData() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text &&
          _acceptedTerms &&
          _acceptedPrivacyPolicy &&
          _acceptedBlockchainConsent) {
        final credentials = UserCredentials(
          email: _emailController.text.trim(),
          password:
              _passwordController.text, // In real app, this should be hashed
          acceptedTerms: _acceptedTerms,
          acceptedPrivacyPolicy: _acceptedPrivacyPolicy,
          acceptedBlockchainConsent: _acceptedBlockchainConsent,
        );

        widget.onDataChanged(credentials);
      } else {
        widget.onDataChanged(null);
      }
    } else {
      widget.onDataChanged(null);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
