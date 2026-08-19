import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/views/verification_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'verification flow starts after first build without provider build error',
    (tester) async {
      final viewModel = VerificationPageViewModel(
        currentUserId: () => 'widget-user',
        checkEmailVerifiedAction: () async => false,
        sendVerificationEmailAction: () async {},
        verificationCheckInterval: const Duration(seconds: 30),
      );
      addTearDown(viewModel.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<VerificationPageViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const VerificationPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      viewModel.pauseVerificationFlow();
    },
  );
}
