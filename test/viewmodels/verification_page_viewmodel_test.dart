import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/viewmodels/verification_page_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('successful resend starts cooldown and blocks duplicate send', () async {
    var sendCount = 0;
    final fixedNow = DateTime(2026, 8, 19, 10);
    final viewModel = VerificationPageViewModel(
      currentUserId: () => 'cooldown-user',
      now: () => fixedNow,
      resendCooldown: const Duration(seconds: 60),
      sendVerificationEmailAction: () async {
        sendCount += 1;
      },
      checkEmailVerifiedAction: () async => false,
    );
    addTearDown(viewModel.dispose);

    final firstSend = await viewModel.sendVerificationEmail(
      sendMailErrorMsg: 'send failed',
      tooManyRequestsMsg: 'rate limited',
    );

    expect(firstSend, isTrue);
    expect(sendCount, 1);
    expect(viewModel.resendCooldownSeconds, 60);
    expect(viewModel.canResend, isFalse);

    final duplicateSend = await viewModel.sendVerificationEmail(
      sendMailErrorMsg: 'send failed',
      tooManyRequestsMsg: 'rate limited',
    );

    expect(duplicateSend, isFalse);
    expect(sendCount, 1);
  });

  test(
    'too-many-requests exposes rate-limit message and starts cooldown',
    () async {
      final fixedNow = DateTime(2026, 8, 19, 11);
      final viewModel = VerificationPageViewModel(
        currentUserId: () => 'rate-limit-user',
        now: () => fixedNow,
        resendCooldown: const Duration(seconds: 60),
        sendVerificationEmailAction: () async {
          throw FirebaseAuthException(code: 'too-many-requests');
        },
        checkEmailVerifiedAction: () async => false,
      );
      addTearDown(viewModel.dispose);

      final sent = await viewModel.sendVerificationEmail(
        sendMailErrorMsg: 'send failed',
        tooManyRequestsMsg: 'rate limited',
      );

      expect(sent, isFalse);
      expect(viewModel.errorMessage, 'rate limited');
      expect(viewModel.resendCooldownSeconds, 60);
      expect(viewModel.canResend, isFalse);
    },
  );

  test(
    'cooldown is restored for the same user after page recreation',
    () async {
      var now = DateTime(2026, 8, 19, 12);

      final firstViewModel = VerificationPageViewModel(
        currentUserId: () => 'restore-user',
        now: () => now,
        resendCooldown: const Duration(seconds: 60),
        sendVerificationEmailAction: () async {},
        checkEmailVerifiedAction: () async => false,
      );

      await firstViewModel.sendVerificationEmail(
        sendMailErrorMsg: 'send failed',
        tooManyRequestsMsg: 'rate limited',
      );
      firstViewModel.pauseVerificationFlow();
      firstViewModel.dispose();

      now = now.add(const Duration(seconds: 10));

      final restoredViewModel = VerificationPageViewModel(
        currentUserId: () => 'restore-user',
        now: () => now,
        resendCooldown: const Duration(seconds: 60),
        sendVerificationEmailAction: () async {},
        checkEmailVerifiedAction: () async => false,
      );
      addTearDown(restoredViewModel.dispose);

      await restoredViewModel.resumeVerificationFlow();

      expect(restoredViewModel.resendCooldownSeconds, 50);
      expect(restoredViewModel.canResend, isFalse);
      restoredViewModel.pauseVerificationFlow();
    },
  );

  test(
    'injected identity exposes email without live Firebase access',
    () async {
      final viewModel = VerificationPageViewModel(
        currentUserId: () => 'email-user',
        currentUserEmail: () => 'email-user@example.com',
        checkEmailVerifiedAction: () async => false,
        sendVerificationEmailAction: () async {},
      );
      addTearDown(viewModel.dispose);

      await viewModel.resumeVerificationFlow();

      expect(viewModel.userEmail, 'email-user@example.com');
      viewModel.pauseVerificationFlow();
    },
  );

  test('verification polling pauses and never overlaps async checks', () async {
    var activeChecks = 0;
    var maxActiveChecks = 0;
    var checkCount = 0;

    final viewModel = VerificationPageViewModel(
      currentUserId: () => 'poll-user',
      verificationCheckInterval: const Duration(milliseconds: 10),
      checkEmailVerifiedAction: () async {
        checkCount += 1;
        activeChecks += 1;
        if (activeChecks > maxActiveChecks) {
          maxActiveChecks = activeChecks;
        }
        await Future<void>.delayed(const Duration(milliseconds: 35));
        activeChecks -= 1;
        return false;
      },
      sendVerificationEmailAction: () async {},
    );
    addTearDown(viewModel.dispose);

    await viewModel.resumeVerificationFlow();
    await Future<void>.delayed(const Duration(milliseconds: 85));

    expect(checkCount, greaterThanOrEqualTo(2));
    expect(maxActiveChecks, 1);

    viewModel.pauseVerificationFlow();
    final countAfterPause = checkCount;
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(checkCount, countAfterPause);
  });
  test(
    'initial verification email starts cooldown even if page resumed first',
    () async {
      final fixedNow = DateTime(2026, 8, 19, 13);
      final viewModel = VerificationPageViewModel(
        currentUserId: () => 'new-account-user',
        now: () => fixedNow,
        resendCooldown: const Duration(seconds: 60),
        sendVerificationEmailAction: () async {},
        checkEmailVerifiedAction: () async => false,
      );
      addTearDown(viewModel.dispose);

      // VerificationPage Firebase userChanges nedeniyle createUser() henüz
      // ilk maili göndermeden önce açılmış olabilir.
      await viewModel.resumeVerificationFlow();
      expect(viewModel.resendCooldownSeconds, 0);
      expect(viewModel.canResend, isTrue);

      // İlk mail sonradan başarıyla tamamlandığında sayaç doğrudan başlamalı.
      await viewModel.markInitialVerificationEmailSent('new-account-user');

      expect(viewModel.resendCooldownSeconds, 60);
      expect(viewModel.canResend, isFalse);
      viewModel.pauseVerificationFlow();
    },
  );
}
