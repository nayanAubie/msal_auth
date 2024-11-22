# MSAL Auth

Microsoft Authentication 🔐 Library for Flutter.

`msal_auth` plugin provides Microsoft authentication in Android and iOS devices using native MSAL library. This is very straightforward and easy to use.

## Platform Support

| Android | iOS     |
|---------|---------|
| SDK 21+ | iOS 14+ |

## Features 🚀

- Option to set one of the following broker (Authentication middleware):
  - MS Authenticator App
  - Browser
  - In-App WebView
- **Single** & **Multiple** account mode support
- Supports different identity providers (authority):
  - **AAD** (Microsoft Entra ID)
  - **B2C** (Business to customer)
- Acquire token **interactively** & **silently**
- Option to set **login hint** & **prompt type** in acquiring token
- Complete authentication result with account information
---

To implement `MSAL` in Flutter, you first need to set up an app in the `Azure Portal` and configure certain platform-specific settings.

➡ Follow the step-by-step guide below ⬇️

## Create an App in Azure Portal

- First, sign up and create an app on the [Azure Portal].
- To create the app, search for `App registrations`, click on it, and navigate to `New registration`.
- Fill in the `Name` field, select the `Supported account types`, and register the app.
- Once the application is created, you will see the `Application (client) ID` and `Directory (tenant) ID`. These values are required in your Dart code.

  ![Azure Dashboard](/Screenshots/Azure-Dashboard.png)

- Next, you need to add platform-specific configurations for **Android** and **iOS** in the Azure Portal. To do this, navigate to `Manage > Authentication > Add platform`.

---

### Android Setup - Azure portal

- For Android, You need to provide `package name` and release `signature hash`.
  - To generate a signature hash in Flutter, use the below command:
  
    ```Bash
    keytool -exportcert -alias androidreleasekey -keystore app/upload-keystore.jks | openssl sha1 -binary | openssl base64
    ```

  - Make sure you have release `keystore` file placed inside `/app` folder.
  - Only one signature hash is required because it maps with `AndroidManifest.xml`.

---
  
### iOS Setup - Azure portal

- For iOS, You need to provide only `Bundle ID`. `Redirect URI` will be generated automatically by system.

  ![iOS Redirect URI](/Screenshots/iOS-Redirect-URI.png)

That's it for the Azure portal configuration.

---

Please follow the platform configuration ⬇️ before jump to the `Dart` code.

## Android Configuration

This plugin offers full customization, allowing you to provide a configuration `JSON` file to be used during application creation & authentication.

Follow the steps below to complete the Android configuration.

### Creating MSAL Configuration JSON

- Create an `msal_config.json` file in the `/assets` folder of your project and copy the **JSON** content from the [Microsoft default configuration file].
- Obtain the `redirect_uri` from the **Azure Portal**. This URI is required in the Android configuration when creating the public client application using Dart code.
- The redirect URI typically follows this format for Android:

  ```
  msauth://<APP_PACKAGE_NAME>/<BASE64_ENCODED_PACKAGE_SIGNATURE>
  ```

- Android redirect URI from Azure Portal:

  ![Android Redirect URI](/Screenshots/Azure-Android-Redirect-URI.png)

> There is no need to include `client_id` and `redirect_uri` in this JSON, as they will be added programmatically by the Dart code when the public client application is created.

---

### Setup Account Mode

To support single account mode in Android, declare the following in a configuration file:

```JSON
"account_mode": "SINGLE"
```

For multiple mode:

```JSON
"account_mode": "MULTIPLE"
```

---

### Setup Authority

Follow the [Android MSAL Authority] documentation to configure it in various ways, depending on your application's requirements.

---

### Setup Broker (Authentication Middleware) (Optional)

- **Set broker authentication** (authenticate user by [Microsoft Authenticator App])

  ```JSON
  "broker_redirect_uri_registered": true
  ```

  - If the Authenticator app is not installed on the Android device, the `authorization_user_agent` configuration will be used for authentication.

- **Authenticate using Browser**

  ```JSON
  "broker_redirect_uri_registered": false,
  "authorization_user_agent": "BROWSER"
  ```

- **Authenticate using WebView**

  ```JSON
  "broker_redirect_uri_registered": false,
  "authorization_user_agent": "WEBVIEW"
  ```

---

### Add BrowserTabActivity in AndroidManifest.xml

- If you use `Browser` for authentication, you must specify `BrowserTabActivity` within the `<application>` tag in your **AndroidManifest.xml** file.

  ```XML
  <application>
  ...

    <activity android:name="com.microsoft.identity.client.BrowserTabActivity">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />

            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />

            <data
                android:host="com.example.msal_auth_example"
                android:path="/<BASE64_ENCODED_PACKAGE_SIGNATURE>"
                android:scheme="msauth" />
        </intent-filter>
    </activity>
    
  </application>
  ```
- Replace `host` with your app's package name and `path` with the `base64 signature hash` that was generated earlier.

> To learn more about configuring JSON, follow [Android MSAL configuration].

## iOS Configuration

- Add a new keychain group `com.microsoft.adalcache` to your project capabilities.

  ![iOS Keychain Sharing](/Screenshots/iOS-Keychain-Sharing.png)

> Without this configuration, your app will not be able to open the [Microsoft Authenticator] app if specified in the broker. Additionally, the `logout` method will throw an exception because it will not be able to find the account in the cache.

---

### `Info.plist` Modification

- Add your application's redirect URI scheme to your `Info.plist` file:

  ```plist
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>msauth.$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
  </array>
  ```

- Add `LSApplicationQueriesSchemes` to allow making call to [Microsoft Authenticator] app if installed.

  ```plist
  <key>LSApplicationQueriesSchemes</key>
  <array>
	  <string>msauthv2</string>
	  <string>msauthv3</string>
  </array>
  ```

---

### Handle `callback` from MSAL

- Your app needs to handle login success callback if app uses [Microsoft Authenticator] app OR `Safari Browser` for authentication. `WebView` does not require it.
- Your app needs to handle the **login success callback** if it uses the [Microsoft Authenticator] app or `Safari Browser` for authentication. `WebView` does not require this callback.

#### AppDelegate.swift

```swift
import MSAL

override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
}
```

- Refer to the [`AppDelegate.swift`] file in the example app for more clarity.

- If you adopted `UISceneDelegate` on iOS 13+, MSAL callback needs to be placed into the appropriate delegate method of `UISceneDelegate` instead of `AppDelegate`.

#### SceneDelegate.swift

```swift
import MSAL

func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
  guard let urlContext = URLContexts.first else {
    return
  }
        
  let url = urlContext.url
  let sourceApp = urlContext.options.sourceApplication
        
  MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApp)
}
```

> See more info on [iOS MSAL configuration].

## Code Implementation 👨‍💻

This section covers how to write the `Dart` code to set up an `MSAL` application in `Flutter` and authenticate the user.

### Create Public Client Application

Create the public client app based on your account mode. usually, it is a single account mode.

```Dart
final msalAuth = await SingleAccountPca.create(
  clientId: '<MICROSOFT_CLIENT_ID>',
  androidConfig: AndroidConfig(
    configFilePath: 'assets/msal_config.json',
    redirectUri: '<Android Redirect URI>',
  ),
  iosConfig: IosConfig(
    authority: '<Optional, but must be provided for b2c>',
    // Change broker if you need.
    broker: Broker.msAuthenticator,
    // Change authority type to 'b2c' for business to customer flow.
    authorityType: AuthorityType.aad,
  ),
);
```
  
- On `iOS`, if the broker is set to `AuthMiddleware.msAuthenticator` and the `Authenticator` app is not installed on the device, it will fall back to using `Safari Browser` for authentication.

- By default, login will be attempted to AAD (Microsoft Entra ID). if you want to use B2C, set the `authorityType` to `AuthorityType.b2c`.

- To modify value of `authority` in `iOS`, follow [Configure iOS authority].

---

### Acquire Token (Login to Microsoft Account)

This method opens the **Microsoft login page** in the specified broker and provides the **authentication result** upon a successful login. The result includes the `accessToken`.

```Dart
final authResult = await publicClientApplication.acquireToken(
  scopes: <String>[
    'https://graph.microsoft.com/user.read',
    // Add other scopes here if required.
  ],
  // UI option for authentication, default is [Prompt.whenRequired]
  prompt: Prompt.login,
  // Provide 'loginHint' if you have.
  loginHint: '<Email Id / Username / Unique Identifier>'
);

log('Auth result: ${authResult.toJson()}');
```

---

### Acquire Token by Silent Call 🔇

Typically, this method should be called when the `accessToken` expires. It uses the refresh token from the cached account, performs authentication in the background, and returns the authentication result, similar to the `acquireToken()` method.

The app can store the `expiresOn` value of the `AuthenticationResult` in the preferences and check the following condition before using the `accessToken`:

```Dart
if (expiresOn.isBefore(DateTime.now())) {
  final authResult = await publicClientApplication.acquireTokenSilent(
    scopes: <String>[], // List of string same as "acquireToken()"
    identifier: 'Account Identifier, required for multiple account mode',
  );

  log('Auth result: ${authResult.toJson()}');
  // Store new value of "expiresOn" or entire "authResult" object.
}
```

> This method can throw an `MsalUiRequiredException` if the refresh token has expired or does not exist. In this case, the `acquireToken()` method should typically be called to prompt the user for interactive authentication and obtain a new access token.

```Dart
try {
  acquireTokenSilent();
} on MsalException catch (e) {
  if (e is MsalUiRequiredException) {
    await acquireToken();
    // Handle auth result
  }
}
```

All other types of exceptions are optional to handle, depending on your use case.

---

### Exception Handling 🚨

All MSAL exceptions thrown by the Android and iOS platforms can be handled on the Dart side. You can manage them according to your use case, such as by logging the errors, displaying user-friendly messages, retrying the operation, or triggering specific app behaviors based on the type of exception.

You can learn more about [MSAL exceptions - Android] and [MSAL exceptions - iOS].

---

### Setup Example App 📱

The [`example`] app demonstrates all the features supported by this plugin with providing a practical implementation.

It uses environment variables for the values such as client id, redirect URI, etc to make it easier to configure the app for different environments.

To set it up, create a `.env/development.env` file in the root of your project and add your values like this:

```ini
AAD_CLIENT_ID=your-apps-client-id
AAD_ANDROID_REDIRECT_URI=your-android-apps-redirect-uri
AAD_IOS_AUTHORITY=https://login.microsoftonline.com/common
```

Use B2C authority URL in `AAD_IOS_AUTHORITY` if your app uses `b2c` flow.

Follow [`example`] code for more details on implementation.


[Azure Portal]: https://portal.azure.com/
[Microsoft default configuration file]: https://learn.microsoft.com/en-in/entra/identity-platform/msal-configuration#the-default-msal-configuration-file
[Microsoft Authenticator App]: https://play.google.com/store/apps/details?id=com.azure.authenticator
[Android MSAL configuration]: https://learn.microsoft.com/en-in/entra/identity-platform/msal-configuration
[Android MSAL Authority]: https://learn.microsoft.com/en-us/entra/identity-platform/msal-configuration#authorities
[iOS MSAL configuration]: https://learn.microsoft.com/en-us/entra/msal/objc/install-and-configure-msal#configuring-your-project-to-use-msal
[Microsoft Authenticator]: https://apps.apple.com/us/app/microsoft-authenticator/id983156458
[Configure iOS authority]: https://learn.microsoft.com/en-us/entra/msal/objc/configure-authority#change-the-default-authority
[MSAL exceptions - Android]: https://learn.microsoft.com/en-us/entra/identity-platform/msal-android-handling-exceptions
[MSAL exceptions - iOS]: https://learn.microsoft.com/en-us/entra/msal/objc/error-handling-ios
[`example`]: example
[`AppDelegate.swift`]: example/ios/Runner/AppDelegate.swift