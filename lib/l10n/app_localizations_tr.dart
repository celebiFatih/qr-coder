// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get language => 'TR';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get login_WelcomeText => 'QR Coder\'a Hoşgeldiniz!';

  @override
  String get login_DescriptionText =>
      'Devam etmek için e-posta ve şifrenizi girin.';

  @override
  String get login_label_email => 'E-posta';

  @override
  String get login_label_password => 'Parola';

  @override
  String get login_hint_email => 'E-postanızı girin';

  @override
  String get login_hint_password => 'Parolanızı girin';

  @override
  String get login_LoginOrRegisterToggle => 'Hesabın yok mu? ';

  @override
  String get login_LoginOrRegisterToggleAlreadyHaveAccount =>
      'Zaten hesabım var. ';

  @override
  String get login_GuestAccessButton => 'Kaydolmadan devam et';

  @override
  String get login_RememberMeCheckbox => 'Beni hatırla';

  @override
  String get login_SubmitButtonLogIn => 'Giriş yap';

  @override
  String get login_SubmitButtonRegister => 'Kaydol';

  @override
  String get login_ForgotPasswordButton => 'Şifremi unuttum';

  @override
  String get login_emailValidatorError => 'Lütfen geçerli bir e-posta girin';

  @override
  String get login_emailValidator => 'Lütfen bir e-posta girin';

  @override
  String get login_passwordValidator => 'Lütfen şifre girin';

  @override
  String get login_passwordValidatorError =>
      'Şifre en az 6 karakter uzunluğunda olmalı';

  @override
  String get login_emailAlreadyRegistered => 'Bu e-posta zaten kayıtlı!';

  @override
  String get login_emailNotVerifiedMsg =>
      'E-posta doğrulaması yapılmadı. Lütfen e-postanızı kontrol edin.';

  @override
  String get login_createUserErrorMsg => 'Kullanıcı kaydı oluşturulamadı!';

  @override
  String get login_signInErrorMsg => 'Giriş yapılamadı!';

  @override
  String get login_signInSuccessMsg => 'Giriş yapıldı!';

  @override
  String get login_invalidCredentialsErrMsg => 'Kullanıcı kaydı bulunamadı!';

  @override
  String get qrCodeGenerator_FabSemantic => 'QR Kodu oluşturma butonu';

  @override
  String get qrCodeGenerator_FabToolTip => 'QR Code Oluştur';

  @override
  String get qrCodeGenerator_LogOutToolTip => 'Oturumu Sonlandır';

  @override
  String get qrCodeGenerator_LogOutErrorMsg => 'Oturum kapatılamadı!';

  @override
  String get qrCodeGenerator_userType => 'Misafir';

  @override
  String get qrCodeGenerator_textSemantic =>
      'QR kodu oluşturmaya yönelik verileri girmek için metin alanı';

  @override
  String get qrCodeGenerator_qrCodeSemantic => 'QR kodu görüntüsü';

  @override
  String get qrCodeGenerator_receiveErrorMsg => 'Veri alınamadı!';

  @override
  String get qrCodeGenerator_sharedData => 'Paylaşılan veri';

  @override
  String get qrCodeGenerator_savePermissionErrorMsg => 'Depolama izni gerekli!';

  @override
  String get qrCodeGenerator_saveErrorMsg => 'QR kodu kaydetme hatası!';

  @override
  String get qrCodeGenerator_saveToDbErrorMsg =>
      'QR kod veritabanına kaydedilemedi!';

  @override
  String get qrCodeGenerator_sharedTitle => 'İşte QR kodunuz';

  @override
  String get qrCodeGenerator_sharedErrorMsg => 'QR kodu paylaşılamadı!';

  @override
  String get qrCodeGenerator_dataEmptyMsg =>
      'QR kod oluşturmak için bir metin girin!';

  @override
  String get qrCodeGenerator_qrCodeDefaultTitle => 'QR Kod';

  @override
  String get qrCodeGenerator_qrCodeGeneratorErrMsg =>
      'QR kod oluşturma hataası!';

  @override
  String get qrCodeGenerator_startScanningToolTip => 'Tarayıcıyı Başlat';

  @override
  String get qrcodeGenerator_qrCodeListToolTip => 'Son Kaydedilenler';

  @override
  String get qrCodeGenerator_textFieldHintText =>
      'QR kod oluşturulacak metni girin';

  @override
  String get qrCodeGenerator_dataTooLongErrMsg => 'Metin çok uzun!';

  @override
  String get qrCodeGenerator_qrCode => 'QR Kod';

  @override
  String get qrCodeList_title => 'Son Oluşturulanlar';

  @override
  String get qrCodeList_deleteAllBtn => 'Tümünü Sil';

  @override
  String get qrCodeList_selectAllBtn => 'Tümünü Seç';

  @override
  String get qrCodeList_deleteSelectedBtn => 'Seçilenleri Sil';

  @override
  String get qrCodeList_editBtn => 'Düzenle';

  @override
  String get qrCodeList_deleteBtn => 'Delete';

  @override
  String get qrCodeList_defaultQrCode => 'QR Coder\'a Hoşgeldiniz!';

  @override
  String get qrCodeList_fetchListErrorMsg => 'QR Kod listesi alınamadı!';

  @override
  String get qrCodeList_emptyList => 'QR Kod listesi boş...';

  @override
  String get qrCodeList_updateDescriptionErrorMsg =>
      'QR Kod tanımlaması güncellenemedi!';

  @override
  String get qrCodeList_deleteAllErrorMsg => 'Tüm QR Kodlar silinemedi!';

  @override
  String get qrCodeList_deleteErrorMsg => 'QR Kod silinemedi!';

  @override
  String qrCodeList_qrCodeTitle(String qrCode) {
    return 'QR Kod: $qrCode';
  }

  @override
  String get qrCodeDetail_Details => 'Detaylar';

  @override
  String get qrCodeDetail_wifiInfo => 'Wi-Fi Bilgileri';

  @override
  String qrCodeDetail_wifiPassw(String password) {
    return 'Şifre: $password';
  }

  @override
  String qrCodeDetail_wifiEncryption(String encryption) {
    return 'Şifreleme: $encryption';
  }

  @override
  String qrCodeDetail_wifiHidden(String hidden) {
    return 'Gizli: $hidden';
  }

  @override
  String get qrCodeDetail_wifiConnectTextBtn => 'Bağlan';

  @override
  String get qrCodeDetail_OpenWifiSettingsButton => 'Wi-Fi ayarlarını aç';

  @override
  String get qrCodeDetail_homePageNavToolTip => 'Ana Sayfa';

  @override
  String get qrCodeDetail_listPageNavToolTip => 'Kaydedilenler';

  @override
  String qrCodeDetail_createdDateTime(String createdAt) {
    return 'Oluşturma Tarihi: $createdAt';
  }

  @override
  String get qrCodeDetail_saveQrCodeButtonToolTip => 'QR kodu indir';

  @override
  String get qrCodeDetail_saveSuccessMsg =>
      'QR kodu başarılı bir şekilde indirildi!';

  @override
  String get qrCodeDetail_openSavedQrCode => 'Aç';

  @override
  String get qrCodeDetail_shareQrCodeBtnToolTip => 'Paylaş';

  @override
  String get qrCodeDetail_resolution => 'Çözünürlük';

  @override
  String get qrCodeDetail_download => 'İndir';

  @override
  String get qrCodeDetail_resolutionStandard => 'Standart Çözünürlük';

  @override
  String get qrCodeDetail_resolutionHigh => 'Yüksek Çözünürlük';

  @override
  String get qrCodeDetail_resolutionUltra => 'Ultra Çözünürlük';

  @override
  String get verificationPage_description =>
      'Doğrulama bekleniyor.\nLütfen e-postanızı kontrol edin.';

  @override
  String get verificationPage_emailVerifiedMsg =>
      'Kullanıcı doğrulaması tamamlandı!\nQR Coder\'a Hoşgeldiniz!';

  @override
  String get verificationPage_emailVerificationErrorMsg =>
      'Kullanıcı doğrulaması tamamlanamadı!';

  @override
  String get verificationPage_sendMailErrorMsg =>
      'Doğrulama e-postası gönderilemedi!\nLütfen yeniden deneyin.';

  @override
  String get verificationPage_verificationEmailResentMsg =>
      'Doğrulama bağlantısı tekrar gönderildi.';

  @override
  String get verificationPage_sendAgainBtn => 'Yeniden gönderin';

  @override
  String get verificationPage_welcomeTitle => 'QR Coder\'a Hoşgeldiniz!';

  @override
  String get verificationPage_sendAgainMsg =>
      'Yeni bir doğrulama e-postası gönderildi. Lütfen 24 saat içinde doğrulayın.';

  @override
  String get verificationPage_sendVerificationEmail =>
      'Doğrulama e-postası gönderildi.\nLütfen e-postanızı kontrol edin.';

  @override
  String get forgotPasswordPage_description =>
      'Lütfen sıfırlama isteğiniz için e-posta adresinizi girin.';

  @override
  String get forgotPasswordPage_emailValidatorError =>
      'Lütfen geçerli bir e-posta girin';

  @override
  String get forgotPasswordPage_emailValidator => 'Lütfen bir e-posta girin';

  @override
  String get forgotPasswordPage_textFieldLabelText => 'E-posta';

  @override
  String get forgotPasswordPage_textFieldHintText => 'E-postanızı girin';

  @override
  String get forgotPasswordPage_sendMailErrorMsg =>
      'Parola sıfırlama e-postası gönderilemedi!\nLütfen yeniden deneyin.';

  @override
  String get forgotPasswordPage_sendEmailSuccessMsg =>
      'Parola sıfırlama e-postası gönderildi.\nGiriş sayfasına yönlendiriliyorsunuz.';

  @override
  String get forgotPasswordPage_btnSend => 'Gönder';

  @override
  String get scannerPage_title => 'Barkod Tarayıcısı';

  @override
  String get scannerPage_cleanScannedListBtn => 'Temizle';

  @override
  String get scannerPage_emptyScannedList => 'Bir şeyler tarayın!';

  @override
  String get scannerPage_scannedData => 'Taranan veri';

  @override
  String get scannerPage_unkonwnBarcode => 'Tanımlanamayan barkod';

  @override
  String get scannerPage_savedToListMsg => 'QR kodu listeye kaydedildi';

  @override
  String get scannerPage_saveErrorMsg => 'QR kod kaydedilemedi!';

  @override
  String get scannerErrorWidget_controllerUninitialized =>
      'Denetleyici hazır değil.';

  @override
  String get scannerErrorWidget_permissionDenied => 'İzin reddedildi';

  @override
  String get scannerErrorWidget_unsupported =>
      'Tarayıcı bu cihazda desteklenmiyor.';

  @override
  String get scannerErrorWidget_unknown => 'Genel Hata. Lütfen tekrar deneyin.';

  @override
  String get scannerPage_cameraStartError =>
      'Kamera başlatılamadı. Lütfen tekrar deneyin.';

  @override
  String get scannerPage_refreshBtnToolTip => 'Kamerayı Yenile';

  @override
  String get wrapper_LoginPageToolTip => 'Beklenmeyen Bir Hata oluştu!';

  @override
  String get qrcodeDisplay_pageTitle => 'A a! Bir şeyler ters gitti...';

  @override
  String get qrcodeDisplay_remove_logo => 'Logoyu Kaldır';

  @override
  String get qrcodeDisplay_removed_logo => 'Logo kaldırıldı.';

  @override
  String get qrcodeDisplay_error_ad => 'Reklam yüklenemedi';

  @override
  String get qrcodeDisplay_loading_ad =>
      'Reklam yükleniyor, lütfen tekrar deneyin.';

  @override
  String get qrcodeDisplay_permission_remove_logo =>
      'Logoyu kaldırmak için bir reklam izlemeniz gerekiyor. Devam etmek istiyor musunuz?';
}
