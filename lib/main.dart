import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'screens/verify_email_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'screens/reset_password_screen.dart';
import 'dart:io';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  if (kDebugMode) {
    HttpOverrides.global = DevHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NBEApp());
}

class NBEApp extends StatefulWidget {
  const NBEApp({super.key});

  @override
  State<NBEApp> createState() => _NBEAppState();
}

class _NBEAppState extends State<NBEApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleIncomingLink(initialUri);
      }
    } catch (e) {
      debugPrint("Failed to get initial link: $e");
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingLink(uri);
    }, onError: (err) {
      debugPrint("Link stream error: $err");
    });
  }

  void _handleIncomingLink(Uri uri) {
    debugPrint("🔗 Link detected by app_links: $uri");

    final email = uri.queryParameters['email'];
    final token = uri.queryParameters['token'];

    if (email != null && token != null) {
      if (uri.scheme == 'nbepocket' && uri.host == 'reset-password') {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (context) =>
                  ResetPasswordScreen(email: email, token: token)),
        );
      } else if (uri.scheme == 'nbepocket' && uri.host == 'verify-email') {
        // ADDED THIS: Route for email verification
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (context) =>
                  VerifyEmailScreen(email: email, token: token)),
        );
      }
    } else {
      debugPrint("❌ ERROR: Missing email or token in the URL!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NBE',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),

      // 1. ADDED THIS: Flutter natively intercepts deep links here!
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.contains('token=')) {
          final uri = Uri.parse(settings.name!);
          final email = uri.queryParameters['email'];
          final token = uri.queryParameters['token'];

          if (email != null && token != null) {
            // Check if the URL contains reset-password or verify-email
            if (settings.name!.contains('reset-password')) {
              return MaterialPageRoute(
                builder: (context) =>
                    ResetPasswordScreen(email: email, token: token),
              );
            } else if (settings.name!.contains('verify-email')) {
              // ADDED THIS: Native route for email verification
              return MaterialPageRoute(
                builder: (context) =>
                    VerifyEmailScreen(email: email, token: token),
              );
            }
          }
        }
        return null;
      },

      // 2. This now acts as a true safety net, not a screen hider
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      },
    );
  }
}
