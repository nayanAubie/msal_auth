part of 'msal_exception.dart';

/// The requested resource is protected by an Intune Conditional Access policy.
/// Please see https://aka.ms/intuneMAMSDK for more information.
///
/// Handling of this error is optional (handle it only if you are going to
/// access resources protected by an Intune Conditional Access policy).
class MsalProtectionPolicyRequiredException extends MsalException {
  /// Account Upn of the user. only present in Android.
  final String? accountUpn;

  /// Account OID of the user. only present in Android.
  final String? accountUserId;

  /// Account Tenant id. only present in Android.
  final String? tenantId;

  /// Authority Url. only present in Android.
  final String? authorityUrl;

  const MsalProtectionPolicyRequiredException({
    required this.accountUpn,
    required this.accountUserId,
    required this.tenantId,
    required this.authorityUrl,
    required super.message,
    required super.correlationId,
  });

  @override
  String toString() {
    return 'MsalProtectionPolicyRequiredException { accountUpn: $accountUpn, accountUserId: $accountUserId, tenantId: $tenantId, authorityUrl: $authorityUrl, message: $message, correlationId: $correlationId }';
  }
}
