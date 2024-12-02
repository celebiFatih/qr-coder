import 'package:flutter/material.dart';
import 'package:qr_coder/widgets/award_winning_ad_widget.dart';

class QRCodeDisplayViewModel extends ChangeNotifier {
  bool _isLogoRemoved = false;
  // RewardedAd? _rewardedAd;
  // bool _isAdReady = false;
  final RewardedAdService _rewardedAdService;

  bool get isLogoRemoved => _isLogoRemoved;

  QRCodeDisplayViewModel(this._rewardedAdService) {
    _rewardedAdService.loadRewardedAd();
  }

  void resetLogo() {
    _isLogoRemoved = false;
    notifyListeners();
  }

  // void _loadRewardedAd() {
  //   RewardedAd.load(
  //     adUnitId: dotenv.env['AWARD_WINNING_UNIT_ID'] ?? '',
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         _rewardedAd = ad;
  //         _isAdReady = true;
  //       },
  //       onAdFailedToLoad: (error) {
  //         debugPrint('Rewarded ad failed to load: $error');
  //         _isAdReady = false;
  //       },
  //     ),
  //   );
  // }

  void promptRemoveLogo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logoyu Kaldır'),
          content: Text(
              'Logoyu kaldırmak için bir reklam izlemeniz gerekiyor. Devam etmek istiyor musunuz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hayır'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _rewardedAdService.showRewardedAd(() {
                  _isLogoRemoved = true;
                  notifyListeners();
                });
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );
  }

  // void _showRewardedAd(
  //   BuildContext context,
  // ) {
  //   if (_isAdReady && _rewardedAd != null) {
  //     _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdDismissedFullScreenContent: (ad) {
  //         ad.dispose();
  //         _loadRewardedAd();
  //       },
  //       onAdFailedToShowFullScreenContent: (ad, error) {
  //         ad.dispose();
  //         debugPrint('Reklam gösterimi başarısız');
  //       },
  //     );
  //     _rewardedAd!.show(
  //       onUserEarnedReward: (ad, reward) {
  //         _isLogoRemoved = true;
  //         notifyListeners();
  //       },
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text('Reklam yüklenemedi, lütfen tekrar deneyin.')),
  //     );
  //   }
  // }
}
