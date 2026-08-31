import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import 'email_confirmed_screen.dart';
import 'email_confirmation_failed_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final String token;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

Future<void> _verifyEmail() async {
    try {
      // 1. Build the URL with the query parameters attached directly to it
      final url = Uri.parse(
        'http://10.0.2.2:5152/api/Auth/verify-email?email=${Uri.encodeComponent(widget.email)}&token=${Uri.encodeComponent(widget.token)}'
      );
      
      // 2. Change from http.post to http.get (No headers or body needed for GET!)
      final response = await http.get(url);

      if (!mounted) return;

      // Print the response so you can see it succeed in the debug console!
      print('==== API RESPONSE ====');
      print('STATUS CODE: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        // Success! Push the green success screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EmailConfirmedScreen()),
        );
      } else {
        // Failed! Push the red failure screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const EmailConfirmationFailedScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('NETWORK ERROR: $e');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmailConfirmationFailedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}