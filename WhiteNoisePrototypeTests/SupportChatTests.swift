import Testing
@testable import WhiteNoisePrototype

@Suite("White Noise Support chat")
struct SupportChatTests {
    @Test("Starting support never creates a duplicate")
    func supportChatIsUnique() {
        var profile = PrototypeProfile.pebble

        let first = profile.openOrCreateSupportChat()
        let second = profile.openOrCreateSupportChat()

        #expect(first == ChatListFixtures.supportChatID)
        #expect(second == first)
        #expect(profile.chats.count == 1)
        #expect(profile.chats.first?.id == ChatListFixtures.supportChatID)
        #expect(profile.chats.first?.timeline.first?.id == "white-noise-support-guidance")
        #expect(profile.chats.first?.messages.isEmpty == true)
    }

    @Test("Support creation requires Chat Messages relays")
    func supportRequiresRelays() {
        var profile = PrototypeProfile.pebble
        profile.relayConfiguration = .missingChatMessages

        #expect(profile.openOrCreateSupportChat() == nil)
        #expect(profile.chats.isEmpty)
    }

    @Test("Support is inserted directly after Fiatjaf")
    func supportFollowsFiatjaf() {
        var profile = PrototypeProfile.marmota
        profile.chats.removeAll { $0.id == ChatListFixtures.supportChatID }

        _ = profile.openOrCreateSupportChat()

        let fiatjafIndex = profile.chats.firstIndex { chat in
            chat.id == ChatListFixtures.fiatjafChatID
        }
        let supportIndex = profile.chats.firstIndex { chat in
            chat.id == ChatListFixtures.supportChatID
        }

        #expect(supportIndex == fiatjafIndex.map { $0 + 1 })
    }

    @Test("Appending a profile-owned message updates its chat preview")
    func appendedMessageUpdatesPreview() throws {
        var profile = PrototypeProfile.marmota
        let index = try #require(
            profile.chats.firstIndex { $0.id == ChatListFixtures.fiatjafChatID }
        )

        profile.chats[index].appendMessage(
            authorID: profile.id,
            text: "Still here after Back."
        )

        let row = profile.chats[index].row(
            people: profile.people,
            currentProfileID: profile.id
        )
        #expect(profile.chats[index].messages.last?.text == "Still here after Back.")
        #expect(row.previewAuthor == "You")
        #expect(row.preview == "Still here after Back.")
        #expect(row.timestamp == "Now")
    }
}
