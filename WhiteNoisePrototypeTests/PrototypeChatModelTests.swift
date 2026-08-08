import Foundation
import Testing
@testable import WhiteNoisePrototype

@Suite("Authoritative chat model")
struct PrototypeChatModelTests {
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

    @Test("Mentions filter group members only")
    func mentions() throws {
        let group = try #require(PrototypeProfile.marmota.chats.first { $0.id == "weekend-walks" })
        let candidates = group.mentionCandidates(query: "ma", people: PrototypeChatFixtures.people(), currentProfileID: "marmota")
        #expect(candidates.map(\.id) == ["maya-chen", "leo-martins"])
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
            listState: PrototypeChatListState(timestampLabel: "Now")
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
        let photo = PrototypeAttachment.photo(id: "p", source: .asset("Photo"), label: "Photo")
        let video = PrototypeAttachment.video(id: "v", url: nil, thumbnail: .asset("Video"), duration: 1)
        let file = PrototypeAttachment.file(id: "f", name: "Notes.pdf", size: 10, url: nil)
        let voice = PrototypeAttachment.voice(id: "a", resourceName: "voice", duration: 1)
        let link = PrototypeAttachment.link(id: "l", title: "Title", domain: "example.com", summary: "Summary", image: nil)
        let gif = PrototypeAttachment.gif(id: "g", assetName: "GIF", label: "GIF")
        let sticker = PrototypeAttachment.sticker(id: "s", assetName: "Sticker", label: "Sticker")
        let location = PrototypeAttachment.location(id: "o", name: "Park", address: "Main Street")
        let contact = PrototypeAttachment.contact(id: "c", personID: "maya-chen")

        #expect(photo.listPreview == .photo)
        #expect(video.listPreview == .video)
        #expect(file.listPreview == .file("Notes.pdf"))
        #expect(voice.listPreview == .voiceMessage)
        #expect(link.listPreview == .link)
        #expect(gif.listPreview == .gif)
        #expect(sticker.listPreview == .sticker)
        #expect(location.listPreview == .location)
        #expect(contact.listPreview == .contact("Contact"))
    }

    @Test("Date separators cover relative, recent, and full-date states")
    func dateSeparators() throws {
        let calendar = Calendar.autoupdatingCurrent
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 8, day: 8, hour: 12)))
        let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: now))
        let recent = try #require(calendar.date(byAdding: .day, value: -3, to: now))
        let old = try #require(calendar.date(byAdding: .day, value: -400, to: now))

        #expect(PrototypeDateFormatter.separator(for: now, now: now) == "Today")
        #expect(PrototypeDateFormatter.separator(for: yesterday, now: now) == "Yesterday")
        #expect(PrototypeDateFormatter.separator(for: recent, now: now) == recent.formatted(.dateTime.weekday(.wide)))
        #expect(PrototypeDateFormatter.separator(for: old, now: now).contains("2025"))
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
            listState: PrototypeChatListState(timestampLabel: "Now")
        )
    }
}
