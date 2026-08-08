import Foundation

extension PrototypeProfile {
    mutating func openOrCreateSupportChat(now: Date = .now) -> String? {
        if chats.contains(where: { $0.id == ChatListFixtures.supportChatID }) {
            return ChatListFixtures.supportChatID
        }

        let relayURLs = relayConfiguration.availableChatMessageRelayURLs
        guard !relayURLs.isEmpty else { return nil }

        if !people.contains(where: { $0.id == ChatListFixtures.supportChatID }) {
            people.append(
                PrototypePerson(
                    id: ChatListFixtures.supportChatID,
                    name: "White Noise Support",
                    about: "Help with White Noise.",
                    avatar: .systemSymbol("questionmark.bubble")
                )
            )
        }

        let support = PrototypeChat(
            id: ChatListFixtures.supportChatID,
            kind: .direct(personID: ChatListFixtures.supportChatID),
            groupName: "White Noise Support",
            groupDescription: "",
            avatar: .systemSymbol("questionmark.bubble"),
            members: [],
            routing: PrototypeChatRouting(relayURLs: relayURLs),
            timeline: [PrototypeChatFixtures.supportNotice(now: now)],
            emptyPreview: "Ask a question, report a problem, or share a suggestion.",
            draft: "",
            replyToMessageID: nil,
            listState: PrototypeChatListState(activityDate: now)
        )
        let insertion = chats.firstIndex { $0.id == ChatListFixtures.fiatjafChatID }
            .map { chats.index(after: $0) }
            ?? chats.startIndex
        chats.insert(support, at: insertion)
        return support.id
    }

    mutating func openOrCreateDirectChat(
        personID: String,
        chatID: String? = nil,
        now: Date = .now
    ) -> String? {
        guard let person = people.first(where: { $0.id == personID }) else { return nil }
        if let existing = chats.first(where: {
            if case let .direct(id) = $0.kind { return id == personID }
            return false
        }) {
            return existing.id
        }

        let relayURLs = relayConfiguration.availableChatMessageRelayURLs
        guard !relayURLs.isEmpty else { return nil }

        let id = chatID ?? "direct-\(personID)-\(UUID().uuidString)"
        let chat = PrototypeChat(
            id: id,
            kind: .direct(personID: personID),
            groupName: person.name,
            groupDescription: "",
            avatar: person.avatar,
            members: [],
            routing: PrototypeChatRouting(relayURLs: relayURLs),
            timeline: [],
            emptyPreview: "No messages yet.",
            draft: "",
            replyToMessageID: nil,
            listState: PrototypeChatListState(activityDate: now)
        )
        let insertion = chats.firstIndex { !$0.listState.isPinned } ?? chats.endIndex
        chats.insert(chat, at: insertion)
        return id
    }

    mutating func createGroup(
        id: String = "group-\(UUID().uuidString)",
        name: String,
        description: String,
        avatar: ChatListItem.Avatar,
        selectedPersonIDs: [String],
        now: Date = .now
    ) -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let uniqueIDs = selectedPersonIDs.reduce(into: [String]()) { result, id in
            if id != self.id, people.contains(where: { $0.id == id }), !result.contains(id) {
                result.append(id)
            }
        }
        guard !trimmedName.isEmpty, !uniqueIDs.isEmpty else { return nil }
        let relayURLs = relayConfiguration.availableChatMessageRelayURLs
        guard !relayURLs.isEmpty else { return nil }

        var group = PrototypeChat(
            id: id,
            kind: .group,
            groupName: trimmedName,
            groupDescription: description.trimmingCharacters(in: .whitespacesAndNewlines),
            avatar: avatar,
            members: [PrototypeGroupMember(personID: self.id, role: .admin)]
                + uniqueIDs.map { PrototypeGroupMember(personID: $0, role: .member) },
            routing: PrototypeChatRouting(relayURLs: relayURLs),
            timeline: [],
            emptyPreview: "You created the group.",
            draft: "",
            replyToMessageID: nil,
            listState: PrototypeChatListState(activityDate: now)
        )
        group.appendEvent(.created(actorID: self.id), now: now)
        let insertion = chats.firstIndex { !$0.listState.isPinned } ?? chats.endIndex
        chats.insert(group, at: insertion)
        return id
    }
}

extension PrototypeChat {
    enum ComposerAvailability: Equatable {
        case available
        case left
        case removed
        case blocked
        case missingRelays
    }

    func composerAvailability(
        currentProfileID: String,
        people: [PrototypePerson]
    ) -> ComposerAvailability {
        switch listState.membershipState {
        case .left: return .left
        case .removed: return .removed
        case .active: break
        }
        if case let .direct(personID) = kind,
           people.first(where: { $0.id == personID })?.isBlocked == true {
            return .blocked
        }
        return routing.relayURLs.isEmpty ? .missingRelays : .available
    }

    func canManageGroup(currentProfileID: String) -> Bool {
        isGroup
            && listState.membershipState == .active
            && isCurrentProfileAdmin(currentProfileID)
    }

    mutating func addMembers(
        personIDs: [String],
        actorID: String,
        now: Date = .now
    ) -> Bool {
        guard canManageGroup(currentProfileID: actorID) else { return false }
        let additions = personIDs.reduce(into: [String]()) { result, id in
            guard id != actorID,
                  !members.contains(where: { $0.personID == id }),
                  !result.contains(id)
            else { return }
            result.append(id)
        }
        guard !additions.isEmpty else { return false }
        members += additions.map { PrototypeGroupMember(personID: $0, role: .member) }
        appendEvent(.added(actorID: actorID, personIDs: additions), now: now)
        return true
    }

    mutating func promoteMember(
        personID: String,
        actorID: String,
        now: Date = .now
    ) -> Bool {
        guard canManageGroup(currentProfileID: actorID),
              let index = members.firstIndex(where: { $0.personID == personID }),
              members[index].role == .member
        else { return false }
        members[index].role = .admin
        appendEvent(.madeAdmin(actorID: actorID, personID: personID), now: now)
        return true
    }

    mutating func demoteMember(
        personID: String,
        actorID: String,
        now: Date = .now
    ) -> Bool {
        guard canManageGroup(currentProfileID: actorID),
              let index = members.firstIndex(where: { $0.personID == personID }),
              members[index].role == .admin,
              members.filter({ $0.role == .admin }).count > 1
        else { return false }
        members[index].role = .member
        appendEvent(.removedAdmin(actorID: actorID, personID: personID), now: now)
        return true
    }

    mutating func removeMember(
        personID: String,
        actorID: String,
        now: Date = .now
    ) -> Bool {
        guard personID != actorID,
              canManageGroup(currentProfileID: actorID),
              let index = members.firstIndex(where: { $0.personID == personID })
        else { return false }
        members.remove(at: index)
        appendEvent(.removed(actorID: actorID, personID: personID), now: now)
        return true
    }

    func matchingMessages(
        query: String,
        people: [PrototypePerson],
        currentProfileID: String
    ) -> [PrototypeMessage] {
        let value = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return messages }
        return messages.filter { message in
            let author = message.authorID == currentProfileID
                ? "You"
                : (people.first { $0.id == message.authorID }?.name ?? "Unknown")
            return message.text.localizedCaseInsensitiveContains(value)
                || author.localizedCaseInsensitiveContains(value)
                || message.attachments.contains {
                    $0.accessibilityLabel.localizedCaseInsensitiveContains(value)
                }
        }
    }

    func mentionCandidates(
        query: String,
        people: [PrototypePerson],
        currentProfileID: String
    ) -> [PrototypePerson] {
        guard isGroup else { return [] }
        let memberIDs = Set(members.map(\.personID))
        return people.filter {
            memberIDs.contains($0.id)
                && $0.id != currentProfileID
                && (query.isEmpty || $0.name.localizedCaseInsensitiveContains(query))
        }
    }

    mutating func toggleReaction(
        emoji: String,
        messageID: String,
        currentProfileID: String
    ) {
        guard PrototypeReaction.supportedEmoji.contains(emoji) else { return }
        mutateMessage(messageID) { message in
            guard !message.isDeleted else { return }
            if let index = message.reactions.firstIndex(where: { $0.emoji == emoji }) {
                if message.reactions[index].personIDs.contains(currentProfileID) {
                    message.reactions[index].personIDs.removeAll { $0 == currentProfileID }
                    if message.reactions[index].personIDs.isEmpty {
                        message.reactions.remove(at: index)
                    }
                } else {
                    message.reactions[index].personIDs.append(currentProfileID)
                }
            } else {
                message.reactions.append(
                    PrototypeReaction(emoji: emoji, personIDs: [currentProfileID])
                )
            }
        }
    }

    mutating func deleteMessage(_ messageID: String, currentProfileID: String) {
        mutateMessage(messageID) { message in
            guard message.authorID == currentProfileID, !message.isDeleted else { return }
            message.deletionState = .deletedByCurrentProfile
            message.text = ""
            message.attachments = []
            message.reactions = []
            message.replyToMessageID = nil
        }
    }

    mutating func retryMessage(_ messageID: String, currentProfileID: String) {
        mutateMessage(messageID) { message in
            guard message.authorID == currentProfileID,
                  message.deliveryState == .failed,
                  !message.isDeleted
            else { return }
            message.deliveryState = .sent
        }
    }

    mutating func leave(currentProfileID: String, now: Date = .now) -> Bool {
        guard isGroup, listState.membershipState == .active else { return false }
        if isCurrentProfileAdmin(currentProfileID),
           members.filter({ $0.role == .admin }).count == 1 {
            return false
        }
        appendEvent(.left(personID: currentProfileID), now: now)
        members.removeAll { $0.personID == currentProfileID }
        listState.membershipState = .left
        listState.unreadCount = 0
        listState.isMarkedUnread = false
        listState.muteDuration = nil
        listState.activityDate = now
        return true
    }

    mutating func mutateMessage(
        _ messageID: String,
        mutation: (inout PrototypeMessage) -> Void
    ) {
        guard let index = timeline.firstIndex(where: { $0.id == messageID }),
              case var .message(message) = timeline[index]
        else { return }
        mutation(&message)
        timeline[index] = .message(message)
    }
}

enum PrototypeGalleryLayout: Equatable {
    case one, two, three, four, five, overflow(Int)

    init(count: Int) {
        switch count {
        case ...1: self = .one
        case 2: self = .two
        case 3: self = .three
        case 4: self = .four
        case 5: self = .five
        default: self = .overflow(max(0, count - 6))
        }
    }

    var visibleCount: Int {
        switch self {
        case .one: 1
        case .two: 2
        case .three: 3
        case .four: 4
        case .five: 5
        case .overflow: 6
        }
    }
}

enum PrototypeMessageGrouping {
    static func belongsToSameCluster(
        _ first: PrototypeMessage,
        _ second: PrototypeMessage,
        calendar: Calendar = .autoupdatingCurrent
    ) -> Bool {
        first.authorID == second.authorID
            && calendar.isDate(first.sentAt, inSameDayAs: second.sentAt)
            && second.sentAt.timeIntervalSince(first.sentAt) <= 300
    }
}
