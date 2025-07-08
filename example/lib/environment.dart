/// Class that helps easy access to the environment variables.
final class Environment {
  Environment._();

  static const aadClientId = String.fromEnvironment('AAD_CLIENT_ID');
  static const aadDebugAndroidRedirectUri =
      String.fromEnvironment('AAD_DEBUG_ANDROID_REDIRECT_URI');
  static const aadReleaseAndroidRedirectUri =
      String.fromEnvironment('AAD_RELEASE_ANDROID_REDIRECT_URI');
  static const aadIosAuthority = String.fromEnvironment('AAD_APPLE_AUTHORITY');
}
