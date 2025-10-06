import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  /// Dışarıda UI göstermek için okunabilir durum
  bool get isAdReady => _rewardedAd != null;
  bool get isLoading => _isLoading;

  Future<void> loadRewardedAd() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: dotenv.env['AWARD_WINNING_UNIT_ID'] ?? '',
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
            debugPrint('Rewarded loaded');
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoading = false;
            debugPrint('Rewarded failed to load: $error');
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      debugPrint('Rewarded load exception: $e');
    }
  }

  /// Reklamı gösterir; kullanıcı ödül kazanırsa true döner.
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      // Yedek: hemen yeniden yüklemeyi dene
      await loadRewardedAd();
      if (_rewardedAd == null) {
        return false; // hâlâ yok -> başarısız
      }
    }

    final completer = Completer<bool>();
    bool earned = false;

    try {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Rewarded showed');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Rewarded failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
          // Gösterim hatasında tekrar preload dene
          unawaited(loadRewardedAd());
          if (!completer.isCompleted) completer.complete(false);
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Rewarded dismissed');
          ad.dispose();
          _rewardedAd = null;
          // Kullanıcı kapattı; ödül almadıysa earned=false kalır
          unawaited(loadRewardedAd());
          if (!completer.isCompleted) completer.complete(earned);
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        earned = true; // ödül anı
      });

      // Ad nesnesini sıfırla; yeni bir tane yüklenecek
      _rewardedAd = null;
    } catch (e) {
      debugPrint('Rewarded show exception: $e');
      _rewardedAd?.dispose();
      _rewardedAd = null;
      unawaited(loadRewardedAd());
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future;
  }
}
