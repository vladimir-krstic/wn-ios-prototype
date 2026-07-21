import SwiftUI

@main
struct WhiteNoisePrototypeApp: App {
    private let launchConfiguration = LaunchConfiguration.current

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .environment(\.prototypeLaunchConfiguration, launchConfiguration)
        }
    }
}

private struct PrototypeLaunchConfigurationKey: EnvironmentKey {
    static let defaultValue = LaunchConfiguration.default
}

extension EnvironmentValues {
    var prototypeLaunchConfiguration: LaunchConfiguration {
        get { self[PrototypeLaunchConfigurationKey.self] }
        set { self[PrototypeLaunchConfigurationKey.self] = newValue }
    }
}
