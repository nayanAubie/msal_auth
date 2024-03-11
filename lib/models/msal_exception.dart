/// Main exception class of MSAL auth exception
class MsalException implements Exception {
  final String? errorMessage;

  const MsalException(this.errorMessage);
}

/// User has cancelled the request.
class MsalUserCanceledException extends MsalException {
  const MsalUserCanceledException(super.errorMessage);
}

/// UI prompt is required to get a token
class MsalUiRequiredException extends MsalException {
  const MsalUiRequiredException(super.errorMessage);
}
