// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'EN';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get login_WelcomeText => 'Welcome to QR Coder!';

  @override
  String get login_DescriptionText =>
      'Please enter your email and password to continue.';

  @override
  String get login_label_email => 'Email';

  @override
  String get login_label_password => 'Password';

  @override
  String get login_hint_email => 'Enter your email';

  @override
  String get login_hint_password => 'Enter your password';

  @override
  String get login_LoginOrRegisterToggle => 'Don\'t have an account? ';

  @override
  String get login_LoginOrRegisterToggleAlreadyHaveAccount =>
      'Already have an account. ';

  @override
  String get login_GuestAccessButton => 'Continue without an account';

  @override
  String get login_RememberMeCheckbox => 'Remember me';

  @override
  String get login_SubmitButtonLogIn => 'Sign in';

  @override
  String get login_SubmitButtonRegister => 'Register';

  @override
  String get login_ForgotPasswordButton => 'Forgot password';

  @override
  String get login_emailValidatorError => 'Please enter a valid email';

  @override
  String get login_emailValidator => 'Please enter an email';

  @override
  String get login_passwordValidator => 'Please enter a password';

  @override
  String get login_passwordValidatorError =>
      'Password must be at least 6 characters long';

  @override
  String get login_emailAlreadyRegistered =>
      'This email is already registered!';

  @override
  String get login_emailNotVerifiedMsg =>
      'Email verification not completed. Please check your email.';

  @override
  String get login_createUserErrorMsg => 'Failed to create user!';

  @override
  String get login_signInErrorMsg => 'Failed to sign in!';

  @override
  String get login_signInSuccessMsg => 'Sign in successful!';

  @override
  String get login_invalidCredentialsErrMsg => 'User not found!';

  @override
  String get qrCodeGenerator_FabSemantic => 'QR Code Generator Button';

  @override
  String get qrCodeGenerator_FabToolTip => 'Generate QR Code';

  @override
  String get qrCodeGenerator_LogOutToolTip => 'Log Out';

  @override
  String get qrCodeGenerator_LogOutErrorMsg => 'Failed to log out!';

  @override
  String get qrCodeGenerator_userType => 'Guest';

  @override
  String get qrCodeGenerator_textSemantic =>
      'Text field for entering data to be encoded';

  @override
  String get qrCodeGenerator_qrCodeSemantic => 'QR Code Preview';

  @override
  String get qrCodeGenerator_receiveErrorMsg => 'Failed to receive data!';

  @override
  String get qrCodeGenerator_sharedData => 'Shared data';

  @override
  String get qrCodeGenerator_savePermissionErrorMsg =>
      'Storage permission required!';

  @override
  String get qrCodeGenerator_saveErrorMsg => 'Failed to save QR Code!';

  @override
  String get qrCodeGenerator_saveToDbErrorMsg =>
      'Failed to save QR Code to database!';

  @override
  String get qrCodeGenerator_sharedTitle => 'Here is your QR Code';

  @override
  String get qrCodeGenerator_sharedErrorMsg => 'Failed to share QR Code!';

  @override
  String get qrCodeGenerator_dataEmptyMsg =>
      'Please enter some text to generate a QR Code!';

  @override
  String get qrCodeGenerator_qrCodeDefaultTitle => 'QR Code';

  @override
  String get qrCodeGenerator_qrCodeGeneratorErrMsg =>
      'Failed to generate QR Code!';

  @override
  String get qrCodeGenerator_startScanningToolTip => 'Start Barcode Scanner';

  @override
  String get qrcodeGenerator_qrCodeListToolTip => 'Saved QR Codes';

  @override
  String get qrCodeGenerator_textFieldHintText =>
      'Enter some text to generate a QR Code';

  @override
  String get qrCodeGenerator_dataTooLongErrMsg => 'Text is too long!';

  @override
  String get qrCodeGenerator_qrCode => 'QR Code';

  @override
  String get qrCodeList_title => 'Saved QR Codes';

  @override
  String get qrCodeList_deleteAllBtn => 'Delete All';

  @override
  String get qrCodeList_selectAllBtn => 'Select All';

  @override
  String get qrCodeList_deleteSelectedBtn => 'Delete Selected';

  @override
  String get qrCodeList_editBtn => 'Edit';

  @override
  String get qrCodeList_deleteBtn => 'Delete';

  @override
  String get qrCodeList_defaultQrCode => 'Welcome to QR Coder!';

  @override
  String get qrCodeList_fetchListErrorMsg => 'Failed to fetch QR Code list!';

  @override
  String get qrCodeList_emptyList => 'QR Code list is empty...';

  @override
  String get qrCodeList_updateDescriptionErrorMsg =>
      'Failed to update QR Code description!';

  @override
  String get qrCodeList_deleteAllErrorMsg => 'Failed to delete all QR Codes!';

  @override
  String get qrCodeList_deleteErrorMsg => 'Failed to delete QR Code!';

  @override
  String qrCodeList_qrCodeTitle(String qrCode) {
    return 'QR Code: $qrCode';
  }

  @override
  String get qrCodeDetail_Details => 'Details';

  @override
  String get qrCodeDetail_wifiInfo => 'Wi-Fi Information';

  @override
  String qrCodeDetail_wifiPassw(String password) {
    return 'Password: $password';
  }

  @override
  String qrCodeDetail_wifiEncryption(String encryption) {
    return 'Encryption: $encryption';
  }

  @override
  String qrCodeDetail_wifiHidden(String hidden) {
    return 'Hidden: $hidden';
  }

  @override
  String get qrCodeDetail_wifiConnectTextBtn => 'Connect';

  @override
  String get qrCodeDetail_OpenWifiSettingsButton => 'Open Wi-Fi Settings';

  @override
  String get qrCodeDetail_homePageNavToolTip => 'Home Page';

  @override
  String get qrCodeDetail_listPageNavToolTip => 'Saved QR Codes';

  @override
  String qrCodeDetail_createdDateTime(String createdAt) {
    return 'Created At: $createdAt';
  }

  @override
  String get qrCodeDetail_saveQrCodeButtonToolTip => 'Save QR Code';

  @override
  String get qrCodeDetail_saveSuccessMsg => 'QR Code saved successfully!';

  @override
  String get qrCodeDetail_openSavedQrCode => 'Open';

  @override
  String get qrCodeDetail_shareQrCodeBtnToolTip => 'Share QR Code';

  @override
  String get qrCodeDetail_resolution => 'Resolution';

  @override
  String get qrCodeDetail_download => 'Download';

  @override
  String get qrCodeDetail_resolutionStandard => 'Standard Resolution';

  @override
  String get qrCodeDetail_resolutionHigh => 'High Resolution';

  @override
  String get qrCodeDetail_resolutionUltra => 'Ultra Resolution';

  @override
  String get verificationPage_description =>
      'Pending Verification.\nPlease check your email.';

  @override
  String get verificationPage_emailVerifiedMsg =>
      'User verification completed!\nWelcome to QR Coder!';

  @override
  String get verificationPage_emailVerificationErrorMsg =>
      'User verification failed!';

  @override
  String get verificationPage_sendMailErrorMsg =>
      'Failed to send verification email!\nPlease try again.';

  @override
  String get verificationPage_verificationEmailResentMsg =>
      'Verification link sent again.';

  @override
  String get verificationPage_sendAgainBtn => 'Send Again';

  @override
  String get verificationPage_welcomeTitle => 'Welcome to QR Coder!';

  @override
  String get verificationPage_sendAgainMsg =>
      'New verification email sent. Please verify your account within 24 hours.';

  @override
  String get verificationPage_sendVerificationEmail =>
      'Verification email sent.\nPlease check your email.';

  @override
  String get forgotPasswordPage_description =>
      'Please enter your email to reset your password.';

  @override
  String get forgotPasswordPage_emailValidatorError =>
      'Please enter a valid email';

  @override
  String get forgotPasswordPage_emailValidator => 'Please enter an email';

  @override
  String get forgotPasswordPage_textFieldLabelText => 'Email';

  @override
  String get forgotPasswordPage_textFieldHintText => 'Enter your email';

  @override
  String get forgotPasswordPage_sendMailErrorMsg =>
      'Failed to send password reset email!\nPlease try again.';

  @override
  String get forgotPasswordPage_sendEmailSuccessMsg =>
      'Password reset email sent.\nYou are directed to the login page.';

  @override
  String get forgotPasswordPage_btnSend => 'Send';

  @override
  String get scannerPage_title => 'Barcode Scanner';

  @override
  String get scannerPage_cleanScannedListBtn => 'Clean';

  @override
  String get scannerPage_emptyScannedList => 'Let\'s scan something!';

  @override
  String get scannerPage_scannedData => 'Saved QR codes';

  @override
  String get scannerPage_unkonwnBarcode => 'Unknown Barcode';

  @override
  String get scannerPage_savedToListMsg => 'QR Code saved successfully!';

  @override
  String get scannerPage_saveErrorMsg => 'Failed to save QR Code!';

  @override
  String get scannerErrorWidget_controllerUninitialized =>
      'Controller is not ready.';

  @override
  String get scannerErrorWidget_permissionDenied => 'Permission denied';

  @override
  String get scannerErrorWidget_unsupported =>
      'Browser does not support this device.';

  @override
  String get scannerErrorWidget_unknown => 'Unknown Error. Please try again.';

  @override
  String get scannerPage_cameraStartError =>
      'Camera could not be started. Please try again.';

  @override
  String get scannerPage_refreshBtnToolTip => 'Refresh Camera';

  @override
  String get wrapper_LoginPageToolTip => 'Unexpected Error Occurred!';

  @override
  String get qrcodeDisplay_pageTitle => 'A a! Bir şeyler ters gitti...';

  @override
  String get qrcodeDisplay_remove_logo => 'Remove Logo';

  @override
  String get qrcodeDisplay_removed_logo => 'Logo removed.';

  @override
  String get qrcodeDisplay_error_ad => 'Ad failed to load.';

  @override
  String get qrcodeDisplay_loading_ad => 'Ad is loading, please try again.';

  @override
  String get qrcodeDisplay_permission_remove_logo =>
      'You need to watch a rewarded ad to remove the logo. Do you want to continue?';
}
