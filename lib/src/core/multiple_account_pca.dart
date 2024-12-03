import '../../msal_auth.dart';
import '../models/config/web_config.dart';
import 'mobile/pca_factory.dart'
    if (dart.library.js_interop) 'web/pca_factory.dart' as pca_factory;
import 'platform_multiple_account_pca.dart';

/// This class is used to create public client application for multiple account
/// mode.
final class MultipleAccountPca implements PlatformMultipleAccountPca {
  MultipleAccountPca._create(this._delegate);

  final PlatformMultipleAccountPca _delegate;

  /// Creates multiple account public client application.
  static Future<MultipleAccountPca> create({
    /// Client id of the application.
    required String clientId,

    /// Android configuration, required for android platform.
    AndroidConfig? androidConfig,

    /// iOS configuration, required for iOS platform.
    IosConfig? iosConfig,

    /// Web configuration, required for web platform.
    WebConfig? webConfig,
  }) async {
    final PlatformMultipleAccountPca delegate;
    delegate = await pca_factory.createMultipleAccountPca(
      clientId: clientId,
      androidConfig: androidConfig,
      iosConfig: iosConfig,
      webConfig: webConfig,
    );
    return MultipleAccountPca._create(delegate);
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
  }) =>
      _delegate.acquireToken(
        scopes: scopes,
        prompt: prompt,
        loginHint: loginHint,
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

  @override
  Future<Account> getAccount({required String identifier}) =>
      _delegate.getAccount(identifier: identifier);

  @override
  Future<List<Account>> getAccounts() => _delegate.getAccounts();

  @override
  Future<bool> removeAccount({required String identifier}) =>
      _delegate.removeAccount(identifier: identifier);
}
