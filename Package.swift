// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SystemDesignOracle",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "SystemDesignOracle",
            path: "Sources/SystemDesignOracle",
            // Content JSON is copied into the .app by scripts/build_app.sh;
            // `swift run` reads it straight from the source folder.
            exclude: ["Content"]
        )
    ]
)
