import 'account_mode.dart';

/// Configuration class for iOS platform.
class IosConfig {
  /// Microsoft authority.
  final String? authority;

  /// Middleware that is used to perform authentication.
  final Broker broker;

  /// The type of tenant to authenticate against.
  final AuthorityType authorityType;

  IosConfig({
    required this.authority,
    this.broker = Broker.msAuthenticator,
    this.authorityType = AuthorityType.aad,
  });
}

/// Types of broker that is used while authenticating user.
enum Broker {
  /// MS Authenticator app will be used if installed on a device.
  msAuthenticator,

  /// Safari browser will be used.
  safariBrowser,

  /// WebView will be used.
  webView
}

/// Types of tenant to authenticate against.
enum AuthorityType {
  /// Entra ID (formerly Azure Active Directory) and Microsoft Account.
  aad,

  /// Azure Active Directory B2C.
  b2c
}
