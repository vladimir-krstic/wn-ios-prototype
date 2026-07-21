import Foundation

enum FixtureUniverse {
    enum CredentialClassification: Equatable, Sendable {
        case neutral
        case accepted(profileID: Profile.ID)
        case existingProfile(profileID: Profile.ID)
        case invalid
    }

    enum Onboarding {
        static let credentialCompletionLength = 32
        static let acceptedCredential = "WNPROTO-ACCEPTED-MAYA-0000000001"
        static let existingProfileCredential = "WNPROTO-EXISTING-MAYA-0000000001"
        static let invalidCompleteCredential = "WNPROTO-INVALID-INPUT-0000000001"

        static let acceptedQRCodePayload = "wnproto://private-key/credential.maya.accepted"
        static let invalidQRCodePayload = "wnproto://private-key/credential.unknown"

        static let acceptedProfileID = "profile.maya"
        static let defaultSignUpInitials = "QP"
        static let defaultSignUpPerson = Person(
            id: "person.quiet-pine",
            name: "Quiet Pine",
            about: "",
            avatarAssetName: nil
        )
        static let defaultSignUpProfile = Profile(
            id: OnboardingFixtureID.profileQuietPine.rawValue,
            personID: defaultSignUpPerson.id,
            isActive: true
        )

        static func classifyCredential(_ value: String) -> CredentialClassification {
            guard value.count >= credentialCompletionLength else {
                return .neutral
            }

            switch value {
            case acceptedCredential:
                return .accepted(profileID: acceptedProfileID)
            case existingProfileCredential:
                return .existingProfile(profileID: acceptedProfileID)
            default:
                return .invalid
            }
        }

        static func classifyQRCodePayload(_ value: String) -> CredentialClassification {
            value == acceptedQRCodePayload
                ? .accepted(profileID: acceptedProfileID)
                : .invalid
        }
    }

    static let fixedClock = Date(timeIntervalSince1970: 1_781_808_120)

    static let people: [Person] = [
        Person(id: "person.maya", name: "Maya Chen", about: "Photographer and weekend hiker.", avatarAssetName: "AvatarMaya"),
        Person(id: "person.noor", name: "Noor Haddad", about: "Always has a thoughtful reading recommendation.", avatarAssetName: nil),
        Person(id: "person.luca", name: "Luca Petrović", about: "Makes useful things and very strong coffee.", avatarAssetName: "AvatarLuca"),
        Person(id: "person.priya", name: "Priya Shah", about: "Organizes the plan before anyone asks.", avatarAssetName: "AvatarPriya"),
        Person(id: "person.eli", name: "Eli Okafor", about: "Sends voice notes from long walks.", avatarAssetName: nil),
        Person(id: "person.sofia", name: "Sofia Alvarez", about: "Collects trail maps and tiny notebooks.", avatarAssetName: "AvatarSofia"),
        Person(id: "person.jordan", name: "Jordan Kim", about: "Usually replies after the second coffee.", avatarAssetName: nil),
        Person(id: "person.ines", name: "Ines Laurent", about: "Patient tester of every edge case.", avatarAssetName: "AvatarInes")
    ]

    static let profiles = [
        Profile(id: "profile.maya", personID: "person.maya", isActive: true)
    ]

    static let messages: [Message] = [
        Message(
            id: "message.noor.001",
            chatID: "chat.maya-noor",
            senderID: "person.noor",
            body: "Saturday morning works. I’ll bring tea and the small first-aid kit.",
            sentAt: Date(timeIntervalSince1970: 1_750_269_600),
            deliveryState: .sent,
            reaction: "👍"
        )
    ]

    static let chats: [Chat] = [
        Chat(
            id: "chat.maya-noor",
            kind: .direct,
            title: "Noor Haddad",
            participantIDs: ["person.maya", "person.noor"],
            messageIDs: ["message.noor.001"],
            unreadCount: 1,
            isArchived: false
        )
    ]
}
