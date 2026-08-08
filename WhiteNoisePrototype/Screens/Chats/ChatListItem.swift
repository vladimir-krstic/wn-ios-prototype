import Foundation

struct ChatListItem: Identifiable, Equatable {
    enum Avatar: Equatable {
        case asset(String)
        case imageData(Data)
        case monogram(String)
        case systemSymbol(String)
    }

    enum MembershipState: Equatable {
        case active
        case left
        case removed
    }

    enum MuteDuration: String, CaseIterable, Identifiable {
        case oneHour
        case eightHours
        case oneDay
        case oneWeek
        case always

        var id: Self {
            self
        }

        var title: String {
            switch self {
            case .oneHour:
                "1 Hour"
            case .eightHours:
                "8 Hours"
            case .oneDay:
                "1 Day"
            case .oneWeek:
                "1 Week"
            case .always:
                "Always"
            }
        }
    }

    enum DeliveryState: Equatable {
        case none
        case failed
    }

    enum AttachmentPreview: Equatable {
        case photo
        case photos(Int)
        case video
        case voiceMessage
        case file(String)
        case location
        case contact(String)
        case link
        case gif
        case sticker

        var symbol: String {
            switch self {
            case .photo:
                "photo"
            case .photos:
                "photo.stack"
            case .video:
                "video.fill"
            case .voiceMessage:
                "waveform"
            case .file:
                "doc.fill"
            case .location:
                "location.fill"
            case .contact:
                "person.crop.circle"
            case .link:
                "link"
            case .gif:
                "play.rectangle.fill"
            case .sticker:
                "face.smiling"
            }
        }

        var label: String {
            switch self {
            case .photo:
                "Photo"
            case let .photos(count):
                "\(count) Photos"
            case .video:
                "Video"
            case .voiceMessage:
                "Voice message"
            case let .file(name):
                name
            case .location:
                "Location"
            case let .contact(name):
                "Contact: \(name)"
            case .link:
                "Link"
            case .gif:
                "GIF"
            case .sticker:
                "Sticker"
            }
        }
    }

    let id: String
    let title: String
    let avatar: Avatar
    let isGroup: Bool
    var preview: String
    var previewAuthor: String?
    var attachmentPreview: AttachmentPreview?
    var timestamp: String
    var membershipState: MembershipState
    var isArchived: Bool
    var isPinned: Bool
    var unreadCount: Int
    var isMarkedUnread: Bool
    var muteDuration: MuteDuration?
    let isDraft: Bool
    var deliveryState: DeliveryState

    init(
        id: String,
        title: String,
        avatar: Avatar,
        isGroup: Bool = false,
        preview: String,
        previewAuthor: String? = nil,
        attachmentPreview: AttachmentPreview? = nil,
        timestamp: String,
        membershipState: MembershipState = .active,
        isArchived: Bool,
        isPinned: Bool = false,
        unreadCount: Int,
        isMarkedUnread: Bool = false,
        isMuted: Bool,
        isDraft: Bool,
        deliveryState: DeliveryState
    ) {
        self.id = id
        self.title = title
        self.avatar = avatar
        self.isGroup = isGroup
        self.preview = preview
        self.previewAuthor = previewAuthor
        self.attachmentPreview = attachmentPreview
        self.timestamp = timestamp
        self.membershipState = membershipState
        self.isArchived = isArchived
        self.isPinned = isPinned
        self.unreadCount = unreadCount
        self.isMarkedUnread = isMarkedUnread
        self.muteDuration = isMuted ? .always : nil
        self.isDraft = isDraft
        self.deliveryState = deliveryState
    }

    var isUnread: Bool {
        unreadCount > 0 || isMarkedUnread
    }

    var isMuted: Bool {
        muteDuration != nil
    }

    var hasEndedMembership: Bool {
        membershipState != .active
    }

    var visiblePreviewAuthor: String? {
        hasEndedMembership ? nil : previewAuthor
    }

    var searchablePreview: String {
        let content = visiblePreview

        if let previewAuthor = visiblePreviewAuthor {
            return "\(previewAuthor): \(content)"
        } else {
            return content
        }
    }

    var visiblePreview: String {
        switch membershipState {
        case .left:
            return "You left this chat."
        case .removed:
            return "You were removed from this chat."
        case .active:
            break
        }

        if preview.isEmpty, let attachmentPreview {
            return attachmentPreview.label
        } else {
            return preview
        }
    }
}
