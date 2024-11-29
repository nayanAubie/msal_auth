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
        mapsEqual(expectedMethod.arguments, method.arguments);
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

    if (!mapsEqual(expectedMethod.arguments, method.arguments)) {
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

/// Helper function to compare maps for equality.
bool mapsEqual(Map? map1, Map? map2) {
  if (identical(map1, map2)) return true;
  if (map1 == null || map2 == null) return map1 == map2;
  if (map1.length != map2.length) return false;

  for (final key in map1.keys) {
    if (!map2.containsKey(key)) return false;

    final value1 = map1[key];
    final value2 = map2[key];

    if (value1 is Map && value2 is Map) {
      if (!mapsEqual(value1, value2)) return false;
    } else if (value1 != value2) {
      return false;
    }
  }

  return true;
}
