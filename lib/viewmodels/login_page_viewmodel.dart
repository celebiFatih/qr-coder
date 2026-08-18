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

  void clearAll() {
    // Oturum kapandığında parola her durumda bellekten temizlenir.
    // "E-postamı hatırla" açıksa yalnızca e-posta alanı korunur.
    if (!rememberMe) {
      _emailController.clear();
    }
    _passwordController.clear();
    _isPasswordVisible = false;
    _isLogin = false;
    _isLoading = false;
    _errorMsg = '';
    notifyListeners();
  }

  void clearPasswordField() {
    _passwordController.clear();
    _isPasswordVisible = false;
    notifyListeners();
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
    _emailController.dispose();
    _passwordController.dispose();
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
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);
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

  Future<void> createUser({
    required String createUserErrorMsg,
    required String emailAlreadyRegisteredMsg,
  }) async {
    errorMsg = '';
    isLoading = true;

    try {
      final userCredential = await Auth().createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      try {
        await userCredential.user?.sendEmailVerification();
      } catch (e) {
        // Hesap başarıyla oluşturulmuş durumda. Doğrulama e-postasının ilk
        // gönderimi başarısız olursa kullanıcı VerificationPage üzerinden
        // yeniden gönderebilir; hesabı başarısız saymıyoruz.
        debugPrint('Initial verification email failed: $e');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMsg = emailAlreadyRegisteredMsg;
      } else {
        errorMsg = createUserErrorMsg;
      }
      debugPrint('Firebase create-user error: ${e.code}');
    } catch (e) {
      errorMsg = createUserErrorMsg;
      debugPrint('Create-user error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String signInErrorMsg}) async {
    errorMsg = '';
    isLoading = true;

    try {
      await Auth().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // E-posta doğrulama durumuna burada müdahale etmiyoruz. Başarılı
      // oturumdan sonra Wrapper, userChanges üzerinden doğrulanmış kullanıcıyı
      // QRCodeGenerator'a; doğrulanmamış kullanıcıyı VerificationPage'e yollar.
    } on FirebaseAuthException catch (e) {
      errorMsg = signInErrorMsg;
      debugPrint('Firebase sign-in error: ${e.code}');
    } catch (e) {
      errorMsg = signInErrorMsg;
      debugPrint('Sign-in error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await Constants().prefs;
    final savedEmail = prefs.getString('email') ?? '';
    rememberMe = prefs.getBool('rememberMe') ?? false;

    // Eski sürümler parolayı SharedPreferences içinde düz metin olarak
    // saklıyordu. Uygulama bu sürüme yükseltildiğinde legacy değeri hemen
    // siliyoruz ve parola alanını hiçbir zaman diskten doldurmuyoruz.
    await prefs.remove('password');
    _passwordController.clear();

    if (rememberMe) {
      _emailController.text = savedEmail;
    } else {
      _emailController.clear();
    }
    notifyListeners();
  }

  Future<void> saveRememberedEmail() async {
    final prefs = await Constants().prefs;

    // Güvenlik migrasyonu: hangi durumda olursa olsun eski parola anahtarını
    // kalıcı depolamadan temiz tut.
    await prefs.remove('password');

    if (rememberMe) {
      await prefs.setString('email', emailController.text.trim());
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.setBool('rememberMe', false);
    }
  }

  void setLoginOrRegisterState() {
    isLogin = !isLogin;
    notifyListeners();
  }
}
