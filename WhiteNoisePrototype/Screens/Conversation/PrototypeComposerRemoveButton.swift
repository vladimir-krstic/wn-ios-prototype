import SwiftUI

struct PrototypeComposerRemoveButton: View {
    let accessibilityLabel: String
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Image(systemName: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 24, height: 24)
            .glassEffect(
                .regular.tint(.black.opacity(0.48)).interactive(),
                in: .circle
            )
            .padding([.top, .trailing], 6)
            .frame(width: 44, height: 44, alignment: .topTrailing)
            .contentShape(.rect)
        }
        .buttonStyle(PrototypeComposerRemoveButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

private struct PrototypeComposerRemoveButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(
                configuration.isPressed && !reduceMotion ? 0.94 : 1
            )
            .animation(.smooth(duration: 0.12), value: configuration.isPressed)
    }
}
