import '../../../msal_auth.dart';
import '../../models/config/web_config.dart';
import '../platform_multiple_account_pca.dart';
import '../platform_single_account_pca.dart';
import 'mobile_multiple_account_pca.dart';
import 'mobile_single_account_pca.dart';

Future<PlatformMultipleAccountPca> createMultipleAccountPca({
  String? clientId,
  AndroidConfig? androidConfig,
  IosConfig? iosConfig,
  WebConfig? webConfig,
}) async {
  assert(clientId != null, 'Client id is required for mobile platform');
  return MobileMultipleAccountPca.create(
    clientId: clientId!,
    androidConfig: androidConfig,
    iosConfig: iosConfig,
  );
}

Future<PlatformSingleAccountPca> createSingleAccountPca({
  String? clientId,
  AndroidConfig? androidConfig,
  IosConfig? iosConfig,
  WebConfig? webConfig,
}) async {
  assert(clientId != null, 'Client id is required for mobile platform');
  return MobileSingleAccountPca.create(
    clientId: clientId!,
    androidConfig: androidConfig,
    iosConfig: iosConfig,
  );
}
