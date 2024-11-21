part of 'msal_exception.dart';

/// Workplace join is required to proceed. Handling of this error is optional.
///
/// Only occurs in iOS platform.
class MsalWorkplaceJoinRequiredException extends MsalException {
  const MsalWorkplaceJoinRequiredException({required super.message});

  @override
  String toString() {
    return 'MsalWorkplaceJoinRequiredException { message: $message }';
  }
}
