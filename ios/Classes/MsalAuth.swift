import Flutter
import MSAL

/// Singleton class that manages required objects for [MsalAuthPlugin].
class MsalAuth {
    static var pcaType: PublicClientApplicationType!
    static var publicClientApplication: MSALPublicClientApplication!
    static var broker: String!

    var nativeAuthAccountResult: MSALNativeAuthUserAccountResult?
    var autoSignInAfterSignUp: Bool = false
    var nativeAuthState: MSALNativeAuthBaseState?

    /// Sign up using native auth.
    /// - Parameters:
    ///   - username: Username of the new user.
    ///   - password: Password of the new user.
    ///   - attributes: Attributes of the new user.
    ///   - signInAfterSignUp: Whether to sign in after sign up.
    func signUp(username: String, password: String? = nil, attributes: [String: Any]? = nil, signInAfterSignUp: Bool = false) {
        if let nativeAuth = MsalAuth.publicClientApplication as? MSALNativeAuthPublicClientApplication {
            autoSignInAfterSignUp = signInAfterSignUp
            nativeAuth.signUp(username: username, password: password, attributes: attributes, delegate: self)
        }
    }

    /// Sign in using native auth.
    /// - Parameters:
    ///   - username: Username of the user.
    ///   - password: Password of the user.
    func signIn(username: String, password: String? = nil) {
        if let nativeAuth = MsalAuth.publicClientApplication as? MSALNativeAuthPublicClientApplication {
            nativeAuth.signIn(username: username, password: password, delegate: self)
        }
    }

    /// Submit attributes using native auth.
    /// - Parameter attributes: Attributes to submit.
    func submitAttributes(attributes: [String: Any]) {
        if let state = nativeAuthState as? SignUpAttributesRequiredState {
            state.submitAttributes(attributes: attributes, delegate: self)
        }
    }

    /// Submit code using native auth.
    /// - Parameter code: Code to submit.
    func submitCode(code: String) {
        if let state = nativeAuthState as? SignUpCodeRequiredState {
            state.submitCode(code: code, delegate: self)
        }

        if let state = nativeAuthState as? SignInCodeRequiredState {
            state.submitCode(code: code, delegate: self)
        }
    }

    /// Resend code using native auth.
    func resendCode() {
        if let state = nativeAuthState as? SignUpCodeRequiredState {
            state.resendCode(delegate: self)
        }

        if let state = nativeAuthState as? SignInCodeRequiredState {
            state.resendCode(delegate: self)
        }
    }
}

/// Public client application type.
enum PublicClientApplicationType {
    case single
    case multiple
    case nativeAuth
}

extension MsalAuth: SignUpStartDelegate {
    func onSignUpStartError(error: SignUpStartError) {
        var err: String!
        if error.isUserAlreadyExists {
            err = "Unable to sign up: User already exists"
        } else if error.isInvalidPassword {
            err = "Unable to sign up: The password is invalid"
        } else if error.isInvalidUsername {
            err = "Unable to sign up: The username is invalid"
        } else {
            err = "Unexpected error signing up: \(error.errorDescription ?? "no description")"
        }
        print(err!)
    }

    func onSignUpCodeRequired(
        newState: SignUpCodeRequiredState,
        sentTo: String,
        channelTargetType _: MSALNativeAuthChannelType,
        codeLength _: Int
    ) {
        print("Verification code sent to \(sentTo)")
        nativeAuthState = newState
    }

    func onSignUpAttributesInvalid(attributeNames: [String]) {
        print("Invalid attributes  \(attributeNames)")
    }
}

extension MsalAuth: SignUpVerifyCodeDelegate, SignUpAttributesRequiredDelegate {
    func onSignUpVerifyCodeError(error: VerifyCodeError, newState: SignUpCodeRequiredState?) {
        print("Error verifying code: \(error.errorDescription ?? "no description")")
        nativeAuthState = newState
    }

    func onSignUpAttributesRequiredError(error: AttributesRequiredError) {
        print("Error submitting attributes: \(error.errorDescription ?? "no description")")
    }

    func onSignUpAttributesRequired(newState: SignUpAttributesRequiredState) {
        print("Attributes required")
        nativeAuthState = newState
    }

    func onSignUpAttributesRequired(attributes _: [MSALNativeAuthRequiredAttribute], newState: SignUpAttributesRequiredState) {
        print("Attributes required")
        nativeAuthState = newState
    }

    func onSignUpAttributesInvalid(attributeNames _: [String], newState: SignUpAttributesRequiredState) {
        print("Attributes invalid")
        nativeAuthState = newState
    }

    func onSignUpCompleted(newState: SignInAfterSignUpState) {
        print("Signed up successfully!")
        if autoSignInAfterSignUp {
            newState.signIn(delegate: self)
            return
        }
        MsalAuthStreamHandler.sendEvent(type: "onSignUpSuccess")
    }
}

extension MsalAuth: SignUpResendCodeDelegate, SignInResendCodeDelegate {
    func onSignInResendCodeError(error: ResendCodeError, newState: SignInCodeRequiredState?) {
        print(error.errorDescription ?? "no description")
        nativeAuthState = newState
    }

    func onSignUpResendCodeError(error: ResendCodeError, newState: SignUpCodeRequiredState?) {
        print(error.errorDescription ?? "no description")
        nativeAuthState = newState
    }
}

extension MsalAuth: SignInStartDelegate {
    func onSignInStartError(error: SignInStartError) {
        var err: String!
        if error.isUserNotFound || error.isInvalidUsername {
            err = "Invalid username"
        } else {
            err = "Error signing in: \(error.errorDescription ?? "no description")"
        }
        print(err!)
    }

    func onSignInCodeRequired(
        newState: SignInCodeRequiredState,
        sentTo: String,
        channelTargetType _: MSALNativeAuthChannelType,
        codeLength _: Int
    ) {
        print("Verification code sent to \(sentTo)")
        nativeAuthState = newState
    }
}

extension MsalAuth: SignInVerifyCodeDelegate, SignInAfterSignUpDelegate {
    func onSignInVerifyCodeError(error: VerifyCodeError, newState: SignInCodeRequiredState?) {
        var err: String!

        nativeAuthState = newState

        if error.isInvalidCode {
            // Inform the user that the submitted code was incorrect and ask for a new code to be supplied
//            let userSuppliedCode = retrieveNewCode()
//            newState?.submitCode(code: userSuppliedCode, delegate: self)
        } else {
            err = "Error verifying code: \(error.errorDescription ?? "no description")"
        }
        print(err!)
    }

    func onSignInAfterSignUpError(error _: SignInAfterSignUpError) {
        print("Error signing in after sign up")
    }

    func onSignInCompleted(result: MSALNativeAuthUserAccountResult) {
        print("Signed in successfully.")
        // User successfully signed in
        result.getAccessToken(delegate: self)

        nativeAuthAccountResult = result

        autoSignInAfterSignUp = false
    }
}

extension MsalAuth: CredentialsDelegate {
    func onAccessTokenRetrieveError(error _: RetrieveAccessTokenError) {
        let error = "Error retrieving access token"
        print(error)
    }

    func onAccessTokenRetrieveCompleted(result: MSALNativeAuthTokenResult) {
        let message = "Signed in. Access Token: \(result.accessToken)"

        var resultDict = [
            "accessToken": result.accessToken,
//            "authenticationScheme": nativeAuthAccountResult?.authenticationScheme,
            "expiresOn": Int(result.expiresOn!.timeIntervalSince1970 * 1000.0),
            "idToken": nativeAuthAccountResult?.idToken ?? "",
//            "authority": nativeAuthAccountResult?.authority.url.absoluteString,
//            "tenantId": nativeAuthAccountResult?.tenantProfile.tenantId,
            "scopes": result.scopes,
//            "correlationId": nativeAuthAccountResult?.correlationId.uuidString,
            "account": [
                "id": nativeAuthAccountResult?.account.identifier ?? "",
                "username": nativeAuthAccountResult?.account.username ?? "",
                "name": nativeAuthAccountResult?.account.accountClaims?["name"] ?? "",
            ],
        ] as [String: Any]

        MsalAuthStreamHandler.sendEvent(type: "onSignInSuccess", data: resultDict)
        print(message)
    }
}
