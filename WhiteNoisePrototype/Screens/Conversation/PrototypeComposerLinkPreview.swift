import LinkPresentation
import SwiftUI
import UIKit

struct PrototypeComposerLinkPreviewView: View {
    let preview: PrototypeComposerLinkPreview
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            PrototypeNativeLinkPreview(preview: preview)
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Link preview, \(preview.title), \(preview.domain)")
                .accessibilityIdentifier("conversation.link-preview")

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)
            .offset(x: 5, y: -5)
            .accessibilityLabel("Remove Link Preview")
            .accessibilityIdentifier("conversation.link-preview.remove")
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

@MainActor
private struct PrototypeNativeLinkPreview: UIViewRepresentable {
    let preview: PrototypeComposerLinkPreview

    func makeUIView(context: Context) -> LPLinkView {
        LPLinkView(metadata: metadata)
    }

    func updateUIView(_ linkView: LPLinkView, context: Context) {
        linkView.metadata = metadata
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: LPLinkView,
        context: Context
    ) -> CGSize? {
        guard let width = proposal.width else { return nil }
        let size = uiView.systemLayoutSizeFitting(
            CGSize(
                width: width,
                height: UIView.layoutFittingCompressedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: width, height: size.height)
    }

    private var metadata: LPLinkMetadata {
        let result = LPLinkMetadata()
        result.originalURL = preview.url
        result.url = preview.url
        result.title = preview.title

        if let image = resolvedImage {
            result.imageProvider = NSItemProvider(object: image)
        }
        return result
    }

    private var resolvedImage: UIImage? {
        guard let source = preview.image else { return nil }
        switch source {
        case let .asset(name):
            return UIImage(named: name)
        case let .data(data):
            return UIImage(data: data)
        }
    }
}
