import '../../../msal_auth.dart';
import '../platform_multiple_account_pca.dart';
import 'web_public_client_application.dart';

final class WebMultipleAccountPca extends WebPublicClientApplication
    implements PlatformMultipleAccountPca {
  WebMultipleAccountPca._create();

  static Future<WebMultipleAccountPca> create() async {
    return WebMultipleAccountPca._create();
  }

  @override
  Future<Account> getAccount({required String identifier}) =>
      throw UnimplementedError();

  @override
  Future<List<Account>> getAccounts() => throw UnimplementedError();

  @override
  Future<bool> removeAccount({required String identifier}) =>
      throw UnimplementedError();
}
