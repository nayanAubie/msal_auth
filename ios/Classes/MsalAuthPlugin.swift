import Flutter
import MSAL
import UIKit

/// This is the main entry point for the Flutter plugin.
/// It manages the method calls from Flutter & sets results accordingly.
public class MsalAuthPlugin: NSObject, FlutterPlugin {

    /// Initializes method channel and register method call delegate.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "msal_auth", binaryMessenger: registrar.messenger())
        let instance = MsalAuthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// Handles method calls received from Dart.
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
                let broker = dict["broker"] as? String,
                let authorityType = dict["authorityType"] as? String
            else {
                setInternalError(methodName: call.method, result: result)
                return
            }

            MsalAuth.broker = broker
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

            acquireToken(
                scopes: scopes, promptType: promptType, loginHint: loginHint,
                result: result)
        case "acquireTokenSilent":
            guard let dict = call.arguments as? NSDictionary,
                let scopes = dict["scopes"] as? [String]
            else {
                setInternalError(methodName: call.method, result: result)
                return
            }

            let identifier = dict["identifier"] as? String

            acquireTokenSilent(
                scopes: scopes, identifier: identifier, result: result)

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
        authorityType: String,
        result: @escaping FlutterResult
    ) {
        var pcaConfig: MSALPublicClientApplicationConfig!

        if authority != nil {
            guard let authorityUrl = URL(string: authority!) else {
                result(
                    FlutterError(
                        code: "INTERNAL_ERROR",
                        message: "invalid authority URL has been provided",
                        details: "invalid_authority"))
                return
            }

            do {
                switch authorityType {
                case "b2c":
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
            // We will only have a public client application object. iOS does not have specific class for differnet account mode (Single & multiple). So we just assigned type that we receives from Dart and then call methods as per the type.
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
    ///   - result: Result of the method call.
    private func acquireToken(
        scopes: [String], promptType: MSALPromptType, loginHint: String?,
        result: @escaping FlutterResult
    ) {
        guard let pca = MsalAuth.publicClientApplication else {
            setPcaInitError(methodName: "acquireToken", result: result)
            return
        }

        guard let viewController = UIViewController.keyViewController else {
            return
        }
        let webViewParameters = MSALWebviewParameters(
            authPresentationViewController: viewController)

        MSALGlobalConfig.brokerAvailability = .auto
        if #available(iOS 13.0, *) {
            webViewParameters.prefersEphemeralWebBrowserSession = true
            switch MsalAuth.broker {
            case "webView":
                webViewParameters.webviewType = .wkWebView
                MSALGlobalConfig.brokerAvailability = .none
            case "safariBrowser":
                webViewParameters.webviewType = .safariViewController
                MSALGlobalConfig.brokerAvailability = .none
            default:
                webViewParameters.webviewType = .default
            }
        }

        let tokenParams = MSALInteractiveTokenParameters(
            scopes: scopes, webviewParameters: webViewParameters)

        tokenParams.promptType = promptType
        tokenParams.loginHint = loginHint

        var account: MSALAccount?

        // Call current account for single account mode. multiple account mode needs to give account identifier to get particular account.
        if MsalAuth.pcaType == PublicClientApplicationType.single {
            if let currentAccount = getCurrentAccount() {
                account = currentAccount
            }
        }

        if account != nil {
            acquireTokenSilent(
                scopes: scopes, identifier: account?.identifier, result: result)
            return
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
    ///   - result: Result of the method call.
    private func acquireTokenSilent(
        scopes: [String], identifier: String? = nil,
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
                code: "INTERNAL_ERROR",
                message:
                    "Invalid data has been provided on method \(methodName).",
                details: "invalid_data"))
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
                code: "INTERNAL_ERROR",
                message: "There is no currently signed in account.",
                details: "no_account"))
    }

    /// Common MSAL error handling function that returns error to Dart.
    /// - Parameters:
    ///   - error: MSAL error.
    ///   - result: Result of the method call.
    fileprivate func setMsalError(
        error: NSError, result: @escaping FlutterResult
    ) {
        var code: String!
        var errorDetails: Any? = nil

        if error.domain == MSALErrorDomain,
            let errorCode = MSALError(rawValue: error.code)
        {
            switch errorCode {
            case .userCanceled:
                code = "USER_CANCEL"
            case .serverDeclinedScopes:
                code = "DECLINED_SCOPE"
                var details = [String: Any]()
                details["grantedScopes"] = error.userInfo[MSALGrantedScopesKey]
                details["declinedScopes"] =
                    error.userInfo[MSALDeclinedScopesKey]
                errorDetails = details
            case .serverProtectionPoliciesRequired:
                code = "PROTECTION_POLICY_REQUIRED"
            case .interactionRequired:
                code = "UI_REQUIRED"
            case .internal:
                code = "INTERNAL_ERROR"
                errorDetails = error.userInfo[MSALInternalErrorCodeKey]
            case .workplaceJoinRequired:
                code = "WORKPLACE_JOIN_REQUIRED"
            case .serverError:
                code = "SERVER_ERROR"
            case .insufficientDeviceStrength:
                code = "INSUFFICIENT_DEVICE_STRENGTH"
            @unknown default:
                code = "INTERNAL_ERROR"
                errorDetails = "unknown"
            }
        } else {
            code = "INTERNAL_ERROR"
            errorDetails = error.domain
        }

        result(
            FlutterError(
                code: code, message: error.localizedDescription,
                details: errorDetails))
    }
}

// MARK: - UIViewController
extension UIViewController {
    static var keyViewController: UIViewController? {
        if #available(iOS 15, *) {
            return
                (UIApplication.shared.connectedScenes.filter({
                    $0.activationState == .foregroundActive
                }).compactMap({ $0 as? UIWindowScene }).first?.windows.filter({
                    $0.isKeyWindow
                }).first?.rootViewController)!
        } else {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow }
            )?.rootViewController
        }
    }
}
