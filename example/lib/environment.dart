/// Class that helps easy access to the environment variables.
final class Environment {
  Environment._();

  static const aadClientId = String.fromEnvironment('AAD_CLIENT_ID');
  static const aadAndroidRedirectUri =
      String.fromEnvironment('AAD_ANDROID_REDIRECT_URI');
  static const aadIosAuthority = String.fromEnvironment('AAD_IOS_AUTHORITY');
  static const webRedirectUri = String.fromEnvironment('WEB_REDIRECT_URL');
  static const aadTenantId = String.fromEnvironment('AAD_TENANT_ID');
}
