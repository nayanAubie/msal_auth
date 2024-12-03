import 'package:flutter/foundation.dart';

import '../../msal_auth.dart';
import '../models/config/web_config.dart';
import 'mobile/mobile_single_account_pca.dart';
import 'platform_single_account_pca.dart';
import 'web/web_single_account_pca.dart';

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
    if (kIsWeb) {
      assert(webConfig != null, 'Web config is required for web platform');
      delegate = await WebSingleAccountPca.create(config: webConfig!);
    } else {
      delegate = await MobileSingleAccountPca.create(
        clientId: clientId,
        androidConfig: androidConfig,
        iosConfig: iosConfig,
      );
    }
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
