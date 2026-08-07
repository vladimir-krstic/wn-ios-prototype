import Testing
@testable import WhiteNoisePrototype

@Suite("White Noise Support chat")
struct SupportChatTests {
    @Test("Starting support never creates a duplicate")
    func supportChatIsUnique() {
        var chats: [ChatListItem] = []

        ChatListFixtures.ensureSupportChat(in: &chats)
        ChatListFixtures.ensureSupportChat(in: &chats)

        #expect(chats.count == 1)
        #expect(chats.first?.id == ChatListFixtures.supportChatID)
    }

    @Test("Support is inserted directly after Fiatjaf")
    func supportFollowsFiatjaf() {
        var chats = ChatListFixtures.populated.filter { chat in
            chat.id != ChatListFixtures.supportChatID
        }

        ChatListFixtures.ensureSupportChat(in: &chats)

        let fiatjafIndex = chats.firstIndex { chat in
            chat.id == ChatListFixtures.fiatjafChatID
        }
        let supportIndex = chats.firstIndex { chat in
            chat.id == ChatListFixtures.supportChatID
        }

        #expect(supportIndex == fiatjafIndex.map { $0 + 1 })
    }

    @Test("Appending a profile-owned message updates its chat preview")
    func appendedMessageUpdatesPreview() throws {
        var messages: [PrototypeConversationMessage] = []
        var chats = ChatListFixtures.populated

        PrototypeConversationState.append(
            .text("Still here after Back."),
            to: &messages,
            chats: &chats,
            chatID: ChatListFixtures.fiatjafChatID
        )

        let chat = try #require(
            chats.first { $0.id == ChatListFixtures.fiatjafChatID }
        )
        #expect(messages.map(\.content) == [.text("Still here after Back.")])
        #expect(chat.previewAuthor == "You")
        #expect(chat.preview == "Still here after Back.")
        #expect(chat.timestamp == "Now")
    }
}
