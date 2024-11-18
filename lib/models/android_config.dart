/// Configuration class for Android platform.
class AndroidConfig {
  /// Asset path of JSON file.
  final String configFilePath;

  final String redirectUri;

  /// Microsoft tenant ID.
  final String? tenantId;

  AndroidConfig({
    required this.configFilePath,
    required this.redirectUri,
    this.tenantId,
  });
}
