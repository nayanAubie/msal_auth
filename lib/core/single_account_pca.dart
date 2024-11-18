import 'dart:developer';

import '../models/account_mode.dart';
import '../msal_auth.dart';
import '../utils/utils.dart';

final class SingleAccountPca extends PublicClientApplication {
  SingleAccountPca._create();

  static Future<SingleAccountPca> create({
    required String clientId,
    AndroidConfig? androidConfig,
    IosConfig? iosConfig,
  }) async {
    final arguments = await Utils.createPcaArguments(
      clientId: clientId,
      androidConfig: androidConfig,
      iosConfig: iosConfig,
    );
    final result = await kMethodChannel.invokeMethod('createSingleAccountPca', arguments);
    print('Result for SinglePca=============$result');
    return SingleAccountPca._create();
  }

  Future<dynamic> get currentAccount async {
    final result = await kMethodChannel.invokeMethod('currentAccount');
    log('Result ====== $result');
  }

  Future<bool> signOut() async {
    final result = await kMethodChannel.invokeMethod('signOut');
    print('Result of signOut======> $result');
    return result;
  }
}
