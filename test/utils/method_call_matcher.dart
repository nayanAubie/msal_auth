import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher equalsMethodCall(MethodCall method) {
  return MethodCallMatcher(method);
}

class MethodCallMatcher extends Matcher {
  const MethodCallMatcher(this.method);

  final MethodCall method;

  @override
  bool matches(Object? expectedMethod, Map<dynamic, dynamic> matchState) {
    return expectedMethod is MethodCall &&
        expectedMethod.method == method.method &&
        DeepCollectionEquality()
            .equals(expectedMethod.arguments, method.arguments);
  }

  @override
  Description describe(Description description) {
    return description.add('method call $method');
  }

  @override
  Description describeMismatch(
    Object? expectedMethod,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (expectedMethod is! MethodCall) {
      return mismatchDescription.add(
        'expected MethodCall, but was ${expectedMethod.runtimeType}',
      );
    }

    if (expectedMethod.method != method.method) {
      return mismatchDescription.add(
        'expected method ${method.method}, but was ${expectedMethod.method}',
      );
    }

    if (!DeepCollectionEquality()
        .equals(expectedMethod.arguments, method.arguments)) {
      return mismatchDescription.add(
        'expected arguments ${method.arguments}, '
        'but was ${expectedMethod.arguments}',
      );
    }

    return mismatchDescription.add(
      'expected $method, but was $expectedMethod',
    );
  }
}
