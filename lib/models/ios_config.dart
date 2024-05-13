/// Configuration class for iOS platform.
class IosConfig {
  /// Microsoft authority.
  final String authority;

  /// Middleware that is used to perform authentication.
  final AuthMiddleware authMiddleware;

  IosConfig({
    required this.authority,
    this.authMiddleware = AuthMiddleware.msAuthenticator,
  });
}

/// Types of middleware that is used while authenticating user.
enum AuthMiddleware {
  /// MS Authenticator app will be used if installed on a device.
  msAuthenticator,

  /// Safari browser will be used.
  safariBrowser,

  /// WebView will be used.
  webView
}
