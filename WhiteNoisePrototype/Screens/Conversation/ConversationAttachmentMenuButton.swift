import SwiftUI
import UIKit

struct ConversationAttachmentMenuButton: UIViewRepresentable {
    let onCamera: () -> Void
    let onPhotosAndVideos: () -> Void
    let onFiles: () -> Void
    let onMenuVisibilityChanged: (Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onCamera: onCamera,
            onPhotosAndVideos: onPhotosAndVideos,
            onFiles: onFiles,
            onMenuVisibilityChanged: onMenuVisibilityChanged
        )
    }

    func makeUIView(context: Context) -> AttachmentMenuButton {
        let button = AttachmentMenuButton(type: .custom)
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus")
        configuration.baseForegroundColor = .label
        configuration.contentInsets = .zero
        button.configuration = configuration
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: 20, weight: .regular),
            forImageIn: .normal
        )
        button.menu = context.coordinator.makeMenu()
        button.showsMenuAsPrimaryAction = true
        button.preferredMenuElementOrder = .fixed
        button.onMenuVisibilityChanged = { [weak coordinator = context.coordinator] shown in
            coordinator?.onMenuVisibilityChanged(shown)
        }
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Add Attachment"
        button.accessibilityHint = "Opens attachment options."
        button.accessibilityIdentifier = "conversation.attachment-menu"
        return button
    }

    func updateUIView(_ button: AttachmentMenuButton, context: Context) {
        context.coordinator.update(
            onCamera: onCamera,
            onPhotosAndVideos: onPhotosAndVideos,
            onFiles: onFiles,
            onMenuVisibilityChanged: onMenuVisibilityChanged
        )
    }

    @MainActor
    final class Coordinator {
        private var onCamera: () -> Void
        private var onPhotosAndVideos: () -> Void
        private var onFiles: () -> Void
        private(set) var onMenuVisibilityChanged: (Bool) -> Void

        init(
            onCamera: @escaping () -> Void,
            onPhotosAndVideos: @escaping () -> Void,
            onFiles: @escaping () -> Void,
            onMenuVisibilityChanged: @escaping (Bool) -> Void
        ) {
            self.onCamera = onCamera
            self.onPhotosAndVideos = onPhotosAndVideos
            self.onFiles = onFiles
            self.onMenuVisibilityChanged = onMenuVisibilityChanged
        }

        func update(
            onCamera: @escaping () -> Void,
            onPhotosAndVideos: @escaping () -> Void,
            onFiles: @escaping () -> Void,
            onMenuVisibilityChanged: @escaping (Bool) -> Void
        ) {
            self.onCamera = onCamera
            self.onPhotosAndVideos = onPhotosAndVideos
            self.onFiles = onFiles
            self.onMenuVisibilityChanged = onMenuVisibilityChanged
        }

        func makeMenu() -> UIMenu {
            UIMenu(children: [
                UIAction(
                    title: "Camera",
                    image: UIImage(systemName: "camera")
                ) { [weak self] _ in
                    self?.onCamera()
                },
                UIAction(
                    title: "Photos and Videos",
                    image: UIImage(systemName: "photo.on.rectangle.angled")
                ) { [weak self] _ in
                    self?.onPhotosAndVideos()
                },
                UIAction(
                    title: "Files",
                    image: UIImage(systemName: "folder")
                ) { [weak self] _ in
                    self?.onFiles()
                }
            ])
        }
    }
}

@MainActor
final class AttachmentMenuButton: UIButton {
    var onMenuVisibilityChanged: (Bool) -> Void = { _ in }

    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willDisplayMenuFor configuration: UIContextMenuConfiguration,
        animator: (any UIContextMenuInteractionAnimating)?
    ) {
        super.contextMenuInteraction(
            interaction,
            willDisplayMenuFor: configuration,
            animator: animator
        )
        onMenuVisibilityChanged(true)
    }

    override func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willEndFor configuration: UIContextMenuConfiguration,
        animator: (any UIContextMenuInteractionAnimating)?
    ) {
        super.contextMenuInteraction(
            interaction,
            willEndFor: configuration,
            animator: animator
        )
        guard let animator else {
            onMenuVisibilityChanged(false)
            return
        }
        animator.addCompletion { [weak self] in
            self?.onMenuVisibilityChanged(false)
        }
    }
}
