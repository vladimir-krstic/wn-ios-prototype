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
            chat.id == "fiatjaf"
        }
        let supportIndex = chats.firstIndex { chat in
            chat.id == ChatListFixtures.supportChatID
        }

        #expect(supportIndex == fiatjafIndex.map { $0 + 1 })
    }
}
