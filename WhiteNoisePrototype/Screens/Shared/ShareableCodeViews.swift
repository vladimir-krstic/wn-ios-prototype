import SwiftUI
import UIKit

struct ShareableQRCodeView: View {
    let image: UIImage
    let accessibilityLabel: String

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .padding(12)
            .containerRelativeFrame(.horizontal) { length, _ in
                length * 0.81
            }
            .aspectRatio(1, contentMode: .fit)
            .background(
                .white,
                in: RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
            .accessibilityLabel(accessibilityLabel)
    }
}

struct CompactCopyValueLabel: View {
    let value: String
    let isCopied: Bool
    var fillsAvailableWidth = false

    var body: some View {
        HStack {
            Text(value)
                .lineLimit(1)
                .truncationMode(.middle)
                .font(.subheadline.monospaced())
                .foregroundStyle(.secondary)

            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 14, height: 14)
                .contentTransition(.symbolEffect(.replace))
                .animation(.default, value: isCopied)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .frame(
            maxWidth: fillsAvailableWidth ? .infinity : nil
        )
        .background(
            Color(uiColor: .secondarySystemFill),
            in: .capsule
        )
        .contentShape(Rectangle())
    }
}
