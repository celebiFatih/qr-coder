import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/widgets/award_winning_ad_widget.dart';

class QRCodeDisplayViewModel extends ChangeNotifier {
  bool _isLogoRemoved = false;
  final RewardedAdService _rewardedAdService;

  bool get isLogoRemoved => _isLogoRemoved;

  QRCodeDisplayViewModel(this._rewardedAdService) {
    _rewardedAdService.loadRewardedAd();
  }

  void resetLogo() {
    _isLogoRemoved = false;
    notifyListeners();
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

    if (confirmed != true) return;

    // Reklam hazır değilse kullanıcıyı bilgilendir
    if (!_rewardedAdService.isAdReady && _rewardedAdService.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qrcodeDisplay_loading_ad)),
      );
      return;
    }

    final ok = await _rewardedAdService.showRewardedAd();

    if (ok) {
      _isLogoRemoved = true;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qrcodeDisplay_removed_logo)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qrcodeDisplay_error_ad)),
      );
    }
  }
}
