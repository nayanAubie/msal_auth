import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msal_auth/msal_auth.dart';

import 'utils/method_call_matcher.dart';
import 'utils/widget_tester_extensions.dart';

void main() {
  group('SingleAccountPca', () {
    group('create', () {
      testWidgets(
        'throws AssertionError if androidConfig is null on Android platform',
        variant: TargetPlatformVariant.only(TargetPlatform.android),
        (tester) async {
          expect(
            () => SingleAccountPca.create(clientId: 'test'),
            throwsA(
              isA<AssertionError>().having(
                (e) => e.message,
                'message',
                'Android config can not be null',
              ),
            ),
          );
        },
      );

      testWidgets(
        'throws AssertionError if iosConfig is null on iOS platform',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          expect(
            () => SingleAccountPca.create(clientId: 'test'),
            throwsA(
              isA<AssertionError>().having(
                (e) => e.message,
                'message',
                'iOS config can not be null',
              ),
            ),
          );
        },
      );

      testWidgets(
        'invokes createSingleAccountPca with correct arguments',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return null;
          });
          final pca = await SingleAccountPca.create(
            clientId: 'testId',
            iosConfig: IosConfig(
              authority: 'testAuthority',
            ),
          );

          expect(pca, isA<SingleAccountPca>());
          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'createSingleAccountPca',
                <String, dynamic>{
                  'clientId': 'testId',
                  'authority': 'testAuthority',
                  'broker': 'msAuthenticator',
                  'authorityType': 'aad',
                },
              ),
            ),
          );
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            throw PlatformException(
              code: 'test',
              message: 'test',
            );
          });
          expect(
            () => SingleAccountPca.create(
              clientId: 'test',
              iosConfig: IosConfig(),
            ),
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'test',
              ),
            ),
          );
        },
      );
    });

    group('currentAccount', () {
      testWidgets(
        'calls currentAccount and returns Account',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return <String, dynamic>{
              'id': 'testId',
              'username': 'testUsername',
              'name': 'testName',
            };
          });
          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );
          final account = await pca.currentAccount;

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall('currentAccount'),
            ),
          );

          expect(account.id, 'testId');
          expect(account.username, 'testUsername');
          expect(account.name, 'testName');
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'currentAccount') {
              throw PlatformException(code: 'test', message: 'test');
            }
            return null;
          });
          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );

          expect(
            pca.currentAccount,
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'test',
              ),
            ),
          );
        },
      );
    });

    group('signOut', () {
      testWidgets(
        'signs out current account successfully',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          late MethodCall methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return true;
          });

          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );
          final result = await pca.signOut();

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall('signOut'),
            ),
          );

          expect(result, true);
        },
      );

      testWidgets(
        'returns false if native signOut returns false',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          late MethodCall methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return false;
          });

          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );
          final result = await pca.signOut();

          expect(
            methodCall,
            equalsMethodCall(MethodCall('signOut')),
          );
          expect(result, false);
        },
      );

      testWidgets(
        'converts PlatformException to MsalException and throws it',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'signOut') {
              throw PlatformException(code: 'test', message: 'test');
            }
            return null;
          });

          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );

          expect(
            pca.signOut,
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'test',
              ),
            ),
          );
        },
      );
    });
  });
}
