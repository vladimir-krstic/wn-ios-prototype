enum ChatListFixtures {
    static let fiatjafChatID = "fiatjaf"
    static let supportChatID = "white-noise-support"
    static let catalogChatIDs = [
        "catalog-direct-text",
        "catalog-direct-replies",
        "catalog-direct-reactions",
        "catalog-direct-new-draft",
        "catalog-media-photo-video",
        "catalog-media-rich",
        "catalog-voice",
        "catalog-group-messages",
        "catalog-group-events",
        "catalog-group-member",
        "catalog-group-sole-admin",
        "catalog-direct-left",
        "catalog-group-left",
        "catalog-group-removed",
        "catalog-direct-blocked",
        "catalog-direct-missing-relays",
        "catalog-direct-archived",
        supportChatID,
    ]

    static let supportChat = ChatListItem(
        id: supportChatID,
        title: "Support — Timeline Notice",
        avatar: .systemSymbol("questionmark.bubble"),
        preview: "Ask a question, report a problem, or share a suggestion.",
        timestamp: "Thursday",
        isArchived: false,
        unreadCount: 0,
        isMuted: false,
        isDraft: false,
        deliveryState: .none
    )

    static let populated: [ChatListItem] = [
        catalogItem(
            id: "catalog-direct-text",
            title: "Direct — Text & Delivery",
            preview: "DLV-03 · Failed outgoing message",
            pinned: true,
            deliveryState: .failed
        ),
        catalogItem(
            id: "catalog-direct-replies",
            title: "Direct — Replies & Deletion",
            preview: "RPL-04 · Missing reply target",
            unreadCount: 3
        ),
        catalogItem(
            id: "catalog-direct-reactions",
            title: "Direct — Reactions & Actions",
            preview: "ACT-05 · Share available file URL",
            markedUnread: true
        ),
        catalogItem(
            id: "catalog-direct-new-draft",
            title: "Direct — New Chat & Draft",
            preview: "STATE-01 · Unsent draft",
            isDraft: true
        ),
        catalogItem(
            id: "catalog-media-photo-video",
            title: "Media — Photos & Video",
            preview: "MED-13 · Unavailable image fallback",
            muted: true
        ),
        catalogItem(
            id: "catalog-media-rich",
            title: "Media — Files & Rich Content",
            preview: "RICH-06 · Stacked attachments"
        ),
        catalogItem(
            id: "catalog-voice",
            title: "Voice Messages",
            preview: "",
            attachmentPreview: .voiceMessage
        ),
        catalogItem(
            id: "catalog-group-messages",
            title: "Group — Messages & Mentions",
            preview: "GRP-RPL-02 · Cross-author reply",
            previewAuthor: "Maya",
            isGroup: true
        ),
        catalogItem(
            id: "catalog-group-events",
            title: "Group — Events & Roles",
            preview: "Elias Moreno turned off disappearing messages.",
            isGroup: true
        ),
        catalogItem(
            id: "catalog-group-member",
            title: "Group — Member Permissions",
            preview: "ROLE-02 · Ordinary member permissions",
            isGroup: true
        ),
        catalogItem(
            id: "catalog-group-sole-admin",
            title: "Group — Sole Admin",
            preview: "ROLE-03 · Promote another admin before leaving",
            isGroup: true
        ),
        catalogItem(
            id: "catalog-direct-left",
            title: "Direct — Left",
            preview: "You left the chat.",
            membershipState: .left
        ),
        catalogItem(
            id: "catalog-group-left",
            title: "Group — Left",
            preview: "You left the group.",
            isGroup: true,
            membershipState: .left
        ),
        catalogItem(
            id: "catalog-group-removed",
            title: "Group — Removed",
            preview: "Maya Chen removed you from the group.",
            isGroup: true,
            membershipState: .removed
        ),
        catalogItem(
            id: "catalog-direct-blocked",
            title: "Direct — Blocked",
            preview: "STATE-05 · History remains available"
        ),
        catalogItem(
            id: "catalog-direct-missing-relays",
            title: "Direct — Missing Relays",
            preview: "STATE-06 · Check Chat Relays"
        ),
        catalogItem(
            id: "catalog-direct-archived",
            title: "Direct — Archived",
            preview: "STATE-07 · Unarchive from Chat Info",
            archived: true
        ),
        supportChat,
        ChatListItem(
            id: "nostr-devs",
            title: "Nostr Devs",
            avatar: .asset("LegacyAvatarNostrDevs"),
            preview: "Marmot draft merged. Time to test the new flow.",
            previewAuthor: "Tim",
            timestamp: "Yesterday",
            isArchived: false,
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
            id: fiatjafChatID,
            title: "Fiatjaf",
            avatar: .asset("AvatarFiatjaf"),
            preview: "Portable identity for the win.",
            attachmentPreview: .photos(5),
            timestamp: "Thursday",
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
            isPinned: false,
            unreadCount: 1,
            isMuted: false,
            isDraft: false,
            deliveryState: .none
        ),
        ChatListItem(
            id: "weekend-walks",
            title: "Weekend Walks",
            avatar: .asset("ProfileAvatarPebble"),
            preview: "Saturday morning works for me.",
            previewAuthor: "Nora",
            timestamp: "Sunday",
            isArchived: false,
            isPinned: false,
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

    private static func catalogItem(
        id: String,
        title: String,
        preview: String,
        previewAuthor: String? = nil,
        attachmentPreview: ChatListItem.AttachmentPreview? = nil,
        isGroup: Bool = false,
        membershipState: ChatListItem.MembershipState = .active,
        archived: Bool = false,
        pinned: Bool = false,
        unreadCount: Int = 0,
        markedUnread: Bool = false,
        muted: Bool = false,
        isDraft: Bool = false,
        deliveryState: ChatListItem.DeliveryState = .none
    ) -> ChatListItem {
        ChatListItem(
            id: id,
            title: title,
            avatar: .monogram(String(title.prefix(1))),
            isGroup: isGroup,
            preview: preview,
            previewAuthor: previewAuthor,
            attachmentPreview: attachmentPreview,
            timestamp: "Now",
            membershipState: membershipState,
            isArchived: archived,
            isPinned: pinned,
            unreadCount: unreadCount,
            isMarkedUnread: markedUnread,
            isMuted: muted,
            isDraft: isDraft,
            deliveryState: deliveryState
        )
    }

}
