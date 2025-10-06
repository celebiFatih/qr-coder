import 'dart:async';

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
  StreamSubscription<User?>? _authStateSubscription;
  bool isGuest = false;

  // Aynı frame içinde tekrar tekrar yazmayı önlemek için:
  bool _savedPendingTrue = false;
  bool _savedPendingFalse = false;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = Auth().authStateChanges.listen((_) {
      if (mounted) setState(() {});
    });
    _checkIfGuest();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
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
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text(AppLocalizations.of(context)!.wrapper_LoginPageToolTip),
          );
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.emailVerified) {
            if (!_savedPendingFalse) {
              _savedPendingFalse = true;
              _savedPendingTrue = false;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _saveVerificationState(false);
              });
            }
            return const QRCodeGenerator();
          } else {
            if (!_savedPendingTrue) {
              _savedPendingTrue = true;
              _savedPendingFalse = false;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _saveVerificationState(true);
              });
            }
            return const VerificationPage();
          }
        }
        if (isGuest) return const QRCodeGenerator();
        return LoginPage();
      },
    );
  }

  Future<void> _saveVerificationState(bool isVerificationPending) async {
    final prefs = await Constants().prefs;
    await prefs.setBool('isVerificationPending', isVerificationPending);
  }
}
