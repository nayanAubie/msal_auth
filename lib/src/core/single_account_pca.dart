import '../../msal_auth.dart';
import 'mobile/pca_factory.dart'
    if (dart.library.js_interop) 'web/pca_factory.dart' as pca_factory;
import 'platform_single_account_pca.dart';

/// This class is used to create public client application for single account
/// mode.
final class SingleAccountPca implements PlatformSingleAccountPca {
  SingleAccountPca._create(this._delegate);

  final PlatformSingleAccountPca _delegate;

  /// Creates single account public client application.
  static Future<SingleAccountPca> create({
    /// Client id of the application.
    required String clientId,

    /// Android configuration, required for android platform.
    AndroidConfig? androidConfig,

    /// iOS configuration, required for iOS platform.
    IosConfig? iosConfig,

    /// Web configuration, required for web platform.
    WebConfig? webConfig,
  }) async {
    final PlatformSingleAccountPca delegate;
    delegate = await pca_factory.createSingleAccountPca(
      clientId: clientId,
      androidConfig: androidConfig,
      iosConfig: iosConfig,
      webConfig: webConfig,
    );
    return SingleAccountPca._create(delegate);
  }

  @override
  Future<AuthenticationResult> acquireToken({
    /// Access levels your application is requesting from the
    /// Microsoft identity platform on behalf of a user.
    required List<String> scopes,

    /// Initial UI option.
    Prompt prompt = Prompt.whenRequired,

    /// It should be valid "email id" or "username" or "unique identifier".
    /// Value is used as an identity provider to pre-fill a user's
    /// email address or username in the login form.
    String? loginHint,

    /// Use redirect flow instead of popup. Only used on web.
    bool webUseRedirect = false,
  }) =>
      _delegate.acquireToken(
        scopes: scopes,
        prompt: prompt,
        loginHint: loginHint,
        webUseRedirect: webUseRedirect,
      );

  @override
  Future<AuthenticationResult> acquireTokenSilent({
    /// Access levels your application is requesting from the
    /// Microsoft identity platform on behalf of a user.
    required List<String> scopes,

    /// Account identifier, basically id from account object.
    /// Required for multiple account mode.
    String? identifier,
  }) =>
      _delegate.acquireTokenSilent(scopes: scopes, identifier: identifier);

  /// Gets the current account from the cache. if no account is available, it
  /// will throw an exception.
  @override
  Future<Account> get currentAccount => _delegate.currentAccount;

  /// Signs out the current account and credentials (tokens).
  /// NOTE: If a device is marked as a shared device within broker,
  /// sign out will be device wide.
  @override
  Future<bool> signOut() => _delegate.signOut();
}
