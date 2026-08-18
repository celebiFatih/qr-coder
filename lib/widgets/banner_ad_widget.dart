import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Policy-safe, bottom-anchored AdMob banner.
///
/// Intended usage:
///   Scaffold(
///     body: ...,
///     bottomNavigationBar: const BannerAdWidget(),
///   )
///
/// The widget:
/// - uses an anchored adaptive banner size,
/// - reserves a dedicated non-content area for the ad,
/// - keeps a small non-clickable separation above the ad,
/// - hides the ad while a dialog/bottom sheet is covering the route,
/// - hides the ad while the keyboard is visible,
/// - hides the ad while the app is not in the resumed state.
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

  BannerAd? _bannerAd;
  BannerAd? _loadingBannerAd;
  AdSize? _reservedAdSize;

  int? _lastRequestedWidth;
  int _loadGeneration = 0;
  bool _isAppResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      _loadBannerForWidth(availableWidth);
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

  Future<void> _loadBannerForWidth(int width) async {
    final generation = ++_loadGeneration;

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );

    if (!mounted || generation != _loadGeneration) return;

    if (size == null) {
      debugPrint('BannerAd: anchored adaptive ad size could not be resolved.');
      return;
    }

    final adUnitId = dotenv.env['BANNER_AD_UNIT_ID']?.trim() ?? '';

    final oldBanner = _bannerAd;
    final oldLoadingBanner = _loadingBannerAd;

    setState(() {
      _reservedAdSize = size;
      _bannerAd = null;
      _loadingBannerAd = null;
    });

    oldBanner?.dispose();
    oldLoadingBanner?.dispose();

    if (adUnitId.isEmpty) {
      debugPrint('BannerAd: BANNER_AD_UNIT_ID is empty.');
      return;
    }

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
            });
          }

          ad.dispose();
        },
      ),
    );

    _loadingBannerAd = bannerAd;
    bannerAd.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loadGeneration++;
    _loadingBannerAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PopupRoute-based UI (AlertDialog, showModalBottomSheet, etc.) makes the
    // underlying page route non-current. Removing the banner from the widget
    // tree prevents publisher content from visually covering the ad.
    final isCurrentRoute = ModalRoute.isCurrentOf(context) ?? true;
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    if (!_isAppResumed || !isCurrentRoute || isKeyboardVisible) {
      return const SizedBox.shrink();
    }

    final adSize = _reservedAdSize;
    final bannerHeight = adSize?.height.toDouble() ?? _fallbackBannerHeight;

    return SafeArea(
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
  }
}
