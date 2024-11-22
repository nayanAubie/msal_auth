part of 'public_client_application.dart';

/// This class is used to create public client application for multiple account
/// mode.
final class MultipleAccountPca extends PublicClientApplication {
  MultipleAccountPca._create();

  /// Creates multiple account public client application.
  static Future<MultipleAccountPca> create({
    /// Client id of the application.
    required String clientId,

    /// Android configuration, required for android platform.
    AndroidConfig? androidConfig,

    /// iOS configuration, required for iOS platform.
    IosConfig? iosConfig,
  }) async {
    final arguments = await Utils.createPcaArguments(
      clientId: clientId,
      androidConfig: androidConfig,
      iosConfig: iosConfig,
    );
    try {
      await kMethodChannel.invokeMethod('createMultipleAccountPca', arguments);
      return MultipleAccountPca._create();
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Gets the account from the cache by using given identifier.
  /// if no account is available, it will throw an exception.
  Future<Account> getAccount({required String identifier}) async {
    try {
      final result =
          await kMethodChannel.invokeMethod('getAccount', identifier);
      return Account.fromJson(result.cast<String, dynamic>());
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Asynchronously returns a list of [Account] objects for which
  /// this application has refresh tokens.
  Future<List<Account>> getAccounts() async {
    try {
      final result = await kMethodChannel.invokeMethod('getAccounts') as List;
      return result
          .map((account) => Account.fromJson(account.cast<String, dynamic>()))
          .toList();
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Removes the account and credentials (tokens) for the given identifier.
  Future<bool> removeAccount({required String identifier}) async {
    try {
      final result =
          await kMethodChannel.invokeMethod('removeAccount', identifier);
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }
}
