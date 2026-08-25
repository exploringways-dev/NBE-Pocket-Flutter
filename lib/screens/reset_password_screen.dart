import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: replace with your real "set new password" API call, e.g.
    // await authRepository.resetPassword(_newPasswordController.text);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );
    Navigator.of(context).pop();
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.labelGray,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.hintGray, fontSize: 13.5),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.4),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildField(
                        label: 'New Password',
                        hint: '••••••••',
                        controller: _newPasswordController,
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Min 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        label: 'Confirm New Password',
                        hint: '••••••••',
                        controller: _confirmPasswordController,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirm your new password';
                          if (v != _newPasswordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Confirm',
                        isLoading: _isLoading,
                        onPressed: _handleConfirm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.primaryGreenDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_left, size: 18, color: Colors.white),
                  SizedBox(width: 2),
                  Text(
                    'Back',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Reset Password',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Create a new password for your account',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
