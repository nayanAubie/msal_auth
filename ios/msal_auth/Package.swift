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
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/AzureAD/microsoft-authentication-library-for-objc",
            "2.11.0"..<"2.15.0"
        )
    ],
    targets: [
        .target(
            name: "msal_auth",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "MSAL", package: "microsoft-authentication-library-for-objc")
            ],
            resources: []
        )
    ]
)
