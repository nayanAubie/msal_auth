import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msal_auth/msal_auth.dart';

extension WidgetTesterX on WidgetTester {
  Future<void> setMockMethodCallHandler(
    Future<dynamic> Function(MethodCall) handler,
  ) async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      kMethodChannel,
      handler,
    );
  }
}
