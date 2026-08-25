import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class EmailConfirmationFailedScreen extends StatelessWidget {
  const EmailConfirmationFailedScreen({super.key});

  static const _red = Color(0xFFC0392B);

  void _handleTryAgain(BuildContext context) {
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
                    border: Border.all(color: _red, width: 1.6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _red.withOpacity(0.12),
                          border: Border.all(color: _red, width: 1.6),
                        ),
                        child: const Icon(Icons.close, color: _red, size: 36),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Email Confirmation Unsuccessful',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Material(
                  color: _red,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _handleTryAgain(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Try Again',
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
