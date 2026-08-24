import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get language;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @login_WelcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to QR Coder!'**
  String get login_WelcomeText;

  /// No description provided for @login_DescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password to continue.'**
  String get login_DescriptionText;

  /// No description provided for @login_label_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get login_label_email;

  /// No description provided for @login_label_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_label_password;

  /// No description provided for @login_hint_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get login_hint_email;

  /// No description provided for @login_hint_password.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get login_hint_password;

  /// No description provided for @login_LoginOrRegisterToggle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get login_LoginOrRegisterToggle;

  /// No description provided for @login_LoginOrRegisterToggleAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account. '**
  String get login_LoginOrRegisterToggleAlreadyHaveAccount;

  /// No description provided for @login_GuestAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get login_GuestAccessButton;

  /// No description provided for @login_RememberMeCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Remember my email'**
  String get login_RememberMeCheckbox;

  /// No description provided for @login_SubmitButtonLogIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login_SubmitButtonLogIn;

  /// No description provided for @login_SubmitButtonRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get login_SubmitButtonRegister;

  /// No description provided for @login_ForgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get login_ForgotPasswordButton;

  /// No description provided for @login_emailValidatorError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get login_emailValidatorError;

  /// No description provided for @login_emailValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get login_emailValidator;

  /// No description provided for @login_passwordValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get login_passwordValidator;

  /// No description provided for @login_passwordValidatorError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get login_passwordValidatorError;

  /// No description provided for @login_emailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered!'**
  String get login_emailAlreadyRegistered;

  /// No description provided for @login_emailNotVerifiedMsg.
  ///
  /// In en, this message translates to:
  /// **'Email verification not completed. Please check your email.'**
  String get login_emailNotVerifiedMsg;

  /// No description provided for @login_createUserErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to create user!'**
  String get login_createUserErrorMsg;

  /// No description provided for @login_signInErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in!'**
  String get login_signInErrorMsg;

  /// No description provided for @login_signInSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Sign in successful!'**
  String get login_signInSuccessMsg;

  /// No description provided for @login_invalidCredentialsErrMsg.
  ///
  /// In en, this message translates to:
  /// **'User not found!'**
  String get login_invalidCredentialsErrMsg;

  /// No description provided for @qrCodeGenerator_FabSemantic.
  ///
  /// In en, this message translates to:
  /// **'QR Code Generator Button'**
  String get qrCodeGenerator_FabSemantic;

  /// No description provided for @qrCodeGenerator_FabToolTip.
  ///
  /// In en, this message translates to:
  /// **'Generate QR Code'**
  String get qrCodeGenerator_FabToolTip;

  /// No description provided for @qrCodeGenerator_LogOutToolTip.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get qrCodeGenerator_LogOutToolTip;

  /// No description provided for @qrCodeGenerator_LogOutErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to log out!'**
  String get qrCodeGenerator_LogOutErrorMsg;

  /// No description provided for @qrCodeGenerator_userType.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get qrCodeGenerator_userType;

  /// No description provided for @qrCodeGenerator_textSemantic.
  ///
  /// In en, this message translates to:
  /// **'Text field for entering data to be encoded'**
  String get qrCodeGenerator_textSemantic;

  /// No description provided for @qrCodeGenerator_qrCodeSemantic.
  ///
  /// In en, this message translates to:
  /// **'QR Code Preview'**
  String get qrCodeGenerator_qrCodeSemantic;

  /// No description provided for @qrCodeGenerator_previewEmptyMsg.
  ///
  /// In en, this message translates to:
  /// **'Your QR Code preview will appear here.'**
  String get qrCodeGenerator_previewEmptyMsg;

  /// No description provided for @qrCodeGenerator_receiveErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to receive data!'**
  String get qrCodeGenerator_receiveErrorMsg;

  /// No description provided for @qrCodeGenerator_sharedData.
  ///
  /// In en, this message translates to:
  /// **'Shared data'**
  String get qrCodeGenerator_sharedData;

  /// No description provided for @qrCodeGenerator_savePermissionErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required!'**
  String get qrCodeGenerator_savePermissionErrorMsg;

  /// No description provided for @qrCodeGenerator_saveErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to save QR Code!'**
  String get qrCodeGenerator_saveErrorMsg;

  /// No description provided for @qrCodeGenerator_saveToDbErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to save QR Code to database!'**
  String get qrCodeGenerator_saveToDbErrorMsg;

  /// No description provided for @qrCodeGenerator_sharedTitle.
  ///
  /// In en, this message translates to:
  /// **'Here is your QR Code'**
  String get qrCodeGenerator_sharedTitle;

  /// No description provided for @qrCodeGenerator_sharedErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to share QR Code!'**
  String get qrCodeGenerator_sharedErrorMsg;

  /// No description provided for @qrCodeGenerator_dataEmptyMsg.
  ///
  /// In en, this message translates to:
  /// **'Please enter some text to generate a QR Code!'**
  String get qrCodeGenerator_dataEmptyMsg;

  /// No description provided for @qrCodeGenerator_qrCodeDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCodeGenerator_qrCodeDefaultTitle;

  /// No description provided for @qrCodeGenerator_qrCodeGeneratorErrMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate QR Code!'**
  String get qrCodeGenerator_qrCodeGeneratorErrMsg;

  /// No description provided for @qrCodeGenerator_startScanningToolTip.
  ///
  /// In en, this message translates to:
  /// **'Start Barcode Scanner'**
  String get qrCodeGenerator_startScanningToolTip;

  /// No description provided for @qrCodeGenerator_privacyOptionsToolTip.
  ///
  /// In en, this message translates to:
  /// **'Privacy options'**
  String get qrCodeGenerator_privacyOptionsToolTip;

  /// No description provided for @qrCodeGenerator_privacyOptionsErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Privacy options could not be opened. Please try again.'**
  String get qrCodeGenerator_privacyOptionsErrorMsg;

  /// No description provided for @qrcodeGenerator_qrCodeListToolTip.
  ///
  /// In en, this message translates to:
  /// **'Saved QR Codes'**
  String get qrcodeGenerator_qrCodeListToolTip;

  /// No description provided for @qrCodeGenerator_textFieldHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter some text to generate a QR Code'**
  String get qrCodeGenerator_textFieldHintText;

  /// No description provided for @qrCodeGenerator_clearTextToolTip.
  ///
  /// In en, this message translates to:
  /// **'Clear text'**
  String get qrCodeGenerator_clearTextToolTip;

  /// No description provided for @qrCodeGenerator_dataTooLongErrMsg.
  ///
  /// In en, this message translates to:
  /// **'Text is too long!'**
  String get qrCodeGenerator_dataTooLongErrMsg;

  /// No description provided for @qrCodeGenerator_qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCodeGenerator_qrCode;

  /// No description provided for @qrCodeList_title.
  ///
  /// In en, this message translates to:
  /// **'Saved QR Codes'**
  String get qrCodeList_title;

  /// No description provided for @qrCodeList_deleteAllBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get qrCodeList_deleteAllBtn;

  /// No description provided for @qrCodeList_selectAllBtn.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get qrCodeList_selectAllBtn;

  /// No description provided for @qrCodeList_deleteSelectedBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get qrCodeList_deleteSelectedBtn;

  /// No description provided for @qrCodeList_editBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get qrCodeList_editBtn;

  /// No description provided for @qrCodeList_deleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get qrCodeList_deleteBtn;

  /// No description provided for @qrCodeList_defaultQrCode.
  ///
  /// In en, this message translates to:
  /// **'Welcome to QR Coder!'**
  String get qrCodeList_defaultQrCode;

  /// No description provided for @qrCodeList_fetchListErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch QR Code list!'**
  String get qrCodeList_fetchListErrorMsg;

  /// No description provided for @qrCodeList_emptyList.
  ///
  /// In en, this message translates to:
  /// **'QR Code list is empty...'**
  String get qrCodeList_emptyList;

  /// No description provided for @qrCodeList_updateDescriptionErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to update QR Code description!'**
  String get qrCodeList_updateDescriptionErrorMsg;

  /// No description provided for @qrCodeList_deleteAllErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete all QR Codes!'**
  String get qrCodeList_deleteAllErrorMsg;

  /// No description provided for @qrCodeList_deleteErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete QR Code!'**
  String get qrCodeList_deleteErrorMsg;

  /// No description provided for @qrCodeList_deleteSelectedErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete selected QR Codes!'**
  String get qrCodeList_deleteSelectedErrorMsg;

  /// No description provided for @qrCodeList_qrCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'QR Code: {qrCode}'**
  String qrCodeList_qrCodeTitle(String qrCode);

  /// No description provided for @qrCodeList_selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String qrCodeList_selectedCount(int count);

  /// No description provided for @qrCodeList_selectBtn.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get qrCodeList_selectBtn;

  /// No description provided for @qrCodeList_exitSelectionBtn.
  ///
  /// In en, this message translates to:
  /// **'Exit selection'**
  String get qrCodeList_exitSelectionBtn;

  /// No description provided for @qrCodeList_retryBtn.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get qrCodeList_retryBtn;

  /// No description provided for @qrCodeList_editTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename QR Code'**
  String get qrCodeList_editTitle;

  /// No description provided for @qrCodeList_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get qrCodeList_nameLabel;

  /// No description provided for @qrCodeList_cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get qrCodeList_cancelBtn;

  /// No description provided for @qrCodeList_saveEditBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get qrCodeList_saveEditBtn;

  /// No description provided for @qrCodeList_deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete QR Code?'**
  String get qrCodeList_deleteConfirmTitle;

  /// No description provided for @qrCodeList_deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This QR code will be permanently deleted.'**
  String get qrCodeList_deleteConfirmMessage;

  /// No description provided for @qrCodeList_deleteSelectedConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete selected QR codes?'**
  String get qrCodeList_deleteSelectedConfirmTitle;

  /// No description provided for @qrCodeList_deleteSelectedConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} selected QR codes will be permanently deleted.'**
  String qrCodeList_deleteSelectedConfirmMessage(int count);

  /// No description provided for @qrCodeList_deleteAllConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all QR codes?'**
  String get qrCodeList_deleteAllConfirmTitle;

  /// No description provided for @qrCodeList_deleteAllConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'All saved QR codes will be permanently deleted.'**
  String get qrCodeList_deleteAllConfirmMessage;

  /// No description provided for @qrCodeDetail_Details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get qrCodeDetail_Details;

  /// No description provided for @qrCodeDetail_wifiInfo.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Information'**
  String get qrCodeDetail_wifiInfo;

  /// No description provided for @qrCodeDetail_wifiPassw.
  ///
  /// In en, this message translates to:
  /// **'Password: {password}'**
  String qrCodeDetail_wifiPassw(String password);

  /// No description provided for @qrCodeDetail_wifiEncryption.
  ///
  /// In en, this message translates to:
  /// **'Encryption: {encryption}'**
  String qrCodeDetail_wifiEncryption(String encryption);

  /// No description provided for @qrCodeDetail_wifiHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden: {hidden}'**
  String qrCodeDetail_wifiHidden(String hidden);

  /// No description provided for @qrCodeDetail_wifiConnectTextBtn.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get qrCodeDetail_wifiConnectTextBtn;

  /// No description provided for @qrCodeDetail_OpenWifiSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open Wi-Fi Settings'**
  String get qrCodeDetail_OpenWifiSettingsButton;

  /// No description provided for @qrCodeDetail_homePageNavToolTip.
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get qrCodeDetail_homePageNavToolTip;

  /// No description provided for @qrCodeDetail_listPageNavToolTip.
  ///
  /// In en, this message translates to:
  /// **'Saved QR Codes'**
  String get qrCodeDetail_listPageNavToolTip;

  /// No description provided for @qrCodeDetail_createdDateTime.
  ///
  /// In en, this message translates to:
  /// **'Created At: {createdAt}'**
  String qrCodeDetail_createdDateTime(String createdAt);

  /// No description provided for @qrCodeDetail_saveQrCodeButtonToolTip.
  ///
  /// In en, this message translates to:
  /// **'Save QR Code'**
  String get qrCodeDetail_saveQrCodeButtonToolTip;

  /// No description provided for @qrCodeDetail_saveSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'QR Code saved successfully!'**
  String get qrCodeDetail_saveSuccessMsg;

  /// No description provided for @qrCodeDetail_openSavedQrCode.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get qrCodeDetail_openSavedQrCode;

  /// No description provided for @qrCodeDetail_shareQrCodeBtnToolTip.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get qrCodeDetail_shareQrCodeBtnToolTip;

  /// No description provided for @qrCodeDetail_resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get qrCodeDetail_resolution;

  /// No description provided for @qrCodeDetail_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get qrCodeDetail_download;

  /// No description provided for @qrCodeDetail_resolutionStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard Resolution'**
  String get qrCodeDetail_resolutionStandard;

  /// No description provided for @qrCodeDetail_resolutionHigh.
  ///
  /// In en, this message translates to:
  /// **'High Resolution'**
  String get qrCodeDetail_resolutionHigh;

  /// No description provided for @qrCodeDetail_resolutionUltra.
  ///
  /// In en, this message translates to:
  /// **'Ultra Resolution'**
  String get qrCodeDetail_resolutionUltra;

  /// No description provided for @verificationPage_description.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification.\nPlease check your email.'**
  String get verificationPage_description;

  /// No description provided for @verificationPage_emailVerifiedMsg.
  ///
  /// In en, this message translates to:
  /// **'User verification completed!\nWelcome to QR Coder!'**
  String get verificationPage_emailVerifiedMsg;

  /// No description provided for @verificationPage_emailVerificationErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'User verification failed!'**
  String get verificationPage_emailVerificationErrorMsg;

  /// No description provided for @verificationPage_sendMailErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email!\nPlease try again.'**
  String get verificationPage_sendMailErrorMsg;

  /// No description provided for @verificationPage_verificationEmailResentMsg.
  ///
  /// In en, this message translates to:
  /// **'Verification link sent again.'**
  String get verificationPage_verificationEmailResentMsg;

  /// No description provided for @verificationPage_sendAgainBtn.
  ///
  /// In en, this message translates to:
  /// **'Send Again'**
  String get verificationPage_sendAgainBtn;

  /// No description provided for @verificationPage_sendAgainCooldownBtn.
  ///
  /// In en, this message translates to:
  /// **'Send again ({seconds}s)'**
  String verificationPage_sendAgainCooldownBtn(int seconds);

  /// No description provided for @verificationPage_tooManyRequestsMsg.
  ///
  /// In en, this message translates to:
  /// **'Too many requests were sent. Please try again later.'**
  String get verificationPage_tooManyRequestsMsg;

  /// No description provided for @verificationPage_useDifferentAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with a different account'**
  String get verificationPage_useDifferentAccountBtn;

  /// No description provided for @verificationPage_welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to QR Coder!'**
  String get verificationPage_welcomeTitle;

  /// No description provided for @verificationPage_sendAgainMsg.
  ///
  /// In en, this message translates to:
  /// **'New verification email sent. Please verify your account within 24 hours.'**
  String get verificationPage_sendAgainMsg;

  /// No description provided for @verificationPage_sendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.\nPlease check your email.'**
  String get verificationPage_sendVerificationEmail;

  /// No description provided for @forgotPasswordPage_description.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email to reset your password.'**
  String get forgotPasswordPage_description;

  /// No description provided for @forgotPasswordPage_emailValidatorError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get forgotPasswordPage_emailValidatorError;

  /// No description provided for @forgotPasswordPage_emailValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get forgotPasswordPage_emailValidator;

  /// No description provided for @forgotPasswordPage_textFieldLabelText.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordPage_textFieldLabelText;

  /// No description provided for @forgotPasswordPage_textFieldHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get forgotPasswordPage_textFieldHintText;

  /// No description provided for @forgotPasswordPage_sendMailErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to send password reset email!\nPlease try again.'**
  String get forgotPasswordPage_sendMailErrorMsg;

  /// No description provided for @forgotPasswordPage_sendEmailSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.\nYou are directed to the login page.'**
  String get forgotPasswordPage_sendEmailSuccessMsg;

  /// No description provided for @forgotPasswordPage_btnSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get forgotPasswordPage_btnSend;

  /// No description provided for @scannerPage_title.
  ///
  /// In en, this message translates to:
  /// **'Barcode Scanner'**
  String get scannerPage_title;

  /// No description provided for @scannerPage_cleanScannedListBtn.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get scannerPage_cleanScannedListBtn;

  /// No description provided for @scannerPage_emptyScannedList.
  ///
  /// In en, this message translates to:
  /// **'Let\'s scan something!'**
  String get scannerPage_emptyScannedList;

  /// No description provided for @scannerPage_scannedData.
  ///
  /// In en, this message translates to:
  /// **'Scanned data'**
  String get scannerPage_scannedData;

  /// No description provided for @scannerPage_unkonwnBarcode.
  ///
  /// In en, this message translates to:
  /// **'Unknown Barcode'**
  String get scannerPage_unkonwnBarcode;

  /// No description provided for @scannerPage_savedToListMsg.
  ///
  /// In en, this message translates to:
  /// **'QR Code saved successfully!'**
  String get scannerPage_savedToListMsg;

  /// No description provided for @scannerPage_saveErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Failed to save QR Code!'**
  String get scannerPage_saveErrorMsg;

  /// No description provided for @scannerErrorWidget_controllerUninitialized.
  ///
  /// In en, this message translates to:
  /// **'Controller is not ready.'**
  String get scannerErrorWidget_controllerUninitialized;

  /// No description provided for @scannerErrorWidget_permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get scannerErrorWidget_permissionDenied;

  /// No description provided for @scannerErrorWidget_unsupported.
  ///
  /// In en, this message translates to:
  /// **'Browser does not support this device.'**
  String get scannerErrorWidget_unsupported;

  /// No description provided for @scannerErrorWidget_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error. Please try again.'**
  String get scannerErrorWidget_unknown;

  /// No description provided for @scannerPage_cameraStartError.
  ///
  /// In en, this message translates to:
  /// **'Camera could not be started. Please try again.'**
  String get scannerPage_cameraStartError;

  /// No description provided for @scannerPage_refreshBtnToolTip.
  ///
  /// In en, this message translates to:
  /// **'Refresh Camera'**
  String get scannerPage_refreshBtnToolTip;

  /// No description provided for @wrapper_LoginPageToolTip.
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error Occurred!'**
  String get wrapper_LoginPageToolTip;

  /// No description provided for @qrcodeDisplay_pageTitle.
  ///
  /// In en, this message translates to:
  /// **'A a! Bir şeyler ters gitti...'**
  String get qrcodeDisplay_pageTitle;

  /// No description provided for @qrcodeDisplay_remove_logo.
  ///
  /// In en, this message translates to:
  /// **'Remove Logo'**
  String get qrcodeDisplay_remove_logo;

  /// No description provided for @qrcodeDisplay_removed_logo.
  ///
  /// In en, this message translates to:
  /// **'Logo removed.'**
  String get qrcodeDisplay_removed_logo;

  /// No description provided for @qrcodeDisplay_error_ad.
  ///
  /// In en, this message translates to:
  /// **'Ad failed to load.'**
  String get qrcodeDisplay_error_ad;

  /// No description provided for @qrcodeDisplay_loading_ad.
  ///
  /// In en, this message translates to:
  /// **'Ad is loading, please try again...'**
  String get qrcodeDisplay_loading_ad;

  /// No description provided for @qrcodeDisplay_permission_remove_logo.
  ///
  /// In en, this message translates to:
  /// **'You need to watch a rewarded ad to remove the logo. Do you want to continue?'**
  String get qrcodeDisplay_permission_remove_logo;

  /// No description provided for @accountPrivacy_title.
  ///
  /// In en, this message translates to:
  /// **'Account & Privacy'**
  String get accountPrivacy_title;

  /// No description provided for @accountPrivacy_guestAccount.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get accountPrivacy_guestAccount;

  /// No description provided for @accountPrivacy_guestDescription.
  ///
  /// In en, this message translates to:
  /// **'QR codes are stored locally while you use guest mode.'**
  String get accountPrivacy_guestDescription;

  /// No description provided for @accountPrivacy_cloudAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Verified account. Saved QR codes are stored in your cloud account.'**
  String get accountPrivacy_cloudAccountDescription;

  /// No description provided for @accountPrivacy_privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get accountPrivacy_privacyPolicy;

  /// No description provided for @accountPrivacy_privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'See how QR Coder handles data, advertising, and privacy.'**
  String get accountPrivacy_privacyPolicyDescription;

  /// No description provided for @accountPrivacy_accountDeletionInfo.
  ///
  /// In en, this message translates to:
  /// **'Account deletion information'**
  String get accountPrivacy_accountDeletionInfo;

  /// No description provided for @accountPrivacy_accountDeletionInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Open the account deletion instructions on the web.'**
  String get accountPrivacy_accountDeletionInfoDescription;

  /// No description provided for @accountPrivacy_deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountPrivacy_deleteAccountTitle;

  /// No description provided for @accountPrivacy_deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes your QR Coder account and QR codes stored in your cloud account. This cannot be undone.'**
  String get accountPrivacy_deleteAccountDescription;

  /// No description provided for @accountPrivacy_deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get accountPrivacy_deleteAccountButton;

  /// No description provided for @accountPrivacy_deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get accountPrivacy_deletingAccount;

  /// No description provided for @accountPrivacy_deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account?'**
  String get accountPrivacy_deleteConfirmTitle;

  /// No description provided for @accountPrivacy_deleteConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm. Your account and cloud-saved QR codes will be permanently deleted.'**
  String get accountPrivacy_deleteConfirmDescription;

  /// No description provided for @accountPrivacy_passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get accountPrivacy_passwordLabel;

  /// No description provided for @accountPrivacy_deleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountPrivacy_deleteConfirmButton;

  /// No description provided for @accountPrivacy_wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is incorrect. Please try again.'**
  String get accountPrivacy_wrongPassword;

  /// No description provided for @accountPrivacy_networkError.
  ///
  /// In en, this message translates to:
  /// **'The account could not be deleted because of a network error. Please try again.'**
  String get accountPrivacy_networkError;

  /// No description provided for @accountPrivacy_tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get accountPrivacy_tooManyRequests;

  /// No description provided for @accountPrivacy_deleteError.
  ///
  /// In en, this message translates to:
  /// **'The account could not be deleted. Please try again.'**
  String get accountPrivacy_deleteError;

  /// No description provided for @accountPrivacy_linkOpenError.
  ///
  /// In en, this message translates to:
  /// **'The link could not be opened.'**
  String get accountPrivacy_linkOpenError;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_personalizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance & language'**
  String get settings_personalizationTitle;

  /// No description provided for @settings_personalizationDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how QR Coder looks and which language it uses.'**
  String get settings_personalizationDescription;

  /// No description provided for @settings_languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_languageTitle;

  /// No description provided for @settings_languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get settings_languageTurkish;

  /// No description provided for @settings_languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_languageEnglish;

  /// No description provided for @settings_themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_themeTitle;

  /// No description provided for @settings_themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_themeSystem;

  /// No description provided for @settings_themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_themeLight;

  /// No description provided for @settings_themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_themeDark;

  /// No description provided for @settings_accountPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Account & Privacy'**
  String get settings_accountPrivacy;

  /// No description provided for @settings_accountPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Review your account, privacy policy, and account deletion options.'**
  String get settings_accountPrivacyDescription;

  /// No description provided for @settings_privacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy options'**
  String get settings_privacyOptions;

  /// No description provided for @settings_privacyOptionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Review or change the advertising consent choices available for this device.'**
  String get settings_privacyOptionsDescription;

  /// No description provided for @accessibility_clearInput.
  ///
  /// In en, this message translates to:
  /// **'Clear field'**
  String get accessibility_clearInput;

  /// No description provided for @accessibility_clearForm.
  ///
  /// In en, this message translates to:
  /// **'Clear form'**
  String get accessibility_clearForm;

  /// No description provided for @accessibility_showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get accessibility_showPassword;

  /// No description provided for @accessibility_hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get accessibility_hidePassword;

  /// No description provided for @accessibility_retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get accessibility_retry;

  /// No description provided for @navigation_accountMenuSemantic.
  ///
  /// In en, this message translates to:
  /// **'Account and navigation menu. Current session: {sessionLabel}'**
  String navigation_accountMenuSemantic(String sessionLabel);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
