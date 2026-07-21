import Foundation

struct LaunchConfiguration: Equatable, Sendable {
    let scenarioID: ScenarioID
    let systemMode: SystemCapabilityMode
    let isUITesting: Bool

    static let `default` = LaunchConfiguration(
        scenarioID: .onboardingWelcomeDefault,
        systemMode: .live,
        isUITesting: false
    )

    static var current: LaunchConfiguration {
        parse(arguments: ProcessInfo.processInfo.arguments)
    }

    static func parse(arguments: [String]) -> LaunchConfiguration {
        var scenarioID = ScenarioID.onboardingWelcomeDefault
        var systemMode = SystemCapabilityMode.live
        let isUITesting = arguments.contains("-WNUITesting")

        var index = arguments.startIndex
        while index < arguments.endIndex {
            switch arguments[index] {
            case "-WNScenario":
                let valueIndex = arguments.index(after: index)
                precondition(valueIndex < arguments.endIndex, "-WNScenario requires a scenario ID")
                guard let parsedScenario = ScenarioID(rawValue: arguments[valueIndex]) else {
                    preconditionFailure("Unknown -WNScenario value: \(arguments[valueIndex])")
                }
                scenarioID = parsedScenario
                index = valueIndex
            case "-WNSystemMode":
                let valueIndex = arguments.index(after: index)
                precondition(valueIndex < arguments.endIndex, "-WNSystemMode requires live or simulated")
                guard let parsedMode = SystemCapabilityMode(rawValue: arguments[valueIndex]) else {
                    preconditionFailure("Unknown -WNSystemMode value: \(arguments[valueIndex])")
                }
                systemMode = parsedMode
                index = valueIndex
            case "-WNUITesting":
                break
            default:
                break
            }
            index = arguments.index(after: index)
        }

        return LaunchConfiguration(
            scenarioID: scenarioID,
            systemMode: isUITesting ? .simulated : systemMode,
            isUITesting: isUITesting
        )
    }
}
