import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Central gate for Google UMP consent and ad-request eligibility.
///
/// Ads must not be requested until UMP reports that requests are allowed.
/// The service also initializes Google Mobile Ads only after that gate opens.
class AdConsentService extends ChangeNotifier {
  AdConsentService._();

  static final AdConsentService instance = AdConsentService._();

  static const String _umpTestDeviceId = String.fromEnvironment(
    'UMP_TEST_DEVICE_ID',
  );
  static const bool _resetConsentForDebug = bool.fromEnvironment(
    'UMP_RESET_CONSENT',
    defaultValue: false,
  );

  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;
  bool _mobileAdsInitialized = false;
  Future<void>? _initializationFuture;

  bool get canRequestAds => _canRequestAds;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  Future<void> initialize() {
    return _initializationFuture ??= _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    // Test-only first-install simulation. This is compiled behind kDebugMode
    // and has no effect in profile/release builds.
    if (kDebugMode && _resetConsentForDebug) {
      ConsentInformation.instance.reset();
      debugPrint('UMP debug: consent state reset.');
    }

    final updateError = await _requestConsentInfoUpdate();

    if (updateError != null) {
      debugPrint(
        'UMP consent info update failed '
        '(${updateError.errorCode}): ${updateError.message}',
      );
    } else {
      final formError = await _loadAndShowConsentFormIfRequired();
      if (formError != null) {
        debugPrint(
          'UMP consent form failed '
          '(${formError.errorCode}): ${formError.message}',
        );
      }
    }

    // Even when the current consent flow has an error, UMP may still allow
    // requests based on a valid decision from a previous app session.
    await _refreshState();
  }

  Future<FormError?> _requestConsentInfoUpdate() {
    final completer = Completer<FormError?>();

    final ConsentRequestParameters parameters;

    if (kDebugMode && _umpTestDeviceId.isNotEmpty) {
      parameters = ConsentRequestParameters(
        consentDebugSettings: ConsentDebugSettings(
          debugGeography: DebugGeography.debugGeographyEea,
          testIdentifiers: [_umpTestDeviceId],
        ),
      );

      debugPrint(
        'UMP debug: forcing EEA geography for registered test device.',
      );
    } else {
      parameters = ConsentRequestParameters();

      if (kDebugMode) {
        debugPrint(
          'UMP debug: no UMP_TEST_DEVICE_ID supplied. '
          'Check the Android log for the UMP hashed test-device ID.',
        );
      }
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      parameters,
      () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      (error) {
        if (!completer.isCompleted) {
          completer.complete(error);
        }
      },
    );

    return completer.future;
  }

  Future<FormError?> _loadAndShowConsentFormIfRequired() {
    final completer = Completer<FormError?>();

    ConsentForm.loadAndShowConsentFormIfRequired((formError) {
      if (!completer.isCompleted) {
        completer.complete(formError);
      }
    });

    return completer.future;
  }

  Future<FormError?> showPrivacyOptionsForm() async {
    final completer = Completer<FormError?>();

    ConsentForm.showPrivacyOptionsForm((formError) {
      if (!completer.isCompleted) {
        completer.complete(formError);
      }
    });

    final formError = await completer.future;
    await _refreshState();
    return formError;
  }

  Future<void> _refreshState() async {
    bool nextCanRequestAds = false;
    bool nextPrivacyOptionsRequired = false;

    try {
      nextCanRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (error) {
      debugPrint('UMP canRequestAds check failed: $error');
    }

    try {
      nextPrivacyOptionsRequired =
          await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (error) {
      debugPrint('UMP privacy options requirement check failed: $error');
    }

    // Initialize the ads SDK only after UMP says an ad request is allowed.
    if (nextCanRequestAds && !_mobileAdsInitialized) {
      try {
        await MobileAds.instance.initialize();
        _mobileAdsInitialized = true;
      } catch (error) {
        debugPrint('Google Mobile Ads initialization failed: $error');
        nextCanRequestAds = false;
      }
    }

    final changed =
        _canRequestAds != nextCanRequestAds ||
        _privacyOptionsRequired != nextPrivacyOptionsRequired;

    _canRequestAds = nextCanRequestAds;
    _privacyOptionsRequired = nextPrivacyOptionsRequired;

    if (changed) {
      notifyListeners();
    }
  }
}
