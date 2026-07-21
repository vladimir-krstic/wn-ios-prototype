import Foundation

struct PrototypeState: Equatable, Sendable {
    var scenarioID: ScenarioID
    var activeScreen: ScreenID
    var fixedClock: Date
    var people: [Person]
    var profiles: [Profile]
    var chats: [Chat]
    var messages: [Message]
    var permissions: [SystemCapability: PrototypePermissionState]
    var isOffline: Bool

    static func seed(for scenarioID: ScenarioID) -> PrototypeState {
        let hasPopulatedData = ![
            ScenarioID.onboardingWelcomeDefault,
            .onboardingSignInEmpty,
            .onboardingSignUpEmpty,
            .chatsEmpty,
            .conversationEmpty
        ].contains(scenarioID)

        return PrototypeState(
            scenarioID: scenarioID,
            activeScreen: scenarioID.startScreen,
            fixedClock: FixtureUniverse.fixedClock,
            people: hasPopulatedData ? FixtureUniverse.people : [],
            profiles: hasPopulatedData ? FixtureUniverse.profiles : [],
            chats: hasPopulatedData ? FixtureUniverse.chats : [],
            messages: hasPopulatedData ? FixtureUniverse.messages : [],
            permissions: [:],
            isOffline: scenarioID == .chatsOffline || scenarioID == .conversationOffline
        )
    }
}

enum PrototypeAction: Equatable, Sendable {
    case applyScenario(ScenarioID)
    case reset
    case setOffline(Bool)
    case setPermission(SystemCapability, PrototypePermissionState)
    case markChatRead(Chat.ID)
    case setChatArchived(Chat.ID, Bool)
    case retryMessage(Message.ID)
}
