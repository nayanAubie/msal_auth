import '../../models/models.dart';
import '../platform_multiple_account_pca.dart';
import 'web_oauth.dart';
import 'web_public_client_application.dart';

final class WebMultipleAccountPca extends WebPublicClientApplication
    implements PlatformMultipleAccountPca {
  WebMultipleAccountPca._create();

  @override
  late final WebOAuth oauth;

  static Future<WebMultipleAccountPca> create({
    required WebConfig config,
  }) async {
    final pca = WebMultipleAccountPca._create()..oauth = WebOAuth(config);
    await pca.oauth.init();
    return pca;
  }

  @override
  Future<Account> getAccount({required String identifier}) =>
      oauth.getAccount(identifier);

  @override
  Future<List<Account>> getAccounts() => oauth.getAccounts();

  @override
  Future<bool> removeAccount({required String identifier}) async {
    await oauth.logout(identifier);
    return true;
  }
}
