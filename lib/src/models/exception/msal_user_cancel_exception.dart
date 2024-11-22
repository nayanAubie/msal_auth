part of 'msal_exception.dart';

/// MSAL internal exception for user cancelling the flow.
class MsalUserCancelException extends MsalException {
  const MsalUserCancelException({required super.message});

  @override
  String toString() {
    return 'MsalUserCancelException { message: $message }';
  }
}
