import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msal_auth/msal_auth.dart';

extension WidgetTesterX on WidgetTester {
  void setMockMethodCallHandler(
    Future<dynamic> Function(MethodCall) handler,
  ) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      kMethodChannel,
      handler,
    );
  }

  void mockRootBundleLoadString(String path, String content) {
    binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async => Future.value(
        ByteData.sublistView(Uint8List.fromList(content.codeUnits)),
      ),
    );
  }
}
