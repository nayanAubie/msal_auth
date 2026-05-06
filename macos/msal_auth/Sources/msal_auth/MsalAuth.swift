import MSAL

/// Singleton class that manages required objects for [MsalAuthPlugin].
class MsalAuth {
    static var pcaType: PublicClientApplicationType!
    static var authorityType : AuthorityType!
    static var publicClientApplication: MSALPublicClientApplication!
}

/// Public client application type.
enum PublicClientApplicationType {
    case single
    case multiple
}

/// Authority type.
enum AuthorityType {
    case aad
    case b2c
}
