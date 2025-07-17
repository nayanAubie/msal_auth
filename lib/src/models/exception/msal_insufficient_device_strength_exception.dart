part of 'msal_exception.dart';

/// This exception indicates that the device does not meet the security or
/// performance requirements for completing the authentication process.
///
/// Workplacejoin migrate device registration is required to proceed.
///
/// Only occurs in iOS/MacOS platform.
class MsalInsufficientDeviceStrengthException extends MsalException {
  const MsalInsufficientDeviceStrengthException({
    required super.message,
    required super.correlationId,
  });

  @override
  String toString() {
    return 'MsalInsufficientDeviceStrengthException { message: $message, correlationId: $correlationId }';
  }
}
