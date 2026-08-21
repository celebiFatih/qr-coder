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

      // onChanged() enables the delete button via setState(). Pump once so the
      // rebuilt FilledButton has a non-null onPressed before tapping it.
      await tester.pump();

      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete'),
      );
      expect(deleteButton.onPressed, isNotNull);

      final pendingResult = dialogResult;
      expect(pendingResult, isNotNull);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));

      // Start the reverse transition, then await the actual result returned by
      // Navigator.pop().
      await tester.pump();
      final result = await pendingResult!;

      // Complete the route removal and verify the controller remained valid
      // for the whole dialog lifecycle.
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
