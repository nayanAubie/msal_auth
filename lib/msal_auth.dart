import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'msal_auth.dart';

export 'core/extensions.dart';
export 'models/models.dart';

class MsalAuth {
  final List<String> _scopes;

  MsalAuth._create({required List<String> scopes}) : _scopes = scopes;

  static const _methodChannel = MethodChannel('msal_auth');

  /// Initializes MSAL with required data.
  static Future<MsalAuth> createPublicClientApplication({
    required String clientId,
    required List<String> scopes,
    AndroidConfig? androidConfig,
    IosConfig? iosConfig,
  }) async {
    try {
      late final Map<String, dynamic> arguments;

      if (Platform.isAndroid) {
        assert(androidConfig != null, 'Android config can not be null');
        final config =
            await rootBundle.loadString(androidConfig!.configFilePath);
        final map = json.decode(config) as Map<String, dynamic>;
        map['client_id'] = clientId;
        if (androidConfig.tenantId != null) {
          map['authorities'][0]['audience']['tenant_id'] =
              androidConfig.tenantId;
        }

        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/msal_auth_config.json');
        await file.writeAsBytes(utf8.encode(json.encode(map)));

        arguments = {'configFilePath': file.path};
      } else if (Platform.isIOS) {
        assert(iosConfig != null, 'iOS config can not be null');
        arguments = <String, dynamic>{
          'clientId': clientId,
          'authority': iosConfig!.authority,
          'authMiddleware': iosConfig.authMiddleware.name,
        };
      }

      await _methodChannel.invokeMethod('initialize', arguments);
      return MsalAuth._create(scopes: scopes);
    } on PlatformException catch (e) {
      throw e.msalException;
    }
  }

  /// Acquire a token interactively for the given [scopes]
  /// return [UserAdModel] contains user information but token and expiration date
  Future<MsalUser?> acquireToken() async {
    try {
      assert(_scopes.isNotEmpty, 'Scopes can not be empty');
      final arguments = <String, dynamic>{'scopes': _scopes};
      final json = await _methodChannel.invokeMethod('acquireToken', arguments);
      if (json != null) {
        return MsalUser.fromJson(jsonDecode(json));
      }
      return null;
    } on PlatformException catch (e) {
      throw e.msalException;
    }
  }

  /// Acquire a token silently, with no user interaction, for the given [scopes]
  /// return [UserAdModel] contains user information but token and expiration date
  Future<MsalUser?> acquireTokenSilent() async {
    assert(_scopes.isNotEmpty, 'Scopes can not be empty');
    final arguments = <String, dynamic>{'scopes': _scopes};
    try {
      if (Platform.isAndroid) {
        await _methodChannel.invokeMethod('loadAccounts');
      }
      final json =
          await _methodChannel.invokeMethod('acquireTokenSilent', arguments);
      if (json != null) {
        return MsalUser.fromJson(jsonDecode(json));
      }
      return null;
    } on PlatformException catch (e) {
      throw e.msalException;
    }
  }

  /// Logout user from Microsoft account.
  Future<void> logout() async {
    try {
      if (Platform.isAndroid) {
        await _methodChannel.invokeMethod('loadAccounts');
      }
      await _methodChannel.invokeMethod('logout', <String, dynamic>{});
    } on PlatformException catch (e) {
      throw e.msalException;
    }
  }
}
