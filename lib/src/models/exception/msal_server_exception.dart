part of 'msal_exception.dart';

/// Occurs when the server (Azure Active Directory or its related services)
/// encounters an issue and fails to process the request properly.
/// This error typically indicates that something went wrong on the server side,
/// such as a transient failure, misconfiguration, or other
/// backend-related problems.
///
/// Only occurs in iOS platform.
class MsalServerException extends MsalException {
  const MsalServerException({required super.message});

  @override
  String toString() {
    return 'MsalServerException { message: $message }';
  }
}
