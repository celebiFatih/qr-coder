import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get userChanges => _auth.userChanges();

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Reload the user to get updated verification status
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  /// Realtime Database rules can inspect `auth.token.email_verified`.
  /// `User.emailVerified` may already be true after `reload()`, while the
  /// cached ID token still contains the older `email_verified: false` claim.
  /// Refresh only when the currently cached token does not yet carry the
  /// verified-email claim.
  Future<void> ensureVerifiedEmailIdToken() async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) {
      return;
    }

    final currentToken = await user.getIdTokenResult();
    if (currentToken.claims?['email_verified'] == true) {
      return;
    }

    final refreshedToken = await user.getIdTokenResult(true);
    if (refreshedToken.claims?['email_verified'] != true) {
      throw FirebaseAuthException(
        code: 'email-verification-token-not-refreshed',
        message:
            'Verified e-mail claim is not present in the refreshed ID token.',
      );
    }
  }

  Future<void> reloadAndCheckEmailVerfication() async {
    if (_auth.currentUser != null) {
      await _auth.currentUser?.reload();
      if (_auth.currentUser!.emailVerified) {
        debugPrint("Kullanıcı doğrulaması tamamlandı!");
      } else {
        debugPrint("Kullanıcı doğrulaması tamamlanamadı!");
      }
    }
  }

  // Create a new user with email and password
  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final UserCredential userCredential = await _auth
        .signInWithEmailAndPassword(email: email, password: password);
    await reloadUser();
    return userCredential;
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
    await reloadUser();
  }
}
