final class Account {
  /// Gets the id of the account.
  /// For the Microsoft Identity Platform: the OID of the account in its home tenant.
  final String id;

  /// Gets the JWT format id_token. This value conforms to "RFC-7519" and
  /// is further specified according to "OpenID Connect Core".
  /// Note: MSAL does not validate the JWT token.
  final String idToken;

  /// Gets the preferred_username claim.
  /// Note: On the Microsoft B2C Identity Platform, this claim may be
  /// unavailable when external identity providers are used.
  final String? username;

  /// Name received from account claims.
  final String name;

  /// Authority used in creating the app.
  final String authority;

  Account({
    required this.id,
    required this.idToken,
    required this.username,
    required this.name,
    required this.authority,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      idToken: json['idToken'],
      username: json['username'],
      name: json['name'],
      authority: json['authority'],
    );
  }
}
