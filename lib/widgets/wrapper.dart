import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/views/login_page.dart';
import 'package:qr_coder/views/qr_code_generator_page.dart';
import 'package:qr_coder/views/verification_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  StreamSubscription<User?>? _authStateSubscription;
  late bool isGuest;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = Auth().authStateChanges.listen((User? user) {
      setState(() {});
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
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text(AppLocalizations.of(context)!.wrapper_LoginPageToolTip),
          );
        } else {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            if (user.emailVerified) {
              return const QRCodeGenerator();
            } else {
              // Kullanıcı doğrulama aşamasında ise durumu kaydet
              _saveVerificationState(true);
              return const VerificationPage();
            }
          } else if (isGuest) {
            return const QRCodeGenerator();
          } else {
            return LoginPage();
          }
        }
      },
    );
  }

  Future<void> _saveVerificationState(bool isVerificationPending) async {
    final prefs = await Constants().prefs;
    await prefs.setBool('isVerificationPending', isVerificationPending);
  }
}
