import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_coder/services/auth_service.dart';
import 'package:qr_coder/utils/constants.dart';

class VerificationPageViewModel extends ChangeNotifier {
  VerificationPageViewModel({
    Future<bool> Function()? checkEmailVerifiedAction,
    Future<void> Function()? sendVerificationEmailAction,
    String? Function()? currentUserId,
    DateTime Function()? now,
    Duration verificationCheckInterval = const Duration(seconds: 5),
    Duration resendCooldown = Constants.verificationEmailResendCooldown,
  }) : _checkEmailVerifiedOverride = checkEmailVerifiedAction,
       _sendVerificationEmailOverride = sendVerificationEmailAction,
       _currentUserIdOverride = currentUserId,
       _now = now ?? DateTime.now,
       _verificationCheckInterval = verificationCheckInterval,
       _resendCooldown = resendCooldown;

  final Future<bool> Function()? _checkEmailVerifiedOverride;
  final Future<void> Function()? _sendVerificationEmailOverride;
  final String? Function()? _currentUserIdOverride;
  final DateTime Function() _now;
  final Duration _verificationCheckInterval;
  final Duration _resendCooldown;

  Timer? _verificationTimer;
  Timer? _resendCooldownTimer;
  bool _verificationCheckInProgress = false;
  String? _activeUserId;

  String errorMessage = '';
  bool isLoading = false;
  bool emailVerified = false;
  int resendCooldownSeconds = 0;

  bool get isResendCoolingDown => resendCooldownSeconds > 0;
  bool get canResend => !isLoading && !isResendCoolingDown;

  Future<void> resumeVerificationFlow() async {
    final userId = _currentUserId;
    final userChanged = _activeUserId != userId;

    if (userChanged) {
      _activeUserId = userId;
      emailVerified = false;
      errorMessage = '';
      _cancelResendCooldownTimer();
      resendCooldownSeconds = 0;
    }

    // SharedPreferences erişimi async olduğundan burada build fazından çıkmış
    // oluyoruz. Kullanıcı değişiminde ilk notify'ı da restore sonrasına
    // bırakarak Provider'ın build sırasında dirty edilmesini önlüyoruz.
    await _restoreResendCooldown();

    if (userChanged) {
      notifyListeners();
    }

    startEmailVerificationCheckTimer(checkImmediately: true);
  }

  Future<void> markInitialVerificationEmailSent(String userId) async {
    if (userId.isEmpty) {
      return;
    }

    if (_activeUserId != userId) {
      _activeUserId = userId;
      emailVerified = false;
      errorMessage = '';
      _cancelResendCooldownTimer();
      resendCooldownSeconds = 0;
    }

    // Hesap oluşturma ile VerificationPage'in ilk build'i yarışabilir.
    // İlk mail gönderimi başarıyla tamamlandığında cooldown'ı doğrudan
    // global VerificationPageViewModel'e bildiriyoruz. Böylece sayfa pref'i
    // mail gönderilmeden önce okumuş olsa bile sayaç hemen başlar.
    await _startResendCooldownFromNow(userId);
  }

  void pauseVerificationFlow() {
    stopEmailVerificationCheckTimer();
    _cancelResendCooldownTimer();
  }

  void clearAll() {
    errorMessage = '';
    isLoading = false;
    emailVerified = false;
    resendCooldownSeconds = 0;
    _activeUserId = null;
    stopEmailVerificationCheckTimer();
    _cancelResendCooldownTimer();
    notifyListeners();
  }

  void startEmailVerificationCheckTimer({bool checkImmediately = false}) {
    stopEmailVerificationCheckTimer();

    if (emailVerified) {
      return;
    }

    if (checkImmediately) {
      unawaited(_checkEmailVerification());
    }

    _verificationTimer = Timer.periodic(_verificationCheckInterval, (_) {
      unawaited(_checkEmailVerification());
    });
  }

  void stopEmailVerificationCheckTimer() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
  }

  Future<void> _checkEmailVerification() async {
    final userId = _currentUserId;
    if (userId == null ||
        userId.isEmpty ||
        _verificationCheckInProgress ||
        emailVerified) {
      return;
    }

    _verificationCheckInProgress = true;

    try {
      final verified = await _checkEmailVerified();

      // Hesap kontrolü sürerken oturum değişmişse eski isteğin sonucunu yeni
      // kullanıcı state'ine uygulama.
      if (_currentUserId != userId || _activeUserId != userId) {
        return;
      }

      if (verified) {
        emailVerified = true;
        stopEmailVerificationCheckTimer();
        notifyListeners();
      }
    } catch (e) {
      // Geçici ağ hatalarında doğrulama ekranında kalıp bir sonraki
      // periyodik kontrolde veya uygulama resume olduğunda yeniden deniyoruz.
      debugPrint('E-posta doğrulama kontrolü başarısız: $e');
    } finally {
      _verificationCheckInProgress = false;
    }
  }

  Future<bool> sendVerificationEmail({
    required String sendMailErrorMsg,
    required String tooManyRequestsMsg,
  }) async {
    if (!canResend) {
      return false;
    }

    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      errorMessage = sendMailErrorMsg;
      notifyListeners();
      return false;
    }

    errorMessage = '';
    isLoading = true;
    notifyListeners();

    try {
      await _sendVerificationEmail();
      await _startResendCooldownFromNow(userId);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        errorMessage = tooManyRequestsMsg;
        // Firebase'in sunucu tarafı kotası esas korumadır. Yerel cooldown,
        // kullanıcının aynı isteği peş peşe göndermesini de engeller.
        await _startResendCooldownFromNow(userId);
      } else {
        errorMessage = sendMailErrorMsg;
      }
      debugPrint('Verification email failed: ${e.code}');
      return false;
    } catch (e) {
      errorMessage = sendMailErrorMsg;
      debugPrint('Verification email failed: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _restoreResendCooldown() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      _setResendCooldownSeconds(0);
      return;
    }

    final prefs = await Constants().prefs;
    final nextAllowedAtMs = prefs.getInt(
      Constants.verificationEmailNextResendAtKey(userId),
    );

    if (nextAllowedAtMs == null) {
      _setResendCooldownSeconds(0);
      return;
    }

    final nextAllowedAt = DateTime.fromMillisecondsSinceEpoch(nextAllowedAtMs);
    _startResendCooldownUntil(nextAllowedAt, userId);
  }

  Future<void> _startResendCooldownFromNow(String userId) async {
    final nextAllowedAt = _now().add(_resendCooldown);
    final prefs = await Constants().prefs;
    await prefs.setInt(
      Constants.verificationEmailNextResendAtKey(userId),
      nextAllowedAt.millisecondsSinceEpoch,
    );
    _startResendCooldownUntil(nextAllowedAt, userId);
  }

  void _startResendCooldownUntil(DateTime nextAllowedAt, String userId) {
    _cancelResendCooldownTimer();
    _updateCooldownFromDeadline(nextAllowedAt);

    if (!isResendCoolingDown) {
      unawaited(_clearPersistedCooldown(userId));
      return;
    }

    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCooldownFromDeadline(nextAllowedAt);
      if (!isResendCoolingDown) {
        _cancelResendCooldownTimer();
        unawaited(_clearPersistedCooldown(userId));
      }
    });
  }

  void _updateCooldownFromDeadline(DateTime nextAllowedAt) {
    final remainingMs = nextAllowedAt.difference(_now()).inMilliseconds;
    final remainingSeconds = remainingMs <= 0
        ? 0
        : math.max(1, (remainingMs / 1000).ceil());
    _setResendCooldownSeconds(remainingSeconds);
  }

  void _setResendCooldownSeconds(int value) {
    if (resendCooldownSeconds == value) {
      return;
    }
    resendCooldownSeconds = value;
    notifyListeners();
  }

  Future<void> _clearPersistedCooldown(String userId) async {
    final prefs = await Constants().prefs;
    await prefs.remove(Constants.verificationEmailNextResendAtKey(userId));
  }

  void _cancelResendCooldownTimer() {
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = null;
  }

  String? get _currentUserId =>
      _currentUserIdOverride?.call() ?? Auth().currentUser?.uid;

  Future<bool> _checkEmailVerified() async {
    final override = _checkEmailVerifiedOverride;
    if (override != null) {
      return override();
    }

    await Auth().reloadUser();

    final isVerified = Auth().currentUser?.emailVerified ?? false;
    if (isVerified) {
      // Security Rules read the verification state from the ID token.
      // Ensure that token is refreshed before Wrapper allows cloud-backed UI.
      await Auth().ensureVerifiedEmailIdToken();
    }

    return isVerified;
  }

  Future<void> _sendVerificationEmail() async {
    final override = _sendVerificationEmailOverride;
    if (override != null) {
      await override();
      return;
    }

    await Auth().sendEmailVerification();
  }

  @override
  void dispose() {
    stopEmailVerificationCheckTimer();
    _cancelResendCooldownTimer();
    super.dispose();
  }
}
