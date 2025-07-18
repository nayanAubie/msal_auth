import Cocoa
import FlutterMacOS
import MSAL

public class MsalAuthPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "msal_auth", binaryMessenger: registrar.messenger)
        let instance = MsalAuthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(
        _ call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        switch call.method {
        case "createSingleAccountPca", "createMultipleAccountPca":
            guard let dict = call.arguments as? NSDictionary,
                let pcaType: PublicClientApplicationType = {
                    switch call.method {
                    case "createSingleAccountPca": return .single
                    default: return .multiple
                    }
                }(),
                let clientId = dict["clientId"] as? String,
                    let authorityType: AuthorityType = {
                        switch call.method {
                        case "b2c": return .b2c
                        default: return .aad
                        }
                    }()
            else {
                setInternalError(methodName: call.method, result: result)
                return
            }

            MsalAuth.authorityType = authorityType
            let authority = dict["authority"] as? String

            createPublicClientApplication(
                pcaType: pcaType,
                clientId: clientId, authority: authority,
                authorityType: authorityType,
                result: result)
        case "acquireToken":
            guard let dict = call.arguments as? NSDictionary,
                let scopes = dict["scopes"] as? [String],
                let prompt = dict["prompt"] as? String,
                let promptType: MSALPromptType = {
                    switch prompt {
                    case "selectAccount": return .selectAccount
                    case "login": return .login
                    case "consent": return .consent
                    case "create": return .create
                    case "whenRequired": return .promptIfNecessary
                    default: return .default
                    }
                }()
            else {
                setInternalError(methodName: call.method, result: result)
                return
            }

            let loginHint = dict["loginHint"] as? String
            let authority = dict["authority"] as? String

            acquireToken(
                scopes: scopes, promptType: promptType, loginHint: loginHint, authority: authority,
                result: result)
        case "acquireTokenSilent":
            guard let dict = call.arguments as? NSDictionary,
                let scopes = dict["scopes"] as? [String]
            else {
                setInternalError(methodName: call.method, result: result)
                return
            }

            let identifier = dict["identifier"] as? String
            let authority = dict["authority"] as? String

            acquireTokenSilent(
                scopes: scopes, identifier: identifier, authority: authority, result: result)

        case "currentAccount": getCurrentAccount(result: result)

        case "signOut": signOut(result: result)

        case "getAccount":
            guard let identifier = call.arguments as? String else {
                setInternalError(methodName: call.method, result: result)
                return
            }

            getAccount(identifier: identifier, result: result)

        case "getAccounts": getAccounts(result: result)

        case "removeAccount":
            guard let identifier = call.arguments as? String else {
                setInternalError(methodName: call.method, result: result)
                return
            }
            removeAccount(identifier: identifier, result: result)

        default: result(FlutterMethodNotImplemented)
        }
    }

    /// Creates public client application object.
    /// - Parameters:
    ///   - pcaType: Public client application type.
    ///   - clientId: Client ID from Azure Portal.
    ///   - authority: Authority URL.
    ///   - authorityType: Authority type.
    ///   - result: Result of the method call.
    private func createPublicClientApplication(
        pcaType: PublicClientApplicationType,
        clientId: String, authority: String?,
        authorityType: AuthorityType,
        result: @escaping FlutterResult
    ) {
        var pcaConfig: MSALPublicClientApplicationConfig!

        if authority != nil {
            guard let authorityUrl = URL(string: authority!) else {
                result(
                    FlutterError(
                        code: "INVALID_AUTHORITY",
                        message: "invalid authority URL has been provided",
                        details: nil))
                return
            }

            do {
                switch authorityType {
                case .b2c:
                    let b2cAuthority = try MSALB2CAuthority(url: authorityUrl)
                    pcaConfig = MSALPublicClientApplicationConfig(
                        clientId: clientId, redirectUri: nil,
                        authority: b2cAuthority)
                    pcaConfig.knownAuthorities = [b2cAuthority]
                default:
                    let defaultAuthority = try MSALAuthority(url: authorityUrl)
                    pcaConfig = MSALPublicClientApplicationConfig(
                        clientId: clientId, redirectUri: nil,
                        authority: defaultAuthority)
                }
            } catch let error as NSError {
                setMsalError(error: error, result: result)
            }
        } else {
            pcaConfig = MSALPublicClientApplicationConfig(clientId: clientId)
        }

        if let application = try? MSALPublicClientApplication(
            configuration: pcaConfig)
        {
            // We will only have a public client application object. Apple MSAL does not have specific class for different account mode (Single & multiple). So we just assigned type that we receives from Dart and then call methods as per the type.
            MsalAuth.publicClientApplication = application
            MsalAuth.pcaType = pcaType
            result(true)
        } else {
            // Sets initialization error. This is a custom exception created at Dart side.
            result(
                FlutterError(
                    code: "PCA_INIT",
                    message: "Unable to create public client application",
                    details: nil))
        }
    }

    /// Acquires token from public client application.
    /// - Parameters:
    ///   - scopes: Scopes to be requested.
    ///   - promptType: Prompt type.
    ///   - loginHint: Login hint.
    ///   - authority: Authority URL to override default authority.
    ///   - result: Result of the method call.
    private func acquireToken(
        scopes: [String], promptType: MSALPromptType, loginHint: String?, authority: String?,
        result: @escaping FlutterResult
    ) {
        guard let pca = MsalAuth.publicClientApplication else {
            setPcaInitError(methodName: "acquireToken", result: result)
            return
        }
        
        guard let mainWindow = NSApplication.shared.mainWindow,
              let viewController = mainWindow.contentViewController else {
            result(
                FlutterError(
                    code: "UI_UNAVAILABLE",
                    message: "Cannot present authentication UI. The view controller is not available.",
                    details: nil))
            return
        }

        let webViewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        webViewParameters.prefersEphemeralWebBrowserSession = true

        let tokenParams = MSALInteractiveTokenParameters(
            scopes: scopes, webviewParameters: webViewParameters)

        tokenParams.promptType = promptType
        tokenParams.loginHint = loginHint
        
        if let authority = authority {
            do {
                let msalAuthority = try getMsalAuthority(authority: authority)
                tokenParams.authority = msalAuthority
            } catch let error as NSError {
                setMsalError(error: error, result: result)
                return
            }
        }

        pca.acquireToken(
            with: tokenParams,
            completionBlock: { (msalresult, error) in
                guard let msalResult = msalresult else {

                    guard let error = error as NSError? else { return }

                    self.setMsalError(error: error, result: result)

                    return
                }

                result(self.getAuthResult(msalResult))
            })
    }

    /// Acquires token from public client application.
    /// - Parameters:
    ///   - scopes: Scopes to be requested.
    ///   - identifier: Account identifier.
    ///   - authority: Authority URL to override cached account's authority.
    ///   - result: Result of the method call.
    private func acquireTokenSilent(
        scopes: [String], identifier: String? = nil, authority: String?,
        result: @escaping FlutterResult
    ) {
        guard let pca = MsalAuth.publicClientApplication else {
            setPcaInitError(methodName: "acquireTokenSilent", result: result)
            return
        }

        var account: MSALAccount!

        if MsalAuth.pcaType == PublicClientApplicationType.single {
            account = getCurrentAccount()
        } else {
            account = getAccount(identifier: identifier!)
        }

        guard let account else {
            setNoCurrentAccountError(result: result)
            return
        }

        let silentParams = MSALSilentTokenParameters(
            scopes: scopes, account: account)
        
        if let authority = authority {
            do {
                let msalAuthority = try getMsalAuthority(authority: authority)
                silentParams.authority = msalAuthority
            } catch let error as NSError {
                setMsalError(error: error, result: result)
                return
            }
        }

        pca.acquireTokenSilent(
            with: silentParams,
            completionBlock: { (msalResult, error) in

                guard let msalResult = msalResult else {

                    guard let error = error as NSError? else { return }

                    self.setMsalError(error: error, result: result)

                    return
                }

                result(self.getAuthResult(msalResult))
            })
    }

    /// Returns current account. used with single account mode.
    /// - Parameter result: Result of the method call.
    @discardableResult
    private func getCurrentAccount(result: FlutterResult? = nil) -> MSALAccount?
    {
        guard let pca = MsalAuth.publicClientApplication else {
            if result != nil {
                setPcaInitError(
                    methodName: "getCurrentAccount", result: result!)
            }
            return nil
        }

        var account: MSALAccount!

        pca.getCurrentAccount(with: MSALParameters()) {
            current, previous, error in
            if let current {
                account = current
                result?(self.getCurrentAccountDic(current))
                return
            }

            if let result {
                if let error = error as NSError? {
                    self.setMsalError(error: error, result: result)
                    return
                }

                self.setNoCurrentAccountError(result: result)
            }
        }
        return account
    }

    /// Signs out from public client application. used with single account mode.
    /// - Parameter result: Result of the method call.
    private func signOut(result: @escaping FlutterResult) {
        guard let pca = MsalAuth.publicClientApplication else {
            setPcaInitError(methodName: "signOut", result: result)
            return
        }

        if let currentAccount = getCurrentAccount() {
            pca.signout(
                with: currentAccount, signoutParameters: MSALSignoutParameters()
            ) { success, error in
                guard let error else {
                    result(success)
                    return
                }

                if let error = error as NSError? {
                    self.setMsalError(error: error, result: result)
                }
            }
        } else {
            setNoCurrentAccountError(result: result)
        }
    }

    /// Returns account with given identifier. used with multiple account mode.
    /// - Parameters:
    ///   - identifier: Account identifier.
    ///   - result: Result of the method call.
    @discardableResult
    private func getAccount(identifier: String, result: FlutterResult? = nil)
        -> MSALAccount?
    {
        guard let pca = MsalAuth.publicClientApplication else {
            if result != nil {
                setPcaInitError(methodName: "getAccount", result: result!)
            }
            return nil
        }

        do {
            return try pca.account(forIdentifier: identifier)
        } catch let error as NSError {
            if result != nil {
                setMsalError(error: error, result: result!)
            }
            return nil
        }
    }

    /// Returns all accounts from public client application. used with multiple account mode.
    /// - Parameter result: Result of the method call.
    private func getAccounts(result: @escaping FlutterResult) {
        guard let pca = MsalAuth.publicClientApplication else {
            setPcaInitError(methodName: "getAccounts", result: result)
            return
        }

        do {
            let accounts = try pca.allAccounts()
            result(accounts.map { getCurrentAccountDic($0) })
        } catch let error as NSError {
            setMsalError(error: error, result: result)
        }
    }

    /// Removes account from public client application. used with multiple account mode.
    /// - Parameters:
    ///   - identifier: Account identifier.
    ///   - result: Result of the method call.
    private func removeAccount(
        identifier: String, result: @escaping FlutterResult
    ) {
        let account = getAccount(identifier: identifier)

        guard let account else {
            setNoCurrentAccountError(result: result)
            return
        }

        do {
            try MsalAuth.publicClientApplication.remove(account)
            result(true)
        } catch let error as NSError {
            setMsalError(error: error, result: result)
        }
    }
}

// MARK: - MsalAuthPlugin
extension MsalAuthPlugin {
    /// Returns the object of MSAL Authority based on the authority type.
    /// - Parameter authority: authority URL in string.
    /// - Returns: `MSALAuthority`.
    fileprivate func getMsalAuthority(authority: String) throws -> MSALAuthority {
        switch (MsalAuth.authorityType) {
            case .b2c:
            return try MSALB2CAuthority(url: URL(string: authority)!)
        default:
            return try MSALAuthority(url: URL(string: authority)!)
        }
    }
    
    /// Returns auth result dictionary. used to set result to Dart.
    /// - Parameter authResult: Auth result.
    /// - Returns: Auth result dictionary.
    fileprivate func getAuthResult(_ authResult: MSALResult) -> [String: Any] {
        var authResultDic = [String: Any]()
        authResultDic["accessToken"] = authResult.accessToken
        authResultDic["authenticationScheme"] = authResult.authenticationScheme
        authResultDic["expiresOn"] = Int(
            authResult.expiresOn!.timeIntervalSince1970 * 1000.0)
        authResultDic["idToken"] = authResult.idToken
        authResultDic["authority"] = authResult.authority.url.absoluteString
        authResultDic["tenantId"] = authResult.tenantProfile.tenantId
        authResultDic["scopes"] = authResult.scopes
        authResultDic["correlationId"] = authResult.correlationId.uuidString
        authResultDic["account"] = getCurrentAccountDic(authResult.account)

        return authResultDic
    }

    /// Returns current account dictionary.
    /// - Parameter account: Current account.
    /// - Returns: Current account dictionary.
    fileprivate func getCurrentAccountDic(_ account: MSALAccount) -> [String:
        Any]
    {
        var accountDic = [String: Any]()
        accountDic["id"] = account.identifier
        accountDic["username"] = account.username
        accountDic["name"] = account.accountClaims?["name"]
        return accountDic
    }
}

// MARK: - MsalAuthPlugin
extension MsalAuthPlugin {
    /// Sets internal error to result due to provided invalid data from Dart.
    /// - Parameters:
    ///   - methodName: Method name.
    ///   - result: Result of the method call.
    fileprivate func setInternalError(
        methodName: String, result: @escaping FlutterResult
    ) {
        result(
            FlutterError(
                code: "INVALID_DATA",
                message:
                    "Invalid data has been provided on method \(methodName).",
                details: nil))
    }

    /// Sets public client application initialization error to result. This is a custom exception created at Dart side.
    /// - Parameters:
    ///   - methodName: Method name.
    ///   - result: Result of the method call.
    fileprivate func setPcaInitError(
        methodName: String, result: @escaping FlutterResult
    ) {
        result(
            FlutterError(
                code: "PCA_INIT",
                message:
                    "PublicClientApplication should be initialized to call \(methodName).",
                details: nil))
    }

    /// Sets no current account error to result.
    /// - Parameter result: Result of the method call.
    fileprivate func setNoCurrentAccountError(result: @escaping FlutterResult) {
        result(
            FlutterError(
                code: "NO_CURRENT_ACCOUNT",
                message: "There is no currently signed in account.",
                details: nil))
    }

    /// Common MSAL error handling function that returns error to Dart.
    /// - Parameters:
    ///   - error: MSAL error.
    ///   - result: Result of the method call.
    fileprivate func setMsalError(
        error: NSError, result: @escaping FlutterResult
    ) {
        var flutterErrorCode: String!
        var errorMessage: Any?
        var errorDetails = [String: Any]()

        if error.domain == MSALErrorDomain,
            let errorCode = MSALError(rawValue: error.code)
        {
            errorMessage = error.userInfo[MSALErrorDescriptionKey]
            errorDetails["correlationId"] = error.userInfo[MSALCorrelationIDKey]
            
            switch errorCode {
            case .userCanceled:
                flutterErrorCode = "USER_CANCEL"
            case .serverDeclinedScopes:
                flutterErrorCode = "DECLINED_SCOPE"
                errorDetails["grantedScopes"] = error.userInfo[MSALGrantedScopesKey]
                errorDetails["declinedScopes"] = error.userInfo[MSALDeclinedScopesKey]
            case .serverProtectionPoliciesRequired:
                flutterErrorCode = "PROTECTION_POLICY_REQUIRED"
            case .interactionRequired:
                flutterErrorCode = "UI_REQUIRED"
                errorDetails["oauthError"] = error.userInfo[MSALOAuthErrorKey]
                errorDetails["oauthErrorDescription"] = error.userInfo[MSALOAuthSubErrorDescriptionKey]
            case .internal:
                flutterErrorCode = "INTERNAL_ERROR"
                errorDetails["internalErrorCode"] = error.userInfo[MSALInternalErrorCodeKey]
            case .workplaceJoinRequired:
                flutterErrorCode = "WORKPLACE_JOIN_REQUIRED"
            case .serverError:
                flutterErrorCode = "SERVER_ERROR"
            case .insufficientDeviceStrength:
                flutterErrorCode = "INSUFFICIENT_DEVICE_STRENGTH"
            @unknown default:
                break
            }
        } else {
            flutterErrorCode = error.domain
            errorMessage = error.localizedDescription
        }

        result(
            FlutterError(
                code: flutterErrorCode, message: errorMessage as? String,
                details: errorDetails))
    }
}
