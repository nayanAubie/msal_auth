part of 'msal_exception.dart';

/// Representing all exceptions that occur due to an
/// unsupported / incompatible broker.
///
/// Only occurs in Android platform.
class MsalUnsupportedBrokerException extends MsalException {
  const MsalUnsupportedBrokerException({required super.message});

  @override
  String toString() {
    return 'MsalUnsupportedBrokerException { message: $message }';
  }
}
