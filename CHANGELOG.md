## 3.0.1
- Added `Account Mode` related instructions for Android in the README & fixed Dart analysis.

## 3.0.0
- Added support of `single` and `multiple` account mode.
- Added new classes & methods based on account mode:
  - SingleAccountPca (Single Account Mode):
    - currentAccount
    - signOut()
  - MultipleAccountPca (Multiple Account Mode):
    - getAccount()
    - getAccounts()
    - removeAccount()
- Added `redirectUri` in `AndroidConfig` class as a required parameter.
- Added `identifier` option in `acquireTokenSilent()` that is required for multiple account mode.
- Defined all the possible exceptions in Dart side that can be thrown by native MSAL SDK.
- `Example` app is completely re-written to showcase all the features.
  
- **BREAKING CHANGES:**
  - `MsalAuth.createPublicClientApplication` is removed and added 3 classes:
    - `PublicClientApplication` super class.
    - `SingleAccountPca` for single account mode.
      - `SingleAccountPca.create()` is used to create single account public client application.
    - `MultipleAccountPca` for multiple account mode.
      - `MultipleAccountPca.create()` is used to create multiple account public client application.
  - `tenantId` from `AndroidConfig` is removed because it can be set through JSON configuration file.
  - `AuthMiddleware` enum in `IosConfig` is renamed to `Broker`.
  - `TenantType` enum in `IosConfig` is renamed to `AuthorityType` with it's values:
    - `entraIDAndMicrosoftAccount` to `aad`.
    - `azureADB2C` to `b2c`.
  - `scopes` argument is moved to `acquireToken()` & `acquireTokenSilent()` methods. these methods are now part of `PublicClientApplication` class.
  - `logout()` is removed so `signOut()` or `removeAccount()` is used based on your account mode.
  - `MsalUser` class is replaced by `AuthenticationResult` with additional parameters.
  - `MsalUserCanceledException` is renamed to `MsalUserCancelException`.

## 2.2.1
- Added keychain group `com.microsoft.adalcache` in `example/ios` and updated instruction in README.

## 2.2.0

- Moved `loginHint` param to `acquireToken` function.
- Added support of `Prompt` option in `acquireToken` function.

## 2.1.1

- Updated README for login process stuck on iOS due to missing callback handling. issue#26, issue#33

## 2.1.0

- Fixed issue of `activity is null` when `FlutterFragmentActivity` is used in `MainActivity.kt`

## 2.0.2

- Added `idToken` param in `MsalUser` class.

## 2.0.1

- Added support of `loginHint`.

## 2.0.0

- Added support for authenticating against Azure AD B2C tenants on iOS.

## 1.0.8

- Fixed crash in Android when `MsalUiRequiredException` occurs.
- Added info about `authority` used in iOS.
- Updated `example` code.

## 1.0.7

- Fixed `Dart Analysis` in model classes.

## 1.0.6

- Added documentation for `How to setup app in Azure portal`.

## 1.0.5

- Added documentation for broker authentication.

## 1.0.4

- Added documentation.

## 1.0.3

- Fixed `Dart Analysis`

## 1.0.2

- Added `Dart Analysis`

## 1.0.1

- Set `tokenExpiresOn` value as a milliseconds since epoch.

## 1.0.0

- Initial release.
