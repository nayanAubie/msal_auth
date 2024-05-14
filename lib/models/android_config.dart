/// Configuration class for Android platform.
class AndroidConfig {
  /// Asset path of JSON file.
  final String configFilePath;
  /// Microsoft tenant ID.
  final String? tenantId;

  AndroidConfig({required this.configFilePath, this.tenantId});
}
