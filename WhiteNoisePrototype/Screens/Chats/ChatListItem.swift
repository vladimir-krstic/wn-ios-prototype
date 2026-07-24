import Foundation

struct ChatListItem: Identifiable {
    enum Avatar {
        case asset(String)
        case monogram(String)
    }

    enum DeliveryState {
        case none
        case failed
    }

    let id: String
    let title: String
    let avatar: Avatar
    let preview: String
    let previewAuthor: String?
    let timestamp: String
    let isArchived: Bool
    let unreadCount: Int
    let isMuted: Bool
    let isDraft: Bool
    let deliveryState: DeliveryState

    init(
        id: String,
        title: String,
        avatar: Avatar,
        preview: String,
        previewAuthor: String? = nil,
        timestamp: String,
        isArchived: Bool,
        unreadCount: Int,
        isMuted: Bool,
        isDraft: Bool,
        deliveryState: DeliveryState
    ) {
        self.id = id
        self.title = title
        self.avatar = avatar
        self.preview = preview
        self.previewAuthor = previewAuthor
        self.timestamp = timestamp
        self.isArchived = isArchived
        self.unreadCount = unreadCount
        self.isMuted = isMuted
        self.isDraft = isDraft
        self.deliveryState = deliveryState
    }

    var isUnread: Bool {
        unreadCount > 0
    }

    var searchablePreview: String {
        if let previewAuthor {
            "\(previewAuthor): \(preview)"
        } else {
            preview
        }
    }
}

enum ChatListFixtures {
    static let populated: [ChatListItem] = [
        ChatListItem(
            id: "maya-chen",
            title: "Maya Chen",
            avatar: .asset("AvatarMayaChen"),
            preview: "Can you send the latest version when you have a moment?",
            timestamp: "Now",
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
            timestamp: "1m",
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
            timestamp: "12m",
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
            timestamp: "59m",
            isArchived: false,
            unreadCount: 128,
            isMuted: true,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "mina-park",
            title: "Mina Park",
            avatar: .asset("AvatarMinaPark"),
            preview: "Let’s pick this up after lunch",
            timestamp: "10:42",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: true,
            deliveryState: .none
        ),
        ChatListItem(
            id: "leo-martins",
            title: "Leo Martins",
            avatar: .asset("AvatarLeoMartins"),
            preview: "Here’s the address.",
            previewAuthor: "You",
            timestamp: "Yesterday",
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
            preview: "Photo",
            previewAuthor: "You",
            timestamp: "Tuesday",
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
            timestamp: "Monday",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "theo-grant",
            title: "Theo Grant",
            avatar: .asset("AvatarTheoGrant"),
            preview: "Voice message",
            timestamp: "Sunday",
            isArchived: false,
            unreadCount: 1,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "aisha-rahman",
            title: "Aisha Rahman",
            avatar: .asset("AvatarAishaRahman"),
            preview: "Photo",
            timestamp: "7/18/26",
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
            timestamp: "7/17/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "quiet-studio",
            title: "Quiet Studio",
            avatar: .monogram("Q"),
            preview: "I’ll lock up when I leave.",
            previewAuthor: "Remy",
            timestamp: "7/16/26",
            isArchived: false,
            unreadCount: 0,
            isMuted: true,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "jonah-reed",
            title: "Jonah Reed",
            avatar: .asset("AvatarJonahReed"),
            preview: "I sent the details.",
            previewAuthor: "You",
            timestamp: "7/15/26",
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
            timestamp: "7/14/26",
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
            timestamp: "7/13/26",
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
            preview: "Voice message",
            previewAuthor: "You",
            timestamp: "7/11/26",
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
            timestamp: "7/9/26",
            isArchived: false,
            unreadCount: 1,
            isMuted: false,
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
            preview: "File",
            previewAuthor: "You",
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
