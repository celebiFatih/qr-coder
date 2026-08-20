import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/services/account_deletion_service.dart';

void main() {
  test(
    'account deletion runs reauth, backup, data delete, then Auth delete',
    () async {
      final events = <String>[];

      await AccountDeletionService.runDeletionTransaction(
        reauthenticate: () async => events.add('reauth'),
        readCloudData: () async {
          events.add('backup');
          return <String, Object?>{'qrcodes': 'data'};
        },
        deleteCloudData: () async => events.add('delete-data'),
        deleteAuthUser: () async => events.add('delete-auth'),
        restoreCloudData: (_) async => events.add('restore'),
      );

      expect(events, <String>[
        'reauth',
        'backup',
        'delete-data',
        'delete-auth',
      ]);
    },
  );

  test('Auth deletion failure restores cloud data before rethrowing', () async {
    final events = <String>[];
    Object? restoredBackup;
    final backup = <String, Object?>{'qrcodes': 'data'};

    await expectLater(
      AccountDeletionService.runDeletionTransaction(
        reauthenticate: () async => events.add('reauth'),
        readCloudData: () async {
          events.add('backup');
          return backup;
        },
        deleteCloudData: () async => events.add('delete-data'),
        deleteAuthUser: () async {
          events.add('delete-auth');
          throw Exception('auth-delete-failed');
        },
        restoreCloudData: (value) async {
          events.add('restore');
          restoredBackup = value;
        },
      ),
      throwsException,
    );

    expect(events, <String>[
      'reauth',
      'backup',
      'delete-data',
      'delete-auth',
      'restore',
    ]);
    expect(restoredBackup, same(backup));
  });

  test('data deletion failure never deletes the Auth user', () async {
    var authDeleteCalled = false;

    await expectLater(
      AccountDeletionService.runDeletionTransaction(
        reauthenticate: () async {},
        readCloudData: () async => <String, Object?>{'qrcodes': 'data'},
        deleteCloudData: () async => throw Exception('db-delete-failed'),
        deleteAuthUser: () async => authDeleteCalled = true,
        restoreCloudData: (_) async {},
      ),
      throwsException,
    );

    expect(authDeleteCalled, isFalse);
  });
}
