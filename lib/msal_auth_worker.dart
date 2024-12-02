import 'dart:async';

import 'msal_auth.dart';
import 'src/models/result/native_auth_result.dart';

// ignore_for_file: use_setters_to_change_properties

/// Msal Auth main bridge as a listener from native side.
class MsalAuthWorker {
  MsalAuthWorker() {
    _eventBroadcast = kEventChannel.receiveBroadcastStream().listen((event) {
      final receivedChannelType = event['type'];
      switch (receivedChannelType) {
        case 'onSignInSuccess':
          _onSignInSuccess?.call(
            NativeAuthResult.fromJson(
              event['data'] as Map<String, dynamic>,
            ),
          );
        case 'onSignUpSuccess':
          _onSignUpSuccess?.call();
        case 'onNativeAuthError':
          _onNativeAuthError?.call();
        default:
          break;
      }
    });
  }

  /// Msal Auth main bridge as a listener from native side.
  late final StreamSubscription<dynamic>? _eventBroadcast;

  /// A function that will be called when the `onSignInSuccess` event is received from Native side.
  static Function(NativeAuthResult)? _onSignInSuccess;

  /// A function that will be called when the `onSignUpSuccess` event is received from Native side.
  static Function()? _onSignUpSuccess;

  /// A function that will be called when the `onNativeAuthError` event is received from Native side.
  static Function()? _onNativeAuthError;

  /// A function that will disconnect all event listeners from Native side. The action
  /// will be irrevocable, and a new [MsalAuthWorker] instance must be created after this.
  ///
  /// [!] It is not recommended to use this function if you do not know what you are doing.
  void closeConnection() {
    _eventBroadcast?.cancel();
  }

  /// A function that will resume the paused all event listeners from Native side.
  void resumeConnection() {
    _eventBroadcast?.resume();
  }

  /// A function that will pause the all active event listeners from Native side.
  void pauseConnection() {
    _eventBroadcast?.pause();
  }

  /// A function that will add a listener for the `onSignInSuccess` event from Native side.
  void addListenerOnSignInSuccess(
    Function(NativeAuthResult) onSignInSuccess,
  ) {
    _onSignInSuccess = onSignInSuccess;
  }

  /// A function that will remove a listener for the `onSignInSuccess` event from Native side.
  void removeListenerOnSignInSuccess() {
    _onSignInSuccess = null;
  }

  /// A function that will add a listener for the `onSignUpSuccess` event from Native side.
  void addListenerOnSignUpSuccess(Function() onSignUpSuccess) {
    _onSignUpSuccess = onSignUpSuccess;
  }

  /// A function that will remove a listener for the `onSignUpSuccess` event from Native side.
  void removeListenerOnSignUpSuccess() {
    _onSignUpSuccess = null;
  }

  /// A function that will add a listener for the `onNativeAuthError` event from Native side.
  void addListenerOnNativeAuthError(Function() onNativeAuthError) {
    _onNativeAuthError = onNativeAuthError;
  }

  /// A function that will remove a listener for the `onNativeAuthError` event from Native side.
  void removeListenerOnNativeAuthError() {
    _onNativeAuthError = null;
  }
}
