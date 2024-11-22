/// The UI options that developer can pass during
/// interactive token acquisition requests.
enum Prompt {
  /// acquireToken will send prompt=select_account to the authorize endpoint.
  /// Shows a list of users from which can be selected for authentication.
  selectAccount,

  /// acquireToken will send prompt=login to the authorize endpoint.
  /// The user will always be prompted for credentials by the service.
  login,

  /// acquireToken will send prompt=consent to the authorize endpoint.
  /// The user will be prompted to consent even if consent was granted before.
  consent,

  /// acquireToken will send prompt=create to the / authorize endpoint.
  /// The user will be prompted to create a new account.
  /// Requires configuring authority as type "AzureADMyOrg" with a tenant_id.
  /// Prerequisite: https://docs.microsoft.com/en-us/azure/active-directory/external-identities/self-service-sign-up-user-flow
  create,

  /// acquireToken will not send the prompt parameter to the authorize endpoint.
  /// The user may be prompted to login or to consent as required by the request.
  whenRequired,
}
