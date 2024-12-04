// This code is adapted from https://github.com/earlybyte/aad_oauth
// Copyright (c) 2020 Earlybyte GmbH
// Licensed under the MIT License
@JS('msalAuth')
library;

import 'dart:js_interop';

import '../../models/models.dart';
import '../../models/web/js_account.dart';
import '../../models/web/js_authentication_result.dart';
import 'msalconfig.dart';

@JS('init')
external JSPromise jsInit(JSMsalConfig config);

@JS('acquireToken')
external JSPromise<JSAuthenticationResult?> jsAcquireToken(
  JSArray<JSString> scopes,
  JSString prompt,
  JSString? loginHint,
  JSBoolean useRedirect,
);

@JS('acquireTokenSilent')
external JSPromise<JSAuthenticationResult?> jsAcquireTokenSilent(
  JSArray<JSString> scopes,
  JSString? identifier,
);

@JS('getAccount')
external JSAccount jsGetAccount(JSString? identifier);

@JS('getAccounts')
external JSArray<JSAccount> jsGetAccounts();

@JS('logout')
external JSPromise jsLogout(
  JSString? identifier,
  // ignore: avoid_positional_boolean_parameters
  JSBoolean showPopup,
);

class WebOAuth {
  WebOAuth(this.config);

  final WebConfig config;

  Future<void> init() async {
    await jsInit(
      JSMsalConfig.fromWebConfig(config),
    ).toDart;
  }

  Future<AuthenticationResult> acquireToken({
    required List<String> scopes,
    Prompt prompt = Prompt.whenRequired,
    String? loginHint,
    bool webUseRedirect = false,
  }) async {
    final jsAuthenticationResult = await jsAcquireToken(
      scopes.map((scope) => scope.toJS).toList().toJS,
      prompt.name.toJS,
      loginHint?.toJS,
      false.toJS,
    ).toDart;

    if (jsAuthenticationResult == null) {
      throw MsalException(message: 'No authentication result');
    }
    return jsAuthenticationResult.toDart;
  }

  Future<AuthenticationResult> acquireTokenSilent({
    required List<String> scopes,
    String? identifier,
  }) async {
    final jsAuthenticationResult = await jsAcquireTokenSilent(
      scopes.map((scope) => scope.toJS).toList().toJS,
      identifier?.toJS,
    ).toDart;

    if (jsAuthenticationResult == null) {
      throw MsalException(message: 'No authentication result');
    }
    return jsAuthenticationResult.toDart;
  }

  Future<Account> getAccount([String? identifier]) async {
    return jsGetAccount(identifier?.toJS).toDart;
  }

  Future<List<Account>> getAccounts() async {
    return jsGetAccounts().toDart.map((jsAccount) => jsAccount.toDart).toList();
  }

  Future<void> logout([String? identifier]) async {
    await jsLogout(identifier?.toJS, false.toJS).toDart;
  }
}
