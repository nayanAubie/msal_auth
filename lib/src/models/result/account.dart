final class Account {
  /// Gets the id of the account.
  /// For the Microsoft Identity Platform: the OID of the account in its home tenant.
  final String id;

  /// Gets the preferred_username claim.
  /// Note: On the Microsoft B2C Identity Platform, this claim may be
  /// unavailable when external identity providers are used.
  final String? username;

  /// Name received from account claims.
  /// It may be null if the user is registered without setting a name.
  final String? name;

  Account({
    required this.id,
    required this.username,
    required this.name,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      username: json['username'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
      };
}
