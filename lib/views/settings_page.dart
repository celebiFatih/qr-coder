import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/services/ad_consent_service.dart';
import 'package:qr_coder/viewmodels/locale_provider.dart';
import 'package:qr_coder/viewmodels/theme_mode_provider.dart';
import 'package:qr_coder/views/account_privacy_page.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';
import 'package:qr_coder/widgets/app_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.userEmail});

  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppPageScaffold(
      appBar: AppBar(title: Text(l10n.settings_title)),
      body: AppContentFrame(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSessionCard(context),
              const SizedBox(height: AppSpacing.lg),
              AppSectionHeader(
                title: l10n.settings_personalizationTitle,
                subtitle: l10n.settings_personalizationDescription,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildLanguageCard(context),
              const SizedBox(height: AppSpacing.sm),
              _buildThemeCard(context),
              const SizedBox(height: AppSpacing.lg),
              _buildAccountAndPrivacyCard(context),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final signedIn = userEmail?.isNotEmpty == true;

    return AppSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            signedIn ? Icons.cloud_done_outlined : Icons.person_outline_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signedIn ? userEmail! : l10n.accountPrivacy_guestAccount,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  signedIn
                      ? l10n.accountPrivacy_cloudAccountDescription
                      : l10n.accountPrivacy_guestDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final activeLanguageCode =
        localeProvider.locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settings_languageTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'tr',
                label: Text(l10n.settings_languageTurkish),
              ),
              ButtonSegment(
                value: 'en',
                label: Text(l10n.settings_languageEnglish),
              ),
            ],
            selected: {activeLanguageCode == 'tr' ? 'tr' : 'en'},
            onSelectionChanged: (selection) {
              context.read<LocaleProvider>().setLocale(Locale(selection.first));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeModeProvider = context.watch<ThemeModeProvider>();

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settings_themeTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto_outlined),
                label: Text(l10n.settings_themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text(l10n.settings_themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text(l10n.settings_themeDark),
              ),
            ],
            selected: {themeModeProvider.themeMode},
            onSelectionChanged: (selection) {
              themeModeProvider.setThemeMode(selection.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountAndPrivacyCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            minTileHeight: 64,
            leading: const Icon(Icons.manage_accounts_outlined),
            title: Text(l10n.settings_accountPrivacy),
            subtitle: Text(l10n.settings_accountPrivacyDescription),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => AccountPrivacyPage())),
          ),
          ListenableBuilder(
            listenable: AdConsentService.instance,
            builder: (context, child) {
              if (!AdConsentService.instance.privacyOptionsRequired) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  const Divider(height: 1),
                  ListTile(
                    minTileHeight: 64,
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(l10n.settings_privacyOptions),
                    subtitle: Text(l10n.settings_privacyOptionsDescription),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showPrivacyOptions(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacyOptions(BuildContext context) async {
    final formError = await AdConsentService.instance.showPrivacyOptionsForm();

    if (formError != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .qrCodeGenerator_privacyOptionsErrorMsg,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}
