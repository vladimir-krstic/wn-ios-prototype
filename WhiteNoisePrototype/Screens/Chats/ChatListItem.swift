import Foundation

struct ChatListItem: Identifiable, Equatable {
    enum Avatar: Equatable {
        case asset(String)
        case monogram(String)
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
    let preview: String
    let previewAuthor: String?
    let attachmentPreview: AttachmentPreview?
    let timestamp: String
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

enum ChatListFixtures {
    static let populated: [ChatListItem] = [
        ChatListItem(
            id: "nostr-devs",
            title: "Nostr Devs",
            avatar: .asset("LegacyAvatarNostrDevs"),
            preview: "Marmot draft merged. Time to test the new flow.",
            previewAuthor: "Tim",
            timestamp: "Yesterday",
            isArchived: false,
            isPinned: true,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "radia-perlman",
            title: "Radia Perlman",
            avatar: .asset("LegacyAvatarRadiaPerlman"),
            preview: "Let the network heal itself; loops (and censors) break.",
            timestamp: "Sunday",
            isArchived: false,
            isPinned: true,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "hal-finney",
            title: "Hal Finney",
            avatar: .asset("LegacyAvatarHalFinney"),
            preview: "Running bitcoin… still amazes me how far we’ve come.",
            timestamp: "Now",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "judith-milhon",
            title: "Judith “St. Jude” Milhon",
            avatar: .asset("LegacyAvatarJudithMilhon"),
            preview: "Hacking means finding clever ways around dumb rules.",
            timestamp: "2m",
            isArchived: false,
            unreadCount: 2,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "marmots",
            title: "Marmots",
            avatar: .asset("LegacyAvatarMarmots"),
            preview: "Big plans—or no plans at all!",
            previewAuthor: "Jude",
            timestamp: "9m",
            isArchived: false,
            unreadCount: 128,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "whitfield-diffie",
            title: "Whitfield Diffie",
            avatar: .asset("LegacyAvatarWhitfieldDiffie"),
            preview: "Key exchange since ’76—still my favorite handshake.",
            previewAuthor: "You",
            timestamp: "1h",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "richard-stallman",
            title: "Richard Stallman",
            avatar: .asset("LegacyAvatarRichardStallman"),
            preview: "Free as in freedom, not as in beer. Keep your keys libre.",
            timestamp: "8h",
            isArchived: false,
            unreadCount: 0,
            isMuted: true,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "eric-hughes",
            title: "Eric Hughes",
            avatar: .asset("LegacyAvatarEricHughes"),
            preview: "Cypherpunks still write code. Ship the patch?",
            timestamp: "Yesterday",
            isArchived: false,
            unreadCount: 12,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "david-chaum",
            title: "David Chaum",
            avatar: .asset("LegacyAvatarDavidChaum"),
            preview: "Privacy is necessary for an open society in the electronic age.",
            timestamp: "Saturday",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "satoshi-nakamoto",
            title: "Satoshi Nakamoto",
            avatar: .asset("LegacyAvatarSatoshiNakamoto"),
            preview: "Chancellor on Brink of Second Bailout for Banks.",
            timestamp: "Friday",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "mina-park",
            title: "Mina Park",
            avatar: .asset("AvatarMinaPark"),
            preview: "Let’s pick this up after lunch",
            timestamp: "Thursday",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: true,
            deliveryState: .none
        ),
        ChatListItem(
            id: "theo-grant",
            title: "Theo Grant",
            avatar: .asset("AvatarTheoGrant"),
            preview: "",
            attachmentPreview: .voiceMessage,
            timestamp: "Wednesday",
            isArchived: false,
            unreadCount: 1,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "maya-chen",
            title: "Maya Chen",
            avatar: .asset("AvatarMayaChen"),
            preview: "Can you send the latest version when you have a moment?",
            timestamp: "Monday",
            isArchived: false,
            unreadCount: 1,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "weekend-walks",
            title: "Weekend Walks",
            avatar: .monogram("W"),
            preview: "Saturday morning works for me.",
            previewAuthor: "Nora",
            timestamp: "Sunday",
            isArchived: false,
            unreadCount: 12,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "elias-moreno",
            title: "Elias Moreno",
            avatar: .asset("AvatarEliasMoreno"),
            preview: "I’ll be there at seven.",
            previewAuthor: "You",
            timestamp: "7/19/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "product-circle",
            title: "Product Circle",
            avatar: .monogram("P"),
            preview: "I added the notes from today’s session.",
            previewAuthor: "Sam",
            timestamp: "7/18/26",
            isArchived: false,
            unreadCount: 128,
            isMuted: true,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "leo-martins",
            title: "Leo Martins",
            avatar: .asset("AvatarLeoMartins"),
            preview: "Here’s the address.",
            previewAuthor: "You",
            timestamp: "7/17/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "aisha-rahman",
            title: "Aisha Rahman",
            avatar: .asset("AvatarAishaRahman"),
            preview: "",
            attachmentPreview: .photos(3),
            timestamp: "7/16/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "lena-ortiz",
            title: "Lena Ortiz",
            avatar: .asset("AvatarLenaOrtiz"),
            preview: "That sounds perfect to me.",
            timestamp: "7/15/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "nora-bennett",
            title: "Nora Bennett",
            avatar: .asset("AvatarNoraBennett"),
            preview: "",
            previewAuthor: "You",
            attachmentPreview: .photo,
            timestamp: "7/14/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .failed
        ),
        ChatListItem(
            id: "book-club",
            title: "Book Club",
            avatar: .monogram("B"),
            preview: "The next chapter is shorter than it looks.",
            previewAuthor: "Owen",
            timestamp: "7/13/26",
            membershipState: .left,
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "quiet-studio",
            title: "Quiet Studio Group",
            avatar: .monogram("Q"),
            preview: "I’ll lock up when I leave.",
            previewAuthor: "Remy",
            timestamp: "7/12/26",
            membershipState: .removed,
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "jonah-reed",
            title: "Jonah Reed",
            avatar: .asset("AvatarJonahReed"),
            preview: "I sent the details.",
            previewAuthor: "You",
            timestamp: "7/11/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "tessa-morgan",
            title: "Tessa Morgan",
            avatar: .asset("AvatarTessaMorgan"),
            preview: "Could we move it to Thursday?",
            timestamp: "7/10/26",
            isArchived: false,
            unreadCount: 2,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "marcus-bell",
            title: "Marcus Bell",
            avatar: .asset("AvatarMarcusBell"),
            preview: "Thanks, I’ll take a look tonight.",
            timestamp: "7/9/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "sofia-alvarez",
            title: "Sofia Alvarez",
            avatar: .asset("AvatarSofiaAlvarez"),
            preview: "",
            previewAuthor: "You",
            attachmentPreview: .video,
            timestamp: "7/8/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "daniel-kim",
            title: "Daniel Kim",
            avatar: .asset("AvatarDanielKim"),
            preview: "The file opened without any problems.",
            timestamp: "7/7/26",
            isArchived: false,
            unreadCount: 1,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "project-files",
            title: "Project Files",
            avatar: .monogram("P"),
            preview: "",
            previewAuthor: "You",
            attachmentPreview: .file("Project Brief.pdf"),
            timestamp: "7/6/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "neighborhood",
            title: "Neighborhood",
            avatar: .monogram("N"),
            preview: "",
            previewAuthor: "Maya",
            attachmentPreview: .location,
            timestamp: "7/5/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "jamie-cooper",
            title: "Jamie Cooper",
            avatar: .monogram("J"),
            preview: "",
            attachmentPreview: .contact("Avery Stone"),
            timestamp: "7/4/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "reading-list",
            title: "Reading List",
            avatar: .monogram("R"),
            preview: "",
            previewAuthor: "Owen",
            attachmentPreview: .link,
            timestamp: "7/3/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "family-group",
            title: "Family Group",
            avatar: .monogram("F"),
            preview: "",
            previewAuthor: "Nora",
            attachmentPreview: .gif,
            timestamp: "7/2/26",
            isArchived: false,
            unreadCount: 3,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "sticker-swap",
            title: "Sticker Swap",
            avatar: .monogram("S"),
            preview: "",
            previewAuthor: "You",
            attachmentPreview: .sticker,
            timestamp: "7/1/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: true,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "road-trip",
            title: "Road Trip",
            avatar: .monogram("R"),
            preview: "The playlist is ready.",
            previewAuthor: "You",
            timestamp: "7/12/26",
            isArchived: true,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "garden-club",
            title: "Garden Club",
            avatar: .asset("AvatarGardenClub"),
            preview: "The seedlings made it through the heat.",
            previewAuthor: "Iris",
            timestamp: "7/8/26",
            isArchived: true,
            unreadCount: 4,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "old-studio",
            title: "Old Studio",
            avatar: .monogram("O"),
            preview: "Everything has been packed away.",
            previewAuthor: "Noah",
            timestamp: "6/29/26",
            isArchived: true,
            unreadCount: 0,
            isMuted: true,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "design-notes",
            title: "Design Notes",
            avatar: .monogram("D"),
            preview: "",
            previewAuthor: "You",
            attachmentPreview: .file("Project Notes.pdf"),
            timestamp: "6/21/26",
            isArchived: true,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        )
    ]

    static let empty: [ChatListItem] = []
}
