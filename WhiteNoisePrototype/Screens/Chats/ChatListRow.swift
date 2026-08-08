import SwiftUI

struct ChatListRow: View {
    private static let statusRegion: CGFloat = 22
    private static let failureSymbolSize: CGFloat = 20

    let chat: ChatListItem

    var body: some View {
        HStack {
            avatar

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(chat.title)
                        .font(.headline)
                        .lineLimit(1)

                    if chat.isMuted {
                        Image(systemName: "bell.slash.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Muted")
                    }

                    if chat.hasEndedMembership {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel(
                                chat.membershipState == .left
                                    ? "Left chat"
                                    : "Removed from chat"
                            )
                    }

                    Spacer(minLength: 8)

                    Text(chat.timestamp)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .lineLimit(1)
                }

                HStack(alignment: .top, spacing: 5) {
                    preview
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    Spacer(minLength: 8)

                    status
                }
            }
        }
        .listRowSeparator(.hidden)
        .accessibilityElement(children: .combine)
        .accessibilityValue(chat.isPinned ? "Pinned" : "")
    }

    @ViewBuilder
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: .secondarySystemFill))

            switch chat.avatar {
            case let .asset(name):
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .accessibilityHidden(true)

            case let .imageData(data):
                if let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .accessibilityHidden(true)
                }

            case let .monogram(initials):
                Text(initials)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)

            case let .systemSymbol(name):
                Image(systemName: name)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(.circle)
        .overlay(alignment: .bottomTrailing) {
            if chat.isPinned {
                Image(systemName: "pin.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(4)
                    .background(
                        Color(uiColor: .systemBackground),
                        in: Circle()
                    )
                    .overlay {
                        Circle()
                            .stroke(
                                Color(uiColor: .separator),
                                lineWidth: 0.5
                            )
                    }
                    .offset(x: 2, y: 2)
                    .accessibilityHidden(true)
            }
        }
    }

    private var preview: Text {
        if chat.isDraft && !chat.hasEndedMembership {
            Text("Draft: \(chat.visiblePreview)")
        } else if let previewAuthor = chat.visiblePreviewAuthor {
            Text(
                "\(Text("\(previewAuthor): ").bold())\(previewContent)"
            )
        } else {
            previewContent
        }
    }

    private var previewContent: Text {
        if let attachmentPreview = chat.attachmentPreview {
            Text(
                "\(Image(systemName: attachmentPreview.symbol)) \(chat.visiblePreview)"
            )
        } else {
            Text(chat.visiblePreview)
        }
    }

    @ViewBuilder
    private var status: some View {
        HStack(spacing: 5) {
            switch chat.deliveryState {
            case .none:
                EmptyView()

            case .failed:
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: Self.failureSymbolSize))
                    .foregroundStyle(.red)
                    .frame(
                        width: Self.statusRegion,
                        height: Self.statusRegion
                    )
                    .accessibilityLabel("Not sent")
            }

            if chat.unreadCount > 0 {
                unreadBadge
            } else if chat.isMarkedUnread {
                unreadDot
            }
        }
        .frame(minHeight: Self.statusRegion)
    }

    private var unreadBadge: some View {
        Text(unreadLabel)
            .font(.caption2.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(Color(uiColor: .systemBackground))
            .lineLimit(1)
            .padding(.horizontal, 6)
            .frame(
                minWidth: Self.statusRegion,
                minHeight: Self.statusRegion,
                alignment: .center
            )
            .background(Color("AccentColor"), in: Capsule())
            .accessibilityLabel(
                "\(chat.unreadCount) unread messages"
            )
    }

    private var unreadLabel: String {
        chat.unreadCount > 99
            ? "99+"
            : chat.unreadCount.formatted(.number.grouping(.never))
    }

    private var unreadDot: some View {
        Circle()
            .fill(Color("AccentColor"))
            .frame(
                width: Self.statusRegion,
                height: Self.statusRegion
            )
            .accessibilityLabel("Unread")
    }
}
