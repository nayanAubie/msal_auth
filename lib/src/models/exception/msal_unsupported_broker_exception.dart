part of 'msal_exception.dart';

/// Representing all exceptions that occur due to an
/// unsupported / incompatible broker.
///
/// Only occurs in Android platform.
class MsalUnsupportedBrokerException extends MsalException {
  /// Android package name of the active broker.
  final String activeBrokerPackageName;

  const MsalUnsupportedBrokerException({
    required this.activeBrokerPackageName,
    required super.message,
    required super.correlationId,
  });

  @override
  String toString() {
    return 'MsalUnsupportedBrokerException { activeBrokerPackageName: $activeBrokerPackageName, message: $message, correlationId: $correlationId }';
  }
}
