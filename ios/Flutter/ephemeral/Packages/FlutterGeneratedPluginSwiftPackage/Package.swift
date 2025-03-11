// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "audio_service", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/audio_service-0.18.17/darwin/audio_service"),
        .package(name: "audio_session", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/audio_session-0.1.25/ios/audio_session"),
        .package(name: "connectivity_plus", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/connectivity_plus-6.1.3/ios/connectivity_plus"),
        .package(name: "firebase_analytics", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/firebase_analytics-11.4.4/ios/firebase_analytics"),
        .package(name: "firebase_core", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/firebase_core-3.12.1/ios/firebase_core"),
        .package(name: "firebase_crashlytics", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/firebase_crashlytics-4.3.4/ios/firebase_crashlytics"),
        .package(name: "firebase_performance", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/firebase_performance-0.10.1+4/ios/firebase_performance"),
        .package(name: "path_provider_foundation", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/path_provider_foundation-2.4.0/darwin/path_provider_foundation"),
        .package(name: "url_launcher_ios", path: "/Users/yesterday17/.pub-cache/hosted/pub.dev/url_launcher_ios-6.3.1/ios/url_launcher_ios")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "audio-service", package: "audio_service"),
                .product(name: "audio-session", package: "audio_session"),
                .product(name: "connectivity-plus", package: "connectivity_plus"),
                .product(name: "firebase-analytics", package: "firebase_analytics"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-crashlytics", package: "firebase_crashlytics"),
                .product(name: "firebase-performance", package: "firebase_performance"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios")
            ]
        )
    ]
)
