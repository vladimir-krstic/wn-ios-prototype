import Foundation

struct PrototypeConversationMessage: Identifiable, Equatable {
    enum Content: Equatable {
        case text(String)
        case photo(Data)
        case file(String)
    }

    let id: Int
    let content: Content
}

typealias FiatjafConversationMessage = PrototypeConversationMessage
typealias SupportConversationMessage = PrototypeConversationMessage

enum PrototypeConversationState {
    static func append(
        _ content: PrototypeConversationMessage.Content,
        to messages: inout [PrototypeConversationMessage],
        chats: inout [ChatListItem],
        chatID: String
    ) {
        messages.append(
            PrototypeConversationMessage(
                id: (messages.last?.id ?? -1) + 1,
                content: content
            )
        )

        guard let index = chats.firstIndex(where: { $0.id == chatID }) else {
            return
        }

        chats[index].previewAuthor = "You"
        chats[index].timestamp = "Now"

        switch content {
        case let .text(text):
            chats[index].preview = text
            chats[index].attachmentPreview = nil
        case .photo:
            chats[index].preview = ""
            chats[index].attachmentPreview = .photo
        case let .file(name):
            chats[index].preview = ""
            chats[index].attachmentPreview = .file(name)
        }
    }
}
