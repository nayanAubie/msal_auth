/// Authentication methods for Native Auth Public Client Application.
enum ChallengeType {
  /// This challenge type indicates that the app supports the collection of a password credential from the user.
  password,

  /// This challenge type indicates that the application supports the use of one-time password or passcode (OTP) codes sent to the user using a secondary channel. Currently, the API supports only email OTP.
  oob,
}
