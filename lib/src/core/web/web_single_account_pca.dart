import '../../../msal_auth.dart';
import '../../models/config/web_config.dart';
import '../platform_single_account_pca.dart';
import 'web_oauth.dart';
import 'web_public_client_application.dart';

final class WebSingleAccountPca extends WebPublicClientApplication
    implements PlatformSingleAccountPca {
  WebSingleAccountPca._create();

  @override
  late final WebOAuth oauth;

  static Future<WebSingleAccountPca> create({
    required WebConfig config,
  }) async {
    final pca = WebSingleAccountPca._create()..oauth = WebOAuth(config);
    await pca.oauth.init();
    return pca;
  }

  @override
  Future<Account> get currentAccount => oauth.getAccount();

  @override
  Future<bool> signOut() async {
    await oauth.logout();
    return true;
  }
}
