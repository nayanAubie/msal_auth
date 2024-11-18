import Flutter
import MSAL

class MsalAuth {
    static var pcaType : PublicClientApplicationType!
    static var publicClientApplication : MSALPublicClientApplication!
    static var broker : String!
}

enum PublicClientApplicationType {
    case single
    case multiple
}
