part of 'msal_exception.dart';

/// An unrecoverable error occured either within the MSAL client or
/// on server side.
/// More detailed information about the specific error can be found in
/// "MSALInternalError" enum.
///
/// Visit this link to check the detailed error by searching your [errorCode].
/// https://github.com/AzureAD/microsoft-authentication-library-for-objc/blob/dev/MSAL/src/public/MSALError.h
///
/// Only occurs in iOS platform.
class MsalInternalException extends MsalException {
  final String errorCode;

  const MsalInternalException({
    required this.errorCode,
    required super.message,
  });

  @override
  String toString() {
    return 'MsalInternalException { errorCode: $errorCode, message: $message }';
  }
}
