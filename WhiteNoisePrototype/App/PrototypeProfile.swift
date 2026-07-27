import Foundation
import UIKit

struct PrototypeProfile: Identifiable {
    let id: String
    var name: String
    let publicKey: String
    var about: String
    var nostrAddress: String
    var lightningAddress: String
    var imageURL: String
    var avatarData: Data?
    var chats: [ChatListItem]

    init(
        id: String,
        name: String,
        publicKey: String,
        about: String = "",
        nostrAddress: String = "",
        lightningAddress: String = "",
        imageURL: String = "",
        avatarData: Data? = nil,
        chats: [ChatListItem]
    ) {
        self.id = id
        self.name = name
        self.publicKey = publicKey
        self.about = about
        self.nostrAddress = nostrAddress
        self.lightningAddress = lightningAddress
        self.imageURL = imageURL
        self.avatarData = avatarData
        self.chats = chats
    }

    var shortPublicKey: String {
        guard publicKey.count > 17 else {
            return publicKey
        }

        return "\(publicKey.prefix(12))…\(publicKey.suffix(4))"
    }

    var initial: String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .first
            .map { String($0).uppercased() }
            ?? "?"
    }

    var unreadCount: Int {
        chats.reduce(into: 0) { count, chat in
            guard !chat.isArchived, chat.isUnread else {
                return
            }

            count += max(chat.unreadCount, 1)
        }
    }
}

extension PrototypeProfile {
    private static let marmotaAvatarData = UIImage(
        named: "ProfileAvatarMarmota"
    )?.pngData()

    private static func avatarData(named assetName: String) -> Data? {
        UIImage(named: assetName)?.jpegData(compressionQuality: 0.9)
    }

    static let marmota = PrototypeProfile(
        id: "marmota",
        name: "Marmota",
        publicKey: "npub1m8z7q4k6v2c9r5t3y8p4s7h2d6n9w3x5j8f4u7e2a6k9q8x4k",
        about: "Quietly making plans and sending good links.",
        nostrAddress: "marmota@whitenoise.example",
        lightningAddress: "marmota@pay.example",
        avatarData: marmotaAvatarData,
        chats: ChatListFixtures.populated
    )

    static let quietCurrent = PrototypeProfile(
        id: "quiet-current",
        name: "Quiet Current",
        publicKey: "npub1q2v9n6t4r7c3x8m5k2w9p6s4y7h3d8f5j2a9e6u4z7n1m2d9",
        avatarData: avatarData(named: "ProfileAvatarQuietCurrent"),
        chats: ChatListFixtures.empty
    )

    static let fuzzyMarmot = PrototypeProfile(
        id: "fuzzy-marmot",
        name: "Fuzzy Marmot",
        publicKey: "npub1f6k3r8w2v9c5m7t4y1p8s6h3d9n2x5j7a4e8u6z3q9k1p7v2",
        avatarData: marmotaAvatarData,
        chats: ChatListFixtures.empty
    )

    static let silverFern = PrototypeProfile(
        id: "silver-fern",
        name: "Silver Fern",
        publicKey: "npub1s4h8c2y7v5m9r3t6p1w8d4n7x2j5a9e3u6z8q4k7c2m1f3k8",
        avatarData: avatarData(named: "ProfileAvatarSilverFern"),
        chats: ChatListFixtures.empty
    )

    static let nightArchive = PrototypeProfile(
        id: "night-archive",
        name: "Night Archive",
        publicKey: "npub1n7d2p5x9v4c8m3t6y1s7h5k2j9a4e8u3z6q1r7w5f2m9w6r4",
        avatarData: avatarData(named: "ProfileAvatarNightArchive"),
        chats: ChatListFixtures.empty
    )

    static let amberSignal = PrototypeProfile(
        id: "amber-signal",
        name: "Amber Signal",
        publicKey: "npub1c9m4v7q2r8t5y3p6s1h9d4n7x2j5a8e3u6z1k4w7f9m2x9q2",
        avatarData: avatarData(named: "ProfileAvatarAmberSignal"),
        chats: ChatListFixtures.empty
    )

    static let tidalEcho = PrototypeProfile(
        id: "tidal-echo",
        name: "Tidal Echo",
        publicKey: "npub1t3r8k6z2v9c5m7y4p1s8h3d6n9x2j5a7e4u8q6w3f9k1s4m7",
        avatarData: avatarData(named: "ProfileAvatarTidalEcho"),
        chats: ChatListFixtures.empty
    )

    static func signedUp(name: String) -> PrototypeProfile {
        let normalizedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return PrototypeProfile(
            id: "added-profile",
            name: normalizedName.isEmpty ? "Pebble" : normalizedName,
            publicKey: "npub1p8c4y6m2v9r5t7s3h1d8n4x6j2a9e5u7z3q8w4f6k1m9c5n7",
            avatarData: marmotaAvatarData,
            chats: ChatListFixtures.empty
        )
    }

    static let initialProfiles: [PrototypeProfile] = [
        .marmota,
    ]

    static let showcasePseudonyms: [PrototypeProfile] = [
        .quietCurrent,
        .silverFern,
        .nightArchive,
        .amberSignal,
        .tidalEcho,
    ]

    static let multipleProfileFixtures: [PrototypeProfile] = [
        .marmota,
    ] + showcasePseudonyms

    static let postAddProfileFixtures: [PrototypeProfile] = [
        .signedUp(name: "Pebble"),
        .marmota,
    ] + showcasePseudonyms
}
