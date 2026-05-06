// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "msal_auth",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "msal-auth", targets: ["msal_auth"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/AzureAD/microsoft-authentication-library-for-objc",
            from: "2.11.0"
        )
    ],
    targets: [
        .target(
            name: "msal_auth",
            dependencies: [
                .product(name: "MSAL", package: "microsoft-authentication-library-for-objc")
            ],
            resources: []
        )
    ]
)
