/// Configuration class for iOS platform.
class IosConfig {
  /// Microsoft authority.
  final String authority;

  /// Middleware that is used to perform authentication.
  final AuthMiddleware authMiddleware;

  /// The type of tenant to authenticate against.
  final TenantType tenantType;

  IosConfig({
    required this.authority,
    this.authMiddleware = AuthMiddleware.msAuthenticator,
    this.tenantType = TenantType.entraIDAndMicrosoftAccount
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

/// Types of tenant to authenticate against.
enum TenantType {
  /// Entra ID (formerly Azure Active Directory) and Microsoft Account.
  entraIDAndMicrosoftAccount,

  /// Azure Active Directory B2C.
  azureADB2C
}
