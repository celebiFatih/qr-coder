import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  final String _addUnitId;

  RewardedAdService({String? addUnitId})
      : _addUnitId = (addUnitId?.isNotEmpty == true)
            ? addUnitId!
            : 'ca-app-pub-3940256099942544/5224354917'; // google test

  bool get isAdReady => _rewardedAd != null;
  bool get isLoading => _isLoading;

  Future<void> loadRewardedAd() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: _addUnitId,
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
      await loadRewardedAd();
      if (_rewardedAd == null) return false;
    }
    final completer = Completer<bool>();
    bool earned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        // bir sonraki için preload
        unawaited(loadRewardedAd());
        completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _rewardedAd = null;
        unawaited(loadRewardedAd());
        completer.complete(false);
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      earned = true;
    });

    // referansı boşalt
    _rewardedAd = null;
    return completer.future;
  }
}
