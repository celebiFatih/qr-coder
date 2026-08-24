import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkable/linkable.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/widgets/app_components.dart';
import 'package:qr_coder/widgets/app_design_tokens.dart';

class BuildContent extends StatelessWidget {
  final QRCodeModel qrCode;
  const BuildContent({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: AppLocalizations.of(context)!.qrCodeDetail_Details,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildContent(context, qrCode.data),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, String data) {
    if (_isWifi(data)) {
      return _buildWifi(context, data);
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Linkable(
      text: data,
      style: theme.textTheme.bodyLarge,
      textColor: scheme.onSurface,
      linkColor: scheme.primary,
    );
  }

  bool _isWifi(String data) {
    final wifiRegExp = RegExp(
      r'^WIFI:T:(WPA|WEP|nopass);S:[^;]+;P:[^;]*;(H:(true|false);)?;$',
      caseSensitive: false,
    );
    return wifiRegExp.hasMatch(data);
  }

  String _valueForPrefix(
    List<String> parts,
    String prefix, {
    String defaultValue = '',
  }) {
    final normalizedPrefix = prefix.toUpperCase();

    for (final part in parts) {
      if (part.length >= prefix.length &&
          part.substring(0, prefix.length).toUpperCase() == normalizedPrefix) {
        return part.substring(prefix.length);
      }
    }

    return defaultValue;
  }

  Widget _buildWifi(BuildContext context, String wifiData) {
    final parts = wifiData.replaceFirst('WIFI:', '').split(';');
    final ssid = _valueForPrefix(parts, 'S:');
    final password = _valueForPrefix(parts, 'P:');
    final encryption = _valueForPrefix(parts, 'T:');
    final hidden = _valueForPrefix(parts, 'H:', defaultValue: 'false');
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadii.control),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.control),
        onTap: () async {
          if (Theme.of(context).platform == TargetPlatform.android) {
            const intent = MethodChannel('com.qrcoder.app/app');
            try {
              await intent.invokeMethod('openWifiSettings');
            } on PlatformException catch (e) {
              debugPrint('Failed to open Wi-Fi settings: ${e.message}');
            }
          } else {
            if (!context.mounted) return;
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  AppLocalizations.of(context)!.qrCodeDetail_wifiInfo,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SSID: $ssid'),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppLocalizations.of(context)!
                          .qrCodeDetail_wifiPassw(password),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppLocalizations.of(context)!
                          .qrCodeDetail_wifiEncryption(encryption),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppLocalizations.of(context)!
                          .qrCodeDetail_wifiHidden(hidden),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!
                          .qrCodeDetail_wifiConnectTextBtn,
                    ),
                  ),
                ],
              ),
            );
          }
        },
        child: Tooltip(
          message: AppLocalizations.of(context)!
              .qrCodeDetail_OpenWifiSettingsButton,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.xxl),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Icon(Icons.wifi_rounded, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ssid,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          wifiData,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.open_in_new_rounded, color: scheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
