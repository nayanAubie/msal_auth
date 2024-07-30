import Flutter
import UIKit
import MSAL

public class MsalAuthPlugin: NSObject, FlutterPlugin {
    
    static var clientId : String = ""
    static var authority : String = ""
    static var authMiddleware : String = ""
    static var tenantType : String = ""
    static var loginHint : String = ""
    
    static let kCurrentAccountIdentifier = "MSALCurrentAccountIdentifier"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "msal_auth", binaryMessenger: registrar.messenger())
        let instance = MsalAuthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
    {
        //get the arguments as a dictionary
        guard let dict = call.arguments as? NSDictionary else { return }
        let scopes = dict["scopes"] as? [String] ?? [String]()
        let clientId = dict["clientId"] as? String ?? ""
        let authority = dict["authority"] as? String ?? ""
        let authMiddleware = dict["authMiddleware"] as? String ?? ""
        let tenantType = dict["tenantType"] as? String ?? ""
        let loginHint = dict["loginHint"] as? String ?? ""
        
        switch( call.method ){
        case "initialize": initialize(clientId: clientId, authority: authority, authMiddleware: authMiddleware, tenantType: tenantType, loginHint: loginHint, result: result)
        case "acquireToken": acquireToken(scopes: scopes, result: result)
        case "acquireTokenSilent": acquireTokenSilent(scopes: scopes, result: result)
        case "getIDToken": getIDToken(result: result)
        case "logout": logout(result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }
    
    
    fileprivate func getResultLogin(_ authResult: MSALResult) -> String?{
        // Get access token from result
        
        var accountMap = authResult.account.accountClaims ?? [String: Any]()
        accountMap["access_token"] = authResult.accessToken
        accountMap["id_token"] = authResult.idToken
        accountMap["exp"] = Int(floor(authResult.expiresOn!.timeIntervalSince1970 * 1000.0))
        
        let signedInAccount = authResult.account
        self.currentAccountIdentifier = signedInAccount.homeAccountId?.identifier
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: accountMap, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8){
                return jsonString
            }
            
        }catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func initialize(clientId: String, authority: String, authMiddleware: String, tenantType: String, loginHint: String, result: @escaping FlutterResult)
    {
        // validate clientId
        if(clientId.isEmpty){
            result(FlutterError(code:"AUTH_ERROR", message: "Call must include a clientId", details: nil))
            return
        }
        
        MsalAuthPlugin.clientId = clientId;
        MsalAuthPlugin.authority = authority;
        MsalAuthPlugin.authMiddleware = authMiddleware;
        MsalAuthPlugin.tenantType = tenantType;
        MsalAuthPlugin.loginHint = loginHint;
        if (authMiddleware != "msAuthenticator") {
            MSALGlobalConfig.brokerAvailability = .none
        }
        result(true)
    }
}
//MARK: - Get token
extension MsalAuthPlugin {
    
    private func acquireToken(scopes: [String], result: @escaping FlutterResult)
    {
        if let application = getApplication(result: result){
            
            guard let viewController = UIViewController.keyViewController else { return }
            let webViewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
            if #available(iOS 13.0, *) {
                webViewParameters.prefersEphemeralWebBrowserSession = true
                webViewParameters.webviewType = MsalAuthPlugin.authMiddleware != "webView" ? MSALWebviewType.safariViewController : MSALWebviewType.wkWebView
            }
            
            removeAccount(application)
            
            let interactiveParameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: webViewParameters)
            interactiveParameters.promptType = MSALPromptType.login

            if (MsalAuthPlugin.loginHint != "") {
                interactiveParameters.loginHint = MsalAuthPlugin.loginHint
            }
                        
            application.acquireToken(with: interactiveParameters, completionBlock: { (msalresult, error) in
                guard let authResult = msalresult, error == nil else {
                    
                    guard let error = error as NSError? else { return }
                    
                    if error.domain == MSALErrorDomain,
                       let errorCode = MSALError(rawValue: error.code)
                    {
                        switch errorCode
                        {
                        case .userCanceled:
                            result(FlutterError(code: "USER_CANCELED", message: error.localizedDescription, details: nil))
                            
                        default:
                            result(FlutterError(code: "AUTH_ERROR", message: error.localizedDescription, details: nil))
                        }
                    }
                    return
                }
                
                result(self.getResultLogin(authResult))
            })
        }
        else {
            return
        }
        
    }
}
//MARK: - Get token silent
extension MsalAuthPlugin {
    
    private func acquireTokenSilent(scopes: [String], result: @escaping FlutterResult)
    {
        if let application = getApplication(result: result){
            var account : MSALAccount!
            
            do{
                guard let currentAccount = try currentAccount(result: result) else{
                    let error = FlutterError(code: "AUTH_ERROR",  message: "No account is available to acquire token silently for", details: nil)
                    result(error)
                    return
                }
                account = currentAccount
            }
            catch{
                result(FlutterError(code: "AUTH_ERROR",  message: "Error retrieving an existing account", details: nil))
            }
            
            let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account)
            
            application.acquireTokenSilent(with: silentParameters, completionBlock: { (msalresult, error) in
                
                guard let authResult = msalresult, error == nil else {
                    
                    guard let error = error as NSError? else { return }
                    
                    if error.domain == MSALErrorDomain,
                       let errorCode = MSALError(rawValue: error.code)
                    {
                        switch errorCode
                        {
                        case .interactionRequired:
                            result(FlutterError(code: "UI_REQUIRED", message: error.localizedDescription, details: nil))
                            
                        case .userCanceled:
                            result(FlutterError(code: "USER_CANCELED", message: error.localizedDescription, details: nil))
                            
                        default:
                            result(FlutterError(code: "AUTH_ERROR", message: error.localizedDescription, details: nil))
                        }
                    }
                    return
                }
                
                result(self.getResultLogin(authResult))
                
            })
        }
        else {
            return
        }
    }
}
//MARK: - Get logout remove or count cachedAccounts
extension MsalAuthPlugin {
    
    fileprivate func removeAccount(_ application: MSALPublicClientApplication) {
        do{
            var msalAcount:MSALAccount?
            if let accountIndetifier = currentAccountIdentifier {
                let parameters = MSALAccountEnumerationParameters(identifier: accountIndetifier)
                application.accountsFromDevice(for: parameters, completionBlock:{(accounts, error) in
                    if(accounts != nil && !accounts!.isEmpty){
                        msalAcount = accounts?.first;
                    }
                    if error != nil
                    {
                        print(error?.localizedDescription ?? "N/A")
                    }
                })
            }
            
            if let account = msalAcount {
                try application.remove(account)
                
            }
        }catch{
            return
        }
    }
    
    fileprivate func signOut(_ application: MSALPublicClientApplication, _ account: MSALAccount, result: @escaping FlutterResult) {
        let viewController: UIViewController = UIViewController.keyViewController!
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        webviewParameters.webviewType = MSALWebviewType.wkWebView
        
        let signoutParameters = MSALSignoutParameters(webviewParameters: webviewParameters)
        
        application.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
            
            if error != nil {
                result(FlutterError(code: "AUTH_ERROR", message: "Signout failed", details: nil))
                return
            }
            // Sign out completed successfully
            result(true)
        })
    }
    
    private func getIDToken(result: @escaping FlutterResult) {

    }

    private func logout(result: @escaping FlutterResult)
    {
        
        if let application = getApplication(result: result){
            do{
                guard let accountToDelete = try currentAccount(result: result) else{
                    result(FlutterError(code: "AUTH_ERROR", message: "Unable get remove accounts Null", details: nil))
                    return
                }
                
                clearCurrentAccount()
                try application.remove(accountToDelete)
                removeAccount(application)
                signOut(application, accountToDelete, result: result)
            } catch {
                result(FlutterError(code: "AUTH_ERROR", message: "Unable get remove accounts", details: nil))
                return
            }
            
            return
        }
        else {
            result(FlutterError(code: "AUTH_ERROR", message: "Unable Application", details: nil))
            return
        }
    }
    
    
    var currentAccountIdentifier: String? {
        get {
            return UserDefaults.standard.string(forKey: MsalAuthPlugin.kCurrentAccountIdentifier)
        }
        set (accountIdentifier) {
            // The identifier in the MSALAccount is the key to retrieve this user from
            // the cache in the future. Save this piece of information in a place you can
            // easily retrieve in your app. In this case we're going to store it in
            // NSUserDefaults.
            UserDefaults.standard.set(accountIdentifier, forKey: MsalAuthPlugin.kCurrentAccountIdentifier)
        }
    }
    
    @discardableResult func currentAccount(result: @escaping FlutterResult) throws -> MSALAccount? {
        // We retrieve our current account by checking for the accountIdentifier that we stored in NSUserDefaults when
        // we first signed in the account.
        guard let accountIdentifier = currentAccountIdentifier else {
            // If we did not find an identifier then throw an error indicating there is no currently signed in account.
            result(FlutterError(code: "AUTH_ERROR", message: "Account identifier", details: nil))
            return nil
        }
        var acc: MSALAccount?
        if let application = getApplication(result: result){
            do {
                acc = try application.account(forIdentifier: accountIdentifier)
            } catch let error as NSError {
                result(FlutterError(code: "AUTH_ERROR", message: "Account identifier", details: error.localizedDescription))
            }
        }
        guard let account = acc else {
            clearCurrentAccount()
            return nil
        }
        
        
        return account
    }
    
    
    func clearCurrentAccount() {
        // Leave around the account identifier as the last piece of state to clean up as you will probably need
        // it to clean up user-specific state
        UserDefaults.standard.removeObject(forKey: MsalAuthPlugin.kCurrentAccountIdentifier)
    }
    
}
//MARK: - get Application config
extension MsalAuthPlugin {
    private func getApplication(result: @escaping FlutterResult) -> MSALPublicClientApplication?
    {
        if(MsalAuthPlugin.clientId.isEmpty){
            result(FlutterError(code: "AUTH_ERROR", message: "Client must be initialized before attempting to acquire a token.", details: nil))
            return nil
        }
        
        var config: MSALPublicClientApplicationConfig
        
        //setup the config, using authority if it is set, or defaulting to msal's own implementation if it's not
        if !MsalAuthPlugin.authority.isEmpty
        {
            //try creating the msal aad authority object
            do{
                //create authority url
                guard let authorityUrl = URL(string: MsalAuthPlugin.authority) else{
                    result(FlutterError(code: "AUTH_ERROR", message: "invalid authority", details: nil))
                    return nil
                }
                
                //create the msal authority and configuration based on the tenant type
                switch MsalAuthPlugin.tenantType {
                    case "entraIDAndMicrosoftAccount":
                        let msalAuthority = try MSALAuthority(url: authorityUrl)
                        config = MSALPublicClientApplicationConfig(clientId: MsalAuthPlugin.clientId, redirectUri: nil, authority: msalAuthority)
                    case "azureADB2C":
                        let msalB2CAuthority = try MSALB2CAuthority(url: authorityUrl)
                        config = MSALPublicClientApplicationConfig(clientId: MsalAuthPlugin.clientId, redirectUri: nil, authority: msalB2CAuthority)
                        // To allow MSAL for iOS and macOS to authenticate against an Azure AD B2C tenant, its authority needs to be set as a "known authority".
                        // https://learn.microsoft.com/en-us/entra/msal/objc/configure-authority#b2c
                        config.knownAuthorities = [msalB2CAuthority];
                    default:
                        result(FlutterError(code: "AUTH_ERROR", message: "invalid tenant type", details: nil))
                        return nil
                }

            } catch {
                //return error if exception occurs
                result(FlutterError(code: "AUTH_ERROR", message: "invalid authority", details: nil))
                return nil
            }
        }
        else
        {
            config = MSALPublicClientApplicationConfig(clientId: MsalAuthPlugin.clientId)
        }
        
        //create the application and return it
        if let application = try? MSALPublicClientApplication(configuration: config)
        {
            return application
        }else{
            result(FlutterError(code: "AUTH_ERROR", message: "Unable to create MSALPublicClientApplication", details: nil))
            return nil
        }
    }
}

//MARK: - UIViewController
extension UIViewController {
    
    
    static var keyViewController: UIViewController?{
        if #available(iOS 15, *){
            return (UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).compactMap({$0 as? UIWindowScene}).first?.windows.filter({$0.isKeyWindow}).first?.rootViewController)!
        }else{
            return UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.rootViewController
        }
    }
    
}

extension WKWebView {
    
    func cleanAllCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Cookie ::: \(record) deleted")
            }
        }
    }
    
    func refreshCookies() {
        self.configuration.processPool = WKProcessPool()
    }
}