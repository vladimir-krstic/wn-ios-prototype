import SwiftUI

struct ChatListRow: View {
    private static let unreadBadgeHeight: CGFloat = 20
    private static let failureSymbolSize: CGFloat = 18
    private static let multiDigitHorizontalPadding: CGFloat = 6

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

                    if chat.hasDisappearingMessages {
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityLabel("Disappearing messages on")
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
        PrototypeChatAvatarView(
            avatar: chat.avatar,
            size: 56,
            publicKey: chat.avatarPublicKey
        )
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
        if chat.isInvitationPending {
            Text(chat.visiblePreview)
        } else if let attachmentPreview = chat.attachmentPreview {
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
            if chat.isInvitationPending {
                Circle()
                    .fill(Color("AccentColor"))
                    .frame(
                        width: Self.unreadBadgeHeight,
                        height: Self.unreadBadgeHeight
                    )
                    .overlay {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(uiColor: .systemBackground))
                    }
                    .accessibilityLabel("Chat invitation")
            } else {
                switch chat.deliveryState {
                case .none:
                    EmptyView()

                case .failed:
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: Self.failureSymbolSize))
                        .foregroundStyle(.red)
                        .frame(
                            width: Self.failureSymbolSize,
                            height: Self.failureSymbolSize
                        )
                        .accessibilityLabel("Not delivered")
                }

                if chat.unreadCount > 0 {
                    unreadBadge
                } else if chat.isMarkedUnread {
                    unreadDot
                }
            }
        }
        .frame(minHeight: Self.unreadBadgeHeight)
    }

    private var unreadBadge: some View {
        Group {
            if unreadLabel.count == 1 {
                Circle()
                    .fill(Color("AccentColor"))
                    .frame(
                        width: Self.unreadBadgeHeight,
                        height: Self.unreadBadgeHeight
                    )
                    .overlay {
                        unreadBadgeLabel
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                    }
            } else {
                unreadBadgeLabel
                    .padding(
                        .horizontal,
                        Self.multiDigitHorizontalPadding
                    )
                    .hidden()
                    .frame(
                        minWidth: Self.unreadBadgeHeight,
                        alignment: .center
                    )
                    .frame(
                        height: Self.unreadBadgeHeight,
                        alignment: .center
                    )
                    .background {
                        Capsule()
                            .fill(Color("AccentColor"))
                    }
                    .overlay {
                        unreadBadgeLabel
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                    }
            }
        }
            .accessibilityLabel(
                "\(chat.unreadCount) unread messages"
            )
    }

    private var unreadBadgeLabel: some View {
        Text(unreadLabel)
            .font(.caption2.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(Color(uiColor: .systemBackground))
            .lineLimit(1)
            .multilineTextAlignment(.center)
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
                width: Self.unreadBadgeHeight,
                height: Self.unreadBadgeHeight
            )
            .accessibilityLabel("Unread")
    }
}
