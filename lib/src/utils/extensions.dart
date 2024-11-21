import 'package:flutter/services.dart';

import '../models/models.dart';

extension PlatformExceptionUtils on PlatformException {
  /// Converts the [PlatformException] to [MsalException]
  MsalException convertToMsalException() {
    switch (code) {
      case 'USER_CANCEL':
        return MsalUserCancelException(message: message!);
      case 'DECLINED_SCOPE':
        final map = details.cast<String, dynamic>();
        return MsalDeclinedScopeException(
          grantedScopes: map['grantedScopes'],
          declinedScopes: map['declinedScopes'],
          message: message!,
        );
      case 'PROTECTION_POLICY_REQUIRED':
        return MsalProtectionPolicyRequiredException(message: message!);
      case 'UI_REQUIRED':
        return MsalUiRequiredException(message: message!);
      case 'INVALID_ARGUMENT':
        final map = details.cast<String, dynamic>();
        return MsalArgumentException(
          errorCode: map['errorCode'],
          argumentName: map['argumentName'],
          operationName: map['operationName'],
          message: message!,
        );
      case 'CLIENT_ERROR':
        return MsalClientException(
          errorCode: details,
          message: message!,
        );
      case 'SERVICE_ERROR':
        final map = details.cast<String, dynamic>();
        return MsalServiceException(
          errorCode: map['errorCode'],
          httpStatusCode: map['httpStatusCode'],
          message: message!,
        );
      case 'UNSUPPORTED_BROKER':
        return MsalUnsupportedBrokerException(message: message!);
      case 'INTERNAL_ERROR':
        return MsalInternalException(
          message: message!,
          errorCode: details.toString(),
        );
      case 'WORKPLACE_JOIN_REQUIRED':
        return MsalWorkplaceJoinRequiredException(message: message!);
      case 'SERVER_ERROR':
        return MsalServerException(message: message!);
      case 'INSUFFICIENT_DEVICE_STRENGTH':
        return MsalInsufficientDeviceStrengthException(message: message!);
    }
    return MsalException(message: message ?? '');
  }
}
