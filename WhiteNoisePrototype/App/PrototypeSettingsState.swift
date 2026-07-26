import SwiftUI

struct PrototypeSettingsState {
    var appearance = PrototypeAppearance.system
    var language = PrototypeLanguage.system
    var returnKeyBehavior = PrototypeReturnKeyBehavior.newLine
    var incomingMessageColor = PrototypeMessageColor.gray
    var outgoingMessageColor = PrototypeMessageColor.blue

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

    var relays = [
        "wss://relay.whitenoise.example",
        "wss://inbox.whitenoise.example",
    ]

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
    case system = "System"
    case english = "English"

    var id: Self { self }
}

enum PrototypeReturnKeyBehavior: String, CaseIterable, Identifiable {
    case newLine = "New Line"
    case send = "Send Message"

    var id: Self { self }
}

enum PrototypeMessageColor: String, CaseIterable, Identifiable {
    case gray = "Gray"
    case blue = "Blue"
    case green = "Green"
    case purple = "Purple"
    case orange = "Orange"

    var id: Self { self }

    var color: Color {
        switch self {
        case .gray: Color(uiColor: .systemGray4)
        case .blue: .blue
        case .green: .green
        case .purple: .purple
        case .orange: .orange
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
            "White Noise · New encrypted message"
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
