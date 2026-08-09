import Foundation

private final class PrototypeChatFixtureBundleToken {}

enum PrototypeChatFixtures {
    static let groupIDs: Set<String> = [
        "nostr-devs", "marmots", "weekend-walks", "product-circle",
        "book-club", "quiet-studio", "project-files", "neighborhood",
        "reading-list", "family-group", "sticker-swap", "road-trip",
        "garden-club", "old-studio", "design-notes",
    ]

    static func people() -> [PrototypePerson] {
        var result: [PrototypePerson] = []

        for row in ChatListFixtures.populated where !groupIDs.contains(row.id) {
            result.append(
                PrototypePerson(
                    id: row.id,
                    name: row.title,
                    about: about(for: row.id),
                    nostrAddress: "\(row.id)@whitenoise.example",
                    avatar: row.avatar,
                    isFollowing: row.id != "satoshi-nakamoto"
                )
            )
        }

        let extras: [PrototypePerson] = [
            PrototypePerson(id: "tim", name: "Tim", avatar: .monogram("T")),
            PrototypePerson(id: "jude", name: "Jude", avatar: .monogram("J")),
            PrototypePerson(id: "sam", name: "Sam", avatar: .monogram("S")),
            PrototypePerson(id: "owen", name: "Owen", avatar: .monogram("O")),
            PrototypePerson(id: "remy", name: "Remy", avatar: .monogram("R")),
            PrototypePerson(id: "iris", name: "Iris", avatar: .monogram("I")),
            PrototypePerson(id: "noah", name: "Noah", avatar: .monogram("N")),
            PrototypePerson(id: "avery-stone", name: "Avery Stone", avatar: .monogram("A")),
            PrototypePerson(id: "theo-grant", name: "Theo Grant", avatar: .monogram("T")),
        ]

        for person in extras where !result.contains(where: { $0.id == person.id }) {
            result.append(person)
        }
        return result
    }

    static func chats(
        profileID: String,
        relayURLs: [String],
        now: Date = .now
    ) -> [PrototypeChat] {
        ChatListFixtures.populated.map { row in
            var chat = baseChat(
                from: row,
                profileID: profileID,
                relayURLs: relayURLs,
                now: now
            )
            switch row.id {
            case "maya-chen":
                chat.timeline = mayaTimeline(profileID: profileID, now: now)
            case "weekend-walks":
                chat.timeline = weekendTimeline(profileID: profileID, now: now)
            case ChatListFixtures.fiatjafChatID:
                chat.timeline = fiatjafTimeline(profileID: profileID, now: now)
            case ChatListFixtures.supportChatID:
                chat.timeline = [supportNotice(now: seedDate(for: row.timestamp, now: now))]
                chat.emptyPreview = "Ask a question, report a problem, or share a suggestion."
            default:
                break
            }
            if chat.draft.isEmpty, let latestDate = chat.timeline.last?.date {
                chat.listState.activityDate = latestDate
            }
            return chat
        }
    }

    static func supportNotice(now: Date) -> PrototypeTimelineEntry {
        .notice(
            PrototypeTimelineNotice(
                id: "white-noise-support-guidance",
                date: now,
                text: "How can we help? Ask a question, report a problem, or share a suggestion. We’ll reply here."
            )
        )
    }

    private static func baseChat(
        from row: ChatListItem,
        profileID: String,
        relayURLs: [String],
        now: Date
    ) -> PrototypeChat {
        let isGroup = groupIDs.contains(row.id)
        let authorID = seedAuthorID(for: row, profileID: profileID)
        let attachments = seedAttachments(row.attachmentPreview, chatID: row.id)
        let message = PrototypeMessage(
            id: "\(row.id)-seed",
            authorID: authorID,
            sentAt: seedDate(for: row.timestamp, now: now),
            text: row.isDraft ? "" : row.preview,
            attachments: attachments,
            deliveryState: row.deliveryState == .failed ? .failed : .sent
        )
        var members: [PrototypeGroupMember] = []
        if isGroup {
            let currentRole: PrototypeGroupRole = row.id == "product-circle" ? .member : .admin
            if row.membershipState == .active {
                members = [PrototypeGroupMember(personID: profileID, role: currentRole)]
            }
            var currentMemberIDs = row.id == "weekend-walks"
                ? ["maya-chen", "mina-park", "elias-moreno", "nora-bennett"]
                : ["maya-chen", "mina-park", "elias-moreno", "nora-bennett", "leo-martins"]

            switch row.id {
            case "nostr-devs":
                currentMemberIDs += ["radia-perlman", "david-chaum"]
            case "marmots", "project-files":
                currentMemberIDs.append("radia-perlman")
            default:
                break
            }

            for personID in currentMemberIDs {
                let role: PrototypeGroupRole = row.id == "product-circle" && personID == "maya-chen"
                    ? .admin
                    : .member
                members.append(PrototypeGroupMember(personID: personID, role: role))
            }
            if authorID != profileID && !members.contains(where: { $0.personID == authorID }) {
                members.append(PrototypeGroupMember(personID: authorID, role: .member))
            }
        }

        return PrototypeChat(
            id: row.id,
            kind: isGroup ? .group : .direct(personID: row.id),
            groupName: row.title,
            groupDescription: isGroup ? groupDescription(for: row.id) : "",
            avatar: row.avatar,
            members: members,
            routing: PrototypeChatRouting(relayURLs: relayURLs),
            timeline: row.isDraft || row.id == ChatListFixtures.supportChatID
                ? []
                : [.message(message)],
            emptyPreview: row.id == ChatListFixtures.supportChatID ? row.preview : "",
            draft: row.isDraft ? row.preview : "",
            replyToMessageID: nil,
            listState: PrototypeChatListState(
                membershipState: row.membershipState,
                isArchived: row.isArchived,
                isPinned: row.isPinned,
                unreadCount: row.unreadCount,
                isMarkedUnread: row.isMarkedUnread,
                muteDuration: row.muteDuration,
                activityDate: seedDate(for: row.timestamp, now: now)
            )
        )
    }

    private static func mayaTimeline(profileID: String, now: Date) -> [PrototypeTimelineEntry] {
        let inception = now.addingTimeInterval(-45 * 86_400)
        let mediaDay = now.addingTimeInterval(-12 * 86_400)
        let yesterday = now.addingTimeInterval(-86_400)
        let today = now.addingTimeInterval(-3_600)
        let photo = PrototypeAttachment.photo(
            id: "maya-photo-one",
            source: .asset("FiatjafMediaFox"),
            label: "Fox beside a tree"
        )
        let video = PrototypeAttachment.video(
            id: "maya-video",
            url: showcaseVideoURL,
            thumbnail: .asset("ProfileAvatarPebble"),
            duration: 8
        )

        return [
            .message(PrototypeMessage(id: "maya-1", authorID: "maya-chen", sentAt: inception, text: "Hi—Maya here.")),
            .message(PrototypeMessage(id: "maya-2", authorID: profileID, sentAt: inception.addingTimeInterval(60), text: "Hi Maya. Good to meet you.")),
            .message(PrototypeMessage(id: "maya-3", authorID: "maya-chen", sentAt: inception.addingTimeInterval(150), text: "I pulled the first draft together.\nCould you look at the opening and the final paragraph?")),
            .message(PrototypeMessage(id: "maya-3b", authorID: profileID, sentAt: inception.addingTimeInterval(240), text: "Yes. I’ll read both before lunch.", replyToMessageID: "maya-3")),
            .message(PrototypeMessage(id: "maya-3c", authorID: profileID, sentAt: inception.addingTimeInterval(300), text: "I’ll keep the opening intact and tighten the middle.\nThe ending can be direct enough to read quickly without losing the context that makes the recommendation useful.")),
            .message(PrototypeMessage(id: "maya-3d", authorID: "maya-chen", sentAt: inception.addingTimeInterval(390), text: "That sounds right. The full background matters, but the main idea should still be obvious to someone who only has a minute to read it.")),
            .message(PrototypeMessage(id: "maya-3e", authorID: "maya-chen", sentAt: inception.addingTimeInterval(450), text: "I marked the sentence I’d keep.")),
            .message(PrototypeMessage(id: "maya-3f", authorID: profileID, sentAt: inception.addingTimeInterval(540), text: "I agree. **The shorter version works better.** I’m using this as the reference: https://whitenoise.chat")),

            .message(PrototypeMessage(id: "maya-4", authorID: profileID, sentAt: mediaDay, text: "This is the latest photo.", attachments: [photo], reactions: [PrototypeReaction(emoji: "❤", personIDs: ["maya-chen"])])),
            .message(PrototypeMessage(id: "maya-5", authorID: "maya-chen", sentAt: mediaDay.addingTimeInterval(120), text: "The crop looks great.", replyToMessageID: "maya-4")),
            .message(PrototypeMessage(id: "maya-6", authorID: "maya-chen", sentAt: mediaDay.addingTimeInterval(210), attachments: [photo])),
            .message(PrototypeMessage(id: "maya-7", authorID: profileID, sentAt: mediaDay.addingTimeInterval(330), text: "These two could sit together.", attachments: [
                .photo(id: "maya-two-a", source: .asset("FiatjafMediaMarmot"), label: "Marmot in grass"),
                .photo(id: "maya-two-b", source: .asset("FiatjafMediaSloth"), label: "Sloth in a tree"),
            ])),
            .message(PrototypeMessage(id: "maya-8", authorID: "maya-chen", sentAt: mediaDay.addingTimeInterval(450), text: "And these tell the full sequence.", attachments: [
                .photo(id: "maya-three-a", source: .asset("FiatjafMediaBadger"), label: "Badger in grass"),
                .photo(id: "maya-three-b", source: .asset("FiatjafMediaFox"), label: "Fox portrait"),
                .photo(id: "maya-three-c", source: .asset("FiatjafMediaOstrich"), label: "Ostrich in a field"),
            ])),
            .message(PrototypeMessage(id: "maya-9", authorID: "maya-chen", sentAt: mediaDay.addingTimeInterval(570), text: "Here’s the short clip.", attachments: [video])),
            .message(PrototypeMessage(id: "maya-9b", authorID: profileID, sentAt: mediaDay.addingTimeInterval(660), text: "That movement makes the sequence much clearer.", replyToMessageID: "maya-9")),
            .message(PrototypeMessage(id: "maya-9c", authorID: profileID, sentAt: mediaDay.addingTimeInterval(750), text: "This pairing is probably the strongest.", attachments: [photo, video])),

            .message(PrototypeMessage(id: "maya-10", authorID: "maya-chen", sentAt: yesterday, text: "Here are the notes from our last pass.", attachments: [bundledFile(id: "maya-file", name: "Weekend Notes.pdf", resourceName: "WeekendNotes")])),
            .message(PrototypeMessage(id: "maya-11", authorID: profileID, sentAt: yesterday.addingTimeInterval(120), attachments: [.voice(id: "maya-voice", resourceName: PrototypeVoiceSample.resourceName, duration: PrototypeVoiceSample.duration)])),
            .message(PrototypeMessage(id: "maya-12", authorID: "maya-chen", sentAt: yesterday.addingTimeInterval(240), text: "This is the reference I mentioned.", attachments: [.link(id: "maya-link", title: "White Noise", domain: "whitenoise.chat", summary: "Private, resilient messaging for people and groups.", image: .asset("WhiteNoiseMark"))])),

            .message(PrototypeMessage(id: "maya-13", authorID: "maya-chen", sentAt: today, deletionState: .deletedByOther)),
            .message(PrototypeMessage(id: "maya-14", authorID: profileID, sentAt: today.addingTimeInterval(120), deletionState: .deletedByCurrentProfile)),
            .message(PrototypeMessage(id: "maya-15", authorID: profileID, sentAt: today.addingTimeInterval(240), text: "Replying to a message that’s no longer available.", replyToMessageID: "maya-13")),
            .message(PrototypeMessage(id: "maya-16", authorID: profileID, sentAt: today.addingTimeInterval(360), text: "I’ll send the revised version now.", deliveryState: .failed)),
            .message(PrototypeMessage(id: "maya-17", authorID: "maya-chen", sentAt: today.addingTimeInterval(480), text: "Can you send the latest version when you have a moment?", reactions: [
                PrototypeReaction(emoji: "👍", personIDs: [profileID]),
                PrototypeReaction(emoji: "😀", personIDs: [profileID, "maya-chen"]),
            ])),
        ]
    }

    private static func weekendTimeline(profileID: String, now: Date) -> [PrototypeTimelineEntry] {
        let old = now.addingTimeInterval(-400 * 86_400)
        let earlyHistory = now.addingTimeInterval(-120 * 86_400)
        let weekday = now.addingTimeInterval(-4 * 86_400)
        let yesterday = now.addingTimeInterval(-86_400)
        let today = now.addingTimeInterval(-7_200)
        func image(_ id: String, _ asset: String, _ label: String) -> PrototypeAttachment {
            .photo(id: id, source: .asset(asset), label: label)
        }

        let gallery = [
            image("week-1", "FiatjafMediaFox", "Fox"),
            image("week-2", "FiatjafMediaBadger", "Badger"),
            image("week-3", "FiatjafMediaMarmot", "Marmot"),
            image("week-4", "FiatjafMediaSloth", "Sloth"),
            image("week-5", "FiatjafMediaOstrich", "Ostrich"),
            image("week-6", "AvatarGardenClub", "Garden"),
            image("week-7", "AvatarWebAionyHaust", "Portrait"),
        ]

        return [
            .event(PrototypeTimelineEvent(id: "week-event-created", date: old, kind: .created(actorID: profileID))),
            .event(PrototypeTimelineEvent(id: "week-event-added", date: old.addingTimeInterval(60), kind: .added(actorID: profileID, personIDs: ["maya-chen", "elias-moreno"]))),
            .message(PrototypeMessage(id: "week-msg-1", authorID: "maya-chen", sentAt: old.addingTimeInterval(180), text: "Thanks for setting this up.")),
            .message(PrototypeMessage(id: "week-msg-2", authorID: "elias-moreno", sentAt: old.addingTimeInterval(240), text: "I have a few easy routes we can try.")),
            .event(PrototypeTimelineEvent(id: "week-event-added-one", date: old.addingTimeInterval(360), kind: .added(actorID: profileID, personIDs: ["nora-bennett"]))),
            .message(PrototypeMessage(id: "week-msg-3", authorID: "nora-bennett", sentAt: old.addingTimeInterval(480), text: "Welcome everyone. Let’s choose a route that works for the whole group.")),
            .event(PrototypeTimelineEvent(id: "week-event-joined", date: old.addingTimeInterval(600), kind: .joined(personID: "mina-park"))),
            .message(PrototypeMessage(id: "week-msg-4", authorID: "mina-park", sentAt: old.addingTimeInterval(720), text: "Glad I found the group.")),
            .message(PrototypeMessage(id: "week-msg-5", authorID: "mina-park", sentAt: old.addingTimeInterval(780), text: "Sunday mornings usually work for me.")),
            .event(PrototypeTimelineEvent(id: "week-event-leo-joined", date: old.addingTimeInterval(900), kind: .joined(personID: "leo-martins"))),

            .event(PrototypeTimelineEvent(id: "week-event-name", date: earlyHistory, kind: .changedName(actorID: profileID, name: "Weekend Walks"))),
            .message(PrototypeMessage(id: "week-msg-6", authorID: "nora-bennett", sentAt: earlyHistory.addingTimeInterval(120), text: "Weekend Walks fits us better.")),
            .event(PrototypeTimelineEvent(id: "week-event-photo", date: earlyHistory.addingTimeInterval(240), kind: .changedPhoto(actorID: profileID))),
            .message(PrototypeMessage(id: "week-msg-7", authorID: "maya-chen", sentAt: earlyHistory.addingTimeInterval(360), text: "That photo is from our first riverside route.")),
            .message(PrototypeMessage(id: "week-msg-8", authorID: "maya-chen", sentAt: earlyHistory.addingTimeInterval(420), text: "I still like that path best.")),
            .event(PrototypeTimelineEvent(id: "week-event-description", date: earlyHistory.addingTimeInterval(540), kind: .changedDescription(actorID: profileID))),

            .event(PrototypeTimelineEvent(id: "week-event-admin", date: weekday, kind: .madeAdmin(actorID: profileID, personID: "maya-chen"))),
            .message(PrototypeMessage(id: "week-msg-9", authorID: "maya-chen", sentAt: weekday.addingTimeInterval(120), text: "I’ll organize the route options and meeting points.")),
            .message(PrototypeMessage(id: "week-msg-10", authorID: "elias-moreno", sentAt: weekday.addingTimeInterval(240), text: "Here are four from the west trail.", attachments: Array(gallery.prefix(4)), reactions: [PrototypeReaction(emoji: "👍", personIDs: [profileID])])),
            .message(PrototypeMessage(id: "week-msg-11", authorID: "mina-park", sentAt: weekday.addingTimeInterval(360), text: "And five from the lake loop.", attachments: Array(gallery.prefix(5)))),
            .message(PrototypeMessage(id: "week-msg-11b", authorID: "maya-chen", sentAt: weekday.addingTimeInterval(420), text: "These six cover the trail from start to finish.", attachments: Array(gallery.prefix(6)))),
            .message(PrototypeMessage(id: "week-msg-12", authorID: "nora-bennett", sentAt: weekday.addingTimeInterval(480), text: "A few views from last time.", attachments: gallery, reactions: [
                PrototypeReaction(emoji: "❤", personIDs: [profileID, "maya-chen", "elias-moreno"]),
                PrototypeReaction(emoji: "🔥", personIDs: ["mina-park"]),
            ])),
            .message(PrototypeMessage(id: "week-msg-13", authorID: "maya-chen", sentAt: weekday.addingTimeInterval(600), text: "I’m done with the route changes, so you can take admin back.")),
            .event(PrototypeTimelineEvent(id: "week-event-admin-remove", date: weekday.addingTimeInterval(720), kind: .removedAdmin(actorID: profileID, personID: "maya-chen"))),

            .event(PrototypeTimelineEvent(id: "week-event-description-remove", date: yesterday, kind: .removedDescription(actorID: profileID))),
            .message(PrototypeMessage(id: "week-msg-14", authorID: "maya-chen", sentAt: yesterday, text: "@Marmota, does the riverside path work?")),
            .message(PrototypeMessage(id: "week-msg-15", authorID: profileID, sentAt: yesterday.addingTimeInterval(120), text: "Yes, and the forecast looks clear.", replyToMessageID: "week-msg-14")),
            .message(PrototypeMessage(id: "week-msg-16", authorID: "nora-bennett", sentAt: yesterday.addingTimeInterval(240), text: "Then let’s keep the changing details here instead of in the description.", replyToMessageID: "week-msg-15")),
            .message(PrototypeMessage(id: "week-msg-17", authorID: "maya-chen", sentAt: yesterday.addingTimeInterval(360), text: "This clip shows the narrow section.", attachments: [
                .video(id: "week-video", url: showcaseVideoURL, thumbnail: .asset("ProfileAvatarPebble"), duration: 8),
            ])),
            .message(PrototypeMessage(id: "week-msg-18", authorID: profileID, sentAt: yesterday.addingTimeInterval(480), text: "And here’s the bridge beside it.", attachments: [
                gallery[0],
                .video(id: "week-mixed-video", url: showcaseVideoURL, thumbnail: .asset("ProfileAvatarPebble"), duration: 8),
            ], replyToMessageID: "week-msg-17")),

            .message(PrototypeMessage(id: "week-msg-19", authorID: "leo-martins", sentAt: today, attachments: [.gif(id: "week-gif", assetName: "FiatjafMediaMarmot", label: "Marmot looking around")], reactions: [PrototypeReaction(emoji: "🤣", personIDs: [profileID, "maya-chen"])])),
            .message(PrototypeMessage(id: "week-msg-20", authorID: profileID, sentAt: today.addingTimeInterval(120), attachments: [.sticker(id: "week-sticker", assetName: "FiatjafMediaFox", label: "Friendly fox")], reactions: [PrototypeReaction(emoji: "🦫", personIDs: ["elias-moreno"])])),
            .message(PrototypeMessage(id: "week-msg-21", authorID: "maya-chen", sentAt: today.addingTimeInterval(240), text: "Not the steep shortcut—this entrance.", attachments: [.location(id: "week-location", name: "Riverside Trail", address: "North entrance by the footbridge")], reactions: [PrototypeReaction(emoji: "👎", personIDs: [profileID, "nora-bennett"])])),
            .message(PrototypeMessage(id: "week-msg-22", authorID: "elias-moreno", sentAt: today.addingTimeInterval(360), attachments: [.contact(id: "week-contact", personID: "avery-stone")])),
            .message(PrototypeMessage(id: "week-msg-23", authorID: "nora-bennett", sentAt: today.addingTimeInterval(480), attachments: [bundledFile(id: "week-file", name: "Trail Plan.pdf", resourceName: "TrailPlan")])),
            .message(PrototypeMessage(id: "week-msg-24", authorID: profileID, sentAt: today.addingTimeInterval(600), attachments: [.voice(id: "week-voice", resourceName: PrototypeVoiceSample.resourceName, duration: PrototypeVoiceSample.duration)])),
            .message(PrototypeMessage(id: "week-msg-25", authorID: "leo-martins", sentAt: today.addingTimeInterval(720), text: "I’m stepping out, but I hope the walk goes well.")),
            .event(PrototypeTimelineEvent(id: "week-event-left", date: today.addingTimeInterval(840), kind: .left(personID: "leo-martins"))),
            .event(PrototypeTimelineEvent(id: "week-event-theo-added", date: today.addingTimeInterval(900), kind: .added(actorID: profileID, personIDs: ["theo-grant"]))),
            .message(PrototypeMessage(id: "week-msg-26", authorID: "theo-grant", sentAt: today.addingTimeInterval(960), text: "I won’t be joining this one.")),
            .event(PrototypeTimelineEvent(id: "week-event-removed", date: today.addingTimeInterval(1_080), kind: .removed(actorID: profileID, personID: "theo-grant"))),
            .message(PrototypeMessage(id: "week-msg-27", authorID: "nora-bennett", sentAt: today.addingTimeInterval(1_200), text: "Saturday morning works for me.")),
        ]
    }

    private static func fiatjafTimeline(profileID: String, now: Date) -> [PrototypeTimelineEntry] {
        let start = now.addingTimeInterval(-2_400)
        return [
            .message(PrototypeMessage(id: "fiatjaf-1", authorID: profileID, sentAt: start, text: "I’m moving from Feather to White Noise.")),
            .message(PrototypeMessage(id: "fiatjaf-2", authorID: "fiatjaf", sentAt: start.addingTimeInterval(60), text: "Let me know how it goes.")),
            .message(PrototypeMessage(id: "fiatjaf-3", authorID: profileID, sentAt: start.addingTimeInterval(120), text: "Signing in now.\nI’ll send a test next.")),
            .message(PrototypeMessage(id: "fiatjaf-4", authorID: profileID, sentAt: start.addingTimeInterval(300), text: "Switched from Feather to White Noise. Same key, same contacts.")),
            .message(PrototypeMessage(id: "fiatjaf-5", authorID: "fiatjaf", sentAt: start.addingTimeInterval(420), text: "Yep, I still see you on Primal. No extra setup on my side.", replyToMessageID: "fiatjaf-4")),
            .message(PrototypeMessage(id: "fiatjaf-6", authorID: profileID, sentAt: start.addingTimeInterval(540), text: "Exactly. Moved apps, kept everything. Didn’t have to re-add anyone.", reactions: [PrototypeReaction(emoji: "🔥", personIDs: ["fiatjaf"])])),
            .message(PrototypeMessage(id: "fiatjaf-7", authorID: "fiatjaf", sentAt: start.addingTimeInterval(660), text: "Perfect!")),
            .message(PrototypeMessage(id: "fiatjaf-8", authorID: "fiatjaf", sentAt: start.addingTimeInterval(780), text: "Portable identity for the win.", attachments: [
                .photo(id: "fiatjaf-photo-1", source: .asset("FiatjafMediaMarmot"), label: "Marmot"),
                .photo(id: "fiatjaf-photo-2", source: .asset("FiatjafMediaBadger"), label: "Badger"),
                .photo(id: "fiatjaf-photo-3", source: .asset("FiatjafMediaFox"), label: "Fox"),
                .photo(id: "fiatjaf-photo-4", source: .asset("FiatjafMediaSloth"), label: "Sloth"),
                .photo(id: "fiatjaf-photo-5", source: .asset("FiatjafMediaOstrich"), label: "Ostrich"),
            ])),
        ]
    }

    private static func seedAuthorID(for row: ChatListItem, profileID: String) -> String {
        guard row.previewAuthor != "You" else { return profileID }
        guard groupIDs.contains(row.id), let author = row.previewAuthor else { return row.id }
        let known = [
            "Tim": "tim", "Jude": "jude", "Sam": "sam", "Owen": "owen",
            "Remy": "remy", "Maya": "maya-chen", "Nora": "nora-bennett",
            "Iris": "iris", "Noah": "noah",
        ]
        return known[author] ?? author.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    private static func seedAttachments(
        _ preview: ChatListItem.AttachmentPreview?,
        chatID: String
    ) -> [PrototypeAttachment] {
        guard let preview else { return [] }
        switch preview {
        case .photo:
            return [.photo(id: "\(chatID)-photo", source: .asset("FiatjafMediaFox"), label: "Photo")]
        case let .photos(count):
            let assets = ["FiatjafMediaFox", "FiatjafMediaBadger", "FiatjafMediaMarmot", "FiatjafMediaSloth", "FiatjafMediaOstrich"]
            return (0..<count).map { index in
                .photo(id: "\(chatID)-photo-\(index)", source: .asset(assets[index % assets.count]), label: "Photo \(index + 1)")
            }
        case .video:
            return [.video(id: "\(chatID)-video", url: showcaseVideoURL, thumbnail: .asset("ProfileAvatarPebble"), duration: 8)]
        case .voiceMessage:
            return [.voice(id: "\(chatID)-voice", resourceName: PrototypeVoiceSample.resourceName, duration: PrototypeVoiceSample.duration)]
        case let .file(name):
            let resourceName = switch name {
            case "Project Brief.pdf": "ProjectBrief"
            case "Project Notes.pdf": "ProjectNotes"
            case "Trail Plan.pdf": "TrailPlan"
            default: "WeekendNotes"
            }
            return [bundledFile(id: "\(chatID)-file", name: name, resourceName: resourceName)]
        case .location:
            return [.location(id: "\(chatID)-location", name: "Riverside Trail", address: "North entrance by the footbridge")]
        case let .contact(name):
            return [.contact(id: "\(chatID)-contact", personID: name == "Avery Stone" ? "avery-stone" : "maya-chen")]
        case .link:
            return [.link(id: "\(chatID)-link", title: "Reading for later", domain: "whitenoise.chat", summary: "A useful link shared with the chat.", image: nil)]
        case .gif:
            return [.gif(id: "\(chatID)-gif", assetName: "FiatjafMediaMarmot", label: "Marmot")]
        case .sticker:
            return [.sticker(id: "\(chatID)-sticker", assetName: "FiatjafMediaFox", label: "Fox")]
        }
    }

    private static func seedDate(for label: String, now: Date) -> Date {
        if label == "Now" { return now }
        if label.hasSuffix("m"), let minutes = Int(label.dropLast()) {
            return now.addingTimeInterval(TimeInterval(-minutes * 60))
        }
        if label.hasSuffix("h"), let hours = Int(label.dropLast()) {
            return now.addingTimeInterval(TimeInterval(-hours * 3_600))
        }
        if label == "Yesterday" { return now.addingTimeInterval(-86_400) }

        let calendar = Calendar.autoupdatingCurrent
        let weekdaySymbols = DateFormatter().weekdaySymbols ?? []
        if let weekdayIndex = weekdaySymbols.firstIndex(of: label) {
            let targetWeekday = weekdayIndex + 1
            let currentWeekday = calendar.component(.weekday, from: now)
            let daysBack = (currentWeekday - targetWeekday + 7) % 7
            return calendar.date(byAdding: .day, value: -(daysBack == 0 ? 7 : daysBack), to: now)
                ?? now.addingTimeInterval(-7 * 86_400)
        }

        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.calendar = calendar
        parser.dateFormat = "M/d/yy"
        if let parsed = parser.date(from: label) {
            let day = calendar.component(.day, from: parsed)
            let hour = 9 + day % 10
            let minute = (day * 7 % 4) * 15
            return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: parsed)
                ?? parsed
        }
        return now.addingTimeInterval(-7 * 86_400)
    }

    private static var showcaseVideoURL: URL? {
        resourceURL(name: "ChatTrailClip", fileExtension: "mp4")
    }

    private static func bundledFile(
        id: String,
        name: String,
        resourceName: String
    ) -> PrototypeAttachment {
        let url = resourceURL(name: resourceName, fileExtension: "pdf")
        let size = url.flatMap { url in
            try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
        } ?? 0
        return .file(id: id, name: name, size: size, url: url)
    }

    private static func resourceURL(name: String, fileExtension: String) -> URL? {
        let owningBundle = Bundle(for: PrototypeChatFixtureBundleToken.self)
        return owningBundle.url(forResource: name, withExtension: fileExtension)
            ?? Bundle.main.url(forResource: name, withExtension: fileExtension)
    }

    private static func about(for id: String) -> String {
        switch id {
        case "maya-chen": "Designer, careful listener, and collector of useful references."
        case "fiatjaf": "Building open tools for portable identity and resilient communication."
        case ChatListFixtures.supportChatID: "Help with White Noise."
        default: "Quietly sharing ideas and keeping in touch."
        }
    }

    private static func groupDescription(for id: String) -> String {
        switch id {
        case "weekend-walks": "Plans, routes, and photos from our weekend walks."
        case "product-circle": "Notes and decisions from the product circle."
        case "nostr-devs": "Building and testing open communication tools."
        default: "A shared space for this group."
        }
    }
}

extension PrototypeRelayConfiguration {
    var availableChatMessageRelayURLs: [String] {
        relays.compactMap { relay in
            guard relay.capability == .readWrite,
                  relay.connectionState == .connected,
                  relay.usages.contains(.chatMessages)
            else { return nil }
            return relay.url
        }
    }
}
