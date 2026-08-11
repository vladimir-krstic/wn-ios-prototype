import Foundation
import Testing
@testable import WhiteNoisePrototype

@Suite("Authoritative chat model")
struct PrototypeChatModelTests {
    @Test("Group monograms use the first group-name letter")
    func groupMonograms() {
        #expect(prototypeGroupMonogram("") == "")
        #expect(prototypeGroupMonogram("Weekend") == "W")
        #expect(prototypeGroupMonogram(" Weekend   Walks ") == "W")
        #expect(prototypeGroupMonogram("river trail plans") == "R")
    }

    @Test("Direct chats are deduplicated and copy relays once")
    func directChatDeduplication() throws {
        var profile = PrototypeProfile.pebble
        profile.relayConfiguration = .fixtures
        let createdDirectID = profile.openOrCreateDirectChat(
            personID: "maya-chen",
            chatID: "maya-new"
        )
        let first = try #require(createdDirectID)
        let copiedRelays = try #require(profile.chats.first?.routing.relayURLs)
        profile.relayConfiguration = .missingChatMessages
        let second = profile.openOrCreateDirectChat(personID: "maya-chen", chatID: "duplicate")

        #expect(first == "maya-new")
        #expect(second == first)
        #expect(profile.chats.count == 1)
        #expect(profile.chats[0].routing.relayURLs == copiedRelays)
    }

    @Test("A new direct chat requires profile Chat Messages relays")
    func directChatCreationRequiresRelays() {
        var profile = PrototypeProfile.pebble
        profile.relayConfiguration = .missingChatMessages

        #expect(profile.openOrCreateDirectChat(personID: "maya-chen") == nil)
        #expect(profile.chats.isEmpty)
    }

    @Test("Group creation validates input, makes the profile admin, and copies relays")
    func groupCreation() throws {
        var profile = PrototypeProfile.pebble
        #expect(profile.createGroup(name: " ", description: "", avatar: .monogram("G"), selectedPersonIDs: ["maya-chen"]) == nil)
        #expect(profile.createGroup(name: "Walks", description: "Outside", avatar: .monogram("W"), selectedPersonIDs: []) == nil)

        let createdGroupID = profile.createGroup(
            id: "walks",
            name: " Walks ",
            description: " Outside ",
            avatar: .monogram("W"),
            selectedPersonIDs: ["maya-chen", "maya-chen", profile.id],
            now: Date(timeIntervalSince1970: 1_000)
        )
        let id = try #require(createdGroupID)
        let group = try #require(profile.chats.first { $0.id == id })
        #expect(group.groupName == "Walks")
        #expect(group.groupDescription == "Outside")
        #expect(group.members == [
            PrototypeGroupMember(personID: profile.id, role: .admin),
            PrototypeGroupMember(personID: "maya-chen", role: .member),
        ])
        #expect(group.routing.relayURLs == profile.relayConfiguration.availableChatMessageRelayURLs)
        #expect(group.timeline.count == 1)
    }

    @Test("A new group requires profile Chat Messages relays")
    func groupCreationRequiresRelays() {
        var profile = PrototypeProfile.pebble
        profile.relayConfiguration = .missingChatMessages

        #expect(
            profile.createGroup(
                name: "Walks",
                description: "",
                avatar: .monogram("W"),
                selectedPersonIDs: ["maya-chen"]
            ) == nil
        )
        #expect(profile.chats.isEmpty)
    }

    @Test("Support is not selectable for direct or group creation")
    func supportIsNotSelectable() {
        var profile = PrototypeProfile.marmota

        #expect(!profile.selectableChatPeople.contains { $0.id == ChatListFixtures.supportChatID })
        #expect(
            profile.createGroup(
                name: "Support Group",
                description: "",
                avatar: .monogram("S"),
                selectedPersonIDs: [ChatListFixtures.supportChatID]
            ) == nil
        )
    }

    @Test("Profile chat state is isolated")
    func profileIsolation() {
        var first = PrototypeProfile.marmota
        var second = PrototypeProfile.pebble
        let id = first.chats[0].id
        first.chats[0].draft = "Only first"
        _ = second.openOrCreateDirectChat(personID: "maya-chen", chatID: "second-maya")

        #expect(first.chats.first { $0.id == id }?.draft == "Only first")
        #expect(second.chats.first?.draft == "")
        #expect(second.chats.first?.id == "second-maya")
    }

    @Test("Every fixture chat has stable unique routing references")
    func fixtureRoutingIntegrity() {
        let profile = PrototypeProfile.marmota
        let personIDs = Set(profile.people.map(\.id))

        #expect(Set(profile.chats.map(\.id)).count == profile.chats.count)
        for chat in profile.chats {
            switch chat.kind {
            case let .direct(personID):
                #expect(personIDs.contains(personID))
            case .group:
                #expect(chat.members.allSatisfy {
                    $0.personID == profile.id || personIDs.contains($0.personID)
                })
            }
            #expect(chat.messages.allSatisfy {
                $0.authorID == profile.id || personIDs.contains($0.authorID)
            })
        }
    }

    @Test("Groups in common require active membership for both profiles")
    func groupsInCommon() throws {
        var profile = PrototypeProfile.marmota

        #expect(
            profile.groupsShared(with: "radia-perlman").map(\.id)
                == ["nostr-devs", "marmots", "project-files"]
        )
        #expect(profile.groupsShared(with: "david-chaum").map(\.id) == ["nostr-devs"])
        #expect(profile.groupsShared(with: "maya-chen").count > 3)

        let sharedGroupID = try #require(
            profile.groupsShared(with: "david-chaum").first?.id
        )
        let index = try #require(
            profile.chats.firstIndex { $0.id == sharedGroupID }
        )
        profile.chats[index].listState.membershipState = .left

        #expect(profile.groupsShared(with: "david-chaum").isEmpty)
    }

    @Test("Row previews derive from messages, deletion, failure, and ended membership")
    func rowProjection() {
        var chat = emptyDirectChat()
        chat.appendMessage(authorID: "marmota", text: "First")
        chat.appendMessage(
            authorID: "marmota",
            text: "Failed",
            now: Date(timeIntervalSince1970: 2_000)
        )
        let lastID = chat.messages.last!.id
        chat.mutateMessage(lastID) { $0.deliveryState = .failed }
        var row = chat.row(people: PrototypeChatFixtures.people(), currentProfileID: "marmota")
        #expect(row.preview == "Failed")
        #expect(row.deliveryState == .failed)

        chat.deleteMessage(lastID, currentProfileID: "marmota")
        row = chat.row(people: PrototypeChatFixtures.people(), currentProfileID: "marmota")
        #expect(row.preview == "First")

        chat.listState.membershipState = .left
        row = chat.row(people: PrototypeChatFixtures.people(), currentProfileID: "marmota")
        #expect(row.visiblePreview == "You left this chat.")
        #expect(row.deliveryState == .none)
    }

    @Test("Reply resolution preserves deleted and missing fallbacks")
    func replyResolution() {
        var chat = emptyDirectChat()
        let original = PrototypeMessage(id: "original", authorID: "maya-chen", sentAt: .now, text: "Hello")
        let reply = PrototypeMessage(id: "reply", authorID: "marmota", sentAt: .now, text: "Hi", replyToMessageID: "original")
        let missing = PrototypeMessage(id: "missing", authorID: "marmota", sentAt: .now, text: "Again", replyToMessageID: "gone")
        chat.timeline = [.message(original), .message(reply), .message(missing)]
        #expect(chat.messages.first { $0.id == reply.replyToMessageID }?.text == "Hello")
        #expect(chat.messages.first { $0.id == missing.replyToMessageID } == nil)
        chat.mutateMessage("original") { $0.deletionState = .deletedByOther }
        #expect(chat.messages.first { $0.id == "original" }?.isDeleted == true)
    }

    @Test("Reaction toggling is reversible")
    func reactionToggle() {
        var chat = emptyDirectChat()
        chat.timeline = [.message(PrototypeMessage(id: "m", authorID: "maya-chen", sentAt: .now, text: "Hi"))]
        chat.toggleReaction(emoji: "🦫", messageID: "m", currentProfileID: "marmota")
        #expect(chat.messages[0].reactions == [PrototypeReaction(emoji: "🦫", personIDs: ["marmota"])])
        chat.toggleReaction(emoji: "🦫", messageID: "m", currentProfileID: "marmota")
        #expect(chat.messages[0].reactions.isEmpty)
        chat.toggleReaction(emoji: "?", messageID: "m", currentProfileID: "marmota")
        #expect(chat.messages[0].reactions.isEmpty)
        chat.mutateMessage("m") { $0.deletionState = .deletedByOther }
        chat.toggleReaction(emoji: "❤", messageID: "m", currentProfileID: "marmota")
        #expect(chat.messages[0].reactions.isEmpty)
    }

    @Test("Gallery layouts cover one through seven")
    func galleryLayouts() {
        #expect(PrototypeGalleryLayout(count: 1) == .one)
        #expect(PrototypeGalleryLayout(count: 2) == .two)
        #expect(PrototypeGalleryLayout(count: 3) == .three)
        #expect(PrototypeGalleryLayout(count: 4) == .four)
        #expect(PrototypeGalleryLayout(count: 5) == .five)
        #expect(PrototypeGalleryLayout(count: 6) == .overflow(0))
        #expect(PrototypeGalleryLayout(count: 7) == .overflow(1))
        #expect(PrototypeGalleryLayout(count: 7).visibleCount == 6)
    }

    @Test("Composer availability follows membership, blocks, and per-chat relays")
    func composerAvailability() {
        var people = PrototypeChatFixtures.people()
        var chat = emptyDirectChat()
        #expect(chat.composerAvailability(currentProfileID: "marmota", people: people) == .available)
        chat.routing.relayURLs = []
        #expect(chat.composerAvailability(currentProfileID: "marmota", people: people) == .missingRelays)
        chat.routing = PrototypeChatRouting()
        people[people.firstIndex { $0.id == "maya-chen" }!].isBlocked = true
        #expect(chat.composerAvailability(currentProfileID: "marmota", people: people) == .blocked)
        chat.listState.membershipState = .removed
        #expect(chat.composerAvailability(currentProfileID: "marmota", people: people) == .removed)
    }

    @Test("Simulated voice recording sends or cancels predictably")
    func voiceStateMachine() {
        var state = PrototypeVoiceRecordingState.idle
        state.begin(at: Date(timeIntervalSince1970: 1))
        state.updateCancellation(isArmed: true)
        #expect(state.finish() == false)
        #expect(state == .idle)
        state.begin(at: Date(timeIntervalSince1970: 2))
        #expect(state.finish() == true)
        #expect(state == .idle)
    }

    @Test("Search covers text, sender, and attachment labels")
    func messageSearch() throws {
        let chat = try #require(PrototypeProfile.marmota.chats.first { $0.id == "maya-chen" })
        #expect(chat.matchingMessages(query: "Maya", people: PrototypeChatFixtures.people(), currentProfileID: "marmota").isEmpty == false)
        #expect(chat.matchingMessages(query: "Weekend Notes", people: PrototypeChatFixtures.people(), currentProfileID: "marmota").count == 1)
        #expect(chat.matchingMessages(query: "revised", people: PrototypeChatFixtures.people(), currentProfileID: "marmota").count == 1)
    }

    @Test("Maya is a chronological and complete direct-message showcase")
    func mayaShowcaseCatalog() throws {
        let chat = try #require(PrototypeProfile.marmota.chats.first { $0.id == "maya-chen" })
        let incoming = chat.messages.filter { $0.authorID == "maya-chen" }
        let outgoing = chat.messages.filter { $0.authorID == "marmota" }

        #expect(Set(chat.timeline.map(\.id)).count == chat.timeline.count)
        #expect(chat.timeline.map(\.date) == chat.timeline.map(\.date).sorted())
        #expect(incoming.contains { !$0.text.isEmpty && $0.text.count < 30 })
        #expect(outgoing.contains { !$0.text.isEmpty && $0.text.count < 30 })
        #expect(incoming.contains { $0.text.contains("\n") })
        #expect(outgoing.contains { $0.text.contains("\n") })
        #expect(incoming.contains { $0.text.count > 120 })
        #expect(outgoing.contains { $0.text.count > 120 })
        #expect(chat.messages.first { $0.id == "maya-3b" }?.replyToMessageID == "maya-3")
        #expect(chat.messages.first { $0.id == "maya-5" }?.replyToMessageID == "maya-4")
        #expect(chat.messages.first { $0.id == "maya-9b" }?.replyToMessageID == "maya-9")
        #expect(chat.messages.contains { $0.deletionState == .deletedByOther })
        #expect(chat.messages.contains { $0.deletionState == .deletedByCurrentProfile })
        #expect(chat.messages.contains { $0.deliveryState == .failed })
        #expect(chat.messages.contains { $0.reactions.count == 1 })
        #expect(chat.messages.contains { $0.reactions.count > 1 })

        let attachmentCounts = Set(chat.messages.map(\.attachments.count))
        #expect(attachmentCounts.isSuperset(of: [1, 2, 3]))
        #expect(chat.messages.flatMap(\.attachments).contains { if case .video = $0 { true } else { false } })
        #expect(chat.messages.flatMap(\.attachments).contains { if case .file = $0 { true } else { false } })
        #expect(chat.messages.flatMap(\.attachments).contains { if case .voice = $0 { true } else { false } })
        #expect(chat.messages.flatMap(\.attachments).contains { if case .link = $0 { true } else { false } })
        #expect(chat.messages.flatMap(\.attachments).allSatisfy { attachment in
            if case let .file(_, _, _, url) = attachment { return url != nil }
            if case let .video(_, url, _, _) = attachment { return url != nil }
            return true
        })
    }

    @Test("Weekend Walks is a chronological group and system-event showcase")
    func weekendWalksShowcaseCatalog() throws {
        let calendar = Calendar.autoupdatingCurrent
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 8, day: 8, hour: 12)))
        let group = try #require(
            PrototypeChatFixtures.chats(
                profileID: "marmota",
                relayURLs: ["wss://relay.example.com"],
                now: now
            ).first { $0.id == "weekend-walks" }
        )

        #expect(Set(group.timeline.map(\.id)).count == group.timeline.count)
        #expect(group.timeline.map(\.date) == group.timeline.map(\.date).sorted())
        guard case let .event(firstEvent)? = group.timeline.first else {
            Issue.record("Weekend Walks must begin with its creation event.")
            return
        }
        #expect(firstEvent.kind == .created(actorID: "marmota"))

        let eventCopy = Set(group.timeline.compactMap { entry -> String? in
            guard case let .event(event) = entry else { return nil }
            return PrototypeGroupEventFormatter.text(
                for: event.kind,
                profileID: "marmota",
                profileName: "Marmota",
                people: PrototypeChatFixtures.people()
            )
        })
        let requiredEvents: Set<String> = [
            "You created the group.",
            "You added Maya Chen and Elias Moreno.",
            "You added Nora Bennett.",
            "Mina Park joined the group.",
            "Leo Martins left the group.",
            "You removed Theo Grant.",
            "You made Maya Chen an admin.",
            "You removed Maya Chen as an admin.",
            "You changed the group name to Weekend Walks.",
            "You changed the group photo.",
            "You changed the group description.",
            "You removed the group description.",
        ]
        #expect(eventCopy.isSuperset(of: requiredEvents))

        let galleryCounts = Set(group.messages.map(\.attachments.count))
        #expect(galleryCounts.isSuperset(of: [4, 5, 6, 7]))
        let attachments = group.messages.flatMap(\.attachments)
        #expect(attachments.contains { if case .video = $0 { true } else { false } })
        #expect(attachments.contains { if case .file = $0 { true } else { false } })
        #expect(attachments.contains { if case .voice = $0 { true } else { false } })
        #expect(attachments.contains { if case .gif = $0 { true } else { false } })
        #expect(attachments.contains { if case .sticker = $0 { true } else { false } })
        #expect(attachments.contains { if case .location = $0 { true } else { false } })
        #expect(attachments.contains { if case .contact = $0 { true } else { false } })
        #expect(attachments.allSatisfy { attachment in
            if case let .file(_, _, _, url) = attachment { return url != nil }
            if case let .video(_, url, _, _) = attachment { return url != nil }
            return true
        })
        #expect(group.messages.contains { $0.text.contains("@Marmota") })
        #expect(group.messages.contains { $0.replyToMessageID != nil && $0.authorID == "marmota" })
        #expect(group.messages.contains { $0.replyToMessageID != nil && $0.authorID != "marmota" })
        #expect(!group.members.contains { $0.personID == "leo-martins" })
        #expect(!group.members.contains { $0.personID == "theo-grant" })

        let direct = try #require(
            PrototypeChatFixtures.chats(
                profileID: "marmota",
                relayURLs: ["wss://relay.example.com"],
                now: now
            ).first { $0.id == "maya-chen" }
        )
        let showcaseGalleryCounts = Set((direct.messages + group.messages).map(\.attachments.count))
        #expect(showcaseGalleryCounts.isSuperset(of: Set(1...7)))
        let showcaseReactionSet = Set(
            (direct.messages + group.messages).flatMap(\.reactions).map(\.emoji)
        )
        #expect(showcaseReactionSet.isSuperset(of: ["❤", "😀", "👍", "👎", "🤣", "🔥", "🦫"]))

        let separators = Set(group.timeline.map { PrototypeDateFormatter.separator(for: $0.date, now: now) })
        #expect(separators.contains("Today"))
        #expect(separators.contains("Yesterday"))
        #expect(separators.contains(where: { $0.contains("2025") }))
        let weekdayDate = try #require(calendar.date(byAdding: .day, value: -4, to: now))
        #expect(separators.contains(weekdayDate.formatted(.dateTime.weekday(.wide))))
    }

    @Test("Ended groups do not retain the active profile as a current member")
    func endedGroupMembershipMatchesListState() throws {
        let chats = PrototypeProfile.marmota.chats
        let left = try #require(chats.first { $0.id == "book-club" })
        let removed = try #require(chats.first { $0.id == "quiet-studio" })

        #expect(left.listState.membershipState == .left)
        #expect(removed.listState.membershipState == .removed)
        #expect(!left.members.contains { $0.personID == "marmota" })
        #expect(!removed.members.contains { $0.personID == "marmota" })
    }

    @Test("Ended groups retain the membership-ending event in their timeline")
    func endedGroupTimelinesExplainMembershipState() throws {
        let profile = PrototypeProfile.marmota
        let left = try #require(profile.chats.first { $0.id == "book-club" })
        let removed = try #require(profile.chats.first { $0.id == "quiet-studio" })
        let leftEvent = try #require(left.timeline.compactMap { entry -> PrototypeTimelineEvent? in
            guard case let .event(event) = entry else { return nil }
            return event
        }.last)
        let removedEvent = try #require(removed.timeline.compactMap { entry -> PrototypeTimelineEvent? in
            guard case let .event(event) = entry else { return nil }
            return event
        }.last)

        #expect(leftEvent.kind == .left(personID: profile.id))
        #expect(removedEvent.kind == .removed(actorID: "maya-chen", personID: profile.id))
        #expect(
            PrototypeGroupEventFormatter.text(
                for: leftEvent.kind,
                profileID: profile.id,
                profileName: profile.name,
                people: profile.people
            ) == "You left the group."
        )
        #expect(
            PrototypeGroupEventFormatter.text(
                for: removedEvent.kind,
                profileID: profile.id,
                profileName: profile.name,
                people: profile.people
            ) == "Maya Chen removed you from the group."
        )
    }

    @Test("Mentions filter group members only")
    func mentions() throws {
        let group = try #require(PrototypeProfile.marmota.chats.first { $0.id == "weekend-walks" })
        let candidates = group.mentionCandidates(query: "ma", people: PrototypeChatFixtures.people(), currentProfileID: "marmota")
        #expect(candidates.map(\.id) == ["maya-chen"])
    }

    @Test("Last-admin protection and successful leave")
    func leaveSafety() {
        var group = PrototypeChat(
            id: "g",
            kind: .group,
            groupName: "Group",
            groupDescription: "",
            avatar: .monogram("G"),
            members: [PrototypeGroupMember(personID: "marmota", role: .admin)],
            routing: PrototypeChatRouting(),
            timeline: [],
            emptyPreview: "",
            draft: "",
            replyToMessageID: nil,
            listState: PrototypeChatListState()
        )
        #expect(group.leave(currentProfileID: "marmota") == false)
        group.members.append(PrototypeGroupMember(personID: "maya-chen", role: .admin))
        #expect(group.leave(currentProfileID: "marmota") == true)
        #expect(group.listState.membershipState == .left)
        #expect(!group.members.contains { $0.personID == "marmota" })
    }

    @Test("Group permissions protect ordinary members and apply admin mutations")
    func groupPermissionMatrix() throws {
        var group = try #require(
            PrototypeProfile.marmota.chats.first { $0.id == "weekend-walks" }
        )
        #expect(!group.canManageGroup(currentProfileID: "maya-chen"))
        let ordinaryAdd = group.addMembers(personIDs: ["avery-stone"], actorID: "maya-chen")
        let ordinaryPromote = group.promoteMember(personID: "maya-chen", actorID: "maya-chen")
        let ordinaryRemove = group.removeMember(personID: "marmota", actorID: "maya-chen")
        #expect(!ordinaryAdd)
        #expect(!ordinaryPromote)
        #expect(!ordinaryRemove)

        let adminAdd = group.addMembers(personIDs: ["avery-stone"], actorID: "marmota")
        let adminPromote = group.promoteMember(personID: "maya-chen", actorID: "marmota")
        let adminDemote = group.demoteMember(personID: "maya-chen", actorID: "marmota")
        let adminRemove = group.removeMember(personID: "avery-stone", actorID: "marmota")
        let selfRemove = group.removeMember(personID: "marmota", actorID: "marmota")
        #expect(adminAdd)
        #expect(adminPromote)
        #expect(adminDemote)
        #expect(adminRemove)
        #expect(!selfRemove)
    }

    @Test("Every attachment class has a deterministic row projection")
    func attachmentRowProjections() {
        let people = PrototypeChatFixtures.people()
        let photo = PrototypeAttachment.photo(id: "p", source: .asset("Photo"), label: "Photo")
        let video = PrototypeAttachment.video(id: "v", url: nil, thumbnail: .asset("Video"), duration: 1)
        let file = PrototypeAttachment.file(id: "f", name: "Notes.pdf", size: 10, url: nil)
        let voice = PrototypeAttachment.voice(id: "a", resourceName: "voice", duration: 1)
        let link = PrototypeAttachment.link(id: "l", title: "Title", domain: "example.com", summary: "Summary", image: nil)
        let gif = PrototypeAttachment.gif(id: "g", assetName: "GIF", label: "GIF")
        let sticker = PrototypeAttachment.sticker(id: "s", assetName: "Sticker", label: "Sticker")
        let location = PrototypeAttachment.location(id: "o", name: "Park", address: "Main Street")
        let contact = PrototypeAttachment.contact(id: "c", personID: "maya-chen")

        #expect(photo.listPreview(people: people) == .photo)
        #expect(video.listPreview(people: people) == .video)
        #expect(file.listPreview(people: people) == .file("Notes.pdf"))
        #expect(voice.listPreview(people: people) == .voiceMessage)
        #expect(link.listPreview(people: people) == .link)
        #expect(gif.listPreview(people: people) == .gif)
        #expect(sticker.listPreview(people: people) == .sticker)
        #expect(location.listPreview(people: people) == .location)
        #expect(contact.listPreview(people: people) == .contact("Maya Chen"))
    }

    @Test("Calendar-date fixtures have plausible message times and Support keeps its stable row date")
    func fixtureDateFidelity() throws {
        let calendar = Calendar.autoupdatingCurrent
        let now = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 8, day: 8, hour: 18))
        )
        let chats = PrototypeChatFixtures.chats(
            profileID: "marmota",
            relayURLs: ["wss://relay.example.com"],
            now: now
        )
        let calendarDateIDs = Set(
            ChatListFixtures.populated
                .filter { $0.timestamp.contains("/") }
                .map(\.id)
        )
        let datedMessages = chats
            .filter { calendarDateIDs.contains($0.id) }
            .flatMap(\.messages)
        #expect(!datedMessages.isEmpty)
        #expect(datedMessages.allSatisfy { calendar.component(.hour, from: $0.sentAt) != 0 })

        let support = try #require(chats.first { $0.id == ChatListFixtures.supportChatID })
        #expect(
            support.row(people: PrototypeChatFixtures.people(), currentProfileID: "marmota", now: now)
                .timestamp == "Thursday"
        )
    }

    @Test("Date separators cover relative, recent, and full-date states")
    func dateSeparators() throws {
        let calendar = Calendar.autoupdatingCurrent
        let now = try #require(calendar.date(from: DateComponents(year: 2024, month: 3, day: 20, hour: 12)))
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: now))
        let recent = try #require(calendar.date(byAdding: .day, value: -3, to: now))
        let old = try #require(calendar.date(byAdding: .day, value: -400, to: now))

        #expect(PrototypeDateFormatter.separator(for: now, now: now) == "Today")
        #expect(PrototypeDateFormatter.separator(for: yesterday, now: now) == "Yesterday")
        #expect(PrototypeDateFormatter.separator(for: recent, now: now) == recent.formatted(.dateTime.weekday(.wide)))
        #expect(PrototypeDateFormatter.separator(for: old, now: now).contains("2023"))
    }

    @Test("Chat-list timestamps derive from activity dates and visible content")
    func chatListTimestampProjection() throws {
        let calendar = Calendar.autoupdatingCurrent
        let now = try #require(calendar.date(from: DateComponents(year: 2024, month: 3, day: 20, hour: 12)))
        let earlier = try #require(calendar.date(byAdding: .day, value: -3, to: now))
        var chat = emptyDirectChat()
        chat.timeline = [
            .message(PrototypeMessage(id: "earlier", authorID: "maya-chen", sentAt: earlier, text: "Earlier")),
            .message(PrototypeMessage(id: "latest", authorID: "marmota", sentAt: now.addingTimeInterval(-120), text: "Latest")),
        ]

        var row = chat.row(
            people: PrototypeChatFixtures.people(),
            currentProfileID: "marmota",
            now: now
        )
        #expect(row.timestamp == "2m")

        chat.deleteMessage("latest", currentProfileID: "marmota")
        row = chat.row(
            people: PrototypeChatFixtures.people(),
            currentProfileID: "marmota",
            now: now
        )
        #expect(row.preview == "Earlier")
        #expect(row.timestamp == earlier.formatted(.dateTime.weekday(.wide)))
    }

    @Test("A group event becomes authoritative row activity")
    func groupEventRowProjection() throws {
        let now = Date(timeIntervalSince1970: 2_000_000_000)
        var group = try #require(
            PrototypeProfile.marmota.chats.first { $0.id == "weekend-walks" }
        )
        group.appendEvent(
            .changedName(actorID: "marmota", name: "River Walks"),
            now: now
        )

        let row = group.row(
            people: PrototypeChatFixtures.people(),
            currentProfileID: "marmota",
            now: now
        )
        #expect(row.preview == "You changed the group name to River Walks.")
        #expect(row.previewAuthor == nil)
        #expect(row.timestamp == "Now")
    }

    @Test("Chat relays normalize, reject duplicates, allow final removal, and stay independent")
    func chatRelays() {
        var first = PrototypeChatRouting(relayURLs: ["wss://Relay.Example.com/"])
        let second = first
        #expect(first.relayURLs == ["wss://relay.example.com"])
        #expect(first.add("wss://relay.example.com/") == false)
        #expect(first.add("https://relay.example.com") == false)
        #expect(first.add("wss://second.example.com/path/") == true)
        first.remove("wss://relay.example.com")
        first.remove("wss://second.example.com/path")
        #expect(first.relayURLs.isEmpty)
        #expect(!first.isDefaultConfiguration)
        first.restoreDefaults()
        #expect(first.relayURLs == ["wss://relay.example.com"])
        #expect(first.isDefaultConfiguration)
        #expect(second.relayURLs == ["wss://relay.example.com"])
    }

    @Test("Message clusters respect author, day, and five-minute gap")
    func messageGrouping() {
        let base = Date(timeIntervalSince1970: 10_000)
        let a = PrototypeMessage(id: "a", authorID: "maya", sentAt: base)
        let b = PrototypeMessage(id: "b", authorID: "maya", sentAt: base.addingTimeInterval(299))
        let c = PrototypeMessage(id: "c", authorID: "maya", sentAt: base.addingTimeInterval(301))
        let d = PrototypeMessage(id: "d", authorID: "other", sentAt: base.addingTimeInterval(30))
        #expect(PrototypeMessageGrouping.belongsToSameCluster(a, b))
        #expect(!PrototypeMessageGrouping.belongsToSameCluster(a, c))
        #expect(!PrototypeMessageGrouping.belongsToSameCluster(a, d))
    }

    private func emptyDirectChat() -> PrototypeChat {
        PrototypeChat(
            id: "direct",
            kind: .direct(personID: "maya-chen"),
            groupName: "Maya Chen",
            groupDescription: "",
            avatar: .monogram("M"),
            members: [],
            routing: PrototypeChatRouting(),
            timeline: [],
            emptyPreview: "No messages yet.",
            draft: "",
            replyToMessageID: nil,
            listState: PrototypeChatListState()
        )
    }
}
