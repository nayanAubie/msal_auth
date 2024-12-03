@JS()

import 'dart:js_interop';

import '../../../msal_auth.dart';
import 'js_account.dart';

extension type JSAuthenticationResult._(JSObject _) implements JSObject {
  external JSString accessToken;
  external JSString expiresOn;
  external JSString idToken;
  external JSString authority;
  external JSString tenantId;
  external JSArray<JSString> scopes;
  external JSString correlationId;
  external JSAccount account;

  AuthenticationResult get toDart => AuthenticationResult(
        accessToken: accessToken.toDart,
        authenticationScheme: '',
        expiresOn: DateTime.parse(expiresOn.toDart),
        idToken: idToken.toDart,
        authority: authority.toDart,
        tenantId: tenantId.toDart,
        scopes: scopes.toDart.map((scope) => scope.toDart).toList(),
        correlationId: correlationId.toDart,
        account: Account(
          id: account.homeAccountId.toDart,
          username: account.username.toDart,
          name: account.name.toDart,
        ),
      );
}
