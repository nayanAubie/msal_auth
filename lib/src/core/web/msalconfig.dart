// This code is adapted from https://github.com/earlybyte/aad_oauth
// Copyright (c) 2020 Earlybyte GmbH
// Licensed under the MIT License

@JS()

import 'dart:js_interop';

import '../../models/config/web_config.dart';

/// Interop with JS, we need to convert Config to a JS object or it comes
/// through as empty when passed to JS.
///
/// Parameters according to official Microsoft Documentation:
/// - Azure AD https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
/// - Azure AD B2C: https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow
///
/// DartDocs of parameters are mostly from those pages.
extension type JSMsalConfig._(JSObject _) implements JSObject {
  /// The Application (client) ID that the Azure portal – App registrations experience assigned to your app.
  external String? clientId;

  /// The tenant value in the path of the request can be used to control who can sign into the application.
  /// The allowed values are common, organizations, consumers, and tenant identifiers. Or Name of your Azure AD B2C tenant.
  external String? tenant;

  /// __AAD B2C only__: The user flow to be run. Specify the name of a user flow you've created in your Azure AD B2C tenant.
  /// For example: b2c_1_sign_in, b2c_1_sign_up, or b2c_1_edit_profile
  external String? policy;

  /// Using Azure AD B2C instead of standard Azure AD.
  /// Azure Active Directory B2C provides business-to-customer identity as a service.
  external bool? isB2C;

  /// The redirect uri of your app, where authentication responses can be sent and received by your app.
  /// It must exactly match one of the redirect_uris you registered in the portal, except it must be url encoded.
  /// For native & mobile apps, you should use the default value.
  external String? redirectUri;

  /// Cache location used when authenticating with a web client.
  /// "localStorage" - Local browser storage (default)
  /// "sessionStorage" - Session context
  /// "memoryStorage" - Memory only
  external String? cacheLocation;

  /// Azure AD OAuth Configuration. Look at individual fields for description.
  external JSMsalConfig({
    String? clientId,
    String? tenant,
    String? policy,
    bool? isB2C,
    String? redirectUri,
    String? cacheLocation,
  });

  factory JSMsalConfig.fromWebConfig(WebConfig config) => JSMsalConfig(
        clientId: config.clientId,
        tenant: config.tenant,
        policy: config.policy,
        isB2C: config.isB2C,
        redirectUri: config.redirectUri,
        cacheLocation: config.cacheLocation.name,
      );
}
