import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/viewmodels/locale_provider.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/views/forgot_passw_page.dart';
import 'package:qr_coder/widgets/app_auth_layout.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/app_layout.dart';
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
    final viewModel = context.watch<LoginPageViewmodel>();

    return AppPageScaffold(
      body: Form(
        key: _formKey,
        child: AppAuthPageFrame(
          child: AppSurface(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLanguageChoice(context),
                  const SizedBox(height: AppSpacing.xs),
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildEmailField(viewModel, context),
                  const SizedBox(height: AppSpacing.md),
                  _buildPasswordField(context, viewModel),
                  if (!viewModel.isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildForgotPasswordButton(context),
                    )
                  else
                    const SizedBox(height: AppSpacing.xs),
                  _buildRememberMeCheckbox(context, viewModel),
                  const SizedBox(height: AppSpacing.md),
                  _buildSubmitButton(context, viewModel),
                  const SizedBox(height: AppSpacing.sm),
                  _buildLoginOrRegisterToggle(context, viewModel),
                  const SizedBox(height: AppSpacing.xs),
                  _buildGuestAccessButton(context, viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageChoice(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Align(
      alignment: Alignment.centerRight,
      child: FilledButton.tonal(
        onPressed: () {
          if (localeProvider.locale?.languageCode != 'tr') {
            localeProvider.setLocale(const Locale('tr'));
          } else {
            localeProvider.setLocale(const Locale('en'));
          }
        },
        child: Text(localeProvider.locale?.languageCode == 'tr' ? 'EN' : 'TR'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Image.asset('assets/img/logo.png', width: 72),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppLocalizations.of(context)!.login_WelcomeText,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppLocalizations.of(context)!.login_DescriptionText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(LoginPageViewmodel viewModel, BuildContext context) {
    return TextFormField(
      key: _emailFieldKey,
      controller: viewModel.emailController,
      enabled: !viewModel.isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      validator: (value) => viewModel.emailValidator(value, context),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.login_label_email,
        hintText: AppLocalizations.of(context)!.login_hint_email,
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: viewModel.isLoading ? null : viewModel.clearLoginForm,
        ),
      ),
      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
    );
  }

  Widget _buildPasswordField(
    BuildContext context,
    LoginPageViewmodel viewModel,
  ) {
    return TextFormField(
      key: _passwordFieldKey,
      controller: viewModel.passwordController,
      enabled: !viewModel.isLoading,
      validator: (value) => viewModel.passwordValidator(value, context),
      obscureText: !viewModel.isPasswordVisible,
      textInputAction: TextInputAction.done,
      autofillHints: [
        viewModel.isLogin ? AutofillHints.newPassword : AutofillHints.password,
      ],
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.login_label_password,
        hintText: AppLocalizations.of(context)!.login_hint_password,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.isPasswordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
          ),
          onPressed: viewModel.isLoading
              ? null
              : () =>
                    viewModel.isPasswordVisible = !viewModel.isPasswordVisible,
        ),
      ),
      onFieldSubmitted: (_) async => _loginControl(viewModel, context),
    );
  }

  Widget _buildRememberMeCheckbox(
    BuildContext context,
    LoginPageViewmodel viewModel,
  ) {
    return CheckboxListTile(
      value: viewModel.rememberMe,
      onChanged: viewModel.isLoading
          ? null
          : (value) {
              if (value == null) return;
              viewModel.rememberMe = value;
            },
      title: Text(AppLocalizations.of(context)!.login_RememberMeCheckbox),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    LoginPageViewmodel viewModel,
  ) {
    final label = !viewModel.isLogin
        ? AppLocalizations.of(context)!.login_SubmitButtonLogIn
        : AppLocalizations.of(context)!.login_SubmitButtonRegister;

    return FilledButton(
      onPressed: viewModel.isLoading
          ? null
          : () async => _loginControl(viewModel, context),
      child: viewModel.isLoading
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Text(label),
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

  Widget _buildLoginOrRegisterToggle(
    BuildContext context,
    LoginPageViewmodel viewModel,
  ) {
    return TextButton(
      onPressed: viewModel.isLoading
          ? null
          : () => viewModel.isLogin = !viewModel.isLogin,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: !viewModel.isLogin
                  ? AppLocalizations.of(context)!.login_LoginOrRegisterToggle
                  : AppLocalizations.of(context)!
                        .login_LoginOrRegisterToggleAlreadyHaveAccount,
            ),
            TextSpan(
              text: !viewModel.isLogin
                  ? '${AppLocalizations.of(context)!.login_SubmitButtonRegister}!'
                  : '${AppLocalizations.of(context)!.login_SubmitButtonLogIn}!',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGuestAccessButton(
    BuildContext context,
    LoginPageViewmodel viewModel,
  ) {
    return OutlinedButton.icon(
      onPressed: viewModel.isLoading
          ? null
          : () async {
              await Constants().prefs.then(
                (prefs) => prefs.setBool('isGuest', true),
              );
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Wrapper()),
                (Route<dynamic> route) => false,
              );
            },
      icon: const Icon(Icons.person_outline_rounded),
      label: Text(AppLocalizations.of(context)!.login_GuestAccessButton),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ForgotPasswPage()),
      ),
      child: Text(AppLocalizations.of(context)!.login_ForgotPasswordButton),
    );
  }
}
