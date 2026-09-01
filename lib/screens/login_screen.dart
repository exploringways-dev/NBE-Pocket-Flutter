import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../theme/app_theme.dart';
import '../widgets/labeled_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/segmented_toggle.dart';
import '../services/auth_service.dart';
import 'app_shell.dart';
import 'forgetpass_screen.dart';
import 'signup_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginRole _role = LoginRole.client;
  bool _isLoading = false;

  // Biometric state detection
  List<BiometricType> _availableBiometrics = [];
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkAvailableBiometrics();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailableBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      List<BiometricType> available = [];
      if (canAuthenticate) {
        available = await _localAuth.getAvailableBiometrics();
      }

      if (mounted) {
        setState(() {
          _canCheckBiometrics = canAuthenticate && available.isNotEmpty;
          _availableBiometrics = available;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _canCheckBiometrics = false;
          _availableBiometrics = [];
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.login(
        email: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {

        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
       );
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricAuth() async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Scan biometrics to sign in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate && mounted) {
        // 1. Check if the user has a saved token from a previous manual login
        final token = await _storage.read(key: ApiClient.accessTokenKey);

        if (!mounted) return;

        if (token != null && token.isNotEmpty) {
          // Success! They proved who they are AND they have an active session.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AppShell()),
          );
        } else {
          // They verified their fingerprint, but they don't have a saved login.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Please log in with your email and password first to enable biometrics.'),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric error: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                LabeledTextField(
                                  label: 'Email',
                                  hint: 'example@domain.com',
                                  controller: _usernameController,
                                  icon: Icons.person_outline,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Enter your email'
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                LabeledTextField(
                                  label: 'Password',
                                  hint: '••••••••',
                                  controller: _passwordController,
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (v) => (v == null || v.length < 6)
                                      ? 'Min 6 characters'
                                      : null,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 32),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: AppColors.accentOrange,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PrimaryButton(
                                  label: 'Login',
                                  isLoading: _isLoading,
                                  onPressed: _handleLogin,
                                ),
                                if (_canCheckBiometrics) ...[
                                  const SizedBox(height: 16),
                                  _buildDivider('or use biometrics'),
                                  const SizedBox(height: 14),
                                  _buildBiometricsRow(),
                                ],
                              ],
                            ),
                            _buildSignUpFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 8, 24, 18),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'National Bank of Egypt',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'البنك الأهلي المصري',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Sign in to your account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedToggle(
            selected: _role,
            onChanged: (role) => setState(() => _role = role),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(String? label) {
    if (label == null) {
      return const Divider(color: AppColors.divider);
    }
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.hintGray, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _buildBiometricsRow() {
    final List<Widget> biometricButtons = [];

    // Check Face ID / Facial Recognition
    if (_availableBiometrics.contains(BiometricType.face)) {
      biometricButtons.add(
        _biometricButton(
          Icons.face_retouching_natural,
          'Face ID',
          onTap: _handleBiometricAuth,
        ),
      );
    }

    // Check Fingerprint
    if (_availableBiometrics.contains(BiometricType.fingerprint) ||
        _availableBiometrics.contains(BiometricType.strong) ||
        _availableBiometrics.contains(BiometricType.weak)) {
      biometricButtons.add(
        _biometricButton(
          Icons.fingerprint,
          'Fingerprint',
          onTap: _handleBiometricAuth,
        ),
      );
    }

    // Fallback if hardware exists but specific type isn't isolated
    if (biometricButtons.isEmpty) {
      biometricButtons.add(
        _biometricButton(
          Icons.fingerprint,
          'Biometrics',
          onTap: _handleBiometricAuth,
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      children: biometricButtons,
    );
  }

  Widget _biometricButton(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.labelGray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ",
            style: TextStyle(color: AppColors.hintGray, fontSize: 13)),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignUpScreen()),
            );
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
