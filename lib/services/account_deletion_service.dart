import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class AccountDeletionService {
  AccountDeletionService({FirebaseAuth? auth, FirebaseDatabase? database})
    : _auth = auth ?? FirebaseAuth.instance,
      _database = database ?? FirebaseDatabase.instance;

  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  Future<void> deleteCurrentAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no signed-in user to delete.',
      );
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'The signed-in account does not have an e-mail address.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final userRef = _database.ref().child('users/${user.uid}');

    await runDeletionTransaction(
      reauthenticate: () async {
        await user.reauthenticateWithCredential(credential);
      },
      readCloudData: () async {
        final snapshot = await userRef.get();
        return snapshot.value;
      },
      deleteCloudData: () => userRef.remove(),
      deleteAuthUser: user.delete,
      restoreCloudData: (backup) async {
        if (backup == null || _auth.currentUser?.uid != user.uid) {
          return;
        }

        await userRef.set(backup);
      },
    );
  }

  /// Firebase Authentication and Realtime Database cannot be deleted in one
  /// cross-product transaction. Re-authentication happens first, then the
  /// user's cloud data is backed up and removed before deleting the Auth user.
  ///
  /// If the final Auth deletion fails while the user is still signed in, the
  /// cloud data is restored best-effort so a transient failure does not leave
  /// an active account with an unexpectedly empty QR list.
  @visibleForTesting
  static Future<void> runDeletionTransaction({
    required Future<void> Function() reauthenticate,
    required Future<Object?> Function() readCloudData,
    required Future<void> Function() deleteCloudData,
    required Future<void> Function() deleteAuthUser,
    required Future<void> Function(Object? backup) restoreCloudData,
  }) async {
    await reauthenticate();
    final backup = await readCloudData();
    await deleteCloudData();

    try {
      await deleteAuthUser();
    } catch (error) {
      try {
        await restoreCloudData(backup);
      } catch (restoreError) {
        debugPrint(
          'Account deletion rollback failed after Auth delete error: '
          '$restoreError',
        );
      }
      rethrow;
    }
  }
}
