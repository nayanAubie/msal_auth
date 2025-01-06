import '../../msal_auth.dart';

abstract class PlatformMultipleAccountPca extends PublicClientApplication {
  Future<Account> getAccount({required String identifier});
  Future<List<Account>> getAccounts();
  Future<bool> removeAccount({required String identifier});
}
