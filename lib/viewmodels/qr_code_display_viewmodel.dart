import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/widgets/rewarded_add_service.dart';

class QRCodeDisplayViewModel extends ChangeNotifier {
  bool _isLogoRemoved = false;
  final RewardedAdService _rewardedAdService;

  bool get isLogoRemoved => _isLogoRemoved;

  QRCodeDisplayViewModel(this._rewardedAdService);

  void resetLogo() {
    _isLogoRemoved = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _rewardedAdService.dispose();
    super.dispose();
  }

  Future<void> promptRemoveLogo(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.qrcodeDisplay_remove_logo),
        content: Text(l10n.qrcodeDisplay_permission_remove_logo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    debugPrint(
      'Remove-logo confirmed: '
      'ready=${_rewardedAdService.isAdReady}, '
      'loading=${_rewardedAdService.isLoading}, '
      'showing=${_rewardedAdService.isShowing}.',
    );

    // A load may already be in progress. Do not make the user tap the logo a
    // second time: show a short status message and let showRewardedAd() join
    // the same in-flight load before opening the full-screen ad.
    if (!_rewardedAdService.isAdReady) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.qrcodeDisplay_loading_ad),
            duration: const Duration(seconds: 2),
          ),
        );
    }

    final ok = await _rewardedAdService.showRewardedAd();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (ok) {
      _isLogoRemoved = true;
      notifyListeners();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.qrcodeDisplay_removed_logo)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.qrcodeDisplay_error_ad)));
    }
  }
}
