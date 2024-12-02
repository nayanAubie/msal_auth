import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';

final class Utils {
  Utils._();

  /// Creates the arguments for creating public client application.
  /// Argument map will be passed to the native side.
  static Future<Map<String, dynamic>> createPcaArguments({
    required String clientId,
    AndroidConfig? androidConfig,
    IosConfig? iosConfig,
  }) async {
    final arguments = <String, dynamic>{};
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        assert(androidConfig != null, 'Android config can not be null');

        final configStr =
            await rootBundle.loadString(androidConfig!.configFilePath);
        final config = json.decode(configStr) as Map<String, dynamic>
          ..addAll({
            'client_id': clientId,
            'redirect_uri': androidConfig.redirectUri,
          });

        arguments.addAll({'config': config});
      case TargetPlatform.iOS:
        assert(iosConfig != null, 'iOS config can not be null');
        arguments.addAll({
          'clientId': clientId,
          'authority': iosConfig!.authority,
          'broker': iosConfig.broker.name,
          'authorityType': iosConfig.authorityType.name,
        });
      default:
    }
    return arguments;
  }
}
