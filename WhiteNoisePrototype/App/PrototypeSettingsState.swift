import SwiftUI

struct PrototypeSettingsState {
    var appearance = PrototypeAppearance.system
    var language = PrototypeLanguage.system
    var returnKeyBehavior = PrototypeReturnKeyBehavior.newLine
    var incomingMessageColor = PrototypeMessageColor.gray
    var outgoingMessageColor = PrototypeMessageColor.black

    var localNotificationsEnabled = true
    var nativePushEnabled = true
    var notificationPreview = PrototypeNotificationPreview.generic

    var mediaQuality = PrototypeMediaQuality.standard
    var autoDownload: [PrototypeMediaType: PrototypeAutoDownloadLevel] = [
        .photos: .wifi,
        .audio: .wifi,
        .videos: .never,
        .files: .never,
    ]

    var appLockEnabled = false
    var autoLock = PrototypeAutoLock.immediately
    var blockScreenshots = false
    var anonymousTelemetry = false
    var auditLogging = false

    var relays = PrototypeRelay.fixtures

    var developerMode = false
    var streamingDebug = false
    var keyPackages = PrototypeKeyPackage.fixtures
}

enum PrototypeAppearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: Self { self }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum PrototypeLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case german
    case spanish
    case french
    case italian
    case portuguese
    case serbian

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .english: "English"
        case .german: "German"
        case .spanish: "Spanish"
        case .french: "French"
        case .italian: "Italian"
        case .portuguese: "Portuguese"
        case .serbian: "Serbian"
        }
    }
}

enum PrototypeReturnKeyBehavior: String, CaseIterable, Identifiable {
    case newLine = "New Line"
    case send = "Send Message"

    var id: Self { self }
}

enum PrototypeMessageColor: String, CaseIterable, Identifiable {
    case black = "Black"
    case gray = "Gray"
    case blue = "Blue"
    case green = "Green"
    case purple = "Purple"
    case orange = "Orange"

    var id: Self { self }

    var color: Color {
        switch self {
        case .black: Color("AccentColor")
        case .gray: Color(uiColor: .systemGray4)
        case .blue: .blue
        case .green: .green
        case .purple: .purple
        case .orange: .orange
        }
    }

    var foregroundColor: Color {
        switch self {
        case .black:
            Color(uiColor: .systemBackground)
        case .gray:
            Color(uiColor: .label)
        case .blue, .green, .purple, .orange:
            .white
        }
    }
}

enum PrototypeNotificationPreview: String, CaseIterable, Identifiable {
    case senderAndMessage = "Sender and Message"
    case senderOnly = "Sender Only"
    case generic = "Generic"

    var id: Self { self }

    var example: String {
        switch self {
        case .senderAndMessage:
            "Maya Chen · Can you send the latest version?"
        case .senderOnly:
            "Maya Chen · New message"
        case .generic:
            "White Noise · New message"
        }
    }
}

enum PrototypeMediaQuality: String, CaseIterable, Identifiable {
    case low = "Low"
    case standard = "Standard"
    case high = "High"
    case original = "Original"

    var id: Self { self }

    var detail: String {
        switch self {
        case .low: "Smallest data use"
        case .standard: "Balanced quality and data use"
        case .high: "Sharper media, more data"
        case .original: "Full resolution"
        }
    }
}

enum PrototypeMediaType: String, CaseIterable, Identifiable {
    case photos = "Photos"
    case audio = "Audio"
    case videos = "Videos"
    case files = "Files"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .photos: "photo"
        case .audio: "waveform"
        case .videos: "video"
        case .files: "doc"
        }
    }
}

enum PrototypeAutoDownloadLevel: String, CaseIterable, Identifiable {
    case never = "Never"
    case wifi = "Wi-Fi"
    case wifiAndCellular = "Wi-Fi and Cellular"

    var id: Self { self }
}

enum PrototypeAutoLock: String, CaseIterable, Identifiable {
    case immediately = "Immediately"
    case oneMinute = "After 1 Minute"
    case fiveMinutes = "After 5 Minutes"
    case fifteenMinutes = "After 15 Minutes"

    var id: Self { self }
}

enum PrototypeRelayConnectionState: Hashable {
    case connected
    case reconnecting
    case disconnected
}

enum PrototypeRelayCapability: Equatable {
    case readWrite
    case readOnly
}

enum PrototypeRelayUsage: String, CaseIterable, Identifiable {
    case publishing = "Publishing"
    case mentions = "Mentions"
    case messages = "Messages"

    var id: Self { self }

    var explanation: String {
        switch self {
        case .publishing:
            "Sends your profile information."
        case .mentions:
            "Tells people where to send mentions of your profile."
        case .messages:
            "Receives your private messages."
        }
    }
}

struct PrototypeRelay: Identifiable, Equatable {
    let id: String
    var displayName: String
    var url: String
    var capability: PrototypeRelayCapability
    var connectionState: PrototypeRelayConnectionState
    var usages: Set<PrototypeRelayUsage>

    static let fixtures = [
        PrototypeRelay(
            id: "primal",
            displayName: "Primal",
            url: "wss://relay.primal.net",
            capability: .readWrite,
            connectionState: .connected,
            usages: [.publishing, .mentions, .messages]
        ),
        PrototypeRelay(
            id: "damus",
            displayName: "Damus",
            url: "wss://relay.damus.io",
            capability: .readWrite,
            connectionState: .connected,
            usages: [.publishing, .mentions]
        ),
        PrototypeRelay(
            id: "nos-lol",
            displayName: "nos.lol",
            url: "wss://nos.lol",
            capability: .readWrite,
            connectionState: .connected,
            usages: [.publishing, .mentions, .messages]
        ),
        PrototypeRelay(
            id: "nostr-band",
            displayName: "Nostr.Band",
            url: "wss://relay.nostr.band",
            capability: .readWrite,
            connectionState: .connected,
            usages: [.mentions]
        ),
        PrototypeRelay(
            id: "vertex",
            displayName: "Vertex",
            url: "wss://relay.vertexlab.io",
            capability: .readOnly,
            connectionState: .connected,
            usages: []
        ),
        PrototypeRelay(
            id: "white-noise-profile",
            displayName: "White Noise Profile",
            url: "wss://relay.whitenoise.chat",
            capability: .readWrite,
            connectionState: .reconnecting,
            usages: [.publishing, .mentions]
        ),
        PrototypeRelay(
            id: "white-noise-inbox",
            displayName: "White Noise Inbox",
            url: "wss://inbox.whitenoise.chat",
            capability: .readWrite,
            connectionState: .disconnected,
            usages: [.messages]
        ),
    ]
}

struct PrototypeKeyPackage: Identifiable, Equatable {
    enum Location: String {
        case synced = "Synced"
        case local = "Local Only"
        case relay = "Relay Only"
    }

    let id: String
    let published: String
    let size: String
    let location: Location

    static let fixtures = [
        PrototypeKeyPackage(
            id: "a17c2e93d8f4b1",
            published: "Today",
            size: "4 KB",
            location: .synced
        ),
        PrototypeKeyPackage(
            id: "73df9a128be640",
            published: "Yesterday",
            size: "4 KB",
            location: .local
        ),
        PrototypeKeyPackage(
            id: "c8904b7e1a26d5",
            published: "Jul 18",
            size: "4 KB",
            location: .relay
        ),
    ]
}
