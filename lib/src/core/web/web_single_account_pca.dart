import '../../../msal_auth.dart';
import '../platform_single_account_pca.dart';
import 'web_public_client_application.dart';

final class WebSingleAccountPca extends WebPublicClientApplication
    implements PlatformSingleAccountPca {
  WebSingleAccountPca._create();

  static Future<WebSingleAccountPca> create() async {
    return WebSingleAccountPca._create();
  }

  @override
  Future<Account> get currentAccount => throw UnimplementedError();

  @override
  Future<bool> signOut() => throw UnimplementedError();
}
