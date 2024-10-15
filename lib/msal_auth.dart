import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'msal_auth.dart';

export 'core/extensions.dart';
export 'models/models.dart';

const _methodChannel = MethodChannel('msal_auth');

enum PublicClientAccountAppType {
  singleAccount,
  multipleAccount,
}

class MsalAuth {
  final MsalAuthImpl? _msalAuthImpl;
  MsalAuth._create({
    required MsalAuthImpl msalAuthImpl,
  }) : _msalAuthImpl = msalAuthImpl;

  /// Initializes MSAL with required data.
  static Future<MsalAuth> createPublicClientApplication({
    required String clientId,
    required List<String> scopes,
    String? loginHint,
    AndroidConfig? androidConfig,
    IosConfig? iosConfig,
    PublicClientAccountAppType publicClientAppAccountType =
        PublicClientAccountAppType.multipleAccount,
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

        arguments = {
          'configFilePath': file.path,
          'publicClientAppAccountType': publicClientAppAccountType.name,
        };
      } else if (Platform.isIOS) {
        assert(iosConfig != null, 'iOS config can not be null');
        arguments = <String, dynamic>{
          'clientId': clientId,
          'authority': iosConfig!.authority,
          'authMiddleware': iosConfig.authMiddleware.name,
          'tenantType': iosConfig.tenantType.name,
          'loginHint': loginHint,
        };
      }

      await _methodChannel.invokeMethod('initialize', arguments);
      return MsalAuth._create(
          msalAuthImpl: switch (publicClientAppAccountType) {
        PublicClientAccountAppType.multipleAccount =>
          MsalMultipleAccountImpl(scopes: scopes),
        PublicClientAccountAppType.singleAccount =>
          MsalSingleAccountImpl(scopes: scopes),
      });
    } on PlatformException catch (e) {
      throw e.msalException;
    }
  }

  Future<MsalUser?> login() {
    assert(
      _msalAuthImpl != null,
      'Must create public client application before attempting to login',
    );
    return _msalAuthImpl!.login();
  }

  Future<MsalUser?> acquireToken() {
    assert(
      _msalAuthImpl != null,
      'Must create public client application before attempting to acquire token',
    );
    return _msalAuthImpl!.acquireToken();
  }

  Future<MsalUser?> acquireTokenSilent() {
    assert(
      _msalAuthImpl != null,
      'Must create public client application before attempting to acquire token silently',
    );
    return _msalAuthImpl!.acquireTokenSilent();
  }

  Future<void> logout() {
    assert(
      _msalAuthImpl != null,
      'Must create public client application before attempting to logout',
    );
    return _msalAuthImpl!.logout();
  }
}

mixin MsalAuthImpl {
  Future<MsalUser?> login();
  Future<MsalUser?> acquireToken();
  Future<MsalUser?> acquireTokenSilent();
  Future<void> logout();
}

class MsalMultipleAccountImpl implements MsalAuthImpl {
  final List<String> _scopes;

  MsalMultipleAccountImpl({required List<String> scopes}) : _scopes = scopes;

  @override
  Future<MsalUser?> login() {
    throw UnimplementedError(
      'Login not available for multiple account public client application',
    );
  }

  /// Acquire a token interactively for the given [scopes]
  /// return [UserAdModel] contains user information but token and expiration date
  @override
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
  @override
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
  @override
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

class MsalSingleAccountImpl implements MsalAuthImpl {
  static const _methodChannel = MethodChannel('msal_auth');
  final List<String> _scopes;

  MsalSingleAccountImpl({required List<String> scopes}) : _scopes = scopes;

  /// Login with the given [scopes]
  /// return [UserAdModel] containing user information
  @override
  Future<MsalUser?> login() async {
    try {
      assert(_scopes.isNotEmpty, 'Scopes cannot be empty');
      final arguments = <String, dynamic>{'scopes': _scopes};
      late String? json;
      if (Platform.isAndroid) {
        await _methodChannel.invokeMethod('loadAccount');
        json = await _methodChannel.invokeMethod('login', arguments);
      } else {
        json = await _methodChannel.invokeMethod('acquireToken', arguments);
      }
      if (json != null) {
        return MsalUser.fromJson(jsonDecode(json));
      }
      return null;
    } on PlatformException catch (e) {
      throw e.msalException;
    }
  }

  /// Acquire a token interactively for the given [scopes]
  /// return [UserAdModel] containing user information
  @override
  Future<MsalUser?> acquireToken() async {
    try {
      assert(_scopes.isNotEmpty, 'Scopes cannot be empty');
      if (Platform.isAndroid) {
        await _methodChannel.invokeMethod('loadAccount');
      }
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
  /// return [UserAdModel] containing user information
  @override
  Future<MsalUser?> acquireTokenSilent() async {
    assert(_scopes.isNotEmpty, 'Scopes cannot be empty');
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod('loadAccount');
    }
    final arguments = <String, dynamic>{'scopes': _scopes};
    try {
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
  @override
  Future<void> logout() async {
    try {
      if (Platform.isAndroid) {
        await _methodChannel.invokeMethod('loadAccount');
      }
      await _methodChannel.invokeMethod('logout', <String, dynamic>{});
    } on PlatformException catch (e) {
      throw e.msalException;
    }
  }
}
