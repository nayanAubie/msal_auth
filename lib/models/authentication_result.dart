final class AuthenticationResult {
  /// The access token requested.
  final String accessToken;

  /// Gets the fully-formed Authorization header value.
  /// Includes the Authentication scheme.
  /// Example: Bearer eyJ1aWQiOiJj.......
  final String authorizationHeader;

  /// Gets the authentication scheme (Bearer, PoP, etc)....
  final String authenticationScheme;

  /// The expiration time of the access token returned in the Token property.
  /// This value is calculated based on current UTC time measured locally and
  /// the value expiresIn returned from the service.
  /// Please note that if the authentication scheme is 'pop',
  /// this value reflects the expiry of the 'inner' token returned by AAD and
  /// does not indicate the expiry of the signed pop JWT ('outer' token).
  final DateTime expiresOn;

  /// A unique tenant identifier that was used in token acquisition.
  /// Could be null if tenant information is not returned by the service.
  final String tenantId;

  /// The scopes returned from the service.
  final List<String> scopes;

  /// Gets the correlation id used during the acquire token request.
  /// Could be null if an error occurs when parsing from String or if not set.
  final String correlationId;

  /// Microsoft account details.
  final dynamic account;

  const AuthenticationResult({
    required this.accessToken,
    required this.authorizationHeader,
    required this.authenticationScheme,
    required this.expiresOn,
    required this.tenantId,
    required this.scopes,
    required this.correlationId,
    required this.account,
  });

  factory AuthenticationResult.fromJson(Map<String, dynamic> json) {
    return AuthenticationResult(
      accessToken: json['accessToken'],
      authorizationHeader: json['authorizationHeader'],
      authenticationScheme: json['authenticationScheme'],
      expiresOn: DateTime.fromMillisecondsSinceEpoch(json['expiresOn']),
      tenantId: json['tenantId'],
      scopes: json['scopes'],
      correlationId: json['correlationId'],
      account: json['account'],
    );
  }
}
