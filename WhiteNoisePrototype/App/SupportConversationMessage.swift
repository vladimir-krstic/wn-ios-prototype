import Foundation

struct SupportConversationMessage: Identifiable, Equatable {
    enum Content: Equatable {
        case text(String)
        case photo(Data)
        case file(String)
    }

    let id: Int
    let content: Content
}
