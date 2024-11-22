import Flutter
import MSAL

/// Singleton class that manages required objects for [MsalAuthPlugin].
class MsalAuth {
    static var pcaType : PublicClientApplicationType!
    static var publicClientApplication : MSALPublicClientApplication!
    static var broker : String!
}

/// Public client application type.
enum PublicClientApplicationType {
    case single
    case multiple
}
