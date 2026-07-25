import SwiftUI
import UIKit

struct NativeChatList: UIViewRepresentable {
    struct Actions {
        let markRead: (String) -> Void
        let markUnread: (String) -> Void
        let mute: (String, ChatListItem.MuteDuration) -> Void
        let unmute: (String) -> Void
        let toggleArchive: (String) -> Void
        let leave: (String) -> Void
        let delete: (String) -> Void
    }

    let chats: [ChatListItem]
    let actions: Actions

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UICollectionView {
        var configuration = UICollectionLayoutListConfiguration(
            appearance: .plain
        )
        configuration.backgroundColor = .systemBackground
        configuration.showsSeparators = false
        configuration.leadingSwipeActionsConfigurationProvider = {
            [weak coordinator = context.coordinator] indexPath in
            coordinator?.leadingActions(at: indexPath)
        }
        configuration.trailingSwipeActionsConfigurationProvider = {
            [weak coordinator = context.coordinator] indexPath in
            coordinator?.trailingActions(at: indexPath)
        }

        let layout = UICollectionViewCompositionalLayout.list(
            using: configuration
        )
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.topEdgeEffect.style = .hard
        collectionView.topEdgeEffect.isHidden = true
        collectionView.delegate = context.coordinator

        context.coordinator.configureDataSource(
            for: collectionView
        )
        context.coordinator.applySnapshot(animated: false)

        return collectionView
    }

    func updateUIView(
        _ collectionView: UICollectionView,
        context: Context
    ) {
        context.coordinator.parent = self
        context.coordinator.applySnapshot(animated: true)
    }

    @MainActor
    final class Coordinator: NSObject,
        UICollectionViewDelegate,
        UIAdaptivePresentationControllerDelegate
    {
        private enum Section {
            case main
        }

        var parent: NativeChatList

        private var dataSource:
            UICollectionViewDiffableDataSource<Section, String>?
        private var pendingCompletion: ((Bool) -> Void)?

        init(parent: NativeChatList) {
            self.parent = parent
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            updateTopEdgeEffectVisibility(in: scrollView)
        }

        func scrollViewDidChangeAdjustedContentInset(
            _ scrollView: UIScrollView
        ) {
            updateTopEdgeEffectVisibility(in: scrollView)
        }

        func configureDataSource(
            for collectionView: UICollectionView
        ) {
            let registration = UICollectionView.CellRegistration<
                ChatListCell,
                String
            > { [weak self] cell, _, chatID in
                guard let chat = self?.chat(id: chatID) else {
                    return
                }

                cell.contentConfiguration = UIHostingConfiguration {
                    ChatListRow(chat: chat)
                }
                cell.backgroundConfiguration =
                    UIBackgroundConfiguration.clear()
                cell.accessories = []
            }

            dataSource = UICollectionViewDiffableDataSource<
                Section,
                String
            >(collectionView: collectionView) {
                collectionView,
                indexPath,
                chatID in
                collectionView.dequeueConfiguredReusableCell(
                    using: registration,
                    for: indexPath,
                    item: chatID
                )
            }
        }

        func applySnapshot(animated: Bool) {
            var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
            snapshot.appendSections([.main])
            snapshot.appendItems(parent.chats.map(\.id))
            dataSource?.apply(
                snapshot,
                animatingDifferences: animated
            )
        }

        func leadingActions(
            at indexPath: IndexPath
        ) -> UISwipeActionsConfiguration? {
            guard let chat = chat(at: indexPath) else {
                return nil
            }

            let action: UIContextualAction
            if chat.isUnread {
                action = contextualAction(
                    title: "Read",
                    symbol: "message.fill",
                    color: .systemBlue
                ) { [weak self] completion in
                    self?.parent.actions.markRead(chat.id)
                    completion(true)
                }
            } else if !chat.isArchived {
                action = contextualAction(
                    title: "Unread",
                    symbol: "message.badge",
                    color: .systemBlue
                ) { [weak self] completion in
                    self?.parent.actions.markUnread(chat.id)
                    completion(true)
                }
            } else {
                return nil
            }

            let configuration = UISwipeActionsConfiguration(
                actions: [action]
            )
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        }

        func trailingActions(
            at indexPath: IndexPath
        ) -> UISwipeActionsConfiguration? {
            guard let chat = chat(at: indexPath) else {
                return nil
            }

            var contextualActions: [UIContextualAction] = []

            if chat.hasEndedMembership {
                contextualActions.append(deleteAction(for: chat))
            } else {
                contextualActions.append(leaveAction(for: chat))
            }

            contextualActions.append(archiveAction(for: chat))

            if !chat.hasEndedMembership && !chat.isArchived {
                contextualActions.append(muteAction(for: chat))
            }

            let configuration = UISwipeActionsConfiguration(
                actions: contextualActions
            )
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }

        func presentationControllerDidDismiss(
            _ presentationController: UIPresentationController
        ) {
            completePendingAction(performed: false)
        }

        private func chat(at indexPath: IndexPath) -> ChatListItem? {
            guard let chatID = dataSource?.itemIdentifier(
                for: indexPath
            ) else {
                return nil
            }

            return chat(id: chatID)
        }

        private func chat(id: String) -> ChatListItem? {
            parent.chats.first { chat in
                chat.id == id
            }
        }

        private func archiveAction(
            for chat: ChatListItem
        ) -> UIContextualAction {
            contextualAction(
                title: chat.isArchived ? "Unarchive" : "Archive",
                symbol: "archivebox.fill",
                color: .systemGray
            ) { [weak self] completion in
                self?.parent.actions.toggleArchive(chat.id)
                completion(true)
            }
        }

        private func muteAction(
            for chat: ChatListItem
        ) -> UIContextualAction {
            if chat.isMuted {
                return contextualAction(
                    title: "Unmute",
                    symbol: "bell.fill",
                    color: .systemIndigo
                ) { [weak self] completion in
                    self?.parent.actions.unmute(chat.id)
                    completion(true)
                }
            }

            return contextualAction(
                title: "Mute",
                symbol: "bell.slash.fill",
                color: .systemIndigo
            ) { [weak self] sourceView, completion in
                self?.presentMuteDialog(
                    for: chat,
                    sourceView: sourceView,
                    completion: completion
                )
            }
        }

        private func leaveAction(
            for chat: ChatListItem
        ) -> UIContextualAction {
            contextualAction(
                title: "Leave",
                symbol: "rectangle.portrait.and.arrow.right",
                color: .systemRed
            ) { [weak self] sourceView, completion in
                self?.presentDestructiveDialog(
                    title: "Leave “\(chat.title)”?",
                    message: "You’ll stop receiving new messages. "
                        + "This chat will remain on this device as read-only "
                        + "history until you delete it.",
                    confirmationTitle: "Leave Chat",
                    sourceView: sourceView,
                    completion: completion
                ) { [weak self] in
                    self?.parent.actions.leave(chat.id)
                }
            }
        }

        private func deleteAction(
            for chat: ChatListItem
        ) -> UIContextualAction {
            contextualAction(
                title: "Delete",
                symbol: "trash.fill",
                color: .systemRed
            ) { [weak self] sourceView, completion in
                self?.presentDestructiveDialog(
                    title: "Delete “\(chat.title)” from this device?",
                    message: "This permanently removes the chat and its "
                        + "messages from this device. Signing in again "
                        + "won’t restore them.",
                    confirmationTitle: "Delete Chat",
                    sourceView: sourceView,
                    completion: completion
                ) { [weak self] in
                    self?.parent.actions.delete(chat.id)
                }
            }
        }

        private func presentMuteDialog(
            for chat: ChatListItem,
            sourceView: UIView,
            completion: @escaping (Bool) -> Void
        ) {
            let alert = UIAlertController(
                title: "Mute Notifications",
                message: "Choose how long to mute \(chat.title).",
                preferredStyle: .actionSheet
            )

            for duration in ChatListItem.MuteDuration.allCases {
                alert.addAction(
                    UIAlertAction(
                        title: duration.title,
                        style: .default
                    ) { [weak self] _ in
                        self?.parent.actions.mute(chat.id, duration)
                        self?.completePendingAction(performed: true)
                    }
                )
            }

            addCancelAction(to: alert)
            present(
                alert,
                from: sourceView,
                completion: completion
            )
        }

        private func presentDestructiveDialog(
            title: String,
            message: String,
            confirmationTitle: String,
            sourceView: UIView,
            completion: @escaping (Bool) -> Void,
            action: @escaping () -> Void
        ) {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .actionSheet
            )
            alert.addAction(
                UIAlertAction(
                    title: confirmationTitle,
                    style: .destructive
                ) { [weak self] _ in
                    action()
                    self?.completePendingAction(performed: true)
                }
            )

            addCancelAction(to: alert)
            present(
                alert,
                from: sourceView,
                completion: completion
            )
        }

        private func addCancelAction(to alert: UIAlertController) {
            alert.addAction(
                UIAlertAction(title: "Cancel", style: .cancel) {
                    [weak self] _ in
                    self?.completePendingAction(performed: false)
                }
            )
        }

        private func present(
            _ alert: UIAlertController,
            from sourceView: UIView,
            completion: @escaping (Bool) -> Void
        ) {
            guard let presenter = presenter(for: sourceView) else {
                completion(false)
                return
            }

            pendingCompletion = completion

            if let popover = alert.popoverPresentationController {
                popover.sourceView = sourceView
                popover.sourceRect = sourceView.bounds
                popover.permittedArrowDirections = []
            }

            presenter.present(alert, animated: true) {
                alert.presentationController?.delegate = self
            }
        }

        private func presenter(
            for sourceView: UIView
        ) -> UIViewController? {
            var presenter = sourceView.window?.rootViewController

            while let presented = presenter?.presentedViewController {
                presenter = presented
            }

            if let navigation = presenter as? UINavigationController {
                return navigation.visibleViewController
            }

            if let tab = presenter as? UITabBarController {
                return tab.selectedViewController
            }

            return presenter
        }

        private func completePendingAction(performed: Bool) {
            let completion = pendingCompletion
            pendingCompletion = nil
            completion?(performed)
        }

        private func updateTopEdgeEffectVisibility(
            in scrollView: UIScrollView
        ) {
            let restingOffset = -scrollView.adjustedContentInset.top
            scrollView.topEdgeEffect.isHidden =
                scrollView.contentOffset.y <= restingOffset
        }

        private func contextualAction(
            title: String,
            symbol: String,
            color: UIColor,
            handler: @escaping ((Bool) -> Void) -> Void
        ) -> UIContextualAction {
            contextualAction(
                title: title,
                symbol: symbol,
                color: color
            ) { _, completion in
                handler(completion)
            }
        }

        private func contextualAction(
            title: String,
            symbol: String,
            color: UIColor,
            handler: @escaping (UIView, @escaping (Bool) -> Void) -> Void
        ) -> UIContextualAction {
            let action = UIContextualAction(
                style: .normal,
                title: nil
            ) { _, sourceView, completion in
                handler(sourceView, completion)
            }
            let image = UIImage(systemName: symbol)
            image?.accessibilityLabel = title
            action.image = image
            action.accessibilityLabel = title
            action.backgroundColor = color
            return action
        }
    }
}

@MainActor
private final class ChatListCell: UICollectionViewListCell {
    private var configuredHeight: CGFloat = 0

    override func updateConfiguration(
        using state: UICellConfigurationState
    ) {
        super.updateConfiguration(using: state)

        var background = UIBackgroundConfiguration.clear()
        if state.isSwiped {
            background.backgroundColor = .secondarySystemFill
            background.cornerRadius = bounds.height / 2
        }
        backgroundConfiguration = background
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard configuredHeight != bounds.height else {
            return
        }

        configuredHeight = bounds.height
        setNeedsUpdateConfiguration()
    }
}
