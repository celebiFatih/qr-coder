import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

  Future<void> reloadAndCheckEmailVerfication() async {
    if (_auth.currentUser != null) {
      await _auth.currentUser?.reload();
      if (_auth.currentUser!.emailVerified) {
        print("Kullanıcı doğrulaması tamamlandı!");
      } else {
        print("Kullanıcı doğrulaması tamamlanamadı!");
      }
    }
  }

  // Create a new user with email and password
  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
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
