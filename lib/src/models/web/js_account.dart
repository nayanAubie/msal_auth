@JS()

import 'dart:js_interop';

import '../../../msal_auth.dart';

extension type JSAccount._(JSObject _) implements JSObject {
  external JSString homeAccountId;
  external JSString username;
  external JSString name;

  Account get toDart => Account(
        id: homeAccountId.toDart,
        username: username.toDart,
        name: name.toDart,
      );
}
