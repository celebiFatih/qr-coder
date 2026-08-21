## QR CODER

**QR Coder is a simple and easy-to-use QR code generator app for *Android***

### Features

---

- Generate QR codes
- Save QR codes to the device gallery or database
- Share, Scan, Delete, Edit and View QR codes
- Multi scan
- Guest & User authentication
- English and Turkish user interface

### Screenshots

---

<p align="center">
  <img src="https://github.com/celebiFatih/qr-coder/blob/main/screenshots/1.png?raw=true" width="200" />
  <img src="https://github.com/celebiFatih/qr-coder/blob/main/screenshots/8.png?raw=true" width="200" />
  <img src="https://github.com/celebiFatih/qr-coder/blob/main/screenshots/2.png?raw=true" width="200" />
  <img src="https://github.com/celebiFatih/qr-coder/blob/main/screenshots/3.png?raw=true" width="200" />
</p>

<p align="center">
  <img src="https://github.com/celebiFatih/qr-coder/blob/main/screenshots/4.png?raw=true" width="200" />
  <img src="https://github.com/celebiFatih/qr-coder/blob/main/screenshots/5.png?raw=true" width="200" />
  <img src="https://github.com/celebiFatih/qr-coder/blob/main/screenshots/6.png?raw=true" width="200" />
  <img src="https://github.com/celebiFatih/qr-coder/blob/main/screenshots/7.png?raw=true" width="200" />
</p>


### Download

---

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
     alt="Get it on Google Play"
     height="80">](https://play.google.com/store/apps/details?id=com.qrcoder.app)

### Packages

---

#### Main Packages
- [qr_flutter](https://pub.dev/packages/qr_flutter)
- [provider](https://pub.dev/packages/provider)
- [sqflite](https://pub.dev/packages/sqflite)
- [share_plus](https://pub.dev/packages/share_plus)
- [mobile_scanner](https://pub.dev/packages/mobile_scanner)
- [permission_handler](https://pub.dev/packages/permission_handler)

#### Firebase integration
- [firebase_core](https://pub.dev/packages/firebase_core)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [firebase_database](https://pub.dev/packages/firebase_database)

#### Extra Packages
- [google_mobile_ads](https://pub.dev/packages/google_mobile_ads)
- [intl](https://pub.dev/packages/intl)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

#### Other Packages
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

### License

```
Copyright 2024 QR Coder

This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License. 
You can view the full license [here](./LICENSE).
```

### Local configuration & source hygiene

QR Coder keeps machine-local configuration and signing material out of source
control. Before building locally:

1. Copy `.env.example` to `.env` and fill the production AdMob banner/rewarded
   unit IDs.
2. Place the Android Firebase configuration at
   `android/app/google-services.json`.
3. For a signed Android release, keep `android/key.properties` and the upload
   keystore only on the release machine.

Do not distribute `.env`, `android/key.properties`, `android/local.properties`,
keystores, or platform Firebase configuration as part of a source archive.

On Windows, create a sanitized source archive with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tool\package_source.ps1
```

`pubspec.lock` and the Gradle wrapper are intentionally kept in source control
for reproducible application builds.

### Privacy & account deletion

- Privacy Policy: https://celebifatih.github.io/qr-coder-privacy/
- Account deletion: https://celebifatih.github.io/qr-coder-privacy/account-deletion.html

Registered users can also delete their account from **Account & Privacy**
inside the app.

