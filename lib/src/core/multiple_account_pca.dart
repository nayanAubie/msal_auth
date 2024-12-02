import 'package:flutter/foundation.dart';

import '../../msal_auth.dart';
import 'mobile/mobile_multiple_account_pca.dart';
import 'platform_multiple_account_pca.dart';
import 'web/web_multiple_platform_pca.dart';

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
  }) async {
    final pca = kIsWeb
        ? await WebMultipleAccountPca.create()
        : await MobileMultipleAccountPca.create(
            clientId: clientId,
            androidConfig: androidConfig,
            iosConfig: iosConfig,
          );
    return MultipleAccountPca._create(pca);
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
