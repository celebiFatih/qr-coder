import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/services/firebase_options.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/locale_provider.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_display_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/views/verification_page.dart';
import 'package:qr_coder/widgets/rewarded_add_service.dart';
import 'package:qr_coder/widgets/theme_data.dart';
import 'package:qr_coder/widgets/wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  await MobileAds.instance.initialize();

  if (!kReleaseMode) {
    // sadece debug
    // TEST CİHAZI BİLDİR
    final testId = dotenv.env['TEST_DEVICE_ID'];
    if (testId != null && testId.isNotEmpty) {
      await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: [testId]));
    }
  } else {
    // release'da testDeviceId yok
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: []),
    );
  }

  final rewardedAdService = RewardedAdService(
    addUnitId: dotenv.env['REWARDED_AD_UNIT_ID'],
  );

  final prefs = await Constants().prefs;
  final isVerificationPending = prefs.getBool('isVerificationPending') ?? false;
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
        ChangeNotifierProvider(
            create: (context) => QRCodeDisplayViewModel(rewardedAdService)),
      ],
      child: MainApp(
        homeWidget:
            isVerificationPending ? const VerificationPage() : const Wrapper(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  final Widget homeWidget;
  const MainApp({super.key, required this.homeWidget});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale ??
              Locale(Platform.localeName.split('_').first),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          title: 'QR Code Generator',
          theme: AppTheme.lightTheme,
          home: homeWidget,
        );
      },
    );
  }
}
