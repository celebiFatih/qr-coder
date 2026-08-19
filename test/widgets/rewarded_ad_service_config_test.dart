import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/services/ad_consent_service.dart';
import 'package:qr_coder/widgets/rewarded_add_service.dart';

void main() {
  test('missing rewarded ad unit id disables rewarded ads', () async {
    final service = RewardedAdService(
      addUnitId: null,
      consentService: AdConsentService.instance,
    );
    addTearDown(service.dispose);

    expect(service.isConfigured, isFalse);
    expect(await service.showRewardedAd(), isFalse);
  });

  test('blank rewarded ad unit id disables rewarded ads', () async {
    final service = RewardedAdService(
      addUnitId: '   ',
      consentService: AdConsentService.instance,
    );
    addTearDown(service.dispose);

    expect(service.isConfigured, isFalse);
    expect(await service.showRewardedAd(), isFalse);
  });
}
