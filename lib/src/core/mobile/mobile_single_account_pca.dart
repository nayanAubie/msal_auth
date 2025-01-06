import 'package:flutter/services.dart';

import '../../../msal_auth.dart';
import '../../utils/extensions.dart';
import '../../utils/utils.dart';
import '../platform_single_account_pca.dart';
import 'mobile_public_client_application.dart';

/// This class is used to create public client application for single account
/// mode.
final class MobileSingleAccountPca extends MobilePublicClientApplication
    implements PlatformSingleAccountPca {
  MobileSingleAccountPca._create();

  /// Creates single account public client application.
  static Future<MobileSingleAccountPca> create({
    /// Client id of the application.
    required String clientId,

    /// Android configuration, required for android platform.
    AndroidConfig? androidConfig,

    /// iOS configuration, required for iOS platform.
    IosConfig? iosConfig,
  }) async {
    try {
      final arguments = await Utils.createPcaArguments(
        clientId: clientId,
        androidConfig: androidConfig,
        iosConfig: iosConfig,
      );
      await kMethodChannel.invokeMethod('createSingleAccountPca', arguments);
      return MobileSingleAccountPca._create();
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Gets the current account from the cache. if no account is available, it
  /// will throw an exception.
  @override
  Future<Account> get currentAccount async {
    try {
      final result = await kMethodChannel.invokeMethod('currentAccount');
      return Account.fromJson(result.cast<String, dynamic>());
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Signs out the current account and credentials (tokens).
  /// NOTE: If a device is marked as a shared device within broker,
  /// sign out will be device wide.
  @override
  Future<bool> signOut() async {
    try {
      final result = await kMethodChannel.invokeMethod('signOut');
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }
}
