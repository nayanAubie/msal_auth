part of 'msal_exception.dart';

/// Occurs when an invalid argument is passed to one of the MSAL API methods.
/// This can include invalid configurations, null or malformed inputs,
/// or missing required arguments.
///
/// Only occurs in Android platform.
class MsalArgumentException extends MsalException {
  /// Argument name that has thrown this exception.
  final String argumentName;

  /// Operation name provided by SDK.
  final String? operationName;

  const MsalArgumentException({
    required this.argumentName,
    required this.operationName,
    required super.message,
    required super.correlationId,
  });

  @override
  String toString() {
    return 'MsalArgumentException { argumentName: $argumentName, operationName: $operationName, message: $message, correlationId: $correlationId }';
  }
}
