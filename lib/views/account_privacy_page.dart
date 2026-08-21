import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/account_deletion_service.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';
import 'package:qr_coder/viewmodels/barcode_scanner_viewmodel.dart';
import 'package:qr_coder/viewmodels/forgot_passw_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/login_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:qr_coder/widgets/account_deletion_password_dialog.dart';
import 'package:qr_coder/widgets/wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountPrivacyPage extends StatefulWidget {
  AccountPrivacyPage({
    super.key,
    AccountDeletionService? accountDeletionService,
  }) : accountDeletionService =
           accountDeletionService ?? AccountDeletionService();

  static final Uri privacyPolicyUri = Uri.parse(
    'https://celebifatih.github.io/qr-coder-privacy/',
  );
  static final Uri accountDeletionInfoUri = Uri.parse(
    'https://celebifatih.github.io/qr-coder-privacy/account-deletion.html',
  );

  final AccountDeletionService accountDeletionService;

  @override
  State<AccountPrivacyPage> createState() => _AccountPrivacyPageState();
}

class _AccountPrivacyPageState extends State<AccountPrivacyPage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = Auth().currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountPrivacy_title), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAccountCard(context, user),
          const SizedBox(height: 16),
          _buildPrivacyCard(context),
          if (user != null) ...[
            const SizedBox(height: 24),
            _buildDeleteAccountSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, User? user) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          user == null ? Icons.person_outline_rounded : Icons.cloud_outlined,
        ),
        title: Text(
          user?.email ?? l10n.accountPrivacy_guestAccount,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          user == null
              ? l10n.accountPrivacy_guestDescription
              : l10n.accountPrivacy_cloudAccountDescription,
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.accountPrivacy_privacyPolicy),
            subtitle: Text(l10n.accountPrivacy_privacyPolicyDescription),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () =>
                _openExternalUrl(context, AccountPrivacyPage.privacyPolicyUri),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: Text(l10n.accountPrivacy_accountDeletionInfo),
            subtitle: Text(l10n.accountPrivacy_accountDeletionInfoDescription),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: () => _openExternalUrl(
              context,
              AccountPrivacyPage.accountDeletionInfoUri,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.accountPrivacy_deleteAccountTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.accountPrivacy_deleteAccountDescription),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isDeleting
                  ? null
                  : () => _confirmAndDeleteAccount(context),
              icon: _isDeleting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_forever_outlined),
              label: Text(
                _isDeleting
                    ? l10n.accountPrivacy_deletingAccount
                    : l10n.accountPrivacy_deleteAccountButton,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalUrl(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.accountPrivacy_linkOpenError,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Future<String?> _requestPassword(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return showAccountDeletionPasswordDialog(
      context: context,
      title: l10n.accountPrivacy_deleteConfirmTitle,
      description: l10n.accountPrivacy_deleteConfirmDescription,
      passwordLabel: l10n.accountPrivacy_passwordLabel,
      cancelLabel: l10n.no,
      deleteLabel: l10n.accountPrivacy_deleteConfirmButton,
    );
  }

  Future<void> _confirmAndDeleteAccount(BuildContext context) async {
    final password = await _requestPassword(context);
    if (password == null || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await widget.accountDeletionService.deleteCurrentAccount(
        password: password,
      );

      await _clearDeletedAccountLocalState();

      if (!mounted) return;

      _clearProviderState();

      Navigator.of(this.context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Wrapper()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showDeletionError(this.context, error.code);
    } catch (error) {
      debugPrint('Account deletion failed: $error');
      if (!mounted) return;
      _showDeletionError(this.context, null);
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _clearDeletedAccountLocalState() async {
    final prefs = await Constants().prefs;
    await prefs.setBool('isGuest', false);
    await prefs.remove('email');
    await prefs.remove('rememberMe');
    await prefs.remove('password');
  }

  void _clearProviderState() {
    context.read<QRCodeViewModel>().clearAll();
    context.read<BarcodeScannerViewmodel>().clearAll();
    context.read<LoginPageViewmodel>().clearLoginForm();
    context.read<QrCodeListPageViewmodel>().clearAll();
    context.read<VerificationPageViewModel>().clearAll();
    context.read<ForgotPasswPageViewmodel>().clearAll();
  }

  void _showDeletionError(BuildContext context, String? code) {
    final l10n = AppLocalizations.of(context)!;

    final message = switch (code) {
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-credentials' => l10n.accountPrivacy_wrongPassword,
      'network-request-failed' => l10n.accountPrivacy_networkError,
      'too-many-requests' => l10n.accountPrivacy_tooManyRequests,
      _ => l10n.accountPrivacy_deleteError,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message, textAlign: TextAlign.center)),
      );
  }
}
