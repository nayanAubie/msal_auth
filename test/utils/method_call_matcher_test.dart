import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'method_call_matcher.dart';

void main() {
  test('equalsMethodCall', () {
    expect(
      MethodCall('test'),
      equalsMethodCall(MethodCall('test')),
    );

    expect(
      MethodCall('test', <String, dynamic>{'test': 'test'}),
      equalsMethodCall(MethodCall('test', <String, dynamic>{'test': 'test'})),
    );

    expect(
      MethodCall('test'),
      isNot(equalsMethodCall(MethodCall('test2'))),
    );

    expect(
      MethodCall('test', <String, dynamic>{'test': 'test'}),
      isNot(equalsMethodCall(MethodCall('test'))),
    );

    expect(
      MethodCall('test'),
      isNot(equalsMethodCall(MethodCall('test', <String, dynamic>{}))),
    );

    expect(
      'test',
      isNot(equalsMethodCall(MethodCall('test'))),
    );

    expect(
      MethodCall('test', <String, dynamic>{
        'test': 'test',
      }),
      isNot(
        equalsMethodCall(
          MethodCall('test', <String, dynamic>{
            'test2': 'test2',
          }),
        ),
      ),
    );
  });
}
