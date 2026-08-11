import SwiftUI

struct PrototypeMessageBubble: View {
    @Environment(\.incomingPrototypeMessageColor) private var incomingColor
    @Environment(\.outgoingPrototypeMessageColor) private var outgoingColor
    @ObservedObject private var playback = PrototypePlaybackCoordinator.shared

    let message: PrototypeMessage
    let outgoing: Bool
    let isGroup: Bool
    let author: PrototypePerson?
    let profileName: String
    let resolvedReply: PrototypeMessage?
    let replyAuthorName: String
    let showsAuthor: Bool
    let showsAvatar: Bool
    let showsTimestamp: Bool
    let isHighlighted: Bool
    let people: [PrototypePerson]
    let currentProfileID: String
    let onReply: () -> Void
    let onDelete: () -> Void
    let onRetry: () -> Void
    let onToggleReaction: (String) -> Void
    let onOpenReply: () -> Void
    let onOpenPerson: (String) -> Void
    let onOpenMedia: ([PrototypeAttachment], Int) -> Void
    let onOpenFile: (URL) -> Void

    @ViewBuilder
    var body: some View {
        if let voiceAttachment {
            messageRow
                .contentShape(.rect)
                .onTapGesture {
                    playback.toggleVoice(
                        id: voiceAttachment.id,
                        duration: voiceAttachment.duration
                    )
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityAction {
                    playback.toggleVoice(
                        id: voiceAttachment.id,
                        duration: voiceAttachment.duration
                    )
                }
        } else {
            messageRow
        }
    }

    private var messageRow: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if outgoing { Spacer(minLength: 54) }

            if !outgoing {
                if showsAvatar {
                    PrototypeChatAvatarView(
                        avatar: author?.avatar ?? .monogram("?"),
                        size: 28
                    )
                } else {
                    Color.clear.frame(width: isGroup ? 28 : 0, height: 1)
                }
            }

            VStack(alignment: outgoing ? .trailing : .leading, spacing: 3) {
                if isGroup, !outgoing, showsAuthor {
                    Button {
                        if let author { onOpenPerson(author.id) }
                    } label: {
                        Text(author?.name ?? "Unknown")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                bubbleContent
                    .contextMenu { contextMenu }
                    .overlay {
                        if isHighlighted {
                            shape.stroke(Color.accentColor, lineWidth: 3)
                        }
                    }

                if !message.reactions.isEmpty, !message.isDeleted {
                    reactionRow
                        .offset(y: -2)
                        .padding(.horizontal, 8)
                }

                if showsTimestamp {
                    HStack(spacing: 4) {
                        if message.deliveryState == .sending {
                            ProgressView().controlSize(.mini)
                        }
                        Text(PrototypeDateFormatter.time(for: message.sentAt))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .padding(outgoing ? .trailing : .leading, 8)
                }

                if message.deliveryState == .failed, outgoing, !message.isDeleted {
                    Button(action: onRetry) {
                        Label("Not sent. Retry", systemImage: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !outgoing { Spacer(minLength: 54) }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("message.\(message.id)")
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if isBorderlessSticker {
            bubbleBody
        } else {
            bubbleBody
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .foregroundStyle(messageColor.foregroundColor)
                .background(messageColor.color, in: shape)
        }
    }

    private var bubbleBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            if message.isDeleted {
                Label(deletedText, systemImage: "trash")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                if message.replyToMessageID != nil {
                    replyQuote
                }
                if !message.attachments.isEmpty {
                    PrototypeAttachmentCollectionView(
                        attachments: message.attachments,
                        people: people,
                        onOpenMedia: onOpenMedia,
                        onOpenFile: onOpenFile,
                        onOpenPerson: onOpenPerson
                    )
                }
                if !message.text.isEmpty {
                    messageText
                }
            }
        }
    }

    private var messageText: some View {
        Text(attributedMessageText)
            .textSelection(.enabled)
    }

    private var attributedMessageText: AttributedString {
        attributedText(message.text)
    }

    private func attributedText(_ text: String) -> AttributedString {
        var markdown = text
        for person in people {
            markdown = markdown.replacingOccurrences(
                of: "@\(person.name)",
                with: "[@\(person.name)](whitenoise-person://\(person.id))"
            )
        }
        var attributed = (try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(text)
        let links = attributed.runs.compactMap { run -> (Range<AttributedString.Index>, URL)? in
            guard let link = run.link else { return nil }
            return (run.range, link)
        }
        for (range, link) in links {
            attributed[range].foregroundColor = messageColor.foregroundColor
            attributed[range].underlineStyle = Text.LineStyle(pattern: .solid)
            if link.scheme == "whitenoise-person" {
                attributed[range].font = .body.weight(.semibold)
            }
        }
        return attributed
    }

    private func plainText(_ text: String) -> String {
        String(attributedText(text).characters)
    }

    private var replyQuote: some View {
        Button(action: onOpenReply) {
            HStack(alignment: .top, spacing: 7) {
                Capsule()
                    .fill(messageColor.foregroundColor.opacity(0.65))
                    .frame(width: 3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(replyAuthorName)
                        .font(.caption.weight(.semibold))
                    Text(replyPreview)
                        .font(.caption)
                        .lineLimit(2)
                        .opacity(0.75)
                }
            }
            .padding(7)
            .background(messageColor.foregroundColor.opacity(0.1), in: .rect(cornerRadius: 9))
        }
        .buttonStyle(.plain)
    }

    private var replyPreview: String {
        guard let resolvedReply else { return "Message unavailable" }
        if resolvedReply.isDeleted { return "Message deleted" }
        if !resolvedReply.text.isEmpty { return plainText(resolvedReply.text) }
        return resolvedReply.attachments.first?.accessibilityLabel ?? "Message"
    }

    @ViewBuilder
    private var contextMenu: some View {
        if !message.isDeleted {
            Menu("React") {
                ForEach(PrototypeReaction.supportedEmoji, id: \.self) { emoji in
                    Button(emoji) { onToggleReaction(emoji) }
                }
            }
            Button("Reply", systemImage: "arrowshape.turn.up.left", action: onReply)
            if !message.text.isEmpty {
                Button("Copy", systemImage: "doc.on.doc") {
                    UIPasteboard.general.string = message.text
                }
            }
            if let shareFileURL {
                ShareLink(item: shareFileURL) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            } else {
                ShareLink(item: shareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            if outgoing {
                Divider()
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            }
        }
    }

    private var reactionRow: some View {
        HStack(spacing: 4) {
            ForEach(message.reactions) { reaction in
                Button {
                    onToggleReaction(reaction.emoji)
                } label: {
                    HStack(spacing: 3) {
                        Text(reaction.emoji)
                        if reaction.personIDs.count > 1 {
                            Text(reaction.personIDs.count.formatted())
                                .font(.caption2.weight(.semibold))
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(
                        reaction.personIDs.contains(currentProfileID)
                            ? Color.accentColor.opacity(0.2)
                            : Color(uiColor: .systemBackground),
                        in: .capsule
                    )
                    .overlay { Capsule().stroke(Color(uiColor: .separator), lineWidth: 0.5) }
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
                .accessibilityLabel("\(reaction.emoji), \(reaction.personIDs.count) reactions")
            }
        }
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: 18,
                bottomLeading: outgoing ? 18 : 6,
                bottomTrailing: outgoing ? 6 : 18,
                topTrailing: 18
            ),
            style: .continuous
        )
    }

    private var messageColor: PrototypeMessageColor { outgoing ? outgoingColor : incomingColor }
    private var isBorderlessSticker: Bool {
        guard message.replyToMessageID == nil,
              message.text.isEmpty,
              message.attachments.count == 1,
              case .sticker = message.attachments[0]
        else { return false }
        return true
    }
    private var deletedText: String {
        outgoing ? "You deleted this message." : "This message was deleted."
    }
    private var shareText: String {
        if !message.text.isEmpty { return message.text }
        return message.attachments.map(\.accessibilityLabel).joined(separator: ", ")
    }
    private var shareFileURL: URL? {
        guard message.attachments.count == 1,
              case let .file(_, _, _, url) = message.attachments[0]
        else { return nil }
        return url
    }
    private var accessibilitySummary: String {
        let sender = outgoing ? profileName : (author?.name ?? "Unknown")
        let content = message.isDeleted
            ? deletedText
            : ([plainText(message.text)] + message.attachments.map(\.accessibilityLabel))
                .filter { !$0.isEmpty }.joined(separator: ", ")
        let reactions = message.reactions.isEmpty ? "" : ", reactions: " + message.reactions.map(\.emoji).joined(separator: ", ")
        let reply = message.replyToMessageID == nil
            ? ""
            : ", reply to \(replyAuthorName): \(replyPreview)"
        let failed = message.deliveryState == .failed ? ", not sent" : ""
        let playbackAction = voiceAttachment.map { attachment in
            let isPlaying = playback.activeVoiceID == attachment.id && !playback.isPaused
            return isPlaying ? ", Pause" : ", Play"
        } ?? ""
        return "\(sender), \(PrototypeDateFormatter.time(for: message.sentAt)). \(content)\(reply)\(reactions)\(failed)\(playbackAction)"
    }
    private var voiceAttachment: (id: String, duration: TimeInterval)? {
        for attachment in message.attachments {
            if case let .voice(id, _, duration) = attachment {
                return (id, duration)
            }
        }
        return nil
    }
}

private struct PrototypeAttachmentCollectionView: View {
    let attachments: [PrototypeAttachment]
    let people: [PrototypePerson]
    let onOpenMedia: ([PrototypeAttachment], Int) -> Void
    let onOpenFile: (URL) -> Void
    let onOpenPerson: (String) -> Void

    private var media: [PrototypeAttachment] {
        attachments.filter {
            if case .photo = $0 { return true }
            if case .video = $0 { return true }
            return false
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !media.isEmpty { mediaGrid }
            ForEach(attachments.filter { !media.contains($0) }) { attachment in
                nonMediaView(attachment)
            }
        }
    }

    @ViewBuilder
    private var mediaGrid: some View {
        Group {
            switch PrototypeGalleryLayout(count: media.count) {
            case .one:
                mediaButton(at: 0, width: 250, height: 250)
            case .two:
                HStack(spacing: 2) {
                    mediaButton(at: 0, width: 124, height: 180)
                    mediaButton(at: 1, width: 124, height: 180)
                }
            case .three:
                HStack(spacing: 2) {
                    mediaButton(at: 0, width: 124, height: 220)
                    VStack(spacing: 2) {
                        mediaButton(at: 1, width: 124, height: 109)
                        mediaButton(at: 2, width: 124, height: 109)
                    }
                }
            case .four:
                VStack(spacing: 2) {
                    mediaRow(indices: [0, 1], width: 124, height: 124)
                    mediaRow(indices: [2, 3], width: 124, height: 124)
                }
            case .five:
                VStack(spacing: 2) {
                    mediaRow(indices: [0, 1], width: 124, height: 124)
                    mediaRow(indices: [2, 3, 4], width: 82, height: 92)
                }
            case .overflow:
                VStack(spacing: 2) {
                    mediaRow(indices: [0, 1], width: 124, height: 100)
                    mediaRow(indices: [2, 3], width: 124, height: 100)
                    mediaRow(indices: [4, 5], width: 124, height: 100)
                }
            }
        }
        .frame(width: 250)
        .clipShape(.rect(cornerRadius: 12))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(media.count) media items")
    }

    private func mediaRow(indices: [Int], width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 2) {
            ForEach(indices, id: \.self) { index in
                mediaButton(at: index, width: width, height: height)
            }
        }
    }

    private func mediaButton(at index: Int, width: CGFloat, height: CGFloat) -> some View {
        let attachment = media[index]
        return Button { onOpenMedia(media, index) } label: {
            mediaTile(attachment, index: index)
                .frame(width: width, height: height)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(attachment.accessibilityLabel), \(index + 1) of \(media.count)")
    }

    @ViewBuilder
    private func mediaTile(_ attachment: PrototypeAttachment, index: Int) -> some View {
        ZStack {
            switch attachment {
            case let .photo(_, source, _):
                PrototypeImageSourceView(source: source).scaledToFill()
            case let .video(_, _, thumbnail, duration):
                PrototypeImageSourceView(source: thumbnail).scaledToFill()
                Image(systemName: "play.circle.fill")
                    .font(.largeTitle).foregroundStyle(.white)
                    .shadow(radius: 2)
                Text(prototypeDurationString(duration))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(.black.opacity(0.55), in: .capsule)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(5)
            default:
                EmptyView()
            }
            if index == 5, media.count > 6 {
                Color.black.opacity(0.5)
                Text("+\(media.count - 6)")
                    .font(.title2.bold()).foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    @ViewBuilder
    private func nonMediaView(_ attachment: PrototypeAttachment) -> some View {
        switch attachment {
        case let .file(_, name, size, url):
            if let url {
                Button {
                    onOpenFile(url)
                } label: {
                    fileRow(name: name, size: size, isAvailable: true)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens a preview.")
            } else {
                fileRow(name: name, size: size, isAvailable: false)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("File, \(name), unavailable")
            }
        case let .voice(id, _, duration):
            PrototypeVoiceBubble(id: id, duration: duration)
        case let .link(_, title, domain, summary, image):
            if let destination = safeLinkDestination(domain: domain) {
                Link(destination: destination) {
                    linkPreview(title: title, domain: domain, summary: summary, image: image)
                }
                .buttonStyle(.plain)
            } else {
                linkPreview(title: title, domain: domain, summary: summary, image: image)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Link preview unavailable, \(title), \(domain)")
            }
        case let .gif(_, assetName, label):
            ZStack(alignment: .bottomLeading) {
                Image(assetName).resizable().scaledToFill().frame(width: 230, height: 180).clipped()
                Label("GIF", systemImage: "play.fill")
                    .font(.caption.bold()).padding(6).background(.black.opacity(0.6), in: .capsule)
                    .foregroundStyle(.white).padding(7)
            }
            .clipShape(.rect(cornerRadius: 12)).accessibilityLabel("GIF, \(label)")
        case let .sticker(_, assetName, label):
            Image(assetName).resizable().scaledToFit().frame(width: 170, height: 170)
                .accessibilityLabel("Sticker, \(label)")
        case let .location(_, name, address):
            VStack(alignment: .leading, spacing: 6) {
                ZStack {
                    Color.green.opacity(0.18)
                    Image(systemName: "map.fill").font(.largeTitle).foregroundStyle(.green)
                }
                .frame(width: 230, height: 105).clipShape(.rect(cornerRadius: 10))
                Text(name).font(.headline)
                Text(address).font(.caption).foregroundStyle(.secondary)
            }
        case let .contact(_, personID):
            if let person = people.first(where: { $0.id == personID }) {
                Button { onOpenPerson(personID) } label: {
                    HStack {
                        PrototypeChatAvatarView(avatar: person.avatar)
                        VStack(alignment: .leading) {
                            Text(person.name).font(.headline)
                            Text(person.shortPublicKey).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        case .photo, .video:
            EmptyView()
        }
    }

    private func fileRow(name: String, size: Int, isAvailable: Bool) -> some View {
        HStack {
            Image(systemName: "doc").font(.title2)
            VStack(alignment: .leading) {
                Text(name).font(.subheadline.weight(.semibold)).lineLimit(1)
                Text(fileMetadata(name: name, size: size))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: isAvailable ? "chevron.right" : "exclamationmark.triangle")
                .foregroundStyle(.secondary)
        }
        .frame(width: 230)
    }

    private func linkPreview(
        title: String,
        domain: String,
        summary: String,
        image: PrototypeImageSource?
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if let image {
                PrototypeImageSourceView(source: image)
                    .scaledToFill().frame(width: 230, height: 100).clipped()
            }
            Text(title).font(.headline)
            Text(domain).font(.caption).foregroundStyle(.secondary)
            Text(summary).font(.subheadline).lineLimit(3)
        }
        .frame(width: 230, alignment: .leading)
    }

    private func safeLinkDestination(domain: String) -> URL? {
        guard !domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let url = URL(string: "https://\(domain)"),
              url.host?.isEmpty == false
        else { return nil }
        return url
    }

    private func fileMetadata(name: String, size: Int) -> String {
        let fileType = URL(fileURLWithPath: name).pathExtension.uppercased()
        let formattedSize = size.formatted(.byteCount(style: .file))
        return fileType.isEmpty ? formattedSize : "\(fileType) • \(formattedSize)"
    }
}

private struct PrototypeVoiceBubble: View {
    let id: String
    let duration: TimeInterval
    @ObservedObject private var playback = PrototypePlaybackCoordinator.shared

    private var isActive: Bool { playback.activeVoiceID == id }
    private var isPlaying: Bool { isActive && !playback.isPaused }
    private var elapsed: TimeInterval { isActive ? playback.elapsed : 0 }

    var body: some View {
        HStack(spacing: 10) {
            Button {
                playback.toggleVoice(id: id, duration: duration)
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPlaying ? "Pause" : "Play")
            .accessibilityIdentifier("voice.\(id).toggle")
            VStack(alignment: .leading, spacing: 5) {
                ProgressView(value: elapsed, total: max(duration, 0.1))
                    .frame(minWidth: 120)
                Text("\(prototypeDurationString(elapsed)) / \(prototypeDurationString(duration))")
                    .font(.caption.monospacedDigit())
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Voice message, \(prototypeDurationString(elapsed)) of \(prototypeDurationString(duration))"
        )
        .accessibilityAction(named: isPlaying ? "Pause" : "Play") {
            playback.toggleVoice(id: id, duration: duration)
        }
        .accessibilityHidden(true)
    }
}

func prototypeDurationString(_ seconds: TimeInterval) -> String {
    let total = max(0, Int(seconds.rounded()))
    return String(format: "%d:%02d", total / 60, total % 60)
}
