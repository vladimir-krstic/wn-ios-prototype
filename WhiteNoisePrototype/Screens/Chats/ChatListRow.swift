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

            case let .monogram(initials):
                Text(initials)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(.circle)
    }

    private var preview: Text {
        if chat.isDraft {
            Text("Draft: \(chat.preview)")
        } else if let previewAuthor = chat.previewAuthor {
            Text(
                "\(Text("\(previewAuthor): ").bold())\(Text(chat.preview))"
            )
        } else {
            Text(chat.preview)
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
}
