part of 'msal_exception.dart';

/// This exception indicates that UI is required for authentication to succeed.
///
/// The cause of this exception could be:
/// - The refresh token used to redeem access token is invalid, expired
/// or revoked.
///
/// - Access token doesn't exist and no refresh token can be found to redeem
/// access token.
///
/// Developer should handle this and generally call the "acquireToken()" method.
class MsalUiRequiredException extends MsalException {
  /// Only present in Android platform.
  final String? oauthSubErrorCode;

  /// Only present in iOS/MacOS platform.
  final String? oauthError;

  /// Only present in iOS/MacOS platform.
  final String? oauthErrorDescription;

  const MsalUiRequiredException({
    required this.oauthSubErrorCode,
    required this.oauthError,
    required this.oauthErrorDescription,
    required super.message,
    required super.correlationId,
  });

  @override
  String toString() {
    return 'MsalUiRequiredException { oauthSubErrorCode: $oauthSubErrorCode, oauthError: $oauthError, oauthErrorDescription: $oauthErrorDescription, message: $message, correlationId: $correlationId }';
  }
}
