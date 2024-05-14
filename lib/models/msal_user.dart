/// Microsoft user details.
class MsalUser {
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

  MsalUser({
    required this.username,
    required this.displayName,
    required this.accessToken,
    required this.tokenCreatedAt,
    required this.tokenExpiresOn,
  });

  factory MsalUser.fromJson(Map<String, dynamic> json) {
    return MsalUser(
      username: json['preferred_username'] ?? '',
      displayName: json['name'] ?? '',
      accessToken: json['access_token'] ?? '',
      tokenCreatedAt: json['iat'] ?? '',
      tokenExpiresOn: json['exp'] ?? '',
    );
  }

  Map<String, dynamic>? toJson() => {
        'username': username,
        'displayName': displayName,
        'accessToken': accessToken,
        'tokenCreatedAt': tokenCreatedAt,
        'tokenExpiresOn': tokenExpiresOn,
      };
}
