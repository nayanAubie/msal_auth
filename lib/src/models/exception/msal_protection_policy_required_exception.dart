part of 'msal_exception.dart';

/// The requested resource is protected by an Intune Conditional Access policy.
/// Please see https://aka.ms/intuneMAMSDK for more information.
///
/// Handling of this error is optional (handle it only if you are going to
/// access resources protected by an Intune Conditional Access policy).
class MsalProtectionPolicyRequiredException extends MsalException {
  const MsalProtectionPolicyRequiredException({required super.message});

  @override
  String toString() {
    return 'MsalProtectionPolicyRequiredException { message: $message }';
  }
}
