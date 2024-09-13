import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  Future<void> createUser(BuildContext context) async {
    errorMsg = '';
    isLoading = true;
    try {
      await Auth().createUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      await Auth().sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      errorMsg = e.code == 'email-already-in-use'
          ? AppLocalizations.of(context)!.login_emailAlreadyRegistered
          : AppLocalizations.of(context)!.login_createUserErrorMsg;
    } finally {
      isLoading = false;
    }
  }

  Future<void> signIn(BuildContext context) async {
    errorMsg = '';
    isLoading = true;
    try {
      await Auth().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      // await Auth().reloadUser();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.login_signInSuccessMsg,
            textAlign: TextAlign.center,
          ),
        ),
      );
      isLogin = true;
    } on FirebaseAuthException catch (e) {
      errorMsg = e.code == 'invalid-credential'
          ? AppLocalizations.of(context)!.login_invalidCredentialsErrMsg
          : AppLocalizations.of(context)!.login_signInErrorMsg;
      print(e.code);
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
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
    final prefs = await SharedPreferences.getInstance();
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
