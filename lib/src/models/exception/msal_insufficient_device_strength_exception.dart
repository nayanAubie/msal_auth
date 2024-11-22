part of 'msal_exception.dart';

/// This exception indicates that the device does not meet the security or
/// performance requirements for completing the authentication process.
///
/// Workplacejoin migrate device registration is required to proceed.
///
/// Only occurs in iOS platform.
class MsalInsufficientDeviceStrengthException extends MsalException {
  const MsalInsufficientDeviceStrengthException({required super.message});

  @override
  String toString() {
    return 'MsalInsufficientDeviceStrengthException { message: $message }';
  }
}
