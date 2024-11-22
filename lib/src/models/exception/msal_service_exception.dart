part of 'msal_exception.dart';

/// This exception class represents errors when communicating to the service,
/// can be from the authorize or token endpoints.
/// Generally, these errors are resolved by fixing app configurations either
/// in code or in the app registration portal.
///
/// Set of error codes that could be returned from this exception:
///
/// "invalid_request": This request is missing a required parameter,
/// includes an invalid parameter, includes a parameter more than once,
/// or is otherwise malformed.
///
/// "unauthorized_client": The client is not authorized to request
/// an authorization code.
///
/// "access_denied": The resource owner or authorization server
/// denied the request.
///
/// "invalid_scope": The request scope is invalid, unknown or malformed.
///
/// "service_not_available": Represents 500/ 503/ 504 error codes.
///
/// "request_timeout": Represents java. net. SocketTimeoutException.
///
/// "invalid_instance": AuthorityMetadata validation failed.
///
/// "unknown_error": Request to server failed.
///
/// Only occurs in Android platform.
class MsalServiceException extends MsalException {
  /// Detailed error code.
  final String errorCode;

  /// The http status code for the request sent to the service.
  final int httpStatusCode;

  const MsalServiceException({
    required this.errorCode,
    required this.httpStatusCode,
    required super.message,
  });

  @override
  String toString() {
    return 'MsalServiceException { errorCode: $errorCode, httpStatusCode: $httpStatusCode, message: $message }';
  }
}
