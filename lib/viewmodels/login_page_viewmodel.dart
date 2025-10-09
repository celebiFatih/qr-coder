import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';

class LoginPageViewmodel extends ChangeNotifier {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLogin = false;
  bool _isLoading = false;
  String _errorMsg = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  LoginPageViewmodel() {
    loadSavedCredentials();
  }

  bool get isPasswordVisible => _isPasswordVisible;
  bool get rememberMe => _rememberMe;
  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;
  String get errorMsg => _errorMsg;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  FocusNode get passwordFocusNode => _passwordFocusNode;
  FocusNode get emailFocusNode => _emailFocusNode;

  void clearAll() {
    if (!rememberMe) {
      _emailController.clear();
      _passwordController.clear();
      _isPasswordVisible = false;
      _rememberMe = false;
      _isLogin = false;
      _isLoading = false;
      _errorMsg = '';
      notifyListeners();
    }
  }

  void clearLoginForm() {
    _emailController.clear();
    _passwordController.clear();
    _isPasswordVisible = false;
    _rememberMe = false;
    _isLogin = false;
    _isLoading = false;
    _errorMsg = '';
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    // clearLoginForm();
    super.dispose();
  }

  set isPasswordVisible(bool value) {
    if (_isPasswordVisible != value) {
      _isPasswordVisible = value;
      notifyListeners();
    }
  }

  set rememberMe(bool value) {
    if (_rememberMe != value) {
      _rememberMe = value;
      notifyListeners();
    }
  }

  set isLogin(bool value) {
    if (_isLogin != value) {
      _isLogin = value;
      notifyListeners();
    }
  }

  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  set errorMsg(String value) {
    if (_errorMsg != value) {
      _errorMsg = value;
      notifyListeners();
    }
  }

  String? emailValidator(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.login_emailValidator;
    }

    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (!emailValid) {
      return AppLocalizations.of(context)!.login_emailValidatorError;
    }

    return null;
  }

  String? passwordValidator(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.login_passwordValidator;
    }

    if (value.length < 6) {
      return AppLocalizations.of(context)!.login_passwordValidatorError;
    }
    return null;
  }

  Future<void> createUser(
      BuildContext context,
      ScaffoldMessengerState scaffoldMessenger,
      String sendVerificationEmailMsg) async {
    errorMsg = '';
    isLoading = true;
    try {
      final userCredential = await Auth().createUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      await userCredential.user!.sendEmailVerification();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            sendVerificationEmailMsg,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final existingUser = await Auth().signIn(
            email: emailController.text.trim(),
            password: passwordController.text.trim());
        if (!existingUser.user!.emailVerified) {
          await existingUser.user!.sendEmailVerification();
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: AppLocalizations.of(context)!
                .login_emailNotVerifiedMsg, // "E-posta doğrulaması yapılmadı. Lütfen e-postanızı kontrol edin."
          );
        }
      }
      errorMsg = AppLocalizations.of(context)!.login_createUserErrorMsg;
    } finally {
      isLoading = false;
    }
  }

  Future<void> signIn(BuildContext context, String emailNotVerifiedMsg,
      String signInErrorMsg, ScaffoldMessengerState scaffoldMessenger) async {
    errorMsg = '';
    isLoading = true;

    try {
      final userCredential = await Auth().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        await Auth().signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: emailNotVerifiedMsg,
        );
      }
      // isLogin = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-not-verified') {
        errorMsg = e.message ?? 'E-posta doğrulaması yapılmadı.';
        scaffoldMessenger
            .showSnackBar(SnackBar(content: Text(emailNotVerifiedMsg)));
      } else {
        errorMsg = signInErrorMsg;
        // scaffoldMessenger.showSnackBar(
        //   SnackBar(
        //     content: Text(errorMsg),
        //   ),
        // );
      }
      // errorMsg = e.code == 'invalid-credential'
      //     ? AppLocalizations.of(context)!.login_invalidCredentialsErrMsg
      //     : AppLocalizations.of(context)!.login_signInErrorMsg;
      print(e.code);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await Constants().prefs;
    final savedEmail = prefs.getString('email') ?? '';
    final savedPassword = prefs.getString('password') ?? '';
    rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      rememberMe = true;
      notifyListeners();
    }
  }

  Future<void> saveCredentials() async {
    final prefs = await Constants().prefs;
    if (rememberMe) {
      await prefs.setString('email', emailController.text.trim());
      await prefs.setString('password', passwordController.text.trim());
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  void setLoginOrRegisterState() {
    isLogin = !isLogin;
    notifyListeners();
  }
}
