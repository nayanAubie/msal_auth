import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msal_auth/msal_auth.dart';

import 'data/test_data.dart';
import 'utils/method_call_matcher.dart';
import 'utils/widget_tester_extensions.dart';

void main() {
  const mockAndroidConfigPath = 'some_path/android_config.json';

  tearDown(rootBundle.clear);

  Future<MultipleAccountPca> setupAndCreateAndroidPca(
    WidgetTester tester,
  ) async {
    tester.mockRootBundleLoadString(
      mockAndroidConfigPath,
      androidConfigString,
    );
    return MultipleAccountPca.create(
      clientId: 'test',
      androidConfig: AndroidConfig(
        configFilePath: mockAndroidConfigPath,
        redirectUri: 'testRedirectUri',
      ),
    );
  }

  group('MultipleAccountPca', () {
    group('create', () {
      testWidgets(
        'throws AssertionError if androidConfig is null on Android platform',
        (tester) async {
          expect(
            () => MultipleAccountPca.create(clientId: 'test'),
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
            () => MultipleAccountPca.create(clientId: 'test'),
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
        'invokes createMultipleAccountPca with correct arguments for Android',
        (tester) async {
          tester.mockRootBundleLoadString(
            mockAndroidConfigPath,
            androidConfigString,
          );
          final androidConfig =
              jsonDecode(androidConfigString) as Map<String, dynamic>;
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return null;
          });

          final pca = await MultipleAccountPca.create(
            clientId: 'testId',
            androidConfig: AndroidConfig(
              configFilePath: mockAndroidConfigPath,
              redirectUri: 'testRedirectUri',
            ),
          );
          final expectedConfig = androidConfig
            ..addAll({
              'client_id': 'testId',
              'redirect_uri': 'testRedirectUri',
            });

          expect(pca, isA<MultipleAccountPca>());
          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'createMultipleAccountPca',
                <String, dynamic>{
                  'config': expectedConfig,
                },
              ),
            ),
          );
        },
      );

      testWidgets(
        'invokes createMultipleAccountPca with correct arguments for iOS',
        skip: true,
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return null;
          });
          final pca = await MultipleAccountPca.create(
            clientId: 'testId',
            iosConfig: IosConfig(
              authority: 'testAuthority',
            ),
          );

          expect(pca, isA<MultipleAccountPca>());
          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'createMultipleAccountPca',
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
        'and throws it for Android',
        (tester) async {
          tester
            ..mockRootBundleLoadString(
              mockAndroidConfigPath,
              androidConfigString,
            )
            ..setMockMethodCallHandler((call) async {
              throw PlatformException(code: 'testCode', message: 'testMessage');
            });

          expect(
            () => MultipleAccountPca.create(
              clientId: 'testId',
              androidConfig: AndroidConfig(
                configFilePath: mockAndroidConfigPath,
                redirectUri: 'testRedirectUri',
              ),
            ),
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'testMessage',
              ),
            ),
          );
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it for iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            throw PlatformException(
              code: 'testCode',
              message: 'testMessage',
            );
          });

          expect(
            () => MultipleAccountPca.create(
              clientId: 'testId',
              iosConfig: IosConfig(),
            ),
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'testMessage',
              ),
            ),
          );
        },
      );
    });

    group('getAccount', () {
      testWidgets(
        'calls getAccount with identifier and returns Account on Android',
        (tester) async {
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            if (call.method == 'getAccount' &&
                call.arguments == 'testIdentifier') {
              return <String, dynamic>{
                'id': 'testId',
                'username': 'testUsername',
                'name': 'testName',
              };
            }
            return null;
          });
          final pca = await setupAndCreateAndroidPca(tester);

          final account = await pca.getAccount(identifier: 'testIdentifier');

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'getAccount',
                'testIdentifier',
              ),
            ),
          );

          expect(account.id, 'testId');
          expect(account.username, 'testUsername');
          expect(account.name, 'testName');
        },
      );

      testWidgets(
        'calls getAccount with identifier and returns Account on iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            if (call.method == 'getAccount' &&
                call.arguments == 'testIdentifier') {
              return <String, dynamic>{
                'id': 'testId',
                'username': 'testUsername',
                'name': 'testName',
              };
            }
            return null;
          });
          final pca = await MultipleAccountPca.create(
            clientId: 'testId',
            iosConfig: IosConfig(),
          );

          final account = await pca.getAccount(identifier: 'testIdentifier');

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'getAccount',
                'testIdentifier',
              ),
            ),
          );

          expect(account.id, 'testId');
          expect(account.username, 'testUsername');
          expect(account.name, 'testName');
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it for Android',
        (tester) async {
          tester
            ..mockRootBundleLoadString(
              mockAndroidConfigPath,
              androidConfigString,
            )
            ..setMockMethodCallHandler((call) async {
              if (call.method == 'getAccount') {
                throw PlatformException(
                  code: 'testCode',
                  message: 'testMessage',
                );
              }
              return null;
            });
          final pca = await setupAndCreateAndroidPca(tester);

          expect(
            () => pca.getAccount(identifier: 'testIdentifier'),
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'testMessage',
              ),
            ),
          );
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it for iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'getAccount') {
              throw PlatformException(
                code: 'testCode',
                message: 'testMessage',
              );
            }
            return null;
          });
          final pca = await MultipleAccountPca.create(
            clientId: 'testId',
            iosConfig: IosConfig(),
          );

          expect(
            () => pca.getAccount(identifier: 'testIdentifier'),
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'testMessage',
              ),
            ),
          );
        },
      );
    });

    group('getAccounts', () {
      testWidgets(
        'calls getAccounts and returns list of Account on Android',
        (tester) async {
          MethodCall? methodCall;
          tester
            ..mockRootBundleLoadString(
              mockAndroidConfigPath,
              androidConfigString,
            )
            ..setMockMethodCallHandler((call) async {
              methodCall = call;
              return [
                <String, dynamic>{
                  'id': 'testId',
                  'username': 'testUsername',
                  'name': 'testName',
                },
                <String, dynamic>{
                  'id': 'testId2',
                  'username': 'testUsername2',
                  'name': 'testName2',
                },
              ];
            });
          final pca = await setupAndCreateAndroidPca(tester);
          final accounts = await pca.getAccounts();

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall('getAccounts'),
            ),
          );

          expect(accounts.length, 2);

          final account1 = accounts[0];
          expect(account1.id, 'testId');
          expect(account1.username, 'testUsername');
          expect(account1.name, 'testName');

          final account2 = accounts[1];
          expect(account2.id, 'testId2');
          expect(account2.username, 'testUsername2');
          expect(account2.name, 'testName2');
        },
      );

      testWidgets(
        'calls getAccounts and returns list of Account on iOS',
        skip: true,
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return [
              <String, dynamic>{
                'id': 'testId',
                'username': 'testUsername',
                'name': 'testName',
              },
              <String, dynamic>{
                'id': 'testId2',
                'username': 'testUsername2',
                'name': 'testName2',
              },
            ];
          });
          final pca = await MultipleAccountPca.create(
            clientId: 'testId',
            iosConfig: IosConfig(),
          );
          final accounts = await pca.getAccounts();

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall('getAccounts'),
            ),
          );

          expect(accounts.length, 2);

          final account1 = accounts[0];
          expect(account1.id, 'testId');
          expect(account1.username, 'testUsername');
          expect(account1.name, 'testName');

          final account2 = accounts[1];
          expect(account2.id, 'testId2');
          expect(account2.username, 'testUsername2');
          expect(account2.name, 'testName2');
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it for Android',
        (tester) async {
          tester
            ..mockRootBundleLoadString(
              mockAndroidConfigPath,
              androidConfigString,
            )
            ..setMockMethodCallHandler((call) async {
              if (call.method == 'getAccounts') {
                throw PlatformException(
                  code: 'testCode',
                  message: 'testMessage',
                );
              }
              return null;
            });
          final pca = await setupAndCreateAndroidPca(tester);

          expect(
            pca.getAccounts,
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'testMessage',
              ),
            ),
          );
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it for iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'getAccounts') {
              throw PlatformException(
                code: 'testCode',
                message: 'testMessage',
              );
            }
            return null;
          });
          final pca = await MultipleAccountPca.create(
            clientId: 'testId',
            iosConfig: IosConfig(),
          );

          expect(
            pca.getAccounts,
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'testMessage',
              ),
            ),
          );
        },
      );
    });

    group('removeAccount', () {
      final resultVariant = ValueVariant<bool>({true, false});
      testWidgets(
        'calls removeAccount with identifier and returns result on Android',
        variant: resultVariant,
        (tester) async {
          final result = resultVariant.currentValue!;
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return result;
          });
          final pca = await setupAndCreateAndroidPca(tester);
          final removed = await pca.removeAccount(identifier: 'testIdentifier');

          expect(removed, result);
          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'removeAccount',
                'testIdentifier',
              ),
            ),
          );
        },
      );

      testWidgets(
        'calls removeAccount with identifier and returns result on iOS',
        variant: resultVariant,
        (tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
          final result = resultVariant.currentValue!;
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return result;
          });
          final pca = await MultipleAccountPca.create(
            clientId: 'testId',
            iosConfig: IosConfig(),
          );
          final removed = await pca.removeAccount(identifier: 'testIdentifier');

          expect(removed, result);
          expect(
            methodCall,
            equalsMethodCall(
              MethodCall('removeAccount', 'testIdentifier'),
            ),
          );
          debugDefaultTargetPlatformOverride = null;
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it for Android',
        (tester) async {
          tester
            ..mockRootBundleLoadString(
              mockAndroidConfigPath,
              androidConfigString,
            )
            ..setMockMethodCallHandler((call) async {
              if (call.method == 'removeAccount') {
                throw PlatformException(
                  code: 'testCode',
                  message: 'testMessage',
                );
              }
              return null;
            });
          final pca = await setupAndCreateAndroidPca(tester);

          expect(
            pca.removeAccount(identifier: 'testIdentifier'),
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'testMessage',
              ),
            ),
          );
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it for iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'removeAccount') {
              throw PlatformException(code: 'testCode', message: 'testMessage');
            }
            return null;
          });
          final pca = await MultipleAccountPca.create(
            clientId: 'testId',
            iosConfig: IosConfig(),
          );

          expect(
            pca.removeAccount(identifier: 'testIdentifier'),
            throwsA(
              isA<MsalException>().having(
                (e) => e.message,
                'message',
                'testMessage',
              ),
            ),
          );
        },
      );
    });
  });
}
