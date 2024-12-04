// This code is adapted from https://github.com/earlybyte/aad_oauth
// Copyright (c) 2020 Earlybyte GmbH
// Licensed under the MIT License

import 'cache_location_enum.dart';

/// Parameters according to official Microsoft Documentation:
/// - Azure AD https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
/// - Azure AD B2C: https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow
///
/// DartDocs of parameters are mostly from those pages.
class WebConfig {
  /// The Application (client) ID that the Azure portal – App registrations experience assigned to your app.
  final String clientId;

  /// The tenant value in the path of the request can be used to control who can sign into the application.
  /// The allowed values are common, organizations, consumers, and tenant identifiers. Or Name of your Azure AD B2C tenant.
  final String tenant;

  /// __AAD B2C only__: The user flow to be run. Specify the name of a user flow you've created in your Azure AD B2C tenant.
  /// For example: b2c_1_sign_in, b2c_1_sign_up, or b2c_1_edit_profile
  final String? policy;

  /// Using Azure AD B2C instead of standard Azure AD.
  /// Azure Active Directory B2C provides business-to-customer identity as a service.
  final bool isB2C;

  /// The redirect uri of your app, where authentication responses can be sent and received by your app.
  /// It must exactly match one of the redirect_uris you registered in the portal, except it must be url encoded.
  /// For native & mobile apps, you should use the default value.
  final String redirectUri;

  /// Cache location used when authenticating with a web client.
  /// "CacheLocation.localStorage" - Local browser storage (default)
  /// "CacheLocation.sessionStorage" - Session context
  /// "CacheLocation.memoryStorage" - Memory only
  CacheLocation cacheLocation;

  /// Azure AD OAuth Configuration. Look at individual fields for description.
  WebConfig({
    required this.tenant,
    required this.clientId,
    required this.redirectUri,
    this.policy,
    this.isB2C = false,
    this.cacheLocation = CacheLocation.localStorage,
  });

  WebConfig copyWith({
    String? tenant,
    String? clientId,
    String? redirectUri,
    String? policy,
    bool? isB2C,
    CacheLocation? cacheLocation,
    Map<String, String>? customParameters,
  }) {
    return WebConfig(
      tenant: tenant ?? this.tenant,
      clientId: clientId ?? this.clientId,
      redirectUri: redirectUri ?? this.redirectUri,
      policy: policy ?? this.policy,
      isB2C: isB2C ?? this.isB2C,
      cacheLocation: cacheLocation ?? this.cacheLocation,
    );
  }
}
