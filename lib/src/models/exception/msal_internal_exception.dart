part of 'msal_exception.dart';

/// An unrecoverable error occured either within the MSAL client or
/// on server side.
/// More detailed information about the specific error can be found in
/// "MSALInternalError" enum.
///
/// Only occurs in iOS/MacOS platform.
class MsalInternalException extends MsalException {
  /// Internal error code.
  ///
  /// Visit this link to check the detailed error by searching your [errorCode].
  /// https://github.com/AzureAD/microsoft-authentication-library-for-objc/blob/dev/MSAL/src/public/MSALError.h
  final int errorCode;

  const MsalInternalException({
    required this.errorCode,
    required super.message,
    required super.correlationId,
  });

  @override
  String toString() {
    return 'MsalInternalException { errorCode: $errorCode, message: $message, correlationId: $correlationId }';
  }
}
