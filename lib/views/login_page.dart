import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/viewmodels/locale_provider.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/views/forgot_passw_page.dart';
import 'package:qr_coder/widgets/wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _emailFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final locale = Localizations.localeOf(context);
    final localeChanged = _lastLocale != null && _lastLocale != locale;
    _lastLocale = locale;

    if (!localeChanged) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final emailFieldState = _emailFieldKey.currentState;
      final passwordFieldState = _passwordFieldKey.currentState;

      // Recalculate only validation errors that are already visible.
      // Changing language must not introduce errors on untouched fields.
      if (emailFieldState?.hasError ?? false) {
        emailFieldState!.validate();
      }

      if (passwordFieldState?.hasError ?? false) {
        passwordFieldState!.validate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginPageViewmodel>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final isPhone = w < 600;
                  final cardMaxWidth = isPhone
                      ? w.clamp(320.0, 420.0)
                      : w.clamp(520.0, 560.0);

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: cardMaxWidth,
                        maxHeight: h,
                      ),
                      child: _buildMainContent(context, isPhone, viewModel),
                    ),
                  );
                },
              ),
              _buildLanguageChoice(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    bool isPhone,
    LoginPageViewmodel viewModel,
  ) {
    final pad = EdgeInsets.symmetric(
      horizontal: isPhone ? 20 : 32,
      vertical: isPhone ? 20 : 28,
    );
    return Card(
      child: SingleChildScrollView(
        padding: pad,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(isPhone),
            _gap(),
            _buildWelcomeText(context, isPhone),
            _buildDescriptionText(context, isPhone),
            _gap(),
            _buildEmailField(viewModel, context),
            _gap(),
            _buildPasswordField(context),
            Align(
              alignment: Alignment.centerRight,
              child: _buildForgotPasswordButton(context),
            ),
            _gap(),
            _buildRememberMeCheckbox(context, isPhone),
            _gap(),
            Consumer<LoginPageViewmodel>(
              builder: (context, value, child) => viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : _buildSubmitButton(context, isPhone, viewModel),
            ),
            _gap(),
            _buildLoginOrRegisterToggle(context),
            _gap(),
            _buildGuestAccessButton(context),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);

  Widget _buildLanguageChoice(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FilledButton.tonal(
          onPressed: () {
            if (localeProvider.locale?.languageCode != 'tr') {
              localeProvider.setLocale(const Locale('tr'));
            } else {
              localeProvider.setLocale(const Locale('en'));
            }
          },
          child: Text(
            localeProvider.locale?.languageCode == 'tr' ? 'EN' : 'TR',
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isPhone) {
    return Image.asset('assets/img/logo.png', width: isPhone ? 84 : 120);
  }

  Widget _buildWelcomeText(BuildContext context, bool isPhone) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        AppLocalizations.of(context)!.login_WelcomeText,
        // telefonlarda headlineMedium, büyüklerde headlineLarge
        style: isPhone
            ? Theme.of(context).textTheme.headlineMedium
            : Theme.of(context).textTheme.headlineLarge,
        textAlign: TextAlign.center,
        maxLines: 2,
        softWrap: true,
      ),
    );
  }

  Widget _buildDescriptionText(BuildContext context, bool isPhone) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        AppLocalizations.of(context)!.login_DescriptionText,
        style: isPhone
            ? Theme.of(context).textTheme.bodyLarge
            : Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmailField(LoginPageViewmodel viewModel, BuildContext context) {
    return TextFormField(
      key: _emailFieldKey,
      controller: viewModel.emailController,
      validator: (value) => viewModel.emailValidator(value, context),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.login_label_email,
        hintText: AppLocalizations.of(context)!.login_hint_email,
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: viewModel.clearLoginForm,
        ),
        border: const OutlineInputBorder(),
      ),
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Consumer<LoginPageViewmodel>(
      builder: (context, viewModel, child) {
        return TextFormField(
          key: _passwordFieldKey,
          controller: viewModel.passwordController,
          validator: (value) => viewModel.passwordValidator(value, context),
          obscureText: !viewModel.isPasswordVisible,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.login_label_password,
            hintText: AppLocalizations.of(context)!.login_hint_password,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.isPasswordVisible
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
              ),
              onPressed: () =>
                  viewModel.isPasswordVisible = !viewModel.isPasswordVisible,
            ),
          ),
          onFieldSubmitted: (value) async =>
              await _loginControl(viewModel, context),
        );
      },
    );
  }

  Widget _buildRememberMeCheckbox(BuildContext context, bool isPhone) {
    return Consumer<LoginPageViewmodel>(
      builder: (context, viewModel, child) {
        return CheckboxListTile(
          value: viewModel.rememberMe,
          onChanged: (value) {
            if (value == null) return;
            viewModel.rememberMe = value;
          },
          title: Text(
            AppLocalizations.of(context)!.login_RememberMeCheckbox,
            style: isPhone
                ? Theme.of(context).textTheme.bodyMedium
                : Theme.of(context).textTheme.bodyLarge,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: const EdgeInsets.all(0),
        );
      },
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    bool isPhone,
    LoginPageViewmodel viewModel,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Consumer<LoginPageViewmodel>(
            builder: (context, viewModel, child) {
              return Text(
                !viewModel.isLogin
                    ? AppLocalizations.of(context)!.login_SubmitButtonLogIn
                    : AppLocalizations.of(context)!.login_SubmitButtonRegister,
                style: isPhone
                    ? Theme.of(context).textTheme.bodyLarge
                    : Theme.of(context).textTheme.headlineSmall,
              );
            },
          ),
        ),
        onPressed: () async {
          // "Giriş yapılamadı!"

          await _loginControl(viewModel, context);
        },
      ),
    );
  }

  Future<void> _loginControl(
    LoginPageViewmodel viewModel,
    BuildContext context,
  ) async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final signInErrorMsg = l10n.login_signInErrorMsg;
    final createUserErrorMsg = l10n.login_createUserErrorMsg;
    final emailAlreadyRegisteredMsg = l10n.login_emailAlreadyRegistered;
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();

      if (!viewModel.isLogin) {
        await viewModel.signIn(signInErrorMsg: signInErrorMsg);
      } else {
        // Firebase createUser() oturumu hemen açtığı için Wrapper, bu async
        // işlem tamamlanmadan VerificationPage'i build edebilir. Global VM'i
        // await öncesinde alıp ilk mail gerçekten gönderildiğinde cooldown'ı
        // doğrudan ona bildiriyoruz.
        final verificationPageViewModel = context
            .read<VerificationPageViewModel>();

        final verificationEmailSentUserId = await viewModel.createUser(
          createUserErrorMsg: createUserErrorMsg,
          emailAlreadyRegisteredMsg: emailAlreadyRegisteredMsg,
        );

        if (verificationEmailSentUserId != null) {
          await verificationPageViewModel.markInitialVerificationEmailSent(
            verificationEmailSentUserId,
          );
        }
      }
      if (viewModel.errorMsg.isNotEmpty) {
        if (!context.mounted) return;
        scaffoldContext.showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMsg, textAlign: TextAlign.center),
          ),
        );
        return;
      }

      // Hem başarılı giriş hem de başarılı kayıt akışında oturum artık
      // Firebase tarafında oluşturulmuştur. Guest bayrağını temizliyoruz;
      // doğrulanmış/doğrulanmamış kullanıcı yönlendirmesini Wrapper yönetir.
      await viewModel.saveRememberedEmail();
      final prefs = await Constants().prefs;
      await prefs.setBool('isGuest', false);

      // Firebase oturumu oluşturulduktan sonra parolaya artık ihtiyaç yok.
      // ViewModel uygulama ömrü boyunca Provider içinde yaşayabildiği için
      // hassas değeri bellekten de temizliyoruz.
      viewModel.clearPasswordField();

      // Başarılı giriş/kayıt sonrasında route değiştirmiyoruz.
      // Wrapper, Firebase userChanges akışını dinlediği için kullanıcı
      // durumuna göre QR veya doğrulama ekranını kendisi gösterecek.
    }
  }

  Widget _buildLoginOrRegisterToggle(BuildContext context) {
    return Consumer<LoginPageViewmodel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () {
            viewModel.isLogin = !viewModel.isLogin;
          },
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: !viewModel.isLogin
                      ? AppLocalizations.of(context)!
                            .login_LoginOrRegisterToggle
                      : AppLocalizations.of(context)!
                            .login_LoginOrRegisterToggleAlreadyHaveAccount,
                ),
                TextSpan(
                  text: !viewModel.isLogin
                      ? '${AppLocalizations.of(context)!.login_SubmitButtonRegister}!'
                      : '${AppLocalizations.of(context)!.login_SubmitButtonLogIn}!',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestAccessButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Constants().prefs.then((prefs) => prefs.setBool('isGuest', true));
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Wrapper()),
          (Route<dynamic> route) => false,
        );
      },
      child: Text(
        AppLocalizations.of(context)!.login_GuestAccessButton,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForgotPasswPage()),
      ),
      child: Text(
        AppLocalizations.of(context)!.login_ForgotPasswordButton,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }
}
