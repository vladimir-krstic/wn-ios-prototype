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
        HStack(alignment: .bottom, spacing: 0) {
            if outgoing { Spacer(minLength: 48) }

            if !outgoing, isGroup {
                Color.clear.frame(width: 37, height: 1)
            }

            VStack(alignment: outgoing ? .trailing : .leading, spacing: 4) {
                if isGroup, !outgoing, showsAuthor {
                    Button {
                        if let author { onOpenPerson(author.id) }
                    } label: {
                        Text(author?.name ?? "Unknown")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(
                                PrototypeAuthorNameColor.color(
                                    for: author?.publicKey ?? message.authorID
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 10)
                }

                decoratedBubble
            }

            if !outgoing { Spacer(minLength: 48) }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("message.\(message.id)")
    }

    private var decoratedBubble: some View {
        bubbleContent
            .contextMenu { contextMenu }
            .overlay {
                if isHighlighted {
                    shape.stroke(Color.accentColor, lineWidth: 3)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if isGroup, !outgoing, showsAvatar {
                    PrototypeChatAvatarView(
                        avatar: author?.avatar ?? .monogram("?"),
                        size: 30,
                        publicKey: author?.publicKey
                    )
                    .offset(x: -37)
                }
            }
            .overlay(alignment: reactionAlignment) {
                if !message.reactions.isEmpty, !message.isDeleted {
                    reactionRow
                        .offset(x: outgoing ? 10 : -10, y: 19)
                }
            }
            .padding(.bottom, showsReactions ? 18 : 0)
            .overlay(alignment: timestampAlignment) {
                if showsVisibleTimestamp {
                    timestamp
                        .padding(
                            outgoing ? .leading : .trailing,
                            PrototypeMessageBubbleShape.cornerRadius
                        )
                        .offset(y: 17)
                } else if showsFailedDeliveryStatus {
                    failedDeliveryStatus
                        .contextMenu { contextMenu }
                        .offset(y: 18)
                }
            }
            .padding(
                .bottom,
                showsVisibleTimestamp ? 17 : (showsFailedDeliveryStatus ? 18 : 0)
            )
    }

    private var timestamp: some View {
        HStack(spacing: 4) {
            if message.deliveryState == .sending {
                ProgressView().controlSize(.mini)
            }
            Text(PrototypeDateFormatter.time(for: message.sentAt))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    private var failedDeliveryStatus: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Image(systemName: "exclamationmark.circle.fill")

            Text("Not delivered, hold for options")
                .multilineTextAlignment(.leading)
        }
        .font(.caption)
        .foregroundStyle(.red)
        .padding(.leading, PrototypeMessageBubbleShape.cornerRadius)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Not delivered")
        .accessibilityHint("Touch and hold for options, then choose Retry Send.")
    }

    @ViewBuilder
    private var bubbleContent: some View {
        bubbleBody
            .padding(.horizontal, hasVisualMedia ? 3 : 13)
            .padding(.vertical, hasVisualMedia ? 3 : 9)
            .foregroundStyle(messageColor.foregroundColor)
            .background(messageColor.color, in: shape)
    }

    private var bubbleBody: some View {
        VStack(alignment: .leading, spacing: 7) {
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
                        tint: messageColor.foregroundColor,
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
            .padding(.horizontal, hasVisualMedia ? 10 : 0)
            .padding(.bottom, hasVisualMedia ? 7 : 0)
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
                Spacer(minLength: 4)
                replyThumbnail
            }
            .frame(maxWidth: 236, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(messageColor.foregroundColor.opacity(0.1), in: .rect(cornerRadius: 12))
            .padding(.horizontal, hasVisualMedia ? 7 : 0)
            .padding(.top, hasVisualMedia ? 6 : 0)
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
    private var replyThumbnail: some View {
        if let attachment = resolvedReply?.attachments.first {
            switch attachment {
            case let .photo(_, source, _):
                PrototypeImageSourceView(source: source)
                    .scaledToFill()
                    .frame(width: 38, height: 38)
                    .clipShape(.rect(cornerRadius: 8))
            case let .video(_, _, thumbnail, _):
                ZStack {
                    PrototypeImageSourceView(source: thumbnail).scaledToFill()
                    Image(systemName: "play.fill")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .shadow(radius: 1)
                }
                .frame(width: 38, height: 38)
                .clipShape(.rect(cornerRadius: 8))
            case let .gif(_, assetName, _):
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 38, height: 38)
                    .clipShape(.rect(cornerRadius: 8))
            case .file:
                Image(systemName: "doc.fill")
                    .frame(width: 38, height: 38)
                    .background(messageColor.foregroundColor.opacity(0.1), in: .rect(cornerRadius: 8))
            case .voice:
                Image(systemName: "waveform")
                    .frame(width: 38, height: 38)
                    .background(messageColor.foregroundColor.opacity(0.1), in: .rect(cornerRadius: 8))
            case .link:
                Image(systemName: "link")
                    .frame(width: 38, height: 38)
                    .background(messageColor.foregroundColor.opacity(0.1), in: .rect(cornerRadius: 8))
            case .contact:
                Image(systemName: "person.crop.circle")
                    .frame(width: 38, height: 38)
                    .background(messageColor.foregroundColor.opacity(0.1), in: .rect(cornerRadius: 8))
            }
        }
    }

    @ViewBuilder
    private var contextMenu: some View {
        if !message.isDeleted {
            if outgoing, message.deliveryState == .failed {
                Button("Retry Send", systemImage: "arrow.clockwise", action: onRetry)
                Divider()
            }
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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        reaction.personIDs.contains(currentProfileID)
                            ? Color.accentColor.opacity(0.18)
                            : Color(uiColor: .secondarySystemBackground),
                        in: .capsule
                    )
                    .overlay { Capsule().stroke(Color(uiColor: .separator), lineWidth: 0.33) }
                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
                .accessibilityLabel("\(reaction.emoji), \(reaction.personIDs.count) reactions")
            }
        }
    }

    private var shape: PrototypeMessageBubbleShape {
        PrototypeMessageBubbleShape()
    }

    private var messageColor: PrototypeMessageColor { outgoing ? outgoingColor : incomingColor }
    private var showsVisibleTimestamp: Bool {
        showsTimestamp && message.deliveryState != .failed
    }
    private var showsFailedDeliveryStatus: Bool {
        message.deliveryState == .failed && outgoing && !message.isDeleted
    }
    private var showsReactions: Bool {
        !message.reactions.isEmpty && !message.isDeleted
    }
    private var reactionAlignment: Alignment {
        outgoing ? .bottomLeading : .bottomTrailing
    }
    private var timestampAlignment: Alignment {
        outgoing ? .bottomLeading : .bottomTrailing
    }
    private var hasVisualMedia: Bool {
        message.attachments.contains { attachment in
            switch attachment {
            case .photo, .video, .gif:
                true
            case let .link(_, _, _, _, image):
                image != nil
            default:
                false
            }
        }
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
    let tint: Color
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
                mediaButton(at: 0, width: 256, height: 246)
            case .two:
                HStack(spacing: 3) {
                    mediaButton(at: 0, width: 126.5, height: 184)
                    mediaButton(at: 1, width: 126.5, height: 184)
                }
            case .three:
                HStack(spacing: 3) {
                    mediaButton(at: 0, width: 126.5, height: 224)
                    VStack(spacing: 3) {
                        mediaButton(at: 1, width: 126.5, height: 110.5)
                        mediaButton(at: 2, width: 126.5, height: 110.5)
                    }
                }
            case .four:
                VStack(spacing: 3) {
                    mediaRow(indices: [0, 1], width: 126.5, height: 126.5)
                    mediaRow(indices: [2, 3], width: 126.5, height: 126.5)
                }
            case .five:
                VStack(spacing: 3) {
                    mediaRow(indices: [0, 1], width: 126.5, height: 126.5)
                    mediaRow(indices: [2, 3, 4], width: 83.3, height: 94)
                }
            case .overflow:
                VStack(spacing: 3) {
                    mediaRow(indices: [0, 1], width: 126.5, height: 102)
                    mediaRow(indices: [2, 3], width: 126.5, height: 102)
                    mediaRow(indices: [4, 5], width: 126.5, height: 102)
                }
            }
        }
        .frame(width: 256)
        .clipShape(.rect(cornerRadius: 17))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(media.count) media items")
    }

    private func mediaRow(indices: [Int], width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 3) {
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
                Image(assetName).resizable().scaledToFill().frame(width: 256, height: 188).clipped()
                Label("GIF", systemImage: "play.fill")
                    .font(.caption.bold()).padding(6).background(.black.opacity(0.6), in: .capsule)
                    .foregroundStyle(.white).padding(7)
            }
            .clipShape(.rect(cornerRadius: 17))
            .accessibilityLabel("GIF, \(label)")
        case let .contact(_, personID):
            if let person = people.first(where: { $0.id == personID }) {
                Button { onOpenPerson(personID) } label: {
                    HStack(spacing: 10) {
                        PrototypeChatAvatarView(
                            avatar: person.avatar,
                            size: 38,
                            publicKey: person.publicKey
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(person.name).font(.headline)
                            Text(person.shortPublicKey).font(.caption).foregroundStyle(tint.opacity(0.72))
                        }
                        Spacer(minLength: 4)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(tint.opacity(0.72))
                    }
                    .padding(8)
                    .frame(width: 236)
                    .background(tint.opacity(0.09), in: .rect(cornerRadius: 13))
                }
                .buttonStyle(.plain)
            }
        case .photo, .video:
            EmptyView()
        }
    }

    private func fileRow(name: String, size: Int, isAvailable: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: fileSymbol(for: name))
                .font(.title3.weight(.medium))
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.1), in: .rect(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.weight(.semibold)).lineLimit(1)
                Text(fileMetadata(name: name, size: size))
                    .font(.caption).foregroundStyle(tint.opacity(0.72))
            }
            Spacer()
            Image(systemName: isAvailable ? "chevron.right" : "exclamationmark.triangle")
                .foregroundStyle(tint.opacity(0.72))
        }
        .padding(8)
        .frame(width: 236)
        .background(tint.opacity(0.09), in: .rect(cornerRadius: 13))
    }

    private func linkPreview(
        title: String,
        domain: String,
        summary: String,
        image: PrototypeImageSource?
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let image {
                PrototypeImageSourceView(source: image)
                    .scaledToFill().frame(width: 256, height: 124).clipped()
            }
            VStack(alignment: .leading, spacing: 4) {
                Label(domain, systemImage: "link")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(tint.opacity(0.72))
                    .lineLimit(1)
                Text(title).font(.headline).lineLimit(2)
                Text(summary).font(.subheadline).lineLimit(3).opacity(0.78)
            }
            .padding(10)
        }
        .frame(width: image == nil ? 236 : 256, alignment: .leading)
        .background(tint.opacity(0.09), in: .rect(cornerRadius: 14))
        .clipShape(.rect(cornerRadius: 14))
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

    private func fileSymbol(for name: String) -> String {
        switch URL(fileURLWithPath: name).pathExtension.lowercased() {
        case "pdf": "doc.richtext"
        case "doc", "docx", "txt": "doc.text"
        case "xls", "xlsx": "tablecells"
        case "zip": "archivebox"
        default: "doc"
        }
    }
}

private struct PrototypeVoiceBubble: View {
    let id: String
    let duration: TimeInterval
    @ObservedObject private var playback = PrototypePlaybackCoordinator.shared

    private var isActive: Bool { playback.activeVoiceID == id }
    private var isPlaying: Bool { isActive && !playback.isPaused }
    private var elapsed: TimeInterval { isActive ? playback.elapsed : 0 }
    private var progress: Double {
        guard isActive, duration > 0 else { return 0 }
        return min(max(elapsed / duration, 0), 1)
    }

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

            PrototypeAudioWaveform(
                samples: playback.waveform(for: id),
                progress: progress
            )
            .frame(minWidth: 120, idealWidth: 170, maxWidth: 210)
            .frame(height: 32)

            Text(
                prototypeDurationString(
                    isActive ? max(0, duration - elapsed) : duration
                )
            )
            .font(.caption.monospacedDigit())
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
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
