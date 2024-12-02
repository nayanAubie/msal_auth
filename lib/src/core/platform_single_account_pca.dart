import '../../msal_auth.dart';

abstract class PlatformSingleAccountPca extends PublicClientApplication {
  Future<Account> get currentAccount;
  Future<bool> signOut();
}
