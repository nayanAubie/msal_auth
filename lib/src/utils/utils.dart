import 'dart:convert';
import 'dart:io';

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
    ChallengeType? challengeTypes,
  }) async {
    final arguments = <String, dynamic>{};
    if (Platform.isAndroid) {
      assert(androidConfig != null, 'Android config can not be null');

      final configStr =
          await rootBundle.loadString(androidConfig!.configFilePath);
      final config = json.decode(configStr) as Map<String, dynamic>
        ..addAll({
          'client_id': clientId,
          'redirect_uri': androidConfig.redirectUri,
        });

      arguments.addAll({'config': config});
    } else if (Platform.isIOS) {
      assert(iosConfig != null, 'iOS config can not be null');
      arguments.addAll({
        'clientId': clientId,
        'authority': iosConfig!.authority,
        'broker': iosConfig.broker.name,
        'authorityType': iosConfig.authorityType.name,
        'tenantSubdomain': iosConfig.tenantSubdomain,
      });
    }

    if (challengeTypes != null) {
      arguments.addAll({'challengeTypes': challengeTypes.name});
    }

    return arguments;
  }
}
