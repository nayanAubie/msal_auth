part of 'public_client_application.dart';

/// This class is used to create public client application for native auth
/// mode.
final class NativeAuthPca extends PublicClientApplication {
  NativeAuthPca._create();

  /// Creates native auth public client application.
  static Future<NativeAuthPca> create({
    /// Client id of the application.
    required String clientId,

    /// Authentication methods for Native Auth Public Client Application.
    required ChallengeType challengeTypes,

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
        challengeTypes: challengeTypes,
      );
      await kMethodChannel.invokeMethod('createNativeAuthPca', arguments);
      return NativeAuthPca._create();
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Gets the current account from the cache. if no account is available, it
  /// will throw an exception.
  Future<Account> get currentAccount async {
    try {
      final result = await kMethodChannel.invokeMethod('currentAccount');
      return Account.fromJson(result.cast<String, dynamic>());
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Signs up a new user.
  Future<bool> signUp({
    /// The username of the new user.
    required String username,

    /// The password of the new user.
    String? password,

    /// The attributes of the new user.
    Map<String, dynamic>? attributes,

    /// Sign in automatically after sign up.
    bool signInAfterSignUp = false,
  }) async {
    try {
      final result = await kMethodChannel.invokeMethod('signUp', {
        'username': username,
        'password': password,
        'attributes': attributes,
        'signInAfterSignUp': signInAfterSignUp,
      });
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Signs in a user.
  Future<bool> signIn({
    /// The username of the user.
    required String username,

    /// The password of the user.
    String? password,
  }) async {
    try {
      final result = await kMethodChannel.invokeMethod('signIn', {
        'username': username,
        'password': password,
      });
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Submits the attributes of the user.
  Future<bool> submitAttributes(Map<String, dynamic> attributes) async {
    try {
      final result = await kMethodChannel.invokeMethod('submitAttributes', {
        'attributes': attributes,
      });
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Submits the code of the user.
  Future<bool> submitCode(String code) async {
    try {
      final result = await kMethodChannel.invokeMethod('submitCode', {
        'code': code,
      });
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Resends the code of the user.
  Future<bool> resendCode() async {
    try {
      final result = await kMethodChannel.invokeMethod('resendCode');
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }

  /// Signs out the current account and credentials (tokens).
  Future<bool> signOut() async {
    try {
      final result = await kMethodChannel.invokeMethod('signOut');
      return result;
    } on PlatformException catch (e) {
      throw e.convertToMsalException();
    }
  }
}
