import '../../../msal_auth.dart';
import 'web_oauth.dart';

abstract class WebPublicClientApplication extends PublicClientApplication {
  WebOAuth get oauth;

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
      oauth.acquireToken(
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
      oauth.acquireTokenSilent(
        scopes: scopes,
        identifier: identifier,
      );
}
