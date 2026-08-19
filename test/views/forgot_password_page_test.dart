import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';
import 'package:qr_coder/views/forgot_passw_page.dart';

class _ControlledForgotPasswordViewModel extends ForgotPasswPageViewmodel {
  final Completer<void> completer = Completer<void>();
  int sendCount = 0;

  @override
  Future<void> sendResetEmail(BuildContext context) async {
    sendCount += 1;
    errorMessage = '';
    isLoading = true;
    notifyListeners();

    await completer.future;

    isLoading = false;
    notifyListeners();
  }
}

Widget _buildTestApp(
  ForgotPasswPageViewmodel viewModel, {
  Locale locale = const Locale('en'),
}) {
  return ChangeNotifierProvider<ForgotPasswPageViewmodel>.value(
    value: viewModel,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ForgotPasswPage(),
    ),
  );
}

Widget _buildLocaleSwitchingTestApp(
  ForgotPasswPageViewmodel viewModel,
  ValueNotifier<Locale> localeNotifier,
) {
  return ChangeNotifierProvider<ForgotPasswPageViewmodel>.value(
    value: viewModel,
    child: ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ForgotPasswPage(),
        );
      },
    ),
  );
}

Future<void> _tapSubmitButton(WidgetTester tester) async {
  final buttonFinder = find.byType(ElevatedButton);

  // The default widget-test surface is 800x600. On this page the submit
  // button can be below the initial viewport, so scroll it into view before
  // tapping. This makes the test verify the real interaction instead of
  // missing the button because of the synthetic test viewport.
  await tester.ensureVisible(buttonFinder);
  await tester.pumpAndSettle();
  await tester.tap(buttonFinder);
  await tester.pump();
}

void main() {
  testWidgets('submit button is disabled while reset request is in progress', (
    tester,
  ) async {
    final viewModel = _ControlledForgotPasswordViewModel();

    await tester.pumpWidget(_buildTestApp(viewModel));
    await tester.enterText(find.byType(TextFormField), 'user@example.com');

    await _tapSubmitButton(tester);

    expect(viewModel.sendCount, 1);

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('invalid email validation uses the active localization', (
    tester,
  ) async {
    final viewModel = _ControlledForgotPasswordViewModel();

    await tester.pumpWidget(
      _buildTestApp(viewModel, locale: const Locale('en')),
    );
    await tester.enterText(find.byType(TextFormField), 'not-an-email');

    await _tapSubmitButton(tester);

    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(viewModel.sendCount, 0);
  });

  testWidgets('visible validation error updates when locale changes', (
    tester,
  ) async {
    final viewModel = _ControlledForgotPasswordViewModel();
    final localeNotifier = ValueNotifier<Locale>(const Locale('en'));
    addTearDown(localeNotifier.dispose);

    await tester.pumpWidget(
      _buildLocaleSwitchingTestApp(viewModel, localeNotifier),
    );
    await tester.enterText(find.byType(TextFormField), 'not-an-email');

    await _tapSubmitButton(tester);

    expect(find.text('Please enter a valid email'), findsOneWidget);

    localeNotifier.value = const Locale('tr');
    await tester.pumpAndSettle();

    expect(find.text('Lütfen geçerli bir e-posta girin'), findsOneWidget);
    expect(find.text('Please enter a valid email'), findsNothing);
  });
}
