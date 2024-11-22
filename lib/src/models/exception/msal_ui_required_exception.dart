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
  const MsalUiRequiredException({required super.message});

  @override
  String toString() {
    return 'MsalUiRequiredException { message: $message }';
  }
}
