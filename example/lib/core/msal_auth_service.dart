import 'package:msal_auth/msal_auth.dart';

import '../environment.dart';

final class MsalAuthService {
  MsalAuthService._();

  static final MsalAuthService instance = MsalAuthService._();

  final _clientId = Environment.aadClientId;

  late PublicClientApplication _publicClientApplication;
  late SingleAccountPca _singleAccountPca;
  late MultipleAccountPca _multipleAccountPca;
}
