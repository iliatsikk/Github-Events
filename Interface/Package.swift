// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
  name: "Interface",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Interface",
      targets: ["Interface"]),
  ],
  dependencies: [
    .package(path: "../Packages/Domain"),
    .package(path: "../Packages/DesignSystem"),
    .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.3.2"))
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Interface",
      dependencies: [
        "Domain",
        "Kingfisher",
        "DesignSystem"
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    )
  ]
)
