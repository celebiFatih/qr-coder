import 'package:flutter/foundation.dart';

/// Compile-time ad mode for development and release-mode smoke tests.
///
/// Production builds use publisher ad unit IDs by default. To verify the
/// release runtime without depending on live inventory, run with:
///
///   flutter run --release --dart-define=ADS_TEST_MODE=true
///
/// The flag is false unless explicitly supplied at build/run time.
class AdRuntimeConfig {
  const AdRuntimeConfig._();

  static const bool forceTestAds = bool.fromEnvironment(
    'ADS_TEST_MODE',
    defaultValue: false,
  );

  static bool get useTestAds => !kReleaseMode || forceTestAds;
}
