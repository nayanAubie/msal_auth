import MSAL

/// Singleton class that manages required objects for [MsalAuthPlugin].
class MsalAuth {
    static var pcaType: PublicClientApplicationType!
    static var publicClientApplication: MSALPublicClientApplication!
}

/// Public client application type.
enum PublicClientApplicationType {
    case single
    case multiple
}
