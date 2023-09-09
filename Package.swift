// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "trilangle-swift",
    targets: [
        .target(
            name: "CStdLib",
            path: ".",
            exclude: ["Sources"],
            sources: ["CStdLib.swift"]
        ),
        .executableTarget(
            name: "trilangle-swift",
            dependencies: [
                .target(name: "CStdLib"),
            ],
            path: "Sources"    
        ),
    ]
)
