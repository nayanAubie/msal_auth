import 'account.dart';

final class AuthenticationResult {
  /// The access token requested.
  final String accessToken;

  /// Gets the authentication scheme (Bearer, PoP, etc)....
  final String authenticationScheme;

  /// The expiration time of the access token returned in the Token property.
  /// This value is calculated based on current UTC time measured locally and
  /// the value expiresIn returned from the service.
  /// Please note that if the authentication scheme is 'pop',
  /// this value reflects the expiry of the 'inner' token returned by AAD and
  /// does not indicate the expiry of the signed pop JWT ('outer' token).
  final DateTime expiresOn;

  /// Gets the JWT format id_token. This value conforms to "RFC-7519" and
  /// is further specified according to "OpenID Connect Core".
  /// Note: MSAL does not validate the JWT token.
  final String? idToken;

  /// Authority used in creating the app.
  final String authority;

  /// A unique tenant identifier that was used in token acquisition.
  /// Could be null if tenant information is not returned by the service.
  final String? tenantId;

  /// The scopes returned from the service.
  final List<String> scopes;

  /// Gets the correlation id used during the acquire token request.
  /// Could be null if an error occurs when parsing from String or if not set.
  final String? correlationId;

  /// Microsoft account details.
  final Account account;

  const AuthenticationResult({
    required this.accessToken,
    required this.authenticationScheme,
    required this.expiresOn,
    required this.idToken,
    required this.authority,
    required this.tenantId,
    required this.scopes,
    required this.correlationId,
    required this.account,
  });

  String get authorizationHeader => '$authenticationScheme $accessToken';

  factory AuthenticationResult.fromJson(Map<String, dynamic> json) {
    return AuthenticationResult(
      accessToken: json['accessToken'],
      authenticationScheme: json['authenticationScheme'],
      expiresOn: DateTime.fromMillisecondsSinceEpoch(json['expiresOn']),
      idToken: json['idToken'],
      authority: json['authority'],
      tenantId: json['tenantId'],
      scopes: json['scopes'].cast<String>(),
      correlationId: json['correlationId'],
      account: Account.fromJson(json['account'].cast<String, dynamic>()),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'authenticationScheme': authenticationScheme,
        'expiresOn': expiresOn.millisecondsSinceEpoch,
        'idToken': idToken,
        'authority': authority,
        'tenantId': tenantId,
        'scopes': scopes,
        'correlationId': correlationId,
        'account': account.toJson(),
      };
}
