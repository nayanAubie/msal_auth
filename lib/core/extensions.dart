import 'package:flutter/services.dart';
import 'package:msal_auth/msal_auth.dart';

extension PlatformExceptionUtils on PlatformException {
  MsalException get msalException {
    switch (code) {
      case 'USER_CANCELED':
        return MsalUserCanceledException(message);
      case 'UI_REQUIRED':
        return MsalUiRequiredException(message);
      case 'AUTH_ERROR':
        return MsalException(message ?? 'Authentication error');
      default:
        return const MsalException('Authentication error');
    }
  }
}
