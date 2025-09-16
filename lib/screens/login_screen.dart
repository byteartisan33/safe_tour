import 'package:flutter/material.dart';
import '../models/user_models.dart';
import 'dashboard/home_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String selectedLanguage;

  const LoginScreen({super.key, required this.selectedLanguage});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height:
              MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[700]!, Colors.blue[50]!],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Welcome
                  _buildHeader(),
                  SizedBox(height: 40),

                  // Login Form
                  _buildLoginForm(),
                  SizedBox(height: 24),

                  // Login Button
                  _buildLoginButton(),
                  SizedBox(height: 16),

                  // Forgot Password
                  _buildForgotPasswordLink(),
                  SizedBox(height: 32),

                  // Register Link
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(Icons.security, size: 40, color: Colors.blue[700]),
        ),
        SizedBox(height: 24),

        // Welcome Text
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to your Smart Tourist Safety account',
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email, color: Colors.blue[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Remember Me
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: Colors.blue[700],
                ),
                Text('Remember me', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return TextButton(
      onPressed: _handleForgotPassword,
      child: Text(
        'Forgot Password?',
        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: TextStyle(color: Colors.grey[700]),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Register here',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login process
      await Future.delayed(Duration(seconds: 2));

      // TODO: Implement actual login logic with backend/Firebase
      // For now, show success message
      _showLoginSuccess();

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to reset your password:'),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password reset link sent to your email!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _showLoginSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Login Successful!'),
          ],
        ),
        content: Text(
          'Welcome back! You have successfully logged into your Smart Tourist Safety account.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Navigate to dashboard with sample user data
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomeDashboard(
                    userData: _createSampleUserData(),
                    selectedLanguage: widget.selectedLanguage,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Create sample user data for login demo
  UserRegistrationData _createSampleUserData() {
    return UserRegistrationData(
      personalInfo: PersonalInformation(
        fullName: 'John Doe',
        gender: 'Male',
        dateOfBirth: DateTime(1990, 5, 15),
        nationality: 'United States',
        documentType: 'passport',
        documentNumber: 'US123456789',
      ),
      kycDocuments: KYCDocuments(passportImagePath: '', isVerified: true),
      tripDetails: TripDetails(
        entryPoint: 'Delhi - Indira Gandhi International Airport',
        tripStartDate: DateTime.now(),
        tripEndDate: DateTime.now().add(Duration(days: 14)),
        placesToVisit: ['New Delhi', 'Agra', 'Jaipur', 'Mumbai', 'Goa'],
        detailedItinerary: 'Golden Triangle tour with beach relaxation in Goa',
      ),
      emergencyContacts: [
        EmergencyContact(
          name: 'Jane Doe',
          relationship: 'Spouse',
          phoneNumber: '+1-555-0123',
          email: 'jane.doe@email.com',
          isPrimary: true,
        ),
        EmergencyContact(
          name: 'Robert Doe',
          relationship: 'Father',
          phoneNumber: '+1-555-0456',
          email: 'robert.doe@email.com',
          isPrimary: false,
        ),
      ],
      healthInfo: HealthInformation(
        bloodGroup: 'O+',
        medicalConditions: ['None'],
        allergies: ['None'],
        medications: [],
        emergencyMedicalInfo: 'No known medical conditions',
      ),
      credentials: UserCredentials(
        email: _emailController.text,
        password: '', // Don't store actual password
        acceptedTerms: true,
        acceptedPrivacyPolicy: true,
        acceptedBlockchainConsent: true,
      ),
      selectedLanguage: widget.selectedLanguage,
      registrationDate: DateTime.now().subtract(Duration(days: 30)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
