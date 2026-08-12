import SwiftUI

enum PrototypeMessageBubbleMetrics {
    static let cornerRadius: CGFloat = 18
    static let outerContentInset: CGFloat = 6
    static let textHorizontalInset: CGFloat = 12
    static let textVerticalInset: CGFloat = 8
    static let richContentWidth: CGFloat = 256
    static let richComponentInset: CGFloat = 6
    static let richComponentCornerRadius = cornerRadius - outerContentInset
    static let contentSpacing: CGFloat = 6
    static let gallerySpacing: CGFloat = 3
}

struct PrototypeMessageBubbleShape: Shape {
    static let cornerRadius = PrototypeMessageBubbleMetrics.cornerRadius

    func path(in rect: CGRect) -> Path {
        let resolvedCornerRadius = min(rect.height / 2, Self.cornerRadius)

        return RoundedRectangle(
            cornerRadius: resolvedCornerRadius,
            style: .continuous
        ).path(in: rect)
    }
}

struct MessageRow<Content: View>: View {
    let outgoing: Bool
    let time: String
    let reaction: String?
    @ViewBuilder let content: Content

    init(
        outgoing: Bool,
        time: String,
        reaction: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.outgoing = outgoing
        self.time = time
        self.reaction = reaction
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if outgoing {
                Spacer(minLength: 56)
            }

            VStack(alignment: timestampAlignment, spacing: 4) {
                MessageBubble(outgoing: outgoing) {
                    content
                }
                .overlay(alignment: reactionAlignment) {
                    if let reaction {
                        Text(reaction)
                            .font(.caption)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(
                                Color(uiColor: .systemBackground),
                                in: Capsule()
                            )
                            .overlay {
                                Capsule()
                                    .stroke(
                                        Color(uiColor: .separator),
                                        lineWidth: 0.5
                                    )
                            }
                            .offset(
                                x: outgoing ? 10 : -10,
                                y: 11
                            )
                            .accessibilityHidden(true)
                    }
                }
                .padding(.bottom, reaction == nil ? 0 : 7)

                Text(time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(
                        outgoing ? .leading : .trailing,
                        10
                    )
            }

            if !outgoing {
                Spacer(minLength: 56)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var timestampAlignment: HorizontalAlignment {
        outgoing ? .leading : .trailing
    }

    private var reactionAlignment: Alignment {
        outgoing ? .bottomLeading : .bottomTrailing
    }
}

private struct MessageBubble<Content: View>: View {
    @Environment(\.incomingPrototypeMessageColor)
    private var incomingMessageColor
    @Environment(\.outgoingPrototypeMessageColor)
    private var outgoingMessageColor

    let outgoing: Bool
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, PrototypeMessageBubbleMetrics.textHorizontalInset)
            .padding(.vertical, PrototypeMessageBubbleMetrics.textVerticalInset)
            .foregroundStyle(foregroundStyle)
            .background(
                fill,
                in: PrototypeMessageBubbleShape()
            )
    }

    private var fill: Color {
        messageColor.color
    }

    private var foregroundStyle: Color {
        messageColor.foregroundColor
    }

    private var messageColor: PrototypeMessageColor {
        outgoing ? outgoingMessageColor : incomingMessageColor
    }

}

private struct IncomingPrototypeMessageColorKey: EnvironmentKey {
    static let defaultValue = PrototypeMessageColor.gray
}

private struct OutgoingPrototypeMessageColorKey: EnvironmentKey {
    static let defaultValue = PrototypeMessageColor.black
}

extension EnvironmentValues {
    var incomingPrototypeMessageColor: PrototypeMessageColor {
        get { self[IncomingPrototypeMessageColorKey.self] }
        set { self[IncomingPrototypeMessageColorKey.self] = newValue }
    }

    var outgoingPrototypeMessageColor: PrototypeMessageColor {
        get { self[OutgoingPrototypeMessageColorKey.self] }
        set { self[OutgoingPrototypeMessageColorKey.self] = newValue }
    }
}
