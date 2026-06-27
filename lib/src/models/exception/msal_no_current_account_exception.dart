part of 'msal_exception.dart';

/// Customized exception created in Dart to handle the case of no signed in
/// account as native SDK does not throw any dedicated exception.
class MsalNoCurrentAccountException extends MsalException {
  const MsalNoCurrentAccountException({
    required super.message,
  });

  @override
  String toString() {
    return 'MsalNoCurrentAccountException { message: $message, correlationId: $correlationId }';
  }
}
