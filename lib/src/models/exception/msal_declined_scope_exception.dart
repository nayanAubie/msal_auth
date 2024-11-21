part of 'msal_exception.dart';

/// Exception class to indicate that one or more requested scopes have been
/// declined by the server. Developers can opt to continue acquiring token by
/// passing the [grantedScopes] and calling "acquireTokenSilent" call
/// on this error.
class MsalDeclinedScopeException extends MsalException {
  /// List of scopes granted by the server.
  final List<String> grantedScopes;

  /// List of scopes declined by the server.
  ///
  /// This can happen due to multiple reasons.
  /// - Requested scope is not supported
  /// - Requested scope is not recognized (According to OIDC, any scope values
  /// used that are not understood by an implementation should be ignored.)
  /// - Requested scope is not supported for a particular account
  /// (Organizational scopes when it is a consumer account)
  final List<String> declinedScopes;

  const MsalDeclinedScopeException({
    required this.grantedScopes,
    required this.declinedScopes,
    required super.message,
  });

  @override
  String toString() {
    return 'MsalDeclinedScopeException { grantedScopes: $grantedScopes, declinedScopes: $declinedScopes, message: $message }';
  }
}
