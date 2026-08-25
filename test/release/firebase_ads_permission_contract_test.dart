import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Firebase initialization and verified-email token refresh stay explicit',
    () {
      final mainSource = File('lib/main.dart').readAsStringSync();
      final authSource = File('lib/services/auth_service.dart')
          .readAsStringSync();

      expect(
        mainSource,
        contains(
          'Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)',
        ),
      );
      expect(authSource, contains('getIdTokenResult(true)'));
      expect(authSource, contains("claims?['email_verified']"));
    },
  );

  test('Realtime Database selected delete stays atomic', () {
    final repository = File('lib/repository/firebase_qrcode_repository.dart')
        .readAsStringSync();

    expect(repository, contains(r"database.child('users/$uid/qrcodes')"));
    expect(
      repository,
      contains(
        "final updates = <String, Object?>{for (final id in ids) id: null};",
      ),
    );
    expect(repository, contains('await userRef.update(updates);'));
  });

  test('UMP remains the gate before Mobile Ads initialization and ad requests', () {
    final consent = File('lib/services/ad_consent_service.dart')
        .readAsStringSync();
    final rewarded = File('lib/widgets/rewarded_add_service.dart')
        .readAsStringSync();

    expect(
      consent,
      contains(
        'nextCanRequestAds = await ConsentInformation.instance.canRequestAds()',
      ),
    );
    expect(consent, contains('await MobileAds.instance.initialize()'));
    expect(rewarded, contains('_consentService.canRequestAds'));
  });

  test(
    'banner uses universal fixed 320x50 size without deprecated adaptive APIs',
    () {
      final banner = File('lib/widgets/banner_ad_widget.dart')
          .readAsStringSync();

      expect(
        banner,
        contains('width >= AdSize.banner.width ? AdSize.banner : null'),
      );
      expect(
        banner,
        contains('static const double _fallbackBannerHeight = 50.0'),
      );
      expect(
        banner,
        isNot(contains('getCurrentOrientationAnchoredAdaptiveBannerAdSize')),
      );
      expect(banner, isNot(contains('getLargeAnchoredAdaptiveBannerAdSize')));
    },
  );

  test('legacy storage permission remains limited to Android 9 and older', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final qrViewModel = File('lib/viewmodels/qr_code_viewmodel.dart')
        .readAsStringSync();

    expect(
      manifest,
      contains(
        'android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"',
      ),
    );
    expect(qrViewModel, contains('androidInfo.version.sdkInt <= 28'));
    expect(qrViewModel, contains('Permission.storage.request()'));
  });

  test(
    'Android 17 is compile-only until target behavior migration is explicit',
    () {
      final appGradle = File('android/app/build.gradle').readAsStringSync();

      expect(appGradle, contains('compileSdk  37'));
      expect(appGradle, contains('targetSdk  36'));
    },
  );

  test(
    'AGP 9 temporarily keeps Flutter legacy Kotlin compatibility enabled',
    () {
      final properties = File('android/gradle.properties').readAsStringSync();

      expect(properties, contains('android.builtInKotlin=false'));
      expect(properties, contains('android.newDsl=false'));
    },
  );
}
