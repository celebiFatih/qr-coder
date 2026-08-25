import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qr_coder/services/ad_consent_service.dart';
import 'package:qr_coder/services/ad_runtime_config.dart';

class RewardedAdService {
  RewardedAdService({String? addUnitId, AdConsentService? consentService})
    : _addUnitId = addUnitId?.trim() ?? '',
      _consentService = consentService ?? AdConsentService.instance {
    _consentService.addListener(_handleConsentChanged);

    if (_consentService.canRequestAds && _hasUsableAdUnit) {
      unawaited(loadRewardedAd());
    }
  }

  RewardedAd? _rewardedAd;
  Completer<bool>? _loadCompleter;

  bool _isLoading = false;
  bool _isShowing = false;
  bool _isDisposed = false;
  int _loadGeneration = 0;

  final String _addUnitId;
  final AdConsentService _consentService;

  // Google-provided sample rewarded ad units.
  // Non-release builds always use these IDs; release builds use .env only.
  static const String _androidTestAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';

  bool get isAdReady => _rewardedAd != null;
  bool get isLoading => _isLoading;
  bool get isShowing => _isShowing;

  /// True only when a real publisher ad unit is configured.
  /// Kept separate from test-ad availability so existing config tests remain
  /// meaningful.
  bool get isConfigured => _addUnitId.isNotEmpty;

  bool get _hasUsableAdUnit => AdRuntimeConfig.useTestAds || isConfigured;

  String get _effectiveAdUnitId {
    if (AdRuntimeConfig.useTestAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _iosTestAdUnitId
          : _androidTestAdUnitId;
    }

    return _addUnitId;
  }

  void _handleConsentChanged() {
    if (_isDisposed) {
      return;
    }

    if (!_consentService.canRequestAds) {
      _loadGeneration++;
      _completePendingLoad(false);

      _rewardedAd?.dispose();
      _rewardedAd = null;
      _isLoading = false;
      return;
    }

    if (_hasUsableAdUnit && !_isShowing) {
      unawaited(loadRewardedAd());
    }
  }

  /// Loads one rewarded ad and completes only when the load callback has
  /// succeeded or failed.
  ///
  /// Calling this method while another load is in progress joins the same
  /// in-flight request instead of starting another one.
  Future<bool> loadRewardedAd() {
    if (_isDisposed || !_hasUsableAdUnit || !_consentService.canRequestAds) {
      return Future<bool>.value(false);
    }

    if (_rewardedAd != null) {
      return Future<bool>.value(true);
    }

    final inFlight = _loadCompleter;
    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<bool>();
    _loadCompleter = completer;
    _isLoading = true;

    final generation = ++_loadGeneration;
    final adUnitId = _effectiveAdUnitId;

    if (AdRuntimeConfig.useTestAds) {
      debugPrint('Rewarded test: loading Google sample rewarded ad unit.');
    }

    try {
      final future = RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (_isDisposed ||
                generation != _loadGeneration ||
                !_consentService.canRequestAds) {
              ad.dispose();
              _finishLoad(completer, false);
              return;
            }

            _rewardedAd = ad;
            debugPrint('Rewarded loaded');
            _finishLoad(completer, true);
          },
          onAdFailedToLoad: (error) {
            if (generation == _loadGeneration) {
              _rewardedAd = null;
            }

            debugPrint('Rewarded failed to load: $error');
            _finishLoad(completer, false);
          },
        ),
      );

      unawaited(
        future.catchError((Object error, StackTrace stackTrace) {
          debugPrint('Rewarded load exception: $error');
          _finishLoad(completer, false);
        }),
      );
    } catch (error) {
      debugPrint('Rewarded load exception: $error');
      _finishLoad(completer, false);
    }

    return completer.future;
  }

  void _finishLoad(Completer<bool> completer, bool result) {
    if (identical(_loadCompleter, completer)) {
      _loadCompleter = null;
      _isLoading = false;
    }

    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  void _completePendingLoad(bool result) {
    final completer = _loadCompleter;
    _loadCompleter = null;
    _isLoading = false;

    if (completer != null && !completer.isCompleted) {
      completer.complete(result);
    }
  }

  /// Shows the rewarded ad and returns true only when the reward is earned.
  Future<bool> showRewardedAd() async {
    debugPrint(
      'Rewarded show requested: '
      'ready=$isAdReady, loading=$isLoading, showing=$isShowing, '
      'canRequestAds=${_consentService.canRequestAds}.',
    );

    if (_isDisposed ||
        _isShowing ||
        !_hasUsableAdUnit ||
        !_consentService.canRequestAds) {
      debugPrint(
        'Rewarded show skipped: unavailable, already showing, '
        'or ads not permitted.',
      );
      return false;
    }

    if (_rewardedAd == null) {
      final loaded = await loadRewardedAd();

      if (!loaded || _rewardedAd == null) {
        debugPrint('Rewarded show aborted: ad could not be loaded.');
        return false;
      }
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;
    _isShowing = true;

    final completer = Completer<bool>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded showed full-screen content.');
      },
      onAdImpression: (ad) {
        debugPrint('Rewarded recorded an impression.');
      },
      onAdClicked: (ad) {
        debugPrint('Rewarded was clicked.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded dismissed.');
        ad.dispose();
        _isShowing = false;

        if (!_isDisposed && _consentService.canRequestAds) {
          unawaited(loadRewardedAd());
        }

        if (!completer.isCompleted) {
          completer.complete(earned);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded failed to show: $error');
        ad.dispose();
        _isShowing = false;

        if (!_isDisposed && _consentService.canRequestAds) {
          unawaited(loadRewardedAd());
        }

        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint(
            'Rewarded user earned reward: ${reward.amount} ${reward.type}',
          );
          earned = true;
        },
      );
    } catch (error) {
      debugPrint('Rewarded show exception: $error');
      ad.dispose();
      _isShowing = false;

      if (!_isDisposed && _consentService.canRequestAds) {
        unawaited(loadRewardedAd());
      }

      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _consentService.removeListener(_handleConsentChanged);
    _loadGeneration++;
    _completePendingLoad(false);

    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isShowing = false;
  }
}
