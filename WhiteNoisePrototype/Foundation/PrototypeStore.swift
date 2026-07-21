import Observation

@MainActor
@Observable
final class PrototypeStore {
    private(set) var state: PrototypeState

    init(scenarioID: ScenarioID = .onboardingWelcomeDefault) {
        state = PrototypeState.seed(for: scenarioID)
    }

    func send(_ action: PrototypeAction) {
        switch action {
        case let .applyScenario(scenarioID):
            state = PrototypeState.seed(for: scenarioID)
        case .reset:
            state = PrototypeState.seed(for: state.scenarioID)
        case let .setOffline(isOffline):
            state.isOffline = isOffline
        case let .setPermission(capability, permissionState):
            state.permissions[capability] = permissionState
        case let .markChatRead(chatID):
            mutateChat(id: chatID) { $0.unreadCount = 0 }
        case let .setChatArchived(chatID, isArchived):
            mutateChat(id: chatID) { $0.isArchived = isArchived }
        case let .retryMessage(messageID):
            guard let index = state.messages.firstIndex(where: { $0.id == messageID }) else { return }
            state.messages[index].deliveryState = .sending
        }
    }

    private func mutateChat(id: Chat.ID, mutation: (inout Chat) -> Void) {
        guard let index = state.chats.firstIndex(where: { $0.id == id }) else { return }
        mutation(&state.chats[index])
    }
}
