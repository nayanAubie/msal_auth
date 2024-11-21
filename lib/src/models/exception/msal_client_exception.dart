part of 'msal_exception.dart';

/// This exception class represents general errors that are local to the library.
/// Below is the table of proposed codes and a short description of each.
///
/// Set of error codes that could be returned from this exception:
///
/// "multiple_matching_tokens_detected": There are multiple cache entries found
/// and the sdk cannot identify the correct access or refresh token from the
/// cache. This usually indicates a bug in the sdk for storing tokens or the
/// authority is not provided in the silent request and multiple matching
/// tokens found.
///
/// "device_network_not_available": No active network is available on the device.
///
/// "json_parse_failure": The sdk failed to parse the JSON format.
///
/// "io_error": IOException happened, could be the device/ network errors.
///
/// "malformed_url": The url is malformed. Likely caused when constructing the
/// auth request, authority, or redirect URI.
///
/// "unsupported_encoding": The encoding is not supported by the device.
///
/// "no_such_algorithm": The algorithm used to generate pkce challenge is
/// not supported.
///
/// "invalid_jwt": JWT returned by the server is not valid, empty or malformed.
///
/// "state_mismatch": State from authorization response did not match the state
/// in the authorization request. For authorization requests, the sdk will
/// verify the state returned from redirect and the one sent in the request.
///
/// "unsupported_url": Unsupported url, cannot perform ADFS authority validation.
///
/// "authority_validation_not_supported": The authority is not supported for
/// authority validation. The sdk supports b2c authorities, but doesn't support
/// b2c authority validation. Only well-known host will be supported.
///
/// "chrome_not_installed": Chrome is not installed on the device. The sdk uses
/// chrome custom tab for authorization requests if available, and will fall
/// back to chrome browser.
///
/// "user_mismatch": The user provided in the acquire token request doesn't
/// match the user returned from server.
///
/// Only occurs in Android platform.
class MsalClientException extends MsalException {
  /// Detailed error code.
  final String errorCode;

  const MsalClientException({required this.errorCode, required super.message});

  @override
  String toString() {
    return 'MsalClientException { errorCode: $errorCode, message: $message }';
  }
}
