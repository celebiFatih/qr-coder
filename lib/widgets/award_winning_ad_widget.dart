import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: dotenv.env['AWARD_WINNING_UNIT_ID'] ??
          '', // AdMob'dan aldığınız reklam birimi ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('Ödüllü reklam yüklendi.');
        },
        onAdFailedToLoad: (error) {
          print('Ödüllü reklam yüklenemedi: $error');
        },
      ),
    );
  }

  void showRewardedAd(Function onRewardEarned) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd(); // Yeni bir reklam yükleyin
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          print('Reklam gösterimi başarısız: $error');
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onRewardEarned();
      });
      _rewardedAd = null; // Reklamı sıfırlayın
    } else {
      print('Reklam hazır değil.');
    }
  }
}
