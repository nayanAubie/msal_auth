import '../../models/models.dart';
import '../platform_multiple_account_pca.dart';
import '../platform_single_account_pca.dart';
import 'web_multiple_platform_pca.dart';
import 'web_single_account_pca.dart';

Future<PlatformMultipleAccountPca> createMultipleAccountPca({
  String? clientId,
  AndroidConfig? androidConfig,
  IosConfig? iosConfig,
  WebConfig? webConfig,
}) async {
  assert(webConfig != null, 'Web config is required for web platform');
  return WebMultipleAccountPca.create(config: webConfig!);
}

Future<PlatformSingleAccountPca> createSingleAccountPca({
  String? clientId,
  AndroidConfig? androidConfig,
  IosConfig? iosConfig,
  WebConfig? webConfig,
}) async {
  assert(webConfig != null, 'Web config is required for web platform');
  return WebSingleAccountPca.create(config: webConfig!);
}
