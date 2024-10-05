/// Microsoft user details.
class MsalUser {
  /// Azure AD object ID.
  final String oid;

  /// Usually, it's an email address.
  final String username;

  /// Full name registered in the Microsoft account.
  final String displayName;

  /// Authentication token.
  final String accessToken;

  /// Token created time.
  final dynamic tokenCreatedAt;

  /// Token expiration time in "MillisecondsSinceEpoch".
  final int tokenExpiresOn;

  /// Azure AD ID token.
  final String idToken;

  MsalUser({
    required this.oid,
    required this.username,
    required this.displayName,
    required this.accessToken,
    required this.tokenCreatedAt,
    required this.tokenExpiresOn,
    required this.idToken,
  });

  factory MsalUser.fromJson(Map<String, dynamic> json) {
    return MsalUser(
      oid: json['oid'] ?? '',
      username: json['preferred_username'] ?? '',
      displayName: json['name'] ?? '',
      accessToken: json['access_token'] ?? '',
      tokenCreatedAt: json['iat'] ?? '',
      tokenExpiresOn: json['exp'] ?? '',
      idToken: json['id_token'] ?? '',
    );
  }

  Map<String, dynamic>? toJson() => {
        'oid': oid,
        'username': username,
        'displayName': displayName,
        'accessToken': accessToken,
        'tokenCreatedAt': tokenCreatedAt,
        'tokenExpiresOn': tokenExpiresOn,
        'idToken': idToken,
      };
}
