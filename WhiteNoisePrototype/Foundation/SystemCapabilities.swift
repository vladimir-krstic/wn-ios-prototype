enum SystemCapabilityMode: String, Codable, Sendable {
    case live
    case simulated
}

enum SystemCapability: String, CaseIterable, Codable, Sendable {
    case camera
    case photos
    case files
    case microphone
    case notifications
    case sharing
    case haptics
    case clipboard
}

enum PrototypePermissionState: String, Codable, Sendable {
    case notDetermined
    case allowed
    case denied
    case restricted
    case unavailable
}

protocol SystemCapabilityClient: Sendable {
    func permissionState(for capability: SystemCapability) async -> PrototypePermissionState
}

struct SimulatedSystemCapabilityClient: SystemCapabilityClient {
    let states: [SystemCapability: PrototypePermissionState]

    func permissionState(for capability: SystemCapability) async -> PrototypePermissionState {
        states[capability] ?? .notDetermined
    }
}
