import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/services/firebase_options.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/lcoale_provider.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/widgets/theme_data.dart';
import 'package:qr_coder/widgets/wrapper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  unawaited(MobileAds.instance.initialize());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(
            create: (context) => QRCodeViewModel(
                isFirebaseUser: Auth().currentUser != null,
                uid: Auth().currentUser?.uid)),
        ChangeNotifierProvider(
            create: (context) => BarcodeScannerViewmodel(
                  isFirebaseUser: Auth().currentUser != null,
                  uid: Auth().currentUser?.uid,
                )),
        ChangeNotifierProvider(create: (context) => LoginPageViewmodel()),
        ChangeNotifierProvider(
            create: (context) => QrCodeListPageViewmodel(
                isFirebaseUser: Auth().currentUser != null,
                uid: Auth().currentUser?.uid)),
        ChangeNotifierProvider(
            create: (context) => VerificationPageViewModel()),
        ChangeNotifierProvider(create: (context) => ForgotPasswPageViewmodel()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale ??
              Locale(Platform.localeName.split('_').first),
          supportedLocales: const [Locale('en'), Locale('tr')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          title: 'QR Code Generator',
          theme: AppTheme.lightTheme,
          home: const Wrapper(),
        );
      },
    );
  }
}
