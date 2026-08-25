import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class EmailConfirmedScreen extends StatelessWidget {
  const EmailConfirmedScreen({super.key});

  static const _green = AppColors.primaryGreen;

  void _handleContinue(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _green, width: 1.6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _green.withOpacity(0.12),
                          border: Border.all(color: _green, width: 1.6),
                        ),
                        child: const Icon(Icons.check, color: _green, size: 36),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Email Confirmed Successfully',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Material(
                  color: _green,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _handleContinue(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
