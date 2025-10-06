import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/views/qr_code_generator_page.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final viewModel = Provider.of<VerificationPageViewModel>(context);

    _checkEmailVerification(context, viewModel);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: _buildBody(context, viewModel, isSmallScreen),
    );
  }

  void _startEmailVerificationCheck() {
    final viewModel =
        Provider.of<VerificationPageViewModel>(context, listen: false);
    viewModel.startEmailVerificationCheckTimer();
  }

  void _checkEmailVerification(
      BuildContext context, VerificationPageViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (viewModel.emailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.verificationPage_emailVerifiedMsg,
                textAlign: TextAlign.center,
              ),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const QRCodeGenerator()),
          );
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, VerificationPageViewModel viewModel,
      bool isSmallScreen) {
    return Center(
      child: Card(
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(32.0),
          constraints: BoxConstraints(maxWidth: isSmallScreen ? 300 : 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(isSmallScreen),
                _gap(),
                _buildWelcomeText(context, isSmallScreen),
                _gap(),
                _buildDescriptionText(context, isSmallScreen),
                _gap(),
                _buildVerificationIndicator(viewModel),
                _gap(),
                _buildSubmitButton(context, isSmallScreen, viewModel),
                _gap(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 32);

  Widget _buildLogo(bool isSmallScreen) {
    return Image.asset('assets/img/logo.png', width: isSmallScreen ? 100 : 200);
  }

  Widget _buildWelcomeText(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        AppLocalizations.of(context)!.verificationPage_welcomeTitle,
        style: isSmallScreen
            ? Theme.of(context).textTheme.headlineLarge
            : Theme.of(context).textTheme.displayMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescriptionText(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        AppLocalizations.of(context)!.verificationPage_description,
        style: isSmallScreen
            ? Theme.of(context).textTheme.bodyMedium
            : Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isSmallScreen,
      VerificationPageViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            AppLocalizations.of(context)!.verificationPage_sendAgainBtn,
            style: isSmallScreen
                ? Theme.of(context).textTheme.bodyLarge
                : Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        onPressed: () => _handleSendVerification(context, viewModel),
      ),
    );
  }

  Future<void> _handleSendVerification(
      BuildContext context, VerificationPageViewModel viewModel) async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    await viewModel.sendVerificationEmail(context);
    if (viewModel.errorMessage.isNotEmpty) {
      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
      viewModel.errorMessage = '';
    } else {
      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.verificationPage_sendAgainMsg,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildVerificationIndicator(VerificationPageViewModel viewModel) {
    return !viewModel.emailVerified
        ? CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            strokeWidth: 3.0,
            // strokeAlign: -5,
          )
        : const Icon(Icons.done_all_rounded, size: 100);
  }
}
