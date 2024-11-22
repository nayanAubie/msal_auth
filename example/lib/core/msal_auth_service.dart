import 'dart:developer';

import 'package:msal_auth/msal_auth.dart';

import '../environment.dart';

/// Singleton class that manages MSAL authentication.
final class MsalAuthService {
  MsalAuthService._();

  static final MsalAuthService instance = MsalAuthService._();

  final clientId = Environment.aadClientId;
  final scopes = [
    'https://graph.microsoft.com/user.read',
    // Add other scopes here if required.
  ];

  /// The parent class of the public client application. developer usually
  /// does not require to initialize this class. example app uses it to
  /// demonstrates the single & multiple account mode.
  PublicClientApplication? publicClientApplication;

  /// Use this instance if you want to use the single account mode.
  SingleAccountPca? singleAccountPca;

  /// Use this instance if you want to use the multiple account mode.
  MultipleAccountPca? multipleAccountPca;

  /// Creates the public client application based on the given account mode.
  Future<(bool, MsalException?)> createPublicClientApplication({
    required AccountMode accountMode,
    required Broker broker,
    required AuthorityType authorityType,
  }) async {
    final androidConfig = AndroidConfig(
      configFilePath: 'assets/msal_config.json',
      redirectUri: Environment.aadAndroidRedirectUri,
    );

    final iOsConfig = IosConfig(
      authority: Environment.aadIosAuthority,
      broker: broker,
      authorityType: authorityType,
    );

    try {
      if (accountMode == AccountMode.single) {
        singleAccountPca = await SingleAccountPca.create(
          clientId: clientId,
          androidConfig: androidConfig,
          iosConfig: iOsConfig,
        );
        publicClientApplication = singleAccountPca;
        multipleAccountPca = null;
      } else {
        multipleAccountPca = await MultipleAccountPca.create(
          clientId: clientId,
          androidConfig: androidConfig,
          iosConfig: iOsConfig,
        );
        publicClientApplication = multipleAccountPca;
        singleAccountPca = null;
      }
      return (true, null);
    } on MsalException catch (e) {
      log('Create public client application failed => $e');
      return (false, e);
    }
  }

  /// Common method for both account mode.
  Future<(AuthenticationResult?, MsalException?)> acquireToken({
    String? loginHint,
    Prompt prompt = Prompt.whenRequired,
  }) async {
    try {
      final result = await publicClientApplication?.acquireToken(
        scopes: scopes,
        loginHint: loginHint,
        prompt: prompt,
      );
      log('Acquire token => ${result?.toJson()}');
      return (result, null);
    } on MsalException catch (e) {
      log('Acquire token failed => $e');
      return (null, e);
    }
  }

  /// Common method for both account mode.
  Future<(AuthenticationResult?, MsalException?)> acquireTokenSilent({
    String? identifier,
  }) async {
    try {
      final result = await publicClientApplication?.acquireTokenSilent(
        scopes: scopes,
        identifier: identifier,
      );
      log('Acquire token silent => ${result?.toJson()}');
      return (result, null);
    } on MsalException catch (e) {
      log('Acquire token silent failed => $e');

      // If it is a UI required exception, try to acquire token interactively.
      if (e is MsalUiRequiredException) {
        return acquireToken();
      }
      return (null, e);
    }
  }

  /// Used only with single account mode.
  Future<(Account?, MsalException?)> getCurrentAccount() async {
    try {
      final result = await singleAccountPca?.currentAccount;
      log('Current account => ${result?.toJson()}');
      return (result, null);
    } on MsalException catch (e) {
      log('Current account failed => $e');
      return (null, e);
    }
  }

  /// Used only with single account mode.
  Future<(bool, MsalException?)> signOut() async {
    try {
      final result = await singleAccountPca?.signOut();
      log('Sign out => $result');
      return (true, null);
    } on MsalException catch (e) {
      log('Sign out failed => $e');
      return (false, e);
    }
  }

  /// Used only with multiple account mode.
  Future<(Account?, MsalException?)> getAccount({
    required String identifier,
  }) async {
    try {
      final account =
          await multipleAccountPca?.getAccount(identifier: identifier);
      log('Get account => ${account?.toJson()}');
      return (account, null);
    } on MsalException catch (e) {
      log('Get account failed => $e');
      return (null, e);
    }
  }

  /// Used only with multiple account mode.
  Future<(List<Account>?, MsalException?)> getAccounts() async {
    try {
      final result = await multipleAccountPca?.getAccounts();
      log('Get accounts => ${result?.map((account) => account.toJson())}');
      return (result, null);
    } on MsalException catch (e) {
      log('Get accounts failed => $e');
      return (null, e);
    }
  }

  /// Used only with multiple account mode.
  Future<(bool, MsalException?)> removeAccount({
    required String identifier,
  }) async {
    try {
      final result =
          await multipleAccountPca?.removeAccount(identifier: identifier);
      log('Remove account => $result');
      return (true, null);
    } on MsalException catch (e) {
      log('Remove account failed => $e');
      return (false, e);
    }
  }
}

/// Declare this enum if your app needs both account mode.
enum AccountMode {
  single,
  multiple,
}
