part 'msal_argument_exception.dart';
part 'msal_client_exception.dart';
part 'msal_declined_scope_exception.dart';
part 'msal_insufficient_device_strength_exception.dart';
part 'msal_internal_exception.dart';
part 'msal_pca_init_exception.dart';
part 'msal_protection_policy_required_exception.dart';
part 'msal_server_exception.dart';
part 'msal_service_exception.dart';
part 'msal_ui_required_exception.dart';
part 'msal_unsupported_broker_exception.dart';
part 'msal_user_cancel_exception.dart';
part 'msal_workplace_join_required_exception.dart';

/// Exception thrown by the MSAL SDK. see the particular child class of
/// [MsalException] for more specific details.
class MsalException implements Exception {
  /// Error message returned by MSAL SDK.
  final String message;

  const MsalException({required this.message});

  @override
  String toString() {
    return 'MsalException { message: $message }';
  }
}
