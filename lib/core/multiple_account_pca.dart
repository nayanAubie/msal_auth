import 'dart:developer';

import '../msal_auth.dart';
import '../utils/utils.dart';

final class MultipleAccountPca extends PublicClientApplication {
  MultipleAccountPca._create();

  static Future<MultipleAccountPca> create({
    required String clientId,
    AndroidConfig? androidConfig,
    IosConfig? iosConfig,
  }) async {
    final arguments = await Utils.createPcaArguments(
      clientId: clientId,
      androidConfig: androidConfig,
      iosConfig: iosConfig,
    );
    await kMethodChannel.invokeMethod('createMultipleAccountPca', arguments);
    return MultipleAccountPca._create();
  }

  Future<dynamic> getAccount({required String identifier}) async {
    final result = await kMethodChannel.invokeMethod('getAccount', identifier);
    log('Get Account result====> $result');
  }

  Future<dynamic> getAccounts() async {
    final result = await kMethodChannel.invokeMethod('getAccounts');
    log('Get Accounts result======$result');
  }

  Future<dynamic> removeAccount({required String identifier}) async {
    final result =
        await kMethodChannel.invokeMethod('removeAccount', identifier);
    log('Remove Account result======$result');
  }
}
