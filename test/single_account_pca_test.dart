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

  Future<SingleAccountPca> setupAndCreateAndroidPca(WidgetTester tester) async {
    tester.mockRootBundleLoadString(
      mockAndroidConfigPath,
      androidConfigString,
    );
    return SingleAccountPca.create(
      clientId: 'test',
      androidConfig: AndroidConfig(
        configFilePath: mockAndroidConfigPath,
        redirectUri: 'testRedirectUri',
      ),
    );
  }

  group('SingleAccountPca', () {
    group('acquireToken', () {
      testWidgets(
        'throws AssertionError if scopes is empty on iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            return null;
          });
          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );

          expect(
            pca.acquireToken(scopes: const []),
            throwsA(
              isA<AssertionError>().having(
                (e) => e.message,
                'message',
                'Scopes can not be empty',
              ),
            ),
          );
        },
      );

      testWidgets(
        'throws AssertionError if scopes is empty on Android',
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            return null;
          });
          final pca = await setupAndCreateAndroidPca(tester);
          expect(
            pca.acquireToken(scopes: const []),
            throwsA(
              isA<AssertionError>().having(
                (e) => e.message,
                'message',
                'Scopes can not be empty',
              ),
            ),
          );
        },
      );

      testWidgets(
        'calls acquireToken with correct arguments and returns '
        'AuthenticationResult on iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          final expiresOn = DateTime(2024, 12, 2);
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'acquireToken') {
              methodCall = call;
            }
            return {
              'accessToken': 'testAccessToken',
              'authenticationScheme': 'Bearer',
              'expiresOn': expiresOn.millisecondsSinceEpoch,
              'idToken': 'testIdToken',
              'authority': 'testAuthority',
              'tenantId': 'testTenantId',
              'scopes': ['scope1', 'scope2'],
              'correlationId': 'testCorrelationId',
              'account': {
                'id': 'testId',
                'username': 'testUsername',
                'name': 'testName',
              },
            };
          });
          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );
          final result = await pca.acquireToken(
            scopes: const ['scope1', 'scope2'],
            loginHint: 'testLoginHint',
            prompt: Prompt.consent,
          );

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'acquireToken',
                <String, dynamic>{
                  'scopes': ['scope1', 'scope2'],
                  'prompt': 'consent',
                  'loginHint': 'testLoginHint',
                  'broker': 'msAuthenticator',
                },
              ),
            ),
          );
          expect(
            result,
            isA<AuthenticationResult>()
                .having(
                  (r) => r.accessToken,
                  'accessToken',
                  'testAccessToken',
                )
                .having(
                  (r) => r.authenticationScheme,
                  'authenticationScheme',
                  'Bearer',
                )
                .having(
                  (r) => r.expiresOn,
                  'expiresOn',
                  expiresOn,
                )
                .having(
                  (r) => r.idToken,
                  'idToken',
                  'testIdToken',
                )
                .having(
                  (r) => r.authority,
                  'authority',
                  'testAuthority',
                )
                .having(
                  (r) => r.tenantId,
                  'tenantId',
                  'testTenantId',
                )
                .having(
                  (r) => r.scopes,
                  'scopes',
                  const ['scope1', 'scope2'],
                )
                .having(
                  (r) => r.correlationId,
                  'correlationId',
                  'testCorrelationId',
                )
                .having(
                  (r) => r.account,
                  'account',
                  isA<Account>()
                      .having(
                        (a) => a.id,
                        'id',
                        'testId',
                      )
                      .having(
                        (a) => a.username,
                        'username',
                        'testUsername',
                      )
                      .having(
                        (a) => a.name,
                        'name',
                        'testName',
                      ),
                ),
          );
        },
      );

      testWidgets(
        'calls acquireToken with correct arguments and returns '
        'AuthenticationResult on Android',
        (tester) async {
          final expiresOn = DateTime(2024, 12, 2);
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'acquireToken') {
              methodCall = call;
            }
            return {
              'accessToken': 'testAccessToken',
              'authenticationScheme': 'Bearer',
              'expiresOn': expiresOn.millisecondsSinceEpoch,
              'idToken': 'testIdToken',
              'authority': 'testAuthority',
              'tenantId': 'testTenantId',
              'scopes': ['scope1', 'scope2'],
              'correlationId': 'testCorrelationId',
              'account': {
                'id': 'testId',
                'username': 'testUsername',
                'name': 'testName',
              },
            };
          });

          final pca = await setupAndCreateAndroidPca(tester);
          final result = await pca.acquireToken(
            scopes: const ['scope1', 'scope2'],
            loginHint: 'testLoginHint',
            prompt: Prompt.consent,
          );

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'acquireToken',
                <String, dynamic>{
                  'scopes': ['scope1', 'scope2'],
                  'prompt': 'consent',
                  'loginHint': 'testLoginHint',
                  'broker': 'msAuthenticator',
                },
              ),
            ),
          );
          expect(
            result,
            isA<AuthenticationResult>()
                .having(
                  (r) => r.accessToken,
                  'accessToken',
                  'testAccessToken',
                )
                .having(
                  (r) => r.authenticationScheme,
                  'authenticationScheme',
                  'Bearer',
                )
                .having(
                  (r) => r.expiresOn,
                  'expiresOn',
                  expiresOn,
                )
                .having(
                  (r) => r.idToken,
                  'idToken',
                  'testIdToken',
                )
                .having(
                  (r) => r.authority,
                  'authority',
                  'testAuthority',
                )
                .having(
                  (r) => r.tenantId,
                  'tenantId',
                  'testTenantId',
                )
                .having(
                  (r) => r.scopes,
                  'scopes',
                  const ['scope1', 'scope2'],
                )
                .having(
                  (r) => r.correlationId,
                  'correlationId',
                  'testCorrelationId',
                )
                .having(
                  (r) => r.account,
                  'account',
                  isA<Account>()
                      .having(
                        (a) => a.id,
                        'id',
                        'testId',
                      )
                      .having(
                        (a) => a.username,
                        'username',
                        'testUsername',
                      )
                      .having(
                        (a) => a.name,
                        'name',
                        'testName',
                      ),
                ),
          );
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it on iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'acquireToken') {
              throw PlatformException(code: 'testCode', message: 'testMessage');
            }
            return null;
          });
          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );

          expect(
            pca.acquireToken(scopes: const ['scope1', 'scope2']),
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
        'and throws it on Android',
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'acquireToken') {
              throw PlatformException(code: 'testCode', message: 'testMessage');
            }
            return null;
          });
          final pca = await setupAndCreateAndroidPca(tester);

          expect(
            pca.acquireToken(scopes: const ['scope1', 'scope2']),
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

    group('acquireTokenSilent', () {
      testWidgets(
        'throws AssertionError if scopes is empty on iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            return null;
          });
          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );

          expect(
            pca.acquireTokenSilent(scopes: const []),
            throwsA(
              isA<AssertionError>().having(
                (e) => e.message,
                'message',
                'Scopes can not be empty',
              ),
            ),
          );
        },
      );

      testWidgets(
        'throws AssertionError if scopes is empty on Android',
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            return null;
          });
          final pca = await setupAndCreateAndroidPca(tester);
          expect(
            pca.acquireTokenSilent(scopes: const []),
            throwsA(
              isA<AssertionError>().having(
                (e) => e.message,
                'message',
                'Scopes can not be empty',
              ),
            ),
          );
        },
      );

      testWidgets(
        'calls acquireTokenSilent with correct arguments and returns '
        'AuthenticationResult on iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          final expiresOn = DateTime(2024, 12, 2);
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'acquireTokenSilent') {
              methodCall = call;
            }
            return {
              'accessToken': 'testAccessToken',
              'authenticationScheme': 'Bearer',
              'expiresOn': expiresOn.millisecondsSinceEpoch,
              'idToken': 'testIdToken',
              'authority': 'testAuthority',
              'tenantId': 'testTenantId',
              'scopes': ['scope1', 'scope2'],
              'correlationId': 'testCorrelationId',
              'account': {
                'id': 'testId',
                'username': 'testUsername',
                'name': 'testName',
              },
            };
          });
          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );
          final result = await pca.acquireTokenSilent(
            scopes: const ['scope1', 'scope2'],
            identifier: 'testIdentifier',
          );

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'acquireTokenSilent',
                <String, dynamic>{
                  'scopes': ['scope1', 'scope2'],
                  'identifier': 'testIdentifier',
                },
              ),
            ),
          );
          expect(
            result,
            isA<AuthenticationResult>()
                .having(
                  (r) => r.accessToken,
                  'accessToken',
                  'testAccessToken',
                )
                .having(
                  (r) => r.authenticationScheme,
                  'authenticationScheme',
                  'Bearer',
                )
                .having(
                  (r) => r.expiresOn,
                  'expiresOn',
                  expiresOn,
                )
                .having(
                  (r) => r.idToken,
                  'idToken',
                  'testIdToken',
                )
                .having(
                  (r) => r.authority,
                  'authority',
                  'testAuthority',
                )
                .having(
                  (r) => r.tenantId,
                  'tenantId',
                  'testTenantId',
                )
                .having(
                  (r) => r.scopes,
                  'scopes',
                  const ['scope1', 'scope2'],
                )
                .having(
                  (r) => r.correlationId,
                  'correlationId',
                  'testCorrelationId',
                )
                .having(
                  (r) => r.account,
                  'account',
                  isA<Account>()
                      .having(
                        (a) => a.id,
                        'id',
                        'testId',
                      )
                      .having(
                        (a) => a.username,
                        'username',
                        'testUsername',
                      )
                      .having(
                        (a) => a.name,
                        'name',
                        'testName',
                      ),
                ),
          );
        },
      );

      testWidgets(
        'calls acquireTokenSilent with correct arguments and returns '
        'AuthenticationResult on Android',
        (tester) async {
          final expiresOn = DateTime(2024, 12, 2);
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'acquireTokenSilent') {
              methodCall = call;
            }
            return {
              'accessToken': 'testAccessToken',
              'authenticationScheme': 'Bearer',
              'expiresOn': expiresOn.millisecondsSinceEpoch,
              'idToken': 'testIdToken',
              'authority': 'testAuthority',
              'tenantId': 'testTenantId',
              'scopes': ['scope1', 'scope2'],
              'correlationId': 'testCorrelationId',
              'account': {
                'id': 'testId',
                'username': 'testUsername',
                'name': 'testName',
              },
            };
          });

          final pca = await setupAndCreateAndroidPca(tester);
          final result = await pca.acquireTokenSilent(
            scopes: const ['scope1', 'scope2'],
            identifier: 'testIdentifier',
          );

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'acquireTokenSilent',
                <String, dynamic>{
                  'scopes': ['scope1', 'scope2'],
                  'identifier': 'testIdentifier',
                },
              ),
            ),
          );
          expect(
            result,
            isA<AuthenticationResult>()
                .having(
                  (r) => r.accessToken,
                  'accessToken',
                  'testAccessToken',
                )
                .having(
                  (r) => r.authenticationScheme,
                  'authenticationScheme',
                  'Bearer',
                )
                .having(
                  (r) => r.expiresOn,
                  'expiresOn',
                  expiresOn,
                )
                .having(
                  (r) => r.idToken,
                  'idToken',
                  'testIdToken',
                )
                .having(
                  (r) => r.authority,
                  'authority',
                  'testAuthority',
                )
                .having(
                  (r) => r.tenantId,
                  'tenantId',
                  'testTenantId',
                )
                .having(
                  (r) => r.scopes,
                  'scopes',
                  const ['scope1', 'scope2'],
                )
                .having(
                  (r) => r.correlationId,
                  'correlationId',
                  'testCorrelationId',
                )
                .having(
                  (r) => r.account,
                  'account',
                  isA<Account>()
                      .having(
                        (a) => a.id,
                        'id',
                        'testId',
                      )
                      .having(
                        (a) => a.username,
                        'username',
                        'testUsername',
                      )
                      .having(
                        (a) => a.name,
                        'name',
                        'testName',
                      ),
                ),
          );
        },
      );

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it on iOS',
        variant: TargetPlatformVariant.only(TargetPlatform.iOS),
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'acquireTokenSilent') {
              throw PlatformException(code: 'testCode', message: 'testMessage');
            }
            return null;
          });
          final pca = await SingleAccountPca.create(
            clientId: 'test',
            iosConfig: IosConfig(),
          );

          expect(
            pca.acquireTokenSilent(scopes: const ['scope1', 'scope2']),
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
        'and throws it on Android',
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'acquireTokenSilent') {
              throw PlatformException(code: 'testCode', message: 'testMessage');
            }
            return null;
          });
          final pca = await setupAndCreateAndroidPca(tester);

          expect(
            pca.acquireTokenSilent(scopes: const ['scope1', 'scope2']),
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
        'invokes createSingleAccountPca with correct arguments for iOS',
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
        'invokes createSingleAccountPca with correct arguments for Android',
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

          final pca = await SingleAccountPca.create(
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

          expect(pca, isA<SingleAccountPca>());
          expect(
            methodCall,
            equalsMethodCall(
              MethodCall(
                'createSingleAccountPca',
                <String, dynamic>{
                  'config': expectedConfig,
                },
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
              throw PlatformException(code: 'test', message: 'test');
            });
          expect(
            () => SingleAccountPca.create(
              clientId: 'test',
              androidConfig: AndroidConfig(
                configFilePath: mockAndroidConfigPath,
                redirectUri: 'testRedirectUri',
              ),
            ),
            throwsA(isA<MsalException>()),
          );
        },
      );
    });

    group('currentAccount', () {
      testWidgets(
        'calls currentAccount and returns Account on iOS',
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
        'calls currentAccount and returns Account on Android',
        (tester) async {
          MethodCall? methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            if (call.method == 'currentAccount') {
              return <String, dynamic>{
                'id': 'testId',
                'username': 'testUsername',
                'name': 'testName',
              };
            }
            return null;
          });

          final pca = await setupAndCreateAndroidPca(tester);
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
        'and throws it on iOS',
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

      testWidgets(
        'converts PlatformException to MsalException exception '
        'and throws it on Android',
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'currentAccount') {
              throw PlatformException(code: 'test', message: 'test');
            }
            return null;
          });

          final pca = await setupAndCreateAndroidPca(tester);

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
      final signOutResult = ValueVariant<bool>({true, false});
      testWidgets(
        'returns native signOut result on iOS',
        variant: signOutResult,
        (tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
          late MethodCall methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            return signOutResult.currentValue!;
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
          expect(result, signOutResult.currentValue!);
          debugDefaultTargetPlatformOverride = null;
        },
      );

      testWidgets(
        'converts PlatformException to MsalException and throws it on iOS',
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

      testWidgets(
        'returns native signOut result on Android',
        variant: signOutResult,
        (tester) async {
          debugDefaultTargetPlatformOverride = TargetPlatform.android;
          late MethodCall methodCall;
          tester.setMockMethodCallHandler((call) async {
            methodCall = call;
            if (call.method == 'signOut') return signOutResult.currentValue!;
            return null;
          });

          final pca = await setupAndCreateAndroidPca(tester);
          final result = await pca.signOut();

          expect(
            methodCall,
            equalsMethodCall(
              MethodCall('signOut'),
            ),
          );
          expect(result, signOutResult.currentValue!);
          debugDefaultTargetPlatformOverride = null;
        },
      );

      testWidgets(
        'converts PlatformException to MsalException and throws it on Android',
        (tester) async {
          tester.setMockMethodCallHandler((call) async {
            if (call.method == 'signOut') {
              throw PlatformException(code: 'test', message: 'test');
            }
            return null;
          });
          final pca = await setupAndCreateAndroidPca(tester);

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
