import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/viewmodels/locale_provider.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/views/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildLocaleSwitchingLoginApp(
  LoginPageViewmodel loginViewModel,
  LocaleProvider localeProvider,
  ValueNotifier<Locale> localeNotifier,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LoginPageViewmodel>.value(value: loginViewModel),
      ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
    ],
    child: ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoginPage(),
        );
      },
    ),
  );
}

Future<void> _tapSubmitButton(WidgetTester tester) async {
  final submitButton = find.byType(ElevatedButton);

  await tester.ensureVisible(submitButton);
  await tester.pumpAndSettle();
  await tester.tap(submitButton);
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('visible login validation errors update when locale changes', (
    tester,
  ) async {
    final loginViewModel = LoginPageViewmodel();
    final localeProvider = LocaleProvider();
    final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

    addTearDown(loginViewModel.dispose);
    addTearDown(localeProvider.dispose);
    addTearDown(localeNotifier.dispose);

    await tester.pumpWidget(
      _buildLocaleSwitchingLoginApp(
        loginViewModel,
        localeProvider,
        localeNotifier,
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));

    await tester.enterText(fields.at(0), 'not-an-email');
    await tester.enterText(fields.at(1), '123456');
    await _tapSubmitButton(tester);

    expect(find.text('Please enter a valid email'), findsOneWidget);

    localeNotifier.value = const Locale('tr');
    await tester.pumpAndSettle();

    expect(find.text('Lütfen geçerli bir e-posta girin'), findsOneWidget);
    expect(find.text('Please enter a valid email'), findsNothing);
  });

  testWidgets(
    'locale change does not introduce validation errors on untouched fields',
    (tester) async {
      final loginViewModel = LoginPageViewmodel();
      final localeProvider = LocaleProvider();
      final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

      addTearDown(loginViewModel.dispose);
      addTearDown(localeProvider.dispose);
      addTearDown(localeNotifier.dispose);

      await tester.pumpWidget(
        _buildLocaleSwitchingLoginApp(
          loginViewModel,
          localeProvider,
          localeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      localeNotifier.value = const Locale('tr');
      await tester.pumpAndSettle();

      expect(find.text('Lütfen geçerli bir e-posta girin'), findsNothing);
    },
  );
}
