import Foundation

struct Person: Identifiable, Equatable, Sendable {
    let id: String
    var name: String
    var about: String
    var avatarAssetName: String?
}

struct Profile: Identifiable, Equatable, Sendable {
    let id: String
    let personID: Person.ID
    var isActive: Bool
}

struct Chat: Identifiable, Equatable, Sendable {
    enum Kind: String, Codable, Sendable {
        case direct
        case group
    }

    let id: String
    var kind: Kind
    var title: String
    var participantIDs: [Person.ID]
    var messageIDs: [Message.ID]
    var unreadCount: Int
    var isArchived: Bool
}

struct Message: Identifiable, Equatable, Sendable {
    enum DeliveryState: String, Codable, Sendable {
        case sending
        case sent
        case failed
    }

    let id: String
    let chatID: Chat.ID
    let senderID: Person.ID
    var body: String
    let sentAt: Date
    var deliveryState: DeliveryState
    var reaction: String?
}
