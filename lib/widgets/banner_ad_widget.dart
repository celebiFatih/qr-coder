import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:qr_coder/services/ad_consent_service.dart';
import 'package:qr_coder/services/ad_runtime_config.dart';

/// Policy-safe, bottom-anchored AdMob banner.
///
/// Intended usage:
///   Scaffold(
///     body: ...,
///     bottomNavigationBar: const BannerAdWidget(),
///   )
///
/// The widget:
/// - uses the universal 320x50 fixed banner so compact screens keep more
///   content visible without relying on deprecated anchored-adaptive APIs,
/// - reserves a dedicated non-content area for the ad,
/// - keeps a small non-clickable separation above the ad,
/// - visually hides the ad while a dialog/bottom sheet is covering the route,
/// - visually hides the ad while the keyboard is visible,
/// - visually hides the ad while the app is not in the resumed state,
/// - keeps a loaded AdWidget mounted during those temporary states so the same
///   ad is not removed and reinserted into the widget tree.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.topSpacing = 8.0});

  /// Non-clickable spacing between app controls/content and the banner.
  final double topSpacing;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with WidgetsBindingObserver {
  static const double _fallbackBannerHeight = 50.0;

  // Current Google-provided sample fixed-banner IDs.
  // Release builds always use BANNER_AD_UNIT_ID.
  static const String _androidFixedTestAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosFixedTestAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  BannerAd? _bannerAd;
  BannerAd? _loadingBannerAd;
  AdSize? _reservedAdSize;

  int? _lastRequestedWidth;
  int _loadGeneration = 0;
  bool _isAppResumed = true;

  final AdConsentService _consentService = AdConsentService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _consentService.addListener(_handleConsentChanged);
  }

  void _handleConsentChanged() {
    if (!mounted) return;

    if (!_consentService.canRequestAds) {
      _loadGeneration++;

      final oldBanner = _bannerAd;
      final oldLoadingBanner = _loadingBannerAd;

      setState(() {
        _bannerAd = null;
        _loadingBannerAd = null;
      });

      oldBanner?.dispose();
      oldLoadingBanner?.dispose();
      return;
    }

    final width = _lastRequestedWidth;
    if (width != null && _bannerAd == null && _loadingBannerAd == null) {
      _loadBannerForWidth(width);
    } else {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mediaQuery = MediaQuery.of(context);
    final availableWidth =
        (mediaQuery.size.width -
                mediaQuery.padding.left -
                mediaQuery.padding.right)
            .floor();

    if (availableWidth > 0 && availableWidth != _lastRequestedWidth) {
      _lastRequestedWidth = availableWidth;

      if (_consentService.canRequestAds) {
        _loadBannerForWidth(availableWidth);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isResumed = state == AppLifecycleState.resumed;
    if (_isAppResumed == isResumed || !mounted) return;

    setState(() {
      _isAppResumed = isResumed;
    });
  }

  void _loadBannerForWidth(int width) {
    if (!_consentService.canRequestAds) {
      return;
    }

    final generation = ++_loadGeneration;

    final size = _resolveAdSize(width);

    if (!mounted ||
        generation != _loadGeneration ||
        !_consentService.canRequestAds) {
      return;
    }

    if (size == null) {
      debugPrint('BannerAd: fixed banner size could not be resolved.');
      return;
    }

    final configuredAdUnitId = dotenv.env['BANNER_AD_UNIT_ID']?.trim() ?? '';

    final adUnitId = AdRuntimeConfig.useTestAds
        ? _testAdUnitId()
        : configuredAdUnitId;

    if (AdRuntimeConfig.useTestAds) {
      debugPrint(
        'BannerAd test: loading fixed ${size.width}x${size.height} banner.',
      );
    }

    if (adUnitId.isEmpty) {
      debugPrint('BannerAd: BANNER_AD_UNIT_ID is empty.');
      return;
    }

    final oldBanner = _bannerAd;
    final oldLoadingBanner = _loadingBannerAd;

    setState(() {
      _reservedAdSize = size;
      _bannerAd = null;
      _loadingBannerAd = null;
    });

    oldBanner?.dispose();
    oldLoadingBanner?.dispose();

    late final BannerAd bannerAd;
    bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || generation != _loadGeneration) {
            ad.dispose();
            return;
          }

          if (_loadingBannerAd != ad) {
            ad.dispose();
            return;
          }

          setState(() {
            _loadingBannerAd = null;
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');

          if (mounted && generation == _loadGeneration) {
            setState(() {
              if (_loadingBannerAd == ad) {
                _loadingBannerAd = null;
              }
              _bannerAd = null;
              _reservedAdSize = null;
            });
          }

          ad.dispose();
        },
      ),
    );

    _loadingBannerAd = bannerAd;
    bannerAd.load();
  }

  String _testAdUnitId() {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosFixedTestAdUnitId
        : _androidFixedTestAdUnitId;
  }

  AdSize? _resolveAdSize(int width) {
    return width >= AdSize.banner.width ? AdSize.banner : null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _consentService.removeListener(_handleConsentChanged);
    _loadGeneration++;
    _loadingBannerAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_consentService.canRequestAds ||
        (_reservedAdSize == null &&
            _bannerAd == null &&
            _loadingBannerAd == null)) {
      return const SizedBox.shrink();
    }

    final isCurrentRoute = ModalRoute.isCurrentOf(context) ?? true;
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final shouldHide = !_isAppResumed || !isCurrentRoute || isKeyboardVisible;

    final adSize = _reservedAdSize;
    final bannerHeight = adSize?.height.toDouble() ?? _fallbackBannerHeight;

    final banner = SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: bannerHeight + widget.topSpacing,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        padding: EdgeInsets.only(top: widget.topSpacing),
        alignment: Alignment.bottomCenter,
        child: adSize != null && _bannerAd != null
            ? SizedBox(
                width: adSize.width.toDouble(),
                height: adSize.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            : SizedBox(height: bannerHeight),
      ),
    );

    // Offstage prevents painting and hit-testing, but keeps the loaded
    // AdWidget mounted. This avoids reinserting the same BannerAd after
    // closing dialogs or hiding the keyboard.
    return Offstage(offstage: shouldHide, child: banner);
  }
}
