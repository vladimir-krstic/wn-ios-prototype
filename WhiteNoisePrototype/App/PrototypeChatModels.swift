import Foundation

struct PrototypePerson: Identifiable, Equatable {
    let id: String
    var name: String
    let publicKey: String
    var about: String
    var nostrAddress: String
    var lightningAddress: String
    var avatar: ChatListItem.Avatar
    var isFollowing: Bool
    var isBlocked: Bool

    init(
        id: String,
        name: String,
        publicKey: String? = nil,
        about: String = "",
        nostrAddress: String = "",
        lightningAddress: String = "",
        avatar: ChatListItem.Avatar = .monogram("?"),
        isFollowing: Bool = true,
        isBlocked: Bool = false
    ) {
        self.id = id
        self.name = name
        self.publicKey = publicKey ?? Self.publicKey(for: id)
        self.about = about
        self.nostrAddress = nostrAddress
        self.lightningAddress = lightningAddress
        self.avatar = avatar
        self.isFollowing = isFollowing
        self.isBlocked = isBlocked
    }

    var shortPublicKey: String {
        guard publicKey.count > 17 else { return publicKey }
        return "\(publicKey.prefix(12))…\(publicKey.suffix(4))"
    }

    private static func publicKey(for id: String) -> String {
        let alphabet = Array("023456789acdefghjklmnpqrstuvwxyz")
        let scalars = id.unicodeScalars.map { Int($0.value) }
        let seed = scalars.isEmpty ? [0] : scalars
        let body = (0..<58).map { index in
            alphabet[(seed[index % seed.count] + index) % alphabet.count]
        }
        return "npub1" + String(body)
    }
}

enum PrototypeGroupRole: String, Equatable {
    case member
    case admin
}

struct PrototypeGroupMember: Identifiable, Equatable {
    let personID: String
    var role: PrototypeGroupRole

    var id: String { personID }
}

enum PrototypeChatKind: Equatable {
    case direct(personID: String)
    case group
}

struct PrototypeChatRouting: Equatable {
    var relayURLs: [String]

    init(relayURLs: [String] = ["wss://relay.primal.net"]) {
        self.relayURLs = Self.normalizedUnique(relayURLs)
    }

    static func normalized(_ candidate: String) -> String? {
        let trimmed = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed),
              components.scheme?.lowercased() == "wss",
              components.host?.isEmpty == false
        else { return nil }

        components.scheme = "wss"
        components.host = components.host?.lowercased()
        components.query = nil
        components.fragment = nil
        var value = components.string ?? trimmed
        while value.hasSuffix("/") { value.removeLast() }
        return value
    }

    mutating func add(_ candidate: String) -> Bool {
        guard let value = Self.normalized(candidate), !relayURLs.contains(value) else {
            return false
        }
        relayURLs.append(value)
        return true
    }

    mutating func remove(_ value: String) {
        relayURLs.removeAll { $0 == value }
    }

    private static func normalizedUnique(_ values: [String]) -> [String] {
        values.reduce(into: []) { result, value in
            guard let normalized = normalized(value), !result.contains(normalized) else { return }
            result.append(normalized)
        }
    }
}

enum PrototypeImageSource: Equatable {
    case asset(String)
    case data(Data)
}

enum PrototypeAttachment: Equatable, Identifiable {
    case photo(id: String, source: PrototypeImageSource, label: String)
    case video(id: String, url: URL?, thumbnail: PrototypeImageSource, duration: TimeInterval)
    case file(id: String, name: String, size: Int, url: URL?)
    case voice(id: String, resourceName: String, duration: TimeInterval)
    case link(id: String, title: String, domain: String, summary: String, image: PrototypeImageSource?)
    case gif(id: String, assetName: String, label: String)
    case sticker(id: String, assetName: String, label: String)
    case location(id: String, name: String, address: String)
    case contact(id: String, personID: String)

    var id: String {
        switch self {
        case let .photo(id, _, _), let .video(id, _, _, _), let .file(id, _, _, _),
             let .voice(id, _, _), let .link(id, _, _, _, _), let .gif(id, _, _),
             let .sticker(id, _, _), let .location(id, _, _), let .contact(id, _):
            id
        }
    }

    var accessibilityLabel: String {
        switch self {
        case let .photo(_, _, label): label
        case .video: "Video"
        case let .file(_, name, _, _): "File, \(name)"
        case .voice: "Voice message"
        case let .link(_, title, domain, _, _): "Link, \(title), \(domain)"
        case let .gif(_, _, label): "GIF, \(label)"
        case let .sticker(_, _, label): "Sticker, \(label)"
        case let .location(_, name, address): "Location, \(name), \(address)"
        case .contact: "Contact"
        }
    }

    var listPreview: ChatListItem.AttachmentPreview {
        switch self {
        case .photo: .photo
        case .video: .video
        case let .file(_, name, _, _): .file(name)
        case .voice: .voiceMessage
        case .link: .link
        case .gif: .gif
        case .sticker: .sticker
        case .location: .location
        case .contact: .contact("Contact")
        }
    }
}

struct PrototypeReaction: Identifiable, Equatable {
    let emoji: String
    var personIDs: [String]
    var id: String { emoji }
}

struct PrototypeMessage: Identifiable, Equatable {
    enum DeliveryState: Equatable {
        case sending
        case sent
        case failed
    }

    enum DeletionState: Equatable {
        case none
        case deletedByCurrentProfile
        case deletedByOther
    }

    let id: String
    let authorID: String
    var sentAt: Date
    var text: String
    var attachments: [PrototypeAttachment]
    var replyToMessageID: String?
    var reactions: [PrototypeReaction]
    var deliveryState: DeliveryState
    var deletionState: DeletionState

    init(
        id: String,
        authorID: String,
        sentAt: Date,
        text: String = "",
        attachments: [PrototypeAttachment] = [],
        replyToMessageID: String? = nil,
        reactions: [PrototypeReaction] = [],
        deliveryState: DeliveryState = .sent,
        deletionState: DeletionState = .none
    ) {
        self.id = id
        self.authorID = authorID
        self.sentAt = sentAt
        self.text = text
        self.attachments = attachments
        self.replyToMessageID = replyToMessageID
        self.reactions = reactions
        self.deliveryState = deliveryState
        self.deletionState = deletionState
    }

    var isDeleted: Bool { deletionState != .none }
}

enum PrototypeGroupEventKind: Equatable {
    case created(actorID: String)
    case added(actorID: String, personIDs: [String])
    case joined(personID: String)
    case left(personID: String)
    case removed(actorID: String, personID: String)
    case madeAdmin(actorID: String, personID: String)
    case removedAdmin(actorID: String, personID: String)
    case changedName(actorID: String, name: String)
    case changedPhoto(actorID: String)
    case changedDescription(actorID: String)
    case removedDescription(actorID: String)
}

struct PrototypeTimelineEvent: Identifiable, Equatable {
    let id: String
    let date: Date
    let kind: PrototypeGroupEventKind
}

struct PrototypeTimelineNotice: Identifiable, Equatable {
    let id: String
    let date: Date
    let text: String
}

enum PrototypeTimelineEntry: Identifiable, Equatable {
    case message(PrototypeMessage)
    case event(PrototypeTimelineEvent)
    case notice(PrototypeTimelineNotice)

    var id: String {
        switch self {
        case let .message(message): message.id
        case let .event(event): event.id
        case let .notice(notice): notice.id
        }
    }

    var date: Date {
        switch self {
        case let .message(message): message.sentAt
        case let .event(event): event.date
        case let .notice(notice): notice.date
        }
    }
}

struct PrototypeChatListState: Equatable {
    var membershipState: ChatListItem.MembershipState = .active
    var isArchived = false
    var isPinned = false
    var unreadCount = 0
    var isMarkedUnread = false
    var muteDuration: ChatListItem.MuteDuration?
    var timestampLabel: String
}

struct PrototypeChat: Identifiable, Equatable {
    let id: String
    var kind: PrototypeChatKind
    var groupName: String
    var groupDescription: String
    var avatar: ChatListItem.Avatar
    var members: [PrototypeGroupMember]
    var routing: PrototypeChatRouting
    var timeline: [PrototypeTimelineEntry]
    var emptyPreview: String
    var draft: String
    var replyToMessageID: String?
    var listState: PrototypeChatListState

    var isGroup: Bool {
        if case .group = kind { return true }
        return false
    }

    var messages: [PrototypeMessage] {
        timeline.compactMap { entry in
            guard case let .message(message) = entry else { return nil }
            return message
        }
    }

    func title(people: [PrototypePerson]) -> String {
        switch kind {
        case let .direct(personID):
            people.first { $0.id == personID }?.name ?? groupName
        case .group:
            groupName
        }
    }

    func resolvedAvatar(people: [PrototypePerson]) -> ChatListItem.Avatar {
        switch kind {
        case let .direct(personID):
            people.first { $0.id == personID }?.avatar ?? avatar
        case .group:
            avatar
        }
    }

    func row(people: [PrototypePerson], currentProfileID: String) -> ChatListItem {
        let lastMessage = messages.last { !$0.isDeleted }
        let previewText: String
        let previewAuthor: String?
        let attachmentPreview: ChatListItem.AttachmentPreview?

        if !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            previewText = draft
            previewAuthor = nil
            attachmentPreview = nil
        } else if let lastMessage {
            previewText = lastMessage.text
            previewAuthor = authorLabel(
                for: lastMessage.authorID,
                people: people,
                currentProfileID: currentProfileID
            )
            if lastMessage.attachments.count > 1,
               lastMessage.attachments.allSatisfy({ attachment in
                   if case .photo = attachment { return true }
                   return false
               }) {
                attachmentPreview = .photos(lastMessage.attachments.count)
            } else {
                attachmentPreview = lastMessage.attachments.first?.listPreview
            }
        } else {
            previewText = emptyPreview
            previewAuthor = nil
            attachmentPreview = nil
        }

        return ChatListItem(
            id: id,
            title: title(people: people),
            avatar: resolvedAvatar(people: people),
            isGroup: isGroup,
            preview: previewText,
            previewAuthor: previewAuthor,
            attachmentPreview: attachmentPreview,
            timestamp: listState.timestampLabel,
            membershipState: listState.membershipState,
            isArchived: listState.isArchived,
            isPinned: listState.isPinned,
            unreadCount: listState.unreadCount,
            isMarkedUnread: listState.isMarkedUnread,
            isMuted: listState.muteDuration != nil,
            isDraft: !draft.isEmpty,
            deliveryState: listState.membershipState == .active
                && lastMessage?.deliveryState == .failed
                ? .failed
                : .none
        )
    }

    mutating func appendMessage(
        authorID: String,
        text: String = "",
        attachments: [PrototypeAttachment] = [],
        now: Date = .now
    ) {
        timeline.append(
            .message(
                PrototypeMessage(
                    id: "\(id)-message-\(UUID().uuidString)",
                    authorID: authorID,
                    sentAt: now,
                    text: text,
                    attachments: attachments,
                    replyToMessageID: replyToMessageID
                )
            )
        )
        draft = ""
        replyToMessageID = nil
        listState.timestampLabel = "Now"
        listState.unreadCount = 0
        listState.isMarkedUnread = false
    }

    mutating func appendEvent(_ kind: PrototypeGroupEventKind, now: Date = .now) {
        timeline.append(
            .event(
                PrototypeTimelineEvent(
                    id: "\(id)-event-\(UUID().uuidString)",
                    date: now,
                    kind: kind
                )
            )
        )
        listState.timestampLabel = "Now"
    }

    func isCurrentProfileAdmin(_ currentProfileID: String) -> Bool {
        members.contains { $0.personID == currentProfileID && $0.role == .admin }
    }

    private func authorLabel(
        for authorID: String,
        people: [PrototypePerson],
        currentProfileID: String
    ) -> String? {
        if authorID == currentProfileID { return "You" }
        guard isGroup else { return nil }
        return people.first { $0.id == authorID }?.name
    }
}

enum PrototypeVoiceRecordingState: Equatable {
    case idle
    case recording(startedAt: Date, isCancellationArmed: Bool)

    mutating func begin(at date: Date = .now) {
        self = .recording(startedAt: date, isCancellationArmed: false)
    }

    mutating func updateCancellation(isArmed: Bool) {
        guard case let .recording(startedAt, _) = self else { return }
        self = .recording(startedAt: startedAt, isCancellationArmed: isArmed)
    }

    mutating func finish() -> Bool {
        defer { self = .idle }
        guard case let .recording(_, isCancellationArmed) = self else { return false }
        return !isCancellationArmed
    }
}
