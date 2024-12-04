/// Configuration class for iOS & MacOS platform.
final class AppleConfig {
  /// Required when using B2C authority.
  /// For more information, follow:
  /// https://learn.microsoft.com/en-us/entra/msal/objc/configure-authority#b2c
  final String? authority;

  /// Type of authority to authenticate against.
  final AuthorityType authorityType;

  /// Authentication middleware that is used to perform authentication.
  /// Only used for iOS platform.
  final Broker broker;

  AppleConfig({
    this.authority,
    this.authorityType = AuthorityType.aad,
    this.broker = Broker.msAuthenticator,
  });
}

/// Type of authority to authenticate against.
enum AuthorityType {
  /// Microsoft Entra ID (formerly Azure Active Directory).
  aad,

  /// Business-to-Consumer.
  b2c
}

/// Types of broker that is used while authenticating user.
enum Broker {
  /// MS Authenticator app will be used if installed on a device, otherwise
  /// Safari browser will be used.
  msAuthenticator,

  /// Safari browser will be used.
  safariBrowser,

  /// WebView will be used.
  webView
}
