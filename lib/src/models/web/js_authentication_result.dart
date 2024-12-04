@JS()

import 'dart:js_interop';

import 'package:intl/intl.dart';

import '../../../msal_auth.dart';
import 'js_account.dart';

extension type JSAuthenticationResult._(JSObject _) implements JSObject {
  external JSString accessToken;
  external JSObject expiresOn;
  external JSString idToken;
  external JSString authority;
  external JSString tenantId;
  external JSArray<JSString> scopes;
  external JSString correlationId;
  external JSAccount account;

  DateTime _parseJSDate(JSObject jsDate) {
    // Example: Wed Dec 04 2024 12:45:36 GMT+0100 (Central European Standard Time)
    final dateFormat = DateFormat("EEE MMM d yyyy HH:mm:ss 'GMT'Z", 'en_US');
    return dateFormat.parse(jsDate.toString());
  }

  AuthenticationResult get toDart => AuthenticationResult(
        accessToken: accessToken.toDart,
        authenticationScheme: '',
        expiresOn: _parseJSDate(expiresOn),
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
