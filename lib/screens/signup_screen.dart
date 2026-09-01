import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Split "Full Name" into First and Last names for the backend
      final nameParts = _fullNameController.text.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.first;
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'User';

      final result = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: _usernameController.text.trim(),
        password: _passwordController.text,
        confirmPassword:
            _confirmPasswordController.text, // <-- Added this field!
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.of(context).pop(); // Return to Login
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledTextField(
                        label: 'Full Name',
                        hint: 'Nour Hassan El-Sayed',
                        controller: _fullNameController,
                        validator: (v) => (v == null ||
                                v.trim().split(RegExp(r'\s+')).length < 2)
                            ? 'Enter your first and last name'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      LabeledTextField(
                        label: 'Username / Email',
                        hint: 'nour.elsayed@example.com',
                        controller: _usernameController,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Enter your email or username'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      LabeledTextField(
                        label: 'Phone Number',
                        hint: '01x-xxxx-xxxx',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.length < 10)
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      LabeledTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 8)
                            ? 'Min 8 characters'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      LabeledTextField(
                        label: 'Confirm Password',
                        hint: '••••••••',
                        controller: _confirmPasswordController,
                        obscureText: true,
                        validator: (v) => (v != _passwordController.text)
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Create Account',
                        isLoading: _isLoading,
                        onPressed: _handleCreateAccount,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 12, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.primaryGreenDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_left, color: Colors.white, size: 20),
                  Text('Back to Login',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Create Account', style: AppTextStyles.headerTitle),
          const SizedBox(height: 6),
          const Text("Join NBE — Egypt's national bank",
              style: AppTextStyles.headerSubtitle),
        ],
      ),
    );
  }
}
