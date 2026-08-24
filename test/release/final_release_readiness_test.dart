import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release version and Android 16 target are pinned for 3.4.0', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final appGradle = File('android/app/build.gradle').readAsStringSync();

    expect(pubspec, contains('version: 3.4.0+126'));
    expect(appGradle, contains('compileSdk  37'));
    expect(appGradle, contains('targetSdk  36'));
  });

  test(
    'Android release keeps edge-to-edge and adaptive behavior unblocked',
    () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      final activity = File(
        'android/app/src/main/kotlin/com/qrcoder/app/MainActivity.kt',
      ).readAsStringSync();

      expect(manifest, isNot(contains('android:screenOrientation=')));
      expect(manifest, isNot(contains('android:resizeableActivity="false"')));
      expect(manifest, isNot(contains('windowOptOutEdgeToEdgeEnforcement')));
      expect(
        manifest,
        isNot(contains('android:enableOnBackInvokedCallback="false"')),
      );
      expect(
        activity,
        contains('WindowCompat.setDecorFitsSystemWindows(window, false)'),
      );
    },
  );

  test('privacy and account-deletion entry points remain release-visible', () {
    final accountPrivacy = File('lib/views/account_privacy_page.dart')
        .readAsStringSync();

    expect(
      accountPrivacy,
      contains('https://celebifatih.github.io/qr-coder-privacy/'),
    );
    expect(
      accountPrivacy,
      contains(
        'https://celebifatih.github.io/qr-coder-privacy/account-deletion.html',
      ),
    );
    expect(accountPrivacy, contains('_confirmAndDeleteAccount'));
  });

  test('UMP gates ads and exposes a privacy-options entry point', () {
    final consent = File('lib/services/ad_consent_service.dart')
        .readAsStringSync();
    final settings = File('lib/views/settings_page.dart').readAsStringSync();

    expect(consent, contains('ConsentInformation.instance.canRequestAds()'));
    expect(consent, contains('ConsentForm.loadAndShowConsentFormIfRequired'));
    expect(consent, contains('getPrivacyOptionsRequirementStatus()'));
    expect(consent, contains('ConsentForm.showPrivacyOptionsForm'));
    expect(settings, contains('privacyOptionsRequired'));
    expect(settings, contains('showPrivacyOptionsForm'));
  });

  test('release source archive excludes obsolete/store screenshots', () {
    final packageScript = File('tool/package_source.ps1').readAsStringSync();
    final readme = File('README.md').readAsStringSync();

    expect(packageScript, contains('"screenshots"'));
    expect(readme, isNot(contains('screenshots/1.png')));
    expect(readme, contains('Use anonymous/demo content only'));
  });

  test('iOS release config does not allow arbitrary cleartext transport', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(infoPlist, isNot(contains('NSAllowsArbitraryLoads')));
  });
}
