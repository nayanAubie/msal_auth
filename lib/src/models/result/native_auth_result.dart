import 'account.dart';

final class NativeAuthResult {
  /// The access token requested.
  final String accessToken;

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
  final String idToken;

  /// The scopes returned from the service.
  final List<String> scopes;

  /// Microsoft account details.
  final Account account;

  const NativeAuthResult({
    required this.accessToken,
    required this.expiresOn,
    required this.idToken,
    required this.scopes,
    required this.account,
  });

  String get authorizationHeader => accessToken;

  factory NativeAuthResult.fromJson(Map<String, dynamic> json) {
    return NativeAuthResult(
      accessToken: json['accessToken'],
      expiresOn: DateTime.fromMillisecondsSinceEpoch(json['expiresOn']),
      idToken: json['idToken'],
      scopes: json['scopes'].cast<String>(),
      account: Account.fromJson(json['account'].cast<String, dynamic>()),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'expiresOn': expiresOn.millisecondsSinceEpoch,
        'idToken': idToken,
        'scopes': scopes,
        'account': account.toJson(),
      };
}
