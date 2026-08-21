import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/widgets/account_deletion_password_dialog.dart';

void main() {
  testWidgets(
    'password controller stays alive until the dialog route is disposed',
    (tester) async {
      Future<String?>? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  dialogResult = showAccountDeletionPasswordDialog(
                    context: context,
                    title: 'Delete account?',
                    description: 'Enter password',
                    passwordLabel: 'Password',
                    cancelLabel: 'Cancel',
                    deleteLabel: 'Delete',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'wrong-password');
      await tester.tap(find.text('Delete'));

      final result = await dialogResult;

      // The Future returned by showDialog can complete before the reverse
      // transition has completely removed the route. Pump through that
      // transition and verify no disposed-controller exception is emitted.
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(result, 'wrong-password');
      expect(find.byType(AccountDeletionPasswordDialog), findsNothing);
    },
  );

  testWidgets('delete action is disabled until a password is entered', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccountDeletionPasswordDialog(
            title: 'Delete account?',
            description: 'Enter password',
            passwordLabel: 'Password',
            cancelLabel: 'Cancel',
            deleteLabel: 'Delete',
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete'),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'password');
    await tester.pump();

    final enabledButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Delete'),
    );
    expect(enabledButton.onPressed, isNotNull);
  });
}
