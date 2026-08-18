import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/views/login_page.dart';
import 'package:qr_coder/views/qr_code_generator_page.dart';
import 'package:qr_coder/views/verification_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool? isGuest;

  @override
  void initState() {
    super.initState();
    _checkIfGuest();
  }

  Future<void> _checkIfGuest() async {
    final prefs = await Constants().prefs;
    if (!mounted) return;
    setState(() {
      isGuest = prefs.getBool('isGuest') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('Authentication stream error: ${snapshot.error}');
          return Center(
            child: Text(AppLocalizations.of(context)!.wrapper_LoginPageToolTip),
          );
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return user.emailVerified
              ? const QRCodeGenerator()
              : const VerificationPage();
        }

        if (isGuest == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (isGuest!) return const QRCodeGenerator();
        return LoginPage();
      },
    );
  }
}
