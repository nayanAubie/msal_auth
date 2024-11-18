import Flutter
import MSAL
import UIKit

public class MsalAuthPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "msal_auth", binaryMessenger: registrar.messenger())
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
                let broker = dict["broker"] as? String,
                let authorityType = dict["authorityType"] as? String
            else {
                result(
                    FlutterError(
                        code: "AUTH_ERROR", message: "Argument not found",
                        details: nil))
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
                result(
                    FlutterError(
                        code: "AUTH_ERROR",
                        message: "Argument not found acquire token",
                        details: nil))
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
                result(
                    FlutterError(
                        code: "AUTH_ERROR", message: "Argument not found",
                        details: nil))
                return
            }
            let identifier = dict["identifier"] as? String
            acquireTokenSilent(
                scopes: scopes, identifier: identifier, result: result)

        case "currentAccount": getCurrentAccount(result: result)
        case "signOut": signOut(result: result)
        case "getAccount":
            guard let identifier = call.arguments as? String else {
                result(
                    FlutterError(
                        code: "AUTH_ERROR", message: "Argument not found",
                        details: nil))
                return
            }
            getAccount(identifier: identifier, result: result)
        case "getAccounts": getAccounts(result: result)
        case "removeAccount":
            guard let identifier = call.arguments as? String else {
                result(
                    FlutterError(
                        code: "AUTH_ERROR", message: "Argument not found",
                        details: nil))
                return
            }
        default: result(FlutterMethodNotImplemented)
        }
    }

    private func createPublicClientApplication(
        pcaType: PublicClientApplicationType,
        clientId: String, authority: String?,
        authorityType: String,
        result: @escaping FlutterResult
    ) {
        var pcaConfig: MSALPublicClientApplicationConfig!

        if (authority != nil) {
            guard let authorityUrl = URL(string: authority!) else {
                result(
                    FlutterError(
                        code: "AUTH_ERROR", message: "invalid authority URL has been provided",
                        details: nil))
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
            } catch {
                result(
                    FlutterError(
                        code: "AUTH_ERROR", message: "Error in authority configuration",
                        details: nil))
            }
        }
        else {
            pcaConfig = MSALPublicClientApplicationConfig(clientId: clientId)
        }

        if let application = try? MSALPublicClientApplication(
            configuration: pcaConfig)
        {
            MsalAuth.publicClientApplication = application
            MsalAuth.pcaType = pcaType
            result(true)
        } else {
            result(
                FlutterError(
                    code: "AUTH_ERROR",
                    message: "Unable to create MSALPublicClientApplication",
                    details: nil))
        }
    }

    private func acquireToken(
        scopes: [String], promptType: MSALPromptType, loginHint: String?,
        result: @escaping FlutterResult
    ) {
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

        MsalAuth.publicClientApplication.acquireToken(
            with: tokenParams,
            completionBlock: { (msalresult, error) in
                guard let authResult = msalresult, error == nil else {

                    guard let error = error as NSError? else { return }

                    if error.domain == MSALErrorDomain,
                        let errorCode = MSALError(rawValue: error.code)
                    {
                        switch errorCode
                        {
                        case .userCanceled:
                            result(
                                FlutterError(
                                    code: "USER_CANCELED",
                                    message: error.localizedDescription,
                                    details: nil))

                        default:
                            result(
                                FlutterError(
                                    code: "AUTH_ERROR",
                                    message: error.localizedDescription,
                                    details: nil))
                        }
                    }
                    return
                }

                result(self.getAuthResult(authResult))
            })
    }

    private func acquireTokenSilent(
        scopes: [String], identifier: String? = nil,
        result: @escaping FlutterResult
    ) {
        var account: MSALAccount!

        if MsalAuth.pcaType == PublicClientApplicationType.single {
            account = getCurrentAccount()
        } else {
            account = getAccount(identifier: identifier!)
        }

        guard let account else {
            result(
                FlutterError(
                    code: "AUTH_ERROR",
                    message: "Error retrieving a current account guard",
                    details: nil))
            return
        }

        let silentParams = MSALSilentTokenParameters(
            scopes: scopes, account: account)

        MsalAuth.publicClientApplication.acquireTokenSilent(
            with: silentParams,
            completionBlock: { (msalresult, error) in

                guard let authResult = msalresult, error == nil else {

                    guard let error = error as NSError? else { return }

                    if error.domain == MSALErrorDomain,
                        let errorCode = MSALError(rawValue: error.code)
                    {
                        switch errorCode
                        {
                        case .interactionRequired:
                            result(
                                FlutterError(
                                    code: "UI_REQUIRED",
                                    message: error.localizedDescription,
                                    details: nil))

                        case .userCanceled:
                            result(
                                FlutterError(
                                    code: "USER_CANCELED",
                                    message: error.localizedDescription,
                                    details: nil))

                        default:
                            result(
                                FlutterError(
                                    code: "AUTH_ERROR",
                                    message: error.localizedDescription,
                                    details: nil))
                        }
                    }
                    return
                }

                result(self.getAuthResult(authResult))
            })
    }

    @discardableResult
    private func getCurrentAccount(result: FlutterResult? = nil) -> MSALAccount?
    {
        var account: MSALAccount!

        MsalAuth.publicClientApplication.getCurrentAccount(
            with: MSALParameters()
        ) { current, previous, error in
            if let current {
                account = current
                result?(self.getCurrentAccountDic(current))
                return
            }
            if let error {
                result?(
                    FlutterError(
                        code: "error", message: error.localizedDescription,
                        details: nil))
                return
            }
            result?(
                FlutterError(
                    code: "error", message: "No current account", details: nil))
        }
        return account
    }

    private func signOut(result: @escaping FlutterResult) {
        if let currentAccount = getCurrentAccount() {
            MsalAuth.publicClientApplication.signout(
                with: currentAccount, signoutParameters: MSALSignoutParameters()
            ) { success, error in
                guard let error else {
                    result(success)
                    return
                }
                result(
                    FlutterError(
                        code: "AUTH_ERROR",
                        message: error.localizedDescription,
                        details: nil))
            }
        } else {
            result(
                FlutterError(
                    code: "AUTH_ERROR",
                    message: "Error retrieving a current account",
                    details: nil))
        }
    }

    @discardableResult
    private func getAccount(identifier: String, result: FlutterResult? = nil)
        -> MSALAccount?
    {
        do {
            return try MsalAuth.publicClientApplication.account(
                forIdentifier: identifier)
        } catch {
            result?(
                FlutterError(
                    code: "AUTH_ERROR",
                    message: "Error retrieving a current account",
                    details: nil))
            return nil
        }
    }

    private func getAccounts(result: @escaping FlutterResult) {
        do {
            let accounts = try MsalAuth.publicClientApplication.allAccounts()
            result(accounts.map { getCurrentAccountDic($0) })
        } catch {
            result(
                FlutterError(
                    code: "AUTH_ERROR",
                    message: "Error retrieving all accounts",
                    details: nil))
        }
    }

    private func removeAccount(
        identifier: String, result: @escaping FlutterResult
    ) {
        let account = getAccount(identifier: identifier)

        guard let account else {
            result(
                FlutterError(
                    code: "AUTH_ERROR",
                    message: "No account to remove",
                    details: nil))
            return
        }

        do {
            try MsalAuth.publicClientApplication.remove(account)
            result(true)
        } catch {
            result(
                FlutterError(
                    code: "AUTH_ERROR",
                    message: "No account to remove",
                    details: nil))
        }
    }

    fileprivate func getAuthResult(_ authResult: MSALResult) -> [String: Any] {
        var authResultDic = [String: Any]()
        authResultDic["accessToken"] = authResult.accessToken
        authResultDic["authenticationScheme"] = authResult.authenticationScheme
        authResultDic["expiresOn"] = Int(
            authResult.expiresOn!.timeIntervalSince1970 * 1000.0)
        authResultDic["tenantId"] = authResult.tenantProfile.tenantId
        authResultDic["scopes"] = authResult.scopes
        authResultDic["correlationId"] = authResult.correlationId.uuidString
        authResultDic["account"] = getCurrentAccountDic(authResult.account)

        return authResultDic
    }

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

//MARK: - UIViewController
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

extension MsalAuthPlugin {
    fileprivate var noAccountError: FlutterError {
        return FlutterError(
            code: "no_account", message: "No active account found", details: nil
        )
    }
}

//extension WKWebView {
//    func cleanAllCookies() {
//        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
//        print("All cookies deleted")
//
//        WKWebsiteDataStore.default().fetchDataRecords(
//            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
//        ) { records in
//            records.forEach { record in
//                WKWebsiteDataStore.default().removeData(
//                    ofTypes: record.dataTypes, for: [record],
//                    completionHandler: {})
//                print("Cookie ::: \(record) deleted")
//            }
//        }
//    }
//
//    func refreshCookies() {
//        self.configuration.processPool = WKProcessPool()
//    }
//}
