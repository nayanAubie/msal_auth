import '../../msal_auth.dart';

abstract class PublicClientApplication {
  /// Acquire token interactively, will pop-up webUI. this flow is called as
  /// Interactive flow and so it skips the cache lookup.
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

    /// Use redirect flow instead of popup on web.
    bool webUseRedirect = false,
  });

  /// Perform acquire token silent call. If there is a valid access token in
  /// the cache, the sdk will return the access token; If no valid access token
  /// exists, the sdk will try to find a refresh token and use the refresh token
  /// to get a new access token. If refresh token does not exist or it fails
  /// the refresh, exception will be sent.
  Future<AuthenticationResult> acquireTokenSilent({
    /// Access levels your application is requesting from the
    /// Microsoft identity platform on behalf of a user.
    required List<String> scopes,

    /// Account identifier, basically id from account object.
    /// Required for multiple account mode.
    String? identifier,
  });
}
