import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../msal_auth.dart';

class PublicClientApplication {
  PublicClientApplication();

  Future<dynamic> acquireToken({
    required List<String> scopes,
    Prompt prompt = Prompt.whenRequired,

    /// It should be valid "email id" or "username" or "unique identifier".
    /// Value is used as an identity provider to pre-fill a user's
    /// email address or username in the login form.
    String? loginHint,
  }) async {
    assert(scopes.isNotEmpty, 'Scopes can not be empty');
    final arguments = <String, dynamic>{
      'scopes': scopes,
      'prompt': prompt.name,
      'loginHint': loginHint,
      'broker': Broker.msAuthenticator.name,
    };
    try {
      print('acquire token called=======');
      final result =
          await kMethodChannel.invokeMethod('acquireToken', arguments);
      log('Result======> ${json.encode(result)}');
      // return AuthenticationResult();
    } on PlatformException catch (e) {
      log('Exception=====> $e');
      throw e.msalException;
    }
  }

  Future<dynamic> acquireTokenSilent({
    required List<String> scopes,
    String? identifier,
  }) async {
    assert(scopes.isNotEmpty, 'Scopes can not be empty');
    final arguments = <String, dynamic>{
      'scopes': scopes,
      'identifier': identifier,
    };
    final result =
        await kMethodChannel.invokeMethod('acquireTokenSilent', arguments);
    log('Result======> ${json.encode(result)}');
    // return result;
  }
}
