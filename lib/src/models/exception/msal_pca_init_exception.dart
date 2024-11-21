part of 'msal_exception.dart';

/// This exception is created from Dart to validate that application is
/// initialized. SDK will throw this if any method from "PublicClientApplication"
/// class is called without creating the object of it.
class MsalPcaInitException extends MsalException {
  const MsalPcaInitException({required super.message});

  @override
  String toString() {
    return 'MsalPcaInitException { message: $message }';
  }
}
