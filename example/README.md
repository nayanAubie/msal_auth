# MSAL Example App

A comprehensive Flutter example app demonstrating Microsoft Authentication Library (MSAL) integration with all supported features.

Before running the app, ensure you follow the steps below to configure the example app.

## Environment Configuration

The example app uses environment variables for values such as client ID, redirect URI, etc., to make it easier to configure the app for different environments.

### Create Environment File

Create a .env/development.env file in the [example] folder with your Azure app credentials:

```ini
AAD_CLIENT_ID=your-apps-client-id
AAD_APPLE_AUTHORITY=https://login.microsoftonline.com/common
```

Use B2C authority URL in `AAD_APPLE_AUTHORITY` if your app uses `b2c` flow.

## Platform-Specific Setup

### Android Configuration

#### 1. Update MSAL Configuration

The example uses [msal_config.json] for Android configuration. Update the fields according to your requirements.

To learn more about configuring JSON, follow [Android MSAL configuration].

#### 2. Generate Keystore

This is required for **release** builds only. Skip this step if you don't want to run/build in release mode.

Follow the Flutter's documentation on [Build and release an Android app].

For this example app, you only need to place the upload-keystore.jks in the [android/app] folder and set the path in `storeFile` within `key.properties`:

```properties
storeFile=./upload-keystore.jks
```

#### 2. Generate Signature Hash

This is required to set up the Android redirect URL. Debug and release modes will have different signature hashes.

Generate the debug signature hash only if you plan to test the app in debug mode only.

From example's [`android`] folder, run the below command:
- Debug

  ```Bash
  keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
  ```

- Release (ensure you have generated the keystore)

  ```Bash
  keytool -exportcert -alias upload -keystore app/upload-keystore.jks | openssl sha1 -binary | openssl base64
  ```

Register the signature hash above in the Android platform configurations in [Azure Portal] and obtain the Redirect URI. Add that value in relevant keys in `.env/development.env`:

```ini
AAD_DEBUG_ANDROID_REDIRECT_URI=debug-redirect-uri
# Required only if you want to run the app in release mode
AAD_RELEASE_ANDROID_REDIRECT_URI=release-redirect-uri
```

If release mode is not required, remove the conditional logic and use debug redirect URI directly in [msal_auth_service.dart]:

```Dart
AndroidConfig(
  redirectUri: Environment.aadDebugAndroidRedirectUri,
)
```

#### 3. Create `secret.properties`

This is required only if you want to use `Browser` or the `Authenticator` app for authorization. This step passes the signature hash value to the [`AndroidManifest.xml`] with the help of [`app/build.gradle.kts`].

Create `android/secret.properties` file for storing signature hash values:

```ini
MSAL_DEBUG_SIGNATURE_HASH=debug-signature-hash
# Required only if you want to run the app in release mode
MSAL_RELEASE_SIGNATURE_HASH=release-signature-hash
```

If you only want to use `WebView` for authentication, the following changes are required:

- Following changes in [`msal_config.json`]:

  ```json
  "authorization_user_agent": "WEBVIEW",
  "broker_redirect_uri_registered": false
  ```

- Remove the below signature hash declaration from [`app/build.gradle.kts`]:

  ```Kotlin
  val secretProperties = Properties()
  val secretPropertiesFile = rootProject.file("secret.properties")
  if (secretPropertiesFile.exists()) {
      secretProperties.load(FileInputStream(secretPropertiesFile))
  }

  val msalDebugSignatureHash = secretProperties["MSAL_DEBUG_SIGNATURE_HASH"]
  val msalReleaseSignatureHash = secretProperties["MSAL_RELEASE_SIGNATURE_HASH"]

  debug {
    manifestPlaceholders["msalSignatureHash"] = msalDebugSignatureHash as String
  }

  release {
    manifestPlaceholders["msalSignatureHash"] = msalReleaseSignatureHash as String
  }
  ```

- Remove the below block from [`AndroidManifest.xml`]:

  ```xml
  <activity android:name="com.microsoft.identity.client.BrowserTabActivity">
  ...
  </activity>
  ```

## Running the Example

Run configurations are created for IDEs to execute the build workflow. From the terminal, you can use the commands below from the [`example`] directory:

### Commands

#### Run the app in debug mode

```sh
flutter run --dart-define-from-file=.env/development.env
```

#### Run the app in release mode

```sh
flutter run --release --dart-define-from-file=.env/development.env
```

#### Build APK

```sh
flutter build apk --dart-define-from-file=.env/development.env
```


[Azure Portal]: https://portal.azure.com/
[`example`]: ./
[`msal_config.json`]: assets/msal_config.json
[Android MSAL configuration]: https://learn.microsoft.com/en-in/entra/identity-platform/msal-configuration
[`android`]: android
[`android/app`]: android/app
[`msal_auth_service.dart`]: lib/core/msal_auth_service.dart
[Build and release an Android app]: https://docs.flutter.dev/deployment/android
[`AndroidManifest.xml`]: android/app/src/main/AndroidManifest.xml
[`app/build.gradle.kts`]: android/app/build.gradle.kts
