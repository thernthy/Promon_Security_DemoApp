# Demo Bank (Flutter)

A demo banking app. All data, including the login user, is static and lives in
`lib/data/demo_data.dart`. Nothing is sent to a server; balances and
transactions reset when you log out.

**Demo login:** username `demo` / password `demo123`
(or tap **Use demo account** on the login screen).

## Screens

- **Login**: form validation, simulated sign-in delay, error for wrong credentials
- **Home**: greeting, swipeable account cards (hide/show balance), quick actions, recent transactions, "See all" history
- **Transfer**: pick source account and recipient, enter an amount (quick chips, balance check), add a note, confirm in a bottom sheet, then see a success receipt. The balance and history update.
- **Profile**: user details, total balance, settings toggles, log out

## Run

Requires Flutter 3.27+.

```sh
# one time: generate android/ios/web/windows platform folders
flutter create . --project-name bank_demo_app

flutter pub get
flutter run
```

```sh
flutter test
```

## Build

Generate the platform folders first if you haven't (`flutter create . --project-name bank_demo_app`).
The app version comes from `version:` in `pubspec.yaml` (`1.0.0+1` = version name `1.0.0`, build number `1`).

### Android (APK)

Requires the Android SDK (install Android Studio) and JDK 17. Run `flutter doctor` to check.

```sh
# release APK for all CPU architectures (one large file)
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk

# or smaller APKs, one per architecture (arm64-v8a, armeabi-v7a, x86_64)
flutter build apk --release --split-per-abi
# output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk, ...

# App Bundle for Google Play
flutter build appbundle --release
# output: build/app/outputs/bundle/release/app-release.aab
```

Install the APK on a connected device:

```sh
flutter install
# or
adb install build/app/outputs/flutter-apk/app-release.apk
```

By default the release build is signed with the debug key. That is fine for
testing, but Google Play needs your own key:

1. Create a keystore (one time; keep it and its passwords safe):

   ```sh
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties` (do not commit it):

   ```properties
   storePassword=<store password>
   keyPassword=<key password>
   keyAlias=upload
   storeFile=<absolute path to upload-keystore.jks>
   ```

3. In `android/app/build.gradle.kts`, load `key.properties` and add a
   `release` signing config:

   ```kotlin
   import java.util.Properties
   import java.io.FileInputStream

   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }

   android {
       // ...
       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String
               keyPassword = keystoreProperties["keyPassword"] as String
               storeFile = keystoreProperties["storeFile"]?.let { file(it) }
               storePassword = keystoreProperties["storePassword"] as String
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
           }
       }
   }
   ```

   (Older projects use `android/app/build.gradle` in Groovy; the settings are the same.)

4. Rebuild with `flutter build apk --release` or `flutter build appbundle --release`.

### iOS (IPA)

You need a Mac with Xcode, CocoaPods (`sudo gem install cocoapods` or
`brew install cocoapods`), and an Apple Developer account to install on devices
or publish. iOS builds cannot be made on Windows or Linux.

1. Open `ios/Runner.xcworkspace` in Xcode. Under **Runner > Signing & Capabilities**,
   select your Team and set a unique Bundle Identifier (e.g. `com.yourname.bankdemo`).

2. Build:

   ```sh
   flutter pub get
   cd ios && pod install && cd ..

   # release build to run on a connected iPhone
   flutter build ios --release
   flutter install

   # IPA archive for App Store / TestFlight
   flutter build ipa --release
   # output: build/ios/archive/Runner.xcarchive
   #         build/ios/ipa/*.ipa
   ```

   For ad-hoc or enterprise distribution, pick the export method:
   `flutter build ipa --export-method ad-hoc` (or `enterprise`, `development`).

3. Upload to App Store Connect with the **Transporter** app or
   `xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey <key> --apiIssuer <issuer>`,
   or open the archive in Xcode (**Window > Organizer > Distribute App**).

To test without a device, use the simulator: `open -a Simulator` then `flutter run`.

## Structure

```
lib/
  main.dart                      app entry, AppScope + MaterialApp
  data/demo_data.dart            static user, accounts, transactions, contacts
  models/models.dart             BankUser, Account, BankTransaction, Contact
  state/app_state.dart           ChangeNotifier (login, logout, transfer)
  theme/app_theme.dart           colors, input + card styles
  utils/format.dart              currency / date formatting
  widgets/transaction_tile.dart
  screens/
    login_screen.dart
    main_shell.dart              bottom navigation
    home_screen.dart
    transactions_screen.dart
    transfer_screen.dart
    transfer_success_screen.dart
    profile_screen.dart
```
