part of 'msal_exception.dart';

/// Occurs when an invalid argument is passed to one of the MSAL API methods.
/// This can include invalid configurations, null or malformed inputs,
/// or missing required arguments.
///
/// Only occurs in Android platform.
class MsalArgumentException extends MsalException {
  /// Detailed error code.
  final String errorCode;

  /// Argument name that has thown this exception.
  final String argumentName;

  /// Operation name provided by SDK.
  final String operationName;

  const MsalArgumentException({
    required this.errorCode,
    required this.argumentName,
    required this.operationName,
    required super.message,
  });

  @override
  String toString() {
    return 'MsalArgumentException { errorCode: $errorCode, argumentName: $argumentName, operationName: $operationName }';
  }
}
