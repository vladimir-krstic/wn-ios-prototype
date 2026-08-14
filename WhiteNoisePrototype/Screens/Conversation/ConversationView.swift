import PhotosUI
import QuickLook
import SwiftUI
import UIKit
import UniformTypeIdentifiers

private struct ConversationIndexedTimelineEntry: Identifiable {
    let index: Int
    let entry: PrototypeTimelineEntry

    var id: String { entry.id }
}

private struct ConversationTimelineDay: Identifiable {
    let date: Date
    var entries: [ConversationIndexedTimelineEntry]

    var id: Date { date }
}

private struct ConversationDeletionRequest: Identifiable {
    let messageIDs: Set<String>

    var id: String { messageIDs.sorted().joined(separator: ",") }
}

private struct ConversationDateHeader: View {
    let date: Date
    let visibilityChanged: (Bool) -> Void

    var body: some View {
        label
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .allowsHitTesting(false)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("conversation.date-header")
            .onScrollVisibilityChange(threshold: 0.01) { isVisible in
                visibilityChanged(isVisible)
            }
            .onDisappear {
                visibilityChanged(false)
            }
    }

    private var label: some View {
        Text(PrototypeDateFormatter.separator(for: date))
            .font(.footnote.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
    }
}

private struct ConversationPinnedDateHeader: View {
    let date: Date

    var body: some View {
        Text(PrototypeDateFormatter.separator(for: date))
            .font(.footnote.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .foregroundStyle(.primary)
            .glassEffect(.regular, in: .capsule)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .allowsHitTesting(false)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("conversation.pinned-date-header")
    }
}

private struct ConversationComposerBarBoundsKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil

    static func reduce(
        value: inout Anchor<CGRect>?,
        nextValue: () -> Anchor<CGRect>?
    ) {
        value = nextValue() ?? value
    }
}

private enum ConversationExpandableComposerLayout {
    static let expandedTopGap: CGFloat = 24
    static let minimumDragDistance: CGFloat = 3
    static let projectedTravelThreshold: CGFloat = 48
}

private struct ConversationComposerExpansionInteraction {
    let isEnabled: Bool
    let update: (CGFloat) -> Void
    let finish: (CGFloat) -> Void
}

private struct ConversationExpandableComposerSurface<
    Transcript: View,
    Composer: View
>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var isExpanded: Bool

    let availableHeight: CGFloat
    let isExpansionEnabled: Bool
    let shouldPushTranscript: Bool
    let onOutsideTap: () -> Void
    let transcript: (Bool) -> Transcript
    let composer: (
        Bool,
        Double,
        ConversationComposerExpansionInteraction
    ) -> Composer

    @State private var compactHeight: CGFloat = 0
    @State private var expansionProgress: CGFloat = 0
    @State private var isSettling = false
    @State private var pushesTranscriptForPresentation: Bool?

    init(
        availableHeight: CGFloat,
        isExpanded: Binding<Bool>,
        isExpansionEnabled: Bool,
        shouldPushTranscript: Bool,
        onOutsideTap: @escaping () -> Void,
        @ViewBuilder transcript: @escaping (Bool) -> Transcript,
        @ViewBuilder composer: @escaping (
            Bool,
            Double,
            ConversationComposerExpansionInteraction
        ) -> Composer
    ) {
        self.availableHeight = availableHeight
        _isExpanded = isExpanded
        self.isExpansionEnabled = isExpansionEnabled
        self.shouldPushTranscript = shouldPushTranscript
        self.onOutsideTap = onOutsideTap
        self.transcript = transcript
        self.composer = composer
    }

    var body: some View {
        transcript(usesFlexibleLayout)
            .scrollDisabled(usesFlexibleLayout)
            .allowsHitTesting(!usesFlexibleLayout)
            .accessibilityHidden(usesFlexibleLayout)
            .offset(
                y: pushesTranscriptForPresentation == true
                    ? -transcriptPushOffset
                    : 0
            )
            .safeAreaBar(edge: .bottom, spacing: 0) {
                compactReservation
            }
            .overlayPreferenceValue(
                ConversationComposerBarBoundsKey.self
            ) { bounds in
                if let bounds {
                    foregroundComposer(bounds: bounds)
                }
            }
            .onChange(of: isExpanded) { _, expanded in
                let targetProgress: CGFloat = expanded ? 1 : 0
                guard expansionProgress != targetProgress else { return }
                settle(toExpanded: expanded, updatesBinding: false)
            }
    }

    private var compactReservation: some View {
        Color.clear
            .frame(height: max(1, compactHeight))
            .anchorPreference(
                key: ConversationComposerBarBoundsKey.self,
                value: .bounds
            ) { $0 }
    }

    private func foregroundComposer(bounds: Anchor<CGRect>) -> some View {
        GeometryReader { proxy in
            let frame = proxy[bounds]

            ZStack(alignment: .bottom) {
                Color.clear
                    .contentShape(.rect)
                    .onTapGesture(perform: onOutsideTap)
                    .allowsHitTesting(usesFlexibleLayout)
                    .accessibilityHidden(true)

                presentedComposer
            }
            .frame(
                width: frame.width,
                height: max(1, frame.maxY),
                alignment: .bottom
            )
            .offset(x: frame.minX)
        }
    }

    private var presentedComposer: some View {
        composer(
            usesFlexibleLayout,
            transcriptBackingOpacity,
            expansionInteraction
        )
            .frame(height: presentationHeight, alignment: .bottom)
            .fixedSize(horizontal: false, vertical: !usesFlexibleLayout)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                guard !usesFlexibleLayout else { return }
                compactHeight = height
            }
    }

    private var usesFlexibleLayout: Bool {
        isExpansionEnabled
            && (isExpanded || expansionProgress > 0 || isSettling)
    }

    private var presentationHeight: CGFloat? {
        guard usesFlexibleLayout else { return nil }
        return compactResolvedHeight
            + ((expandedHeight - compactResolvedHeight) * expansionProgress)
    }

    private var compactResolvedHeight: CGFloat {
        max(1, compactHeight)
    }

    private var transcriptPushOffset: CGFloat {
        (expandedHeight - compactResolvedHeight) * expansionProgress
    }

    private var transcriptBackingOpacity: Double {
        guard pushesTranscriptForPresentation == false else { return 0 }
        return Double(expansionProgress)
    }

    private var expandedHeight: CGFloat {
        max(
            compactResolvedHeight,
            availableHeight
                - ConversationExpandableComposerLayout.expandedTopGap
        )
    }

    private var expansionInteraction: ConversationComposerExpansionInteraction {
        ConversationComposerExpansionInteraction(
            isEnabled: isExpansionEnabled,
            update: updateExpansion(translationHeight:),
            finish: finishExpansion(projectedTravel:)
        )
    }

    private func updateExpansion(translationHeight: CGFloat) {
        guard isExpansionEnabled, !isSettling else { return }

        let travel = expandedHeight - compactResolvedHeight
        guard travel > 0 else { return }
        captureTranscriptBehaviorIfNeeded()
        let startingProgress: CGFloat = isExpanded ? 1 : 0
        let progress = startingProgress - (translationHeight / travel)

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            expansionProgress = min(max(progress, 0), 1)
        }
    }

    private func finishExpansion(projectedTravel: CGFloat) {
        guard isExpansionEnabled, !isSettling else { return }

        let destination: Bool
        if projectedTravel
            <= -ConversationExpandableComposerLayout
                .projectedTravelThreshold {
            destination = true
        } else if projectedTravel
            >= ConversationExpandableComposerLayout
                .projectedTravelThreshold {
            destination = false
        } else {
            destination = expansionProgress >= 0.5
        }

        settle(toExpanded: destination, updatesBinding: true)
    }

    private func settle(toExpanded expanded: Bool, updatesBinding: Bool) {
        let targetProgress: CGFloat = expanded ? 1 : 0
        if updatesBinding, isExpanded != expanded {
            isExpanded = expanded
        }

        if expanded || expansionProgress > 0 {
            captureTranscriptBehaviorIfNeeded()
        }

        if reduceMotion {
            expansionProgress = targetProgress
            isSettling = false
            if !expanded {
                pushesTranscriptForPresentation = nil
            }
            return
        }

        isSettling = true
        withAnimation(
            .interactiveSpring,
            completionCriteria: .logicallyComplete
        ) {
            expansionProgress = targetProgress
        } completion: {
            if expansionProgress == targetProgress {
                isSettling = false
                if !expanded {
                    pushesTranscriptForPresentation = nil
                }
            }
        }
    }

    private func captureTranscriptBehaviorIfNeeded() {
        guard pushesTranscriptForPresentation == nil else { return }
        pushesTranscriptForPresentation = shouldPushTranscript
    }
}

struct ConversationView: View {
    private let bottomID = "conversation-bottom"

    private struct TimelineScrollRequest: Equatable {
        let messageID: String
        let highlightsTarget: Bool
    }

    private enum TimelineSpacing {
        static let compactCluster: CGFloat = 3
        static let separateCluster: CGFloat = 16
    }

    private enum ComposerMediaDraftLayout {
        static let previewHeight: CGFloat = 112
        static let minimumPreviewWidth: CGFloat = 68
        static let maximumPreviewWidth: CGFloat = 200
        static let cornerRadius: CGFloat = 14
        static let shelfPadding: CGFloat = 8
        static let shelfMaskCornerRadius: CGFloat = 22
        static let itemSpacing: CGFloat = 8
        static let minimumUtilityPreviewWidth: CGFloat = 104
        static let maximumUtilityPreviewWidth: CGFloat = 160
        static let utilityPreviewHeight: CGFloat = 72
        static let utilityPreviewHorizontalPadding: CGFloat = 12
        static let separatorHorizontalInset: CGFloat = 12
        static let separatorThickness: CGFloat = 1

        static var shelfHeight: CGFloat {
            previewHeight + (shelfPadding * 2)
        }
    }

    private let playback = PrototypePlaybackCoordinator.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .caption2) private var conversationHeaderTimerIconSize: CGFloat = 9

    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    let chatID: String
    let authoritativeChatReplacement: ((String, PrototypeChat) -> Void)?

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isPhotoPickerPresented = false
    @State private var isCameraPresented = false
    @State private var queuedAttachments: [PrototypeAttachment] = []
    @State private var composerMediaSelection: PrototypeComposerMediaSelection?
    @State private var suppressedLinkPreviewURL: String?
    @State private var isFileImporterPresented = false
    @State private var isContactPickerPresented = false
    @State private var mediaSelection: PrototypeMediaSelection?
    @State private var pendingMediaMessageID: String?
    @State private var quickLookURL: URL?
    @State private var deletionRequest: ConversationDeletionRequest?
    @State private var isDeleteAllConfirmationPresented = false
    @State private var isDeclineInvitationConfirmationPresented = false
    @State private var messageFrames: [String: CGRect] = [:]
    @State private var messageContextContentFrames: [String: CGRect] = [:]
    @State private var contextMessageID: String?
    @State private var emojiPickerMessageID: String?
    @State private var selectedMessageIDs: Set<String> = []
    @State private var isSelectingMessages = false
    @State private var forwardingMessageIDs: [String] = []
    @State private var isForwardingMessages = false
    @State private var messageDetailsID: String?
    @State private var copyFeedbackTrigger = 0
    @State private var reactionFeedbackTrigger = 0
    @State private var highlightedMessageID: String?
    @State private var requestedScroll: TimelineScrollRequest?
    @State private var selectedPersonID: String?
    @State private var isShowingChatInfo = false
    @State private var isShowingSearch = false
    @State private var pendingSearchResultID: String?
    @State private var composerText: String
    @State private var renderedChat: PrototypeChat?
    @State private var voiceState = PrototypeVoiceRecordingState.idle
    @State private var recordingSeconds = 0
    @State private var recordingWaveformSamples: [Double] = []
    @State private var isVoiceButtonPressing = false
    @State private var isComposerInteractionBlocked = false
    @State private var isAttachmentMenuPresented = false
    @State private var attachmentMenuDismissalTask: Task<Void, Never>?
    @State private var fileImportTask: Task<Void, Never>?
    @State private var attachmentPresentationTask: Task<Void, Never>?
    @State private var composerTextHeight: CGFloat = 0
    @State private var composerIsExpanded = false
    @State private var conversationAvailableHeight: CGFloat = 0
    @State private var isTimelineBottomVisible = true
    @State private var activeTimelineDate: Date?
    @State private var visibleTimelineDateHeaders: Set<Date> = []
    @State private var composerIsFocused = false

    init(
        profile: Binding<PrototypeProfile>,
        settings: Binding<PrototypeSettingsState>,
        chatID: String,
        authoritativeChatReplacement: ((String, PrototypeChat) -> Void)? = nil
    ) {
        _profile = profile
        _settings = settings
        self.chatID = chatID
        self.authoritativeChatReplacement = authoritativeChatReplacement
        let initialChat = profile.wrappedValue.chats.first(where: { $0.id == chatID })
        _renderedChat = State(initialValue: initialChat)
        _composerText = State(
            initialValue: initialChat?.draft ?? ""
        )
        _queuedAttachments = State(
            initialValue: initialChat?.draftAttachments ?? []
        )
        _suppressedLinkPreviewURL = State(
            initialValue: initialChat?.suppressedDraftLinkURL
        )
        _activeTimelineDate = State(
            initialValue: initialChat?.timeline.last.map {
                Calendar.autoupdatingCurrent.startOfDay(for: $0.date)
            }
        )
    }

    var body: some View {
        if renderedChat != nil || chatIndex != nil {
            conversation
        } else {
            ContentUnavailableView("Chat Unavailable", systemImage: "bubble.left")
        }
    }

    private var conversation: some View {
        ScrollViewReader { proxy in
            conversationBottomSurface(
                availableHeight: conversationAvailableHeight
            ) { hidesDatePills in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(timelineDays) { day in
                            ConversationDateHeader(date: day.date) { isVisible in
                                setDateHeader(day.date, isVisible: isVisible)
                            }
                            .opacity(hidesDatePills ? 0 : 1)
                            .accessibilityHidden(hidesDatePills)

                            ForEach(day.entries) { indexedEntry in
                                timelineEntry(indexedEntry.entry, at: indexedEntry.index)
                                    .padding(.top, timelineTopPadding(at: indexedEntry.index))
                                    .id(indexedEntry.entry.id)
                            }

                            if day.id == timelineDays.last?.id {
                                Color.clear.frame(height: 8).id(bottomID)
                            }
                        }

                        if timelineDays.isEmpty {
                            Color.clear.frame(height: 8).id(bottomID)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .defaultScrollAnchor(.bottom, for: .initialOffset)
                .defaultScrollAnchor(.bottom, for: .alignment)
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
                .scrollEdgeEffectStyle(.soft, for: .bottom)
                .onScrollTargetVisibilityChange(idType: String.self, threshold: 0.01) { identifiers in
                    if !hidesDatePills {
                        isTimelineBottomVisible = identifiers.contains(bottomID)
                    }
                    updateActiveTimelineDate(from: identifiers)
                }
                .overlay(alignment: .top) {
                    if !hidesDatePills,
                       let activeTimelineDate,
                       !visibleTimelineDateHeaders.contains(activeTimelineDate) {
                        ConversationPinnedDateHeader(date: activeTimelineDate)
                    }
                }
            }
            .onChange(of: chat.timeline.count) {
                activeTimelineDate = timelineDays.last?.date
                withAnimation { proxy.scrollTo(bottomID, anchor: .bottom) }
            }
            .onChange(of: composerIsFocused) { _, isFocused in
                guard isFocused else { return }
                withAnimation { proxy.scrollTo(bottomID, anchor: .bottom) }
            }
            .onChange(of: composerTextHeight) { oldHeight, newHeight in
                guard composerIsFocused, newHeight > oldHeight else { return }
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
            .onChange(of: requestedScroll) { _, request in
                guard let request else { return }
                withAnimation { proxy.scrollTo(request.messageID, anchor: .center) }
                requestedScroll = nil

                if request.highlightsTarget {
                    highlightedMessageID = request.messageID
                    Task {
                        try? await Task.sleep(for: .seconds(1.2))
                        if highlightedMessageID == request.messageID {
                            highlightedMessageID = nil
                        }
                    }
                }
            }
        }
        .coordinateSpace(name: "conversationSurface")
        .accessibilityHidden(contextMessageID != nil)
        .overlay {
            messageContextOverlay
        }
        .environment(\.incomingPrototypeMessageColor, settings.incomingMessageColor)
        .environment(\.outgoingPrototypeMessageColor, settings.outgoingMessageColor)
        .environment(\.openURL, OpenURLAction { url in
            if url.scheme == "whitenoise-person", let id = url.host {
                selectedPersonID = id
                return .handled
            }
            return url.scheme?.lowercased() == "https" ? .systemAction : .discarded
        })
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isSelectingMessages)
        .toolbar { conversationToolbar }
        .background {
            ConversationKeyboardLayoutReader { availableHeight in
                conversationAvailableHeight = availableHeight
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(item: $mediaSelection, onDismiss: openPendingMediaMessage) { selection in
            PrototypeMediaViewer(
                profile: $profile,
                sourceChatID: chatID,
                selection: selection,
                onRequestOpenMessage: { messageID in
                    pendingMediaMessageID = messageID
                    mediaSelection = nil
                }
            )
        }
        .fullScreenCover(item: $composerMediaSelection) { selection in
            PrototypeComposerMediaViewer(selection: selection) {
                includedItemIDs in
                let reviewedItemIDs = Set(selection.attachments.map(\.id))
                queuedAttachments.removeAll { attachment in
                    reviewedItemIDs.contains(attachment.id)
                        && !includedItemIDs.contains(attachment.id)
                }
            }
        }
        .sheet(isPresented: $isCameraPresented) {
            ConversationCameraCaptureView(onCapture: handleCameraCapture)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isContactPickerPresented) {
            NavigationStack {
                ConversationContactPicker(people: shareableContacts) { person in
                    queueContact(person)
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .quickLookPreview($quickLookURL)
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true,
            onCompletion: importFiles
        )
        .photosPicker(
            isPresented: $isPhotoPickerPresented,
            selection: $selectedPhotoItems,
            maxSelectionCount: 20,
            matching: .any(of: [.images, .videos])
        )
        .onChange(of: isCameraPresented) { _, _ in
            restoreComposerInteractionIfPossible()
        }
        .onChange(of: isPhotoPickerPresented) { _, _ in
            restoreComposerInteractionIfPossible()
        }
        .onChange(of: isFileImporterPresented) { _, _ in
            restoreComposerInteractionIfPossible()
        }
        .onChange(of: isContactPickerPresented) { _, _ in
            restoreComposerInteractionIfPossible()
        }
        .task(id: selectedPhotoItems) { await preparePhotoItems() }
        .alert(
            "Decline Invitation?",
            isPresented: $isDeclineInvitationConfirmationPresented
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Decline", role: .destructive, action: declineInvitation)
        } message: {
            Text(
                chat.isGroup
                    ? "This group invitation and its messages will be removed from Chats."
                    : "This invitation and its messages will be removed from Chats."
            )
        }
        .confirmationDialog(
            deletionDialogTitle,
            isPresented: Binding(
                get: { deletionRequest != nil },
                set: { if !$0 { deletionRequest = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete for Me", role: .destructive) {
                deleteRequestedMessagesForCurrentProfile()
            }
            if canDeleteRequestedMessagesForEveryone {
                Button("Delete for Everyone", role: .destructive) {
                    deleteRequestedMessagesForEveryone()
                }
            }
            Button("Cancel", role: .cancel) { deletionRequest = nil }
        } message: {
            Text(deletionDialogMessage)
        }
        .confirmationDialog(
            "Delete all messages in the chat?",
            isPresented: $isDeleteAllConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete All Messages", role: .destructive) { deleteAllMessagesForMe() }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $isForwardingMessages, onDismiss: {
            forwardingMessageIDs = []
        }) {
            PrototypeForwardMessagesView(
                chats: profile.chats,
                people: profile.people,
                currentProfileID: profile.id,
                onForward: completeForward
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(
            isPresented: Binding(
                get: { emojiPickerMessageID != nil },
                set: { if !$0 { emojiPickerMessageID = nil } }
            )
        ) {
            PrototypeEmojiPickerView(
                quickReactionEmoji: $profile.quickReactionEmoji,
                onSelect: selectFullReaction
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingSearch) {
            NavigationStack {
                ChatMessageSearchView(
                    chat: chat,
                    people: profile.people,
                    profileID: profile.id
                ) { messageID in
                    pendingSearchResultID = messageID
                    isShowingSearch = false
                }
            }
        }
        .onChange(of: isShowingSearch) { _, isPresented in
            guard !isPresented, let messageID = pendingSearchResultID else { return }
            pendingSearchResultID = nil
            composerIsFocused = false
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(350))
                requestedScroll = TimelineScrollRequest(
                    messageID: messageID,
                    highlightsTarget: true
                )
            }
        }
        .navigationDestination(isPresented: $isShowingChatInfo) {
            ChatInfoView(
                profile: $profile,
                settings: $settings,
                chatID: chatID,
                onSearch: openSearchFromChatInfo,
                onOpenMessage: openMessageFromChatInfo
            )
        }
        .onChange(of: authoritativeDisappearingMessageDuration) { _, _ in
            guard let current = profile.chats.first(where: { $0.id == chatID }) else {
                return
            }
            renderedChat = current
        }
        .navigationDestination(isPresented: messageDetailsIsPresented) {
            if let messageDetailsMessage {
                PrototypeMessageDetailsView(
                    message: messageDetailsMessage,
                    chat: chat,
                    profile: profile
                )
            }
        }
        .navigationDestination(isPresented: personIsPresented) {
            if let selectedPersonID {
                if chat.isGroup,
                   chat.members.contains(where: { $0.personID == selectedPersonID }) {
                    GroupMemberView(
                        profile: $profile,
                        settings: $settings,
                        chatID: chatID,
                        personID: selectedPersonID
                    )
                } else {
                    PersonProfileView(
                        profile: $profile,
                        settings: $settings,
                        personID: selectedPersonID,
                        contextGroupID: chat.isGroup ? chatID : nil,
                        onMessagePerson: { _ in
                            self.selectedPersonID = nil
                        }
                    )
                }
            }
        }
        .onAppear {
            guard var current = profile.chats.first(where: { $0.id == chatID }) else {
                return
            }
            let changedReadState = current.listState.unreadCount > 0
                || current.listState.isMarkedUnread
            current.listState.unreadCount = 0
            current.listState.isMarkedUnread = false
            renderedChat = current
            composerText = current.draft
            queuedAttachments = current.draftAttachments
            suppressedLinkPreviewURL = current.suppressedDraftLinkURL
            if changedReadState {
                persistAuthoritativeChat(current)
            }
        }
        .onDisappear {
            persistDraft()
            PrototypePlaybackCoordinator.shared.stopAll()
            fileImportTask?.cancel()
            attachmentPresentationTask?.cancel()
            attachmentMenuDismissalTask?.cancel()
            voiceState.reset()
            recordingSeconds = 0
            recordingWaveformSamples = []
            isComposerInteractionBlocked = false
            isAttachmentMenuPresented = false
            contextMessageID = nil
            emojiPickerMessageID = nil
            dismissSelection()
        }
        .sensoryFeedback(.impact, trigger: contextMessageID) { oldValue, newValue in
            oldValue == nil && newValue != nil
        }
        .sensoryFeedback(.selection, trigger: selectedMessageIDs)
        .sensoryFeedback(.selection, trigger: reactionFeedbackTrigger)
        .sensoryFeedback(.success, trigger: copyFeedbackTrigger)
    }

    @ViewBuilder
    private func conversationBottomSurface<Content: View>(
        availableHeight: CGFloat,
        @ViewBuilder content: @escaping (Bool) -> Content
    ) -> some View {
        if chat.listState.membershipState == .invited {
            content(false)
                .safeAreaBar(edge: .bottom, spacing: 0) {
                    invitationActionBar
                }
        } else if isSelectingMessages {
            content(false)
                .safeAreaBar(edge: .bottom, spacing: 0) {
                    selectionToolbar
                }
        } else {
            switch chat.listState.membershipState {
            case .invited:
                content(false)
            case .left:
                content(false)
                    .safeAreaBar(edge: .bottom, spacing: 0) {
                        recoveryView(.left)
                    }
            case .removed:
                content(false)
                    .safeAreaBar(edge: .bottom, spacing: 0) {
                        recoveryView(.removed)
                    }
            case .active:
                if let recovery = composerRecovery {
                    content(false)
                        .safeAreaBar(edge: .bottom, spacing: 0) {
                            recoveryView(recovery)
                        }
                } else {
                    ConversationExpandableComposerSurface(
                        availableHeight: availableHeight,
                        isExpanded: $composerIsExpanded,
                        isExpansionEnabled: !isRecording
                            && !isReviewingVoice
                            && !isComposerInteractionBlocked,
                        shouldPushTranscript: isTimelineBottomVisible,
                        onOutsideTap: dismissComposerFromOutside
                    ) { hidesDatePills in
                        content(hidesDatePills)
                            .simultaneousGesture(
                                conversationKeyboardDismissTapGesture
                            )
                    } composer: {
                        usesFlexibleLayout,
                        transcriptBackingOpacity,
                        expansionInteraction in
                        composerArea(
                            usesFlexibleLayout: usesFlexibleLayout,
                            transcriptBackingOpacity:
                                transcriptBackingOpacity,
                            expansionInteraction: expansionInteraction
                        )
                    }
                }
            }
        }
    }

    private var conversationKeyboardDismissTapGesture: some Gesture {
        TapGesture()
            .onEnded {
                dismissComposerFromOutside()
            }
    }

    private func dismissComposerFromOutside() {
        guard !isAttachmentMenuPresented,
              composerIsFocused || composerIsExpanded else {
            return
        }
        composerIsFocused = false
        composerIsExpanded = false
    }

    private func composerExpansionGesture(
        _ interaction: ConversationComposerExpansionInteraction
    ) -> some Gesture {
        DragGesture(
            minimumDistance:
                ConversationExpandableComposerLayout.minimumDragDistance,
            coordinateSpace: .global
        )
            .onChanged { value in
                interaction.update(value.translation.height)
            }
            .onEnded { value in
                interaction.update(value.translation.height)
                interaction.finish(
                    value.predictedEndTranslation.height
                        - value.translation.height
                )
            }
    }

    @ToolbarContentBuilder
    private var conversationToolbar: some ToolbarContent {
        if isSelectingMessages {
            ToolbarItem(placement: .topBarLeading) {
                Button("Delete All") {
                    isDeleteAllConfirmationPresented = true
                }
            }
        }

        ToolbarItem(placement: .principal) {
            if isSelectingMessages {
                Text(chat.title(people: profile.people))
                    .font(.headline)
                    .lineLimit(1)
            } else {
                Button {
                    isShowingChatInfo = true
                } label: {
                    HStack(spacing: 8) {
                        PrototypeChatAvatarView(
                            avatar: chat.resolvedAvatar(people: profile.people),
                            size: 44,
                            publicKey: chat.resolvedAvatarPublicKey(people: profile.people)
                        )
                        VStack(alignment: .leading, spacing: 0) {
                            Text(chat.title(people: profile.people))
                                .font(.headline).lineLimit(1)
                            conversationHeaderSubtitle
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(conversationHeaderAccessibilityLabel)
                .accessibilityHint("Opens chat information.")
                .accessibilityIdentifier("conversation.info")
            }
        }

        if isSelectingMessages {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close", systemImage: "xmark", role: .close) {
                    dismissSelection()
                }
            }
        }
    }

    @ViewBuilder
    private var conversationHeaderSubtitle: some View {
        if chat.isGroup && chat.disappearingMessageDuration.isEnabled {
            HStack(spacing: 0) {
                Text("\(conversationMemberCountLabel) · ")
                Image(systemName: "timer")
                    .font(.system(size: conversationHeaderTimerIconSize))
                Text(" \(chat.disappearingMessageDuration.compactTitle)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        } else if chat.isGroup {
            Text(conversationMemberCountLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        } else if chat.disappearingMessageDuration.isEnabled {
            HStack(spacing: 0) {
                Image(systemName: "timer")
                    .font(.system(size: conversationHeaderTimerIconSize))
                Text(" \(chat.disappearingMessageDuration.compactTitle)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
    }

    private var conversationMemberCountLabel: String {
        "\(chat.members.count) members"
    }

    private var conversationHeaderAccessibilityLabel: String {
        var components = [chat.title(people: profile.people)]
        if chat.isGroup {
            components.append(conversationMemberCountLabel)
        }
        if chat.disappearingMessageDuration.isEnabled {
            components.append(
                "Disappearing messages, \(chat.disappearingMessageDuration.title)"
            )
        }
        return components.joined(separator: ", ")
    }

    private func openSearchFromChatInfo() {
        isShowingChatInfo = false
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            isShowingSearch = true
        }
    }

    private func openMessageFromChatInfo(_ messageID: String) {
        isShowingChatInfo = false
        composerIsFocused = false
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(350))
            requestedScroll = TimelineScrollRequest(
                messageID: messageID,
                highlightsTarget: true
            )
        }
    }

    @ViewBuilder
    private func timelineEntry(_ entry: PrototypeTimelineEntry, at index: Int) -> some View {
        switch entry {
        case let .event(event):
            Text(
                PrototypeChatEventFormatter.text(
                    for: event.kind,
                    profileID: profile.id,
                    people: profile.people
                )
            )
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("event.\(event.id)")

        case let .notice(notice):
            Text(notice.text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("notice.\(notice.id)")

        case let .message(message):
            let author = profile.people.first { $0.id == message.authorID }
            HStack(alignment: .bottom, spacing: 0) {
                if isSelectingMessages {
                    selectionIndicator(for: message)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }

                messageBubble(message, at: index, author: author)
                    .opacity(contextMessageID == message.id ? 0 : 1)
                    .onGeometryChange(for: CGRect.self) { proxy in
                        proxy.frame(in: .named("conversationSurface"))
                    } action: { frame in
                        messageFrames[message.id] = frame
                    }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard isSelectingMessages else { return }
                toggleSelection(message.id)
            }
            .accessibilityActions {
                if isSelectingMessages {
                    Button(
                        selectedMessageIDs.contains(message.id)
                            ? "Deselect Message"
                            : "Select Message"
                    ) {
                        toggleSelection(message.id)
                    }
                } else if !message.isDeleted,
                          chat.listState.membershipState != .invited {
                    if message.authorID == profile.id, message.deliveryState == .failed {
                        Button("Retry Send") { retryMessage(message.id) }
                    }
                    Button("Show Actions") { showMessageActions(message.id) }
                    Button("Reply") { beginReply(to: message.id) }
                    Button("Forward") { beginForward(messageIDs: [message.id]) }
                    if !message.text.isEmpty {
                        Button("Copy") {
                            UIPasteboard.general.string = message.text
                            copyFeedbackTrigger += 1
                        }
                    }
                    Button("Select") { beginSelection(at: message.id) }
                    Button("Info") { messageDetailsID = message.id }
                    Button("Delete", role: .destructive) {
                        requestDeletion(of: [message.id])
                    }
                }
            }
            .accessibilityValue(
                isSelectingMessages
                    ? (selectedMessageIDs.contains(message.id) ? "Selected" : "Not selected")
                    : ""
            )
            .animation(.easeInOut(duration: 0.2), value: isSelectingMessages)
        }
    }

    private func messageBubble(
        _ message: PrototypeMessage,
        at index: Int,
        author: PrototypePerson?,
        reportsContextContentFrame: Bool = true
    ) -> some View {
        PrototypeMessageBubble(
            message: message,
            outgoing: message.authorID == profile.id,
            isGroup: chat.isGroup,
            author: author,
            profileName: profile.name,
            resolvedReply: resolvedReply(for: message),
            replyAuthorName: replyAuthorName(for: message),
            showsAuthor: startsCluster(at: index),
            showsAvatar: endsCluster(at: index),
            showsTimestamp: endsCluster(at: index),
            isHighlighted: highlightedMessageID == message.id,
            people: profile.people,
            currentProfileID: profile.id,
            onToggleReaction: { toggleReaction($0, messageID: message.id) },
            onOpenReply: {
                if let target = message.replyToMessageID {
                    requestedScroll = TimelineScrollRequest(
                        messageID: target,
                        highlightsTarget: false
                    )
                }
            },
            onOpenPerson: { selectedPersonID = $0 },
            onOpenMedia: { attachment in
                PrototypePlaybackCoordinator.shared.stopAll()
                mediaSelection = PrototypeMediaSelection(
                    chat: chat,
                    messageID: message.id,
                    attachmentID: attachment.id
                )
            },
            onOpenFile: { quickLookURL = $0 },
            isContextInteractionEnabled: !isSelectingMessages
                && contextMessageID == nil
                && chat.listState.membershipState != .invited,
            onShowActions: { showMessageActions(message.id) },
            isSwipeToReplyEnabled: !message.isDeleted
                && !isSelectingMessages
                && contextMessageID == nil
                && chat.listState.membershipState == .active
                && composerRecovery == nil,
            onSwipeToReply: { beginReply(to: message.id) },
            onContextContentFrameChange: { frame in
                guard reportsContextContentFrame else { return }
                messageContextContentFrames[message.id] = frame
            }
        )
    }

    @ViewBuilder
    private var messageContextOverlay: some View {
        if let message = contextMessage,
           let sourceFrame = messageFrames[message.id],
           let contentFrame = messageContextContentFrames[message.id],
           let index = chat.timeline.firstIndex(where: { $0.id == message.id }) {
            PrototypeMessageContextPresentation(
                message: message,
                outgoing: message.authorID == profile.id,
                sourceFrame: sourceFrame,
                contentFrame: contentFrame,
                currentProfileID: profile.id,
                quickReactionEmoji: profile.quickReactionEmoji,
                preview: {
                    messageBubble(
                        message,
                        at: index,
                        author: profile.people.first { $0.id == message.authorID },
                        reportsContextContentFrame: false
                    )
                },
                onDismiss: { contextMessageID = nil },
                onAction: { performContextAction($0, for: message) },
                onReaction: { emoji in
                    toggleReaction(emoji, messageID: message.id)
                },
                onMoreReactions: {
                    emojiPickerMessageID = message.id
                }
            )
            .zIndex(100)
        }
    }

    private func selectionIndicator(for message: PrototypeMessage) -> some View {
        Image(
            systemName: selectedMessageIDs.contains(message.id)
                ? "checkmark.circle.fill"
                : "circle"
        )
        .font(.title3)
        .foregroundStyle(
            selectedMessageIDs.contains(message.id) ? Color.accentColor : .secondary
        )
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .accessibilityHidden(true)
    }

    private var selectionToolbar: some View {
        GlassEffectContainer {
            HStack {
                Button(role: .destructive) {
                    requestDeletion(of: selectedMessageIDs)
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .disabled(selectedMessageIDs.isEmpty)
                .accessibilityLabel("Delete Selected Messages")

                Spacer()

                Text("\(selectedMessageIDs.count) Selected")
                    .font(.body.weight(.medium))
                    .contentTransition(.numericText())
                    .padding(.horizontal, 20)
                    .frame(minHeight: 44)
                    .glassEffect(.regular, in: .capsule)
                    .accessibilityIdentifier("conversation.selection.count")

                Spacer()

                Button {
                    beginForward(messageIDs: selectedMessageIDs)
                } label: {
                    Image(systemName: "arrowshape.turn.up.right")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
                .disabled(!canForwardSelection)
                .accessibilityLabel("Forward Selected Messages")
                .accessibilityHint(selectionForwardHint)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private var invitationActionBar: some View {
        VStack {
            membershipStatusLabel(
                "Invited to chat by \(invitationInviterName)",
                systemImage: "envelope.badge"
            )
            .accessibilityIdentifier("conversation.invitation.status")

            HStack {
                Button("Decline", role: .destructive) {
                    isDeclineInvitationConfirmationPresented = true
                }
                .buttonStyle(.glass)
                .accessibilityIdentifier("conversation.invitation.decline")

                Button("Accept", action: acceptInvitation)
                    .buttonStyle(.glassProminent)
                    .accessibilityIdentifier("conversation.invitation.accept")
            }
            .controlSize(.large)
            .buttonSizing(.flexible)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var invitationInviterName: String {
        guard let inviterID = chat.invitedByPersonID else { return "Someone" }
        return profile.people.first { $0.id == inviterID }?.name ?? "Someone"
    }

    @ViewBuilder
    private func composerArea(
        usesFlexibleLayout: Bool,
        transcriptBackingOpacity: Double,
        expansionInteraction: ConversationComposerExpansionInteraction
    ) -> some View {
        VStack(spacing: 0) {
            if mentionQuery != nil, !mentionMatches.isEmpty {
                mentionSuggestions
            }

            composer(
                usesFlexibleLayout: usesFlexibleLayout,
                transcriptBackingOpacity: transcriptBackingOpacity,
                expansionInteraction: expansionInteraction
            )
        }
    }

    private func composer(
        usesFlexibleLayout: Bool,
        transcriptBackingOpacity: Double,
        expansionInteraction: ConversationComposerExpansionInteraction
    ) -> some View {
        GlassEffectContainer {
            HStack(alignment: .bottom, spacing: 8) {
                if isReviewingVoice {
                    Button(action: discardVoiceMessage) {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .frame(width: 44, height: 44)
                            .contentShape(.circle)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: .circle)
                    .accessibilityLabel("Cancel Voice Message")
                    .accessibilityIdentifier("conversation.voice.cancel")
                } else if !isRecording {
                    ConversationAttachmentMenuButton(
                        onCamera: {
                            presentAttachmentDestination(.camera)
                        },
                        onPhotosAndVideos: {
                            presentAttachmentDestination(.photosAndVideos)
                        },
                        onFiles: {
                            presentAttachmentDestination(.files)
                        },
                        onContact: {
                            presentAttachmentDestination(.contact)
                        },
                        onMenuVisibilityChanged: { shown in
                            attachmentMenuVisibilityDidChange(shown)
                        }
                    )
                    .frame(width: 44, height: 44)
                    .contentShape(.circle)
                    .glassEffect(.regular.interactive(), in: .circle)
                }

                VStack(spacing: 0) {
                    if !queuedAttachments.isEmpty {
                        queuedAttachmentStrip

                        if queuedAttachments.contains(
                            where: \.prototypeIsComposerVisualMedia
                        ) {
                            Color(uiColor: .separator)
                                .frame(
                                    height: ComposerMediaDraftLayout.separatorThickness
                                )
                                .padding(
                                    .horizontal,
                                    ComposerMediaDraftLayout.separatorHorizontalInset
                                )
                                .accessibilityHidden(true)
                        }
                    }

                    if let composerLinkPreview {
                        PrototypeComposerLinkPreviewView(
                            preview: composerLinkPreview,
                            onRemove: dismissComposerLinkPreview
                        )
                    }

                    if let replyID = chat.replyToMessageID {
                        replyComposerQuote(replyID)
                    }

                    composerInputRow(
                        usesFlexibleLayout: usesFlexibleLayout,
                        expansionInteraction: expansionInteraction
                    )
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: usesFlexibleLayout ? .infinity : nil,
                    alignment: .bottom
                )
                .contentShape(.rect)
                .highPriorityGesture(
                    composerExpansionGesture(expansionInteraction),
                    isEnabled: expansionInteraction.isEnabled
                )
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
                .background(
                    Color(uiColor: .systemBackground)
                        .opacity(transcriptBackingOpacity),
                    in: .rect(cornerRadius: 22)
                )
                .overlay {
                    if isComposerInteractionBlocked {
                        Color.clear
                            .contentShape(.rect)
                            .onTapGesture { }
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityHidden(isComposerInteractionBlocked)
            }
            .frame(
                maxHeight: usesFlexibleLayout ? .infinity : nil,
                alignment: .bottom
            )
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .frame(
            maxHeight: usesFlexibleLayout ? .infinity : nil,
            alignment: .bottom
        )
    }

    @ViewBuilder
    private func composerInputRow(
        usesFlexibleLayout: Bool,
        expansionInteraction: ConversationComposerExpansionInteraction
    ) -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            if isRecording {
                recordingStatus
            } else if let voiceReview {
                voiceReviewStatus(
                    id: voiceReview.id,
                    duration: voiceReview.duration
                )
            } else {
                ZStack(
                    alignment: usesFlexibleLayout ? .topLeading : .leading
                ) {
                    if composerText.isEmpty {
                        Text("Message")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 4)
                            .padding(.top, usesFlexibleLayout ? 10 : 0)
                            .allowsHitTesting(false)
                    }

                    PrototypeComposerTextView(
                        text: composerTextBinding,
                        mentionNames: composerMentionNames,
                        isFocused: composerIsFocused,
                        isEnabled: !isComposerInteractionBlocked,
                        sendsWithReturn: settings.returnKeyBehavior == .send,
                        maximumVisibleLines: composerMaximumVisibleLines,
                        usesAvailableHeight: usesFlexibleLayout,
                        onFocusChange: { composerIsFocused = $0 },
                        onSubmit: send
                    )
                    .accessibilityActions {
                        Button(
                            composerIsExpanded
                                ? "Collapse Message"
                                : "Expand Message"
                        ) {
                            composerIsExpanded.toggle()
                        }

                        if composerIsExpanded, composerIsFocused {
                            Button("Hide Keyboard") {
                                composerIsFocused = false
                            }
                        }
                    }
                    .frame(
                        maxHeight: usesFlexibleLayout ? .infinity : nil,
                        alignment: .bottom
                    )
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        guard !usesFlexibleLayout else { return }
                        composerTextHeight = height
                    }
                }
                .frame(
                    maxHeight: usesFlexibleLayout ? .infinity : nil,
                    alignment: .bottom
                )

                trailingComposerControl
            }
        }
        .frame(
            minHeight: 44,
            maxHeight: usesFlexibleLayout ? .infinity : nil,
            alignment: .bottom
        )
        .padding(.leading, isReviewingVoice ? 0 : 14)
    }

    @ViewBuilder
    private var trailingComposerControl: some View {
        if canSend {
            Button(action: send) {
                ZStack {
                    Circle()
                        .fill(sendButtonFill)
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(sendButtonSymbolColor)
                }
                .frame(width: 32, height: 32)
                .frame(width: 44, height: 44)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Send")
            .accessibilityIdentifier("conversation.send")
        } else {
            voiceButton
        }
    }

    private var sendButtonFill: Color {
        colorScheme == .dark ? .white : .black
    }

    private var sendButtonSymbolColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var voiceButton: some View {
        Image(systemName: "waveform")
            .foregroundStyle(.secondary)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
            .scaleEffect(isVoiceButtonPressing ? 0.92 : 1)
            .opacity(isVoiceButtonPressing ? 0.65 : 1)
            .onLongPressGesture(
                minimumDuration: 0.5,
                maximumDistance: 10,
                perform: beginVoiceMessage,
                onPressingChanged: { isVoiceButtonPressing = $0 }
            )
            .animation(.snappy(duration: 0.2), value: isVoiceButtonPressing)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("Record Voice Message")
            .accessibilityIdentifier("conversation.voice")
            .accessibilityHint("Touch and hold to start recording.")
            .accessibilityAction { beginVoiceMessage() }
    }

    private var recordingStatus: some View {
        HStack(spacing: 8) {
            PrototypeAudioWaveform(
                samples: recordingWaveformSamples,
                progress: 1,
                attenuatesQuietSamples: true
            )
            .frame(maxWidth: .infinity)
            .frame(height: 30)

            Text(prototypeDurationString(TimeInterval(recordingSeconds)))
                .font(.body.monospacedDigit())
                .lineLimit(1)
                .accessibilityIdentifier("conversation.voice.timer")

            Button(action: finishVoiceMessage) {
                Image(systemName: "stop.fill")
                    .frame(width: 44, height: 44)
                    .contentShape(.rect)
            }
            .frame(width: 44, height: 44)
            .buttonStyle(.plain)
            .accessibilityLabel("Stop Recording")
            .accessibilityIdentifier("conversation.voice.stop")
        }
        .foregroundStyle(.red)
        .frame(minHeight: 44)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            "Recording, \(prototypeDurationString(TimeInterval(recordingSeconds)))"
        )
        .task(id: isRecording) {
            var tick = 0
            while isRecording {
                try? await Task.sleep(for: .milliseconds(100))
                if Task.isCancelled { return }
                tick += 1
                recordingSeconds = tick / 10
                recordingWaveformSamples.append(
                    PrototypeWaveformSamples.liveSample(at: tick)
                )
                if recordingWaveformSamples.count > 160 {
                    recordingWaveformSamples.removeFirst(
                        recordingWaveformSamples.count - 160
                    )
                }
            }
        }
    }

    private func voiceReviewStatus(
        id: String,
        duration: TimeInterval
    ) -> some View {
        PrototypeVoiceReviewStatus(id: id, duration: duration) {
            confirmVoiceMessage(id: id, duration: duration)
        }
    }

    private var queuedAttachmentStrip: some View {
        compactAttachmentShelf
    }

    private var compactAttachmentShelf: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: ComposerMediaDraftLayout.itemSpacing) {
                ForEach(queuedAttachments) { attachment in
                    compactAttachmentCard(attachment)
                }
            }
            .padding(ComposerMediaDraftLayout.shelfPadding)
        }
        .frame(height: compactAttachmentShelfHeight)
        .clipShape(
            .rect(
                topLeadingRadius: ComposerMediaDraftLayout.shelfMaskCornerRadius,
                topTrailingRadius: ComposerMediaDraftLayout.shelfMaskCornerRadius
            )
        )
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            "\(queuedAttachments.count) attachment\(queuedAttachments.count == 1 ? "" : "s") ready to send"
        )
    }

    private var compactAttachmentShelfHeight: CGFloat {
        queuedAttachments.contains(where: \.prototypeIsComposerVisualMedia)
            ? ComposerMediaDraftLayout.shelfHeight
            : 88
    }

    private func compactAttachmentCard(
        _ attachment: PrototypeAttachment
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            compactAttachmentContent(attachment)

            PrototypeComposerRemoveButton(
                accessibilityLabel: "Remove \(attachment.accessibilityLabel)",
                accessibilityIdentifier: "conversation.attachment.remove.\(attachment.id)",
                appearance: attachment.prototypeIsComposerVisualMedia
                    ? .mediaOverlay
                    : .secondary
            ) {
                removeQueuedAttachment(attachment)
            }
        }
    }

    @ViewBuilder
    private func compactAttachmentContent(
        _ attachment: PrototypeAttachment
    ) -> some View {
        if attachment.prototypeIsComposerVisualMedia {
            Button {
                composerIsFocused = false
                composerMediaSelection = PrototypeComposerMediaSelection(
                    attachments: queuedAttachments,
                    initialItemID: attachment.id
                )
            } label: {
                queuedPreview(attachment)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                "Preview \(attachment.accessibilityLabel)"
            )
            .accessibilityIdentifier(
                "conversation.attachment.\(attachment.id)"
            )
        } else {
            queuedPreview(attachment)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(attachment.accessibilityLabel)
                .accessibilityIdentifier(
                    "conversation.attachment.\(attachment.id)"
                )
        }
    }

    private func removeQueuedAttachment(_ attachment: PrototypeAttachment) {
        queuedAttachments.removeAll { $0.id == attachment.id }
    }

    private var composerMaximumVisibleLines: Int {
        return queuedAttachments.isEmpty ? 10 : 6
    }

    @ViewBuilder
    private func queuedPreview(_ attachment: PrototypeAttachment) -> some View {
        switch attachment {
        case .photo, .video, .gif:
            PrototypeComposerMediaThumbnail(
                attachment: attachment,
                height: ComposerMediaDraftLayout.previewHeight,
                minimumWidth: ComposerMediaDraftLayout.minimumPreviewWidth,
                maximumWidth: ComposerMediaDraftLayout.maximumPreviewWidth,
                cornerRadius: ComposerMediaDraftLayout.cornerRadius
            )
        case let .file(_, name, _, _):
            VStack(spacing: 5) {
                Image(systemName: "doc")
                    .font(.title3)
                composerFileNameLabel(name)
                    .font(.caption2)
            }
            .padding(
                .horizontal,
                ComposerMediaDraftLayout.utilityPreviewHorizontalPadding
            )
            .frame(
                minWidth: ComposerMediaDraftLayout.minimumUtilityPreviewWidth,
                maxWidth: ComposerMediaDraftLayout.maximumUtilityPreviewWidth,
                minHeight: ComposerMediaDraftLayout.utilityPreviewHeight,
                maxHeight: ComposerMediaDraftLayout.utilityPreviewHeight
            )
            .background(.secondary.opacity(0.12), in: .rect(cornerRadius: 10))
        case let .voice(_, _, duration):
            VStack(spacing: 5) {
                Image(systemName: "waveform")
                    .font(.title3)
                Text(prototypeDurationString(duration))
                    .font(.caption2.monospacedDigit())
            }
            .frame(
                width: ComposerMediaDraftLayout.minimumUtilityPreviewWidth,
                height: ComposerMediaDraftLayout.utilityPreviewHeight
            )
            .background(.secondary.opacity(0.12), in: .rect(cornerRadius: 10))
        case let .link(_, title, domain, _, image):
            ZStack(alignment: .bottomLeading) {
                if let image {
                    PrototypeImageSourceView(source: image)
                        .scaledToFill()
                        .frame(width: 116, height: 72)
                        .clipped()
                } else {
                    Color.secondary.opacity(0.12)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                    Text(domain)
                        .font(.caption2)
                        .lineLimit(1)
                }
                .foregroundStyle(.white)
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.black.opacity(0.56))
            }
            .frame(width: 116, height: 72)
            .clipShape(.rect(cornerRadius: 10))
        case let .contact(_, personID):
            if let person = profile.people.first(where: { $0.id == personID }) {
                VStack(spacing: 4) {
                    PrototypeChatAvatarView(
                        avatar: person.avatar,
                        size: 40,
                        publicKey: person.publicKey
                    )
                    Text(person.name)
                        .font(.caption2)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(
                    .horizontal,
                    ComposerMediaDraftLayout.utilityPreviewHorizontalPadding
                )
                .frame(
                    minWidth: ComposerMediaDraftLayout.minimumUtilityPreviewWidth,
                    maxWidth: ComposerMediaDraftLayout.maximumUtilityPreviewWidth,
                    minHeight: ComposerMediaDraftLayout.utilityPreviewHeight,
                    maxHeight: ComposerMediaDraftLayout.utilityPreviewHeight
                )
                .background(.secondary.opacity(0.12), in: .rect(cornerRadius: 10))
            }
        }
    }

    @ViewBuilder
    private func composerFileNameLabel(_ name: String) -> some View {
        if let parts = composerFileNameParts(name) {
            HStack(spacing: 0) {
                Text(parts.leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(parts.trailing)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        } else {
            Text(name)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    private func composerFileNameParts(
        _ name: String
    ) -> (leading: String, trailing: String)? {
        let fileName = name as NSString
        let pathExtension = fileName.pathExtension
        let stem = fileName.deletingPathExtension
        guard !pathExtension.isEmpty, stem.count > 3 else { return nil }

        return (
            String(stem.dropLast(3)),
            "\(stem.suffix(3)).\(pathExtension)"
        )
    }

    private func replyComposerQuote(_ replyID: String) -> some View {
        let target = chat.messages.first { $0.id == replyID }
        return HStack(alignment: .top, spacing: 7) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Replying to \(target.map(authorName(for:)) ?? "message")")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Text(target.map(replyPreview) ?? "Message unavailable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2, reservesSpace: false)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 32)
        }
        .padding(.leading, 10)
        .overlay(alignment: .leading) {
            Capsule()
                .fill(.secondary)
                .frame(width: 3)
                .frame(maxHeight: .infinity)
        }
        .padding(.leading, 10)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.trailing, 4)
        .padding(.vertical, 8)
        .background(
            Color(uiColor: .secondarySystemFill),
            in: .rect(cornerRadius: 12)
        )
        .overlay(alignment: .topTrailing) {
            PrototypeComposerRemoveButton(
                accessibilityLabel: "Cancel Reply",
                accessibilityIdentifier: "conversation.reply.cancel"
            ) {
                updateChat { $0.replyToMessageID = nil }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var mentionSuggestions: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(mentionMatches) { person in
                    Button {
                        insertMention(person)
                    } label: {
                        Label(person.name, systemImage: "person.crop.circle")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .scrollIndicators(.hidden)
        .background(Color(uiColor: .secondarySystemBackground))
    }

    private enum ComposerRecovery {
        case left, removed, blocked(String), relays
    }

    @ViewBuilder
    private func recoveryView(_ recovery: ComposerRecovery) -> some View {
        switch recovery {
        case .left:
            membershipStatusLabel(
                chat.isGroup ? "You left this group." : "You left this chat.",
                systemImage: "rectangle.portrait.and.arrow.right"
            )
        case .removed:
            membershipStatusLabel(
                "You were removed from this group.",
                systemImage: "person.crop.circle.badge.minus"
            )
        case let .blocked(personID):
            Button("Unblock to Send Messages") {
                if let index = profile.people.firstIndex(where: { $0.id == personID }) {
                    profile.people[index].isBlocked = false
                }
            }
            .buttonStyle(.borderedProminent).padding()
        case .relays:
            NavigationLink {
                ChatRelaysView(profile: $profile, chatID: chatID)
            } label: {
                Label("Check Chat Relays", systemImage: "exclamationmark.triangle")
            }
            .buttonStyle(.borderedProminent).padding()
        }
    }

    private func membershipStatusLabel(
        _ title: LocalizedStringKey,
        systemImage: String
    ) -> some View {
        Label(title, systemImage: systemImage)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .accessibilityElement(children: .combine)
    }

    private var composerRecovery: ComposerRecovery? {
        switch chat.listState.membershipState {
        case .invited: return nil
        case .left: return .left
        case .removed: return .removed
        case .active: break
        }
        if case let .direct(personID) = chat.kind,
           profile.people.first(where: { $0.id == personID })?.isBlocked == true {
            return .blocked(personID)
        }
        return chat.routing.relayURLs.isEmpty ? .relays : nil
    }

    private var composerTextBinding: Binding<String> {
        Binding { composerText } set: { value in
            if !isComposerInteractionBlocked {
                composerText = value
            }
        }
    }

    private var canSend: Bool {
        !composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !queuedAttachments.isEmpty
    }

    private var composerLinkPreview: PrototypeComposerLinkPreview? {
        guard queuedAttachments.isEmpty,
              !isRecording,
              !isReviewingVoice,
              let preview = PrototypeComposerLinkPreview.first(in: composerText),
              preview.url.absoluteString != suppressedLinkPreviewURL
        else { return nil }
        return preview
    }

    private func dismissComposerLinkPreview() {
        guard let preview = composerLinkPreview else { return }
        suppressedLinkPreviewURL = preview.url.absoluteString
        updateChat { chat in
            chat.suppressedDraftLinkURL = preview.url.absoluteString
        }
    }

    private func presentAttachmentDestination(
        _ destination: ComposerAttachmentDestination
    ) {
        attachmentMenuDismissalTask?.cancel()
        attachmentMenuDismissalTask = nil
        isComposerInteractionBlocked = true
        composerIsFocused = false
        attachmentPresentationTask?.cancel()
        attachmentPresentationTask = Task { @MainActor in
            defer {
                attachmentPresentationTask = nil
                restoreComposerInteractionIfPossible()
            }
            // Let the context menu finish its native dismissal before another
            // system-owned destination begins presenting.
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }

            switch destination {
            case .camera:
                isCameraPresented = true
            case .photosAndVideos:
                isPhotoPickerPresented = true
            case .files:
                isFileImporterPresented = true
            case .contact:
                isContactPickerPresented = true
            }
        }
    }

    private func attachmentMenuVisibilityDidChange(_ shown: Bool) {
        isAttachmentMenuPresented = shown
        attachmentMenuDismissalTask?.cancel()
        attachmentMenuDismissalTask = nil
        if shown {
            isComposerInteractionBlocked = true
        } else {
            // Keep the composer inert through the menu row's touch-up and the
            // selection callback. This prevents the lowest row from briefly
            // re-enabling the field beneath the dismissing context menu.
            attachmentMenuDismissalTask = Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(200))
                guard !Task.isCancelled else { return }
                attachmentMenuDismissalTask = nil
                restoreComposerInteractionIfPossible()
            }
        }
    }

    private func restoreComposerInteractionIfPossible() {
        guard !isCameraPresented,
              !isPhotoPickerPresented,
              !isFileImporterPresented,
              !isContactPickerPresented,
              !isAttachmentMenuPresented,
              attachmentPresentationTask == nil,
              attachmentMenuDismissalTask == nil
        else { return }
        isComposerInteractionBlocked = false
    }

    private var isRecording: Bool {
        if case .recording = voiceState { return true }
        return false
    }

    private var shareableContacts: [PrototypePerson] {
        profile.selectableChatPeople.filter(\.isFollowing)
    }

    private func queueContact(_ person: PrototypePerson) {
        queuedAttachments.removeAll { attachment in
            if case .contact = attachment { return true }
            return false
        }
        queuedAttachments.append(
            .contact(
                id: "composer-contact-\(person.id)-\(UUID().uuidString)",
                personID: person.id
            )
        )
    }

    private var voiceReview: (id: String, duration: TimeInterval)? {
        guard case let .review(id, duration) = voiceState else { return nil }
        return (id, duration)
    }

    private var isReviewingVoice: Bool { voiceReview != nil }

    private var mentionQuery: String? {
        guard chat.isGroup,
              let at = composerText.lastIndex(of: "@"),
              composerText[at...].contains(" ") == false
        else { return nil }
        return String(composerText[composerText.index(after: at)...])
    }

    private var mentionMatches: [PrototypePerson] {
        guard let mentionQuery else { return [] }
        return chat.mentionCandidates(
            query: mentionQuery,
            people: profile.people,
            currentProfileID: profile.id
        )
    }

    private var composerMentionNames: [String] {
        guard chat.isGroup else { return [] }
        return chat.mentionCandidates(
            query: "",
            people: profile.people,
            currentProfileID: profile.id
        ).map(\.name)
    }

    private var chatIndex: Int? { profile.chats.firstIndex { $0.id == chatID } }
    private var authoritativeDisappearingMessageDuration: PrototypeDisappearingMessageDuration {
        profile.chats.first(where: { $0.id == chatID })?
            .disappearingMessageDuration ?? .off
    }

    private var chat: PrototypeChat {
        if let renderedChat { return renderedChat }
        return profile.chats[chatIndex!]
    }

    private var contextMessage: PrototypeMessage? {
        guard let contextMessageID else { return nil }
        return chat.messages.first { $0.id == contextMessageID }
    }

    private var messageDetailsMessage: PrototypeMessage? {
        guard let messageDetailsID else { return nil }
        return chat.messages.first { $0.id == messageDetailsID }
    }

    private var messageDetailsIsPresented: Binding<Bool> {
        Binding {
            messageDetailsID != nil
        } set: { isPresented in
            if !isPresented { messageDetailsID = nil }
        }
    }

    private var requestedDeletionMessages: [PrototypeMessage] {
        guard let deletionRequest else { return [] }
        return messages(for: deletionRequest.messageIDs)
    }

    private var deletionDialogTitle: String {
        requestedDeletionMessages.count == 1
            ? "Delete Message?"
            : "Delete \(requestedDeletionMessages.count) Messages?"
    }

    private var deletionDialogMessage: String {
        if canDeleteRequestedMessagesForEveryone {
            return "Choose whether to remove the selected message"
                + (requestedDeletionMessages.count == 1 ? "" : "s")
                + " only for you or for everyone."
        }
        return "The selected message"
            + (requestedDeletionMessages.count == 1 ? "" : "s")
            + " will be removed only for you."
    }

    private var canDeleteRequestedMessagesForEveryone: Bool {
        !requestedDeletionMessages.isEmpty
            && requestedDeletionMessages.allSatisfy {
                $0.authorID == profile.id && !$0.isDeleted
            }
    }

    private var canForwardSelection: Bool {
        let selectedMessages = messages(for: selectedMessageIDs)
        return !selectedMessages.isEmpty
            && selectedMessages.count == selectedMessageIDs.count
            && selectedMessages.count <= 32
            && selectedMessages.allSatisfy { !$0.isDeleted }
    }

    private var selectionForwardHint: String {
        if selectedMessageIDs.count > 32 {
            return "Select no more than 32 messages."
        }
        if messages(for: selectedMessageIDs).contains(where: \.isDeleted) {
            return "Deleted messages cannot be forwarded."
        }
        return "Choose up to five destination chats."
    }

    private var personIsPresented: Binding<Bool> {
        Binding { selectedPersonID != nil } set: { if !$0 { selectedPersonID = nil } }
    }

    private func updateChat(_ mutation: (inout PrototypeChat) -> Void) {
        var updatedChat = chat
        mutation(&updatedChat)
        renderedChat = updatedChat

        persistAuthoritativeChat(updatedChat)
    }

    private func acceptInvitation() {
        updateChat {
            $0.acceptInvitation(currentProfileID: profile.id)
        }
    }

    private func declineInvitation() {
        var updatedProfile = profile
        guard updatedProfile.declineChatInvitation(chatID) else { return }
        profile = updatedProfile
        dismiss()
    }

    private func persistAuthoritativeChat(_ updatedChat: PrototypeChat) {
        if let authoritativeChatReplacement {
            authoritativeChatReplacement(chatID, updatedChat)
        } else {
            var updatedProfile = profile
            guard let index = updatedProfile.chats.firstIndex(where: { $0.id == chatID }) else {
                return
            }
            updatedProfile.chats[index] = updatedChat
            profile = updatedProfile
        }
    }

    private func send() {
        let text = composerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || !queuedAttachments.isEmpty else { return }
        var attachments = queuedAttachments
        if let composerLinkPreview {
            attachments.append(
                composerLinkPreview.attachment(
                    id: "composer-link-\(UUID().uuidString)"
                )
            )
        }
        queuedAttachments.removeAll()
        updateChat { $0.appendMessage(authorID: profile.id, text: text, attachments: attachments) }
        composerText = ""
        suppressedLinkPreviewURL = nil
        composerIsExpanded = false
    }

    private func beginVoiceMessage() {
        guard voiceState == .idle else { return }
        playback.stopAll()
        composerIsExpanded = false
        composerIsFocused = false
        recordingSeconds = 0
        recordingWaveformSamples = []
        voiceState.begin()
    }

    private func finishVoiceMessage() {
        let voiceID = UUID().uuidString
        let duration = max(1, TimeInterval(recordingSeconds))
        let waveform = recordingWaveformSamples.isEmpty
            ? PrototypeWaveformSamples.samples(seed: voiceID)
            : recordingWaveformSamples
        guard voiceState.moveToReview(id: voiceID, duration: duration) else { return }
        recordingWaveformSamples = waveform
        playback.registerWaveform(waveform, for: voiceID)
    }

    private func discardVoiceMessage() {
        if let voiceReview, playback.activeVoiceID == voiceReview.id {
            playback.stopAll()
        }
        voiceState.reset()
        recordingSeconds = 0
        recordingWaveformSamples = []
    }

    private func confirmVoiceMessage(id: String, duration: TimeInterval) {
        guard voiceReview?.id == id else { return }
        playback.stopAll()
        sendVoiceMessage(
            id: id,
            duration: duration,
            waveform: recordingWaveformSamples
        )
        voiceState.reset()
        recordingSeconds = 0
        recordingWaveformSamples = []
    }

    private func sendVoiceMessage(
        id voiceID: String,
        duration: TimeInterval,
        waveform: [Double]
    ) {
        playback.registerWaveform(
            waveform.isEmpty ? PrototypeWaveformSamples.samples(seed: voiceID) : waveform,
            for: voiceID
        )
        updateChat {
            $0.appendMessage(
                authorID: profile.id,
                attachments: [
                    .voice(
                        id: voiceID,
                        resourceName: PrototypeVoiceSample.resourceName,
                        duration: duration
                    )
                ]
            )
        }
    }

    private func showMessageActions(_ messageID: String) {
        guard !isSelectingMessages,
              contextMessageID == nil,
              messageFrames[messageID] != nil,
              messageContextContentFrames[messageID] != nil,
              let message = chat.messages.first(where: { $0.id == messageID }),
              !message.isDeleted
        else { return }
        playback.stopAll()
        composerIsFocused = false
        contextMessageID = messageID
    }

    private func performContextAction(
        _ action: PrototypeMessageContextAction,
        for message: PrototypeMessage
    ) {
        switch action {
        case .retry:
            retryMessage(message.id)
        case .reply:
            beginReply(to: message.id)
        case .forward:
            beginForward(messageIDs: [message.id])
        case .copy:
            UIPasteboard.general.string = message.text
            copyFeedbackTrigger += 1
        case .select:
            beginSelection(at: message.id)
        case .info:
            messageDetailsID = message.id
        case .delete:
            requestDeletion(of: [message.id])
        }
    }

    private func beginReply(to messageID: String) {
        updateChat { $0.replyToMessageID = messageID }
        composerIsFocused = true
    }

    private func retryMessage(_ messageID: String) {
        updateChat {
            $0.retryMessage(messageID, currentProfileID: profile.id)
        }
    }

    private func beginSelection(at messageID: String) {
        guard chat.messages.contains(where: { $0.id == messageID }) else { return }
        selectedMessageIDs = [messageID]
        withAnimation(.easeInOut(duration: 0.2)) {
            isSelectingMessages = true
        }
    }

    private func toggleSelection(_ messageID: String) {
        if selectedMessageIDs.contains(messageID) {
            selectedMessageIDs.remove(messageID)
        } else {
            selectedMessageIDs.insert(messageID)
        }
    }

    private func dismissSelection() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isSelectingMessages = false
            selectedMessageIDs.removeAll()
        }
    }

    private func beginForward(messageIDs: Set<String>) {
        let selectedMessages = messages(for: messageIDs)
        guard selectedMessages.count == messageIDs.count,
              selectedMessages.count <= 32,
              selectedMessages.allSatisfy({ !$0.isDeleted })
        else { return }
        let orderedIDs = chat.timeline.compactMap { entry -> String? in
            guard case let .message(message) = entry,
                  messageIDs.contains(message.id),
                  !message.isDeleted
            else { return nil }
            return message.id
        }
        .prefix(32)
        guard !orderedIDs.isEmpty else { return }
        forwardingMessageIDs = Array(orderedIDs)
        isForwardingMessages = true
    }

    private func completeForward(to destinationChatIDs: [String]) {
        let forwardedMessages = forwardingMessageIDs.compactMap { messageID in
            chat.messages.first { $0.id == messageID }
        }
        guard !forwardedMessages.isEmpty, !destinationChatIDs.isEmpty else { return }

        var updatedProfile = profile
        let timestamp = Date.now
        for destinationChatID in destinationChatIDs.prefix(5) {
            guard let index = updatedProfile.chats.firstIndex(where: {
                $0.id == destinationChatID
            }) else { continue }
            updatedProfile.chats[index].appendForwardedMessages(
                forwardedMessages,
                authorID: profile.id,
                now: timestamp
            )
        }
        profile = updatedProfile
        if let current = updatedProfile.chats.first(where: { $0.id == chatID }) {
            renderedChat = current
        }
        isForwardingMessages = false
        forwardingMessageIDs = []
        dismissSelection()
    }

    private func requestDeletion(of messageIDs: Set<String>) {
        guard !messageIDs.isEmpty else { return }
        deletionRequest = ConversationDeletionRequest(messageIDs: messageIDs)
    }

    private func deleteRequestedMessagesForCurrentProfile() {
        guard let deletionRequest else { return }
        updateChat {
            $0.removeMessagesForCurrentProfile(deletionRequest.messageIDs)
        }
        self.deletionRequest = nil
        dismissSelection()
    }

    private func deleteRequestedMessagesForEveryone() {
        guard let deletionRequest else { return }
        updateChat {
            $0.deleteMessagesForEveryone(
                deletionRequest.messageIDs,
                currentProfileID: profile.id
            )
        }
        self.deletionRequest = nil
        dismissSelection()
    }

    private func deleteAllMessagesForMe() {
        updateChat { $0.removeAllMessagesForCurrentProfile() }
        dismissSelection()
    }

    private func messages(for messageIDs: Set<String>) -> [PrototypeMessage] {
        chat.timeline.compactMap { entry in
            guard case let .message(message) = entry,
                  messageIDs.contains(message.id)
            else { return nil }
            return message
        }
    }

    private func selectFullReaction(_ emoji: String) {
        guard let messageID = emojiPickerMessageID else { return }
        toggleReaction(emoji, messageID: messageID)
        emojiPickerMessageID = nil
        contextMessageID = nil
    }

    private func toggleReaction(_ emoji: String, messageID: String) {
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            updateChat {
                $0.toggleReaction(
                    emoji: emoji,
                    messageID: messageID,
                    currentProfileID: profile.id
                )
            }
        }
        reactionFeedbackTrigger += 1
    }

    private func resolvedReply(for message: PrototypeMessage) -> PrototypeMessage? {
        guard let id = message.replyToMessageID else { return nil }
        return chat.messages.first { $0.id == id }
    }

    private func replyAuthorName(for message: PrototypeMessage) -> String {
        guard let target = resolvedReply(for: message) else { return "Message" }
        return authorName(for: target)
    }

    private func authorName(for message: PrototypeMessage) -> String {
        if message.authorID == profile.id { return "You" }
        return profile.people.first { $0.id == message.authorID }?.name ?? "Unknown"
    }

    private func replyPreview(_ message: PrototypeMessage) -> String {
        if message.isDeleted { return "Message deleted" }
        if !message.text.isEmpty { return message.text }
        return message.attachments.first?.accessibilityLabel ?? "Message"
    }

    private var timelineDays: [ConversationTimelineDay] {
        let calendar = Calendar.autoupdatingCurrent
        var days: [ConversationTimelineDay] = []

        for (index, entry) in chat.timeline.enumerated() {
            let date = calendar.startOfDay(for: entry.date)
            let indexedEntry = ConversationIndexedTimelineEntry(index: index, entry: entry)
            if days.last?.date == date {
                days[days.count - 1].entries.append(indexedEntry)
            } else {
                days.append(ConversationTimelineDay(date: date, entries: [indexedEntry]))
            }
        }
        return days
    }

    private func updateActiveTimelineDate(from visibleIdentifiers: [String]) {
        let identifiers = Set(visibleIdentifiers)
        guard let topVisibleEntry = chat.timeline.first(where: { identifiers.contains($0.id) }) else {
            return
        }
        activeTimelineDate = Calendar.autoupdatingCurrent.startOfDay(for: topVisibleEntry.date)
    }

    private func setDateHeader(_ date: Date, isVisible: Bool) {
        if isVisible {
            visibleTimelineDateHeaders.insert(date)
        } else {
            visibleTimelineDateHeaders.remove(date)
        }
    }

    private func timelineTopPadding(at index: Int) -> CGFloat {
        guard index > 0 else { return 0 }
        guard Calendar.autoupdatingCurrent.isDate(
            chat.timeline[index - 1].date,
            inSameDayAs: chat.timeline[index].date
        ) else {
            return 0
        }
        switch chat.timeline[index] {
        case .message:
            return startsCluster(at: index)
                ? TimelineSpacing.separateCluster
                : TimelineSpacing.compactCluster
        case .event, .notice:
            return TimelineSpacing.separateCluster
        }
    }

    private func startsCluster(at index: Int) -> Bool {
        guard case let .message(message) = chat.timeline[index], index > 0,
              case let .message(previous) = chat.timeline[index - 1]
        else { return true }
        return previous.authorID != message.authorID
            || !Calendar.autoupdatingCurrent.isDate(previous.sentAt, inSameDayAs: message.sentAt)
            || message.sentAt.timeIntervalSince(previous.sentAt) > 300
    }

    private func endsCluster(at index: Int) -> Bool {
        guard case let .message(message) = chat.timeline[index], index + 1 < chat.timeline.count,
              case let .message(next) = chat.timeline[index + 1]
        else { return true }
        return next.authorID != message.authorID
            || !Calendar.autoupdatingCurrent.isDate(next.sentAt, inSameDayAs: message.sentAt)
            || next.sentAt.timeIntervalSince(message.sentAt) > 300
    }

    private func insertMention(_ person: PrototypePerson) {
        guard let at = composerText.lastIndex(of: "@") else { return }
        let updatedDraft = String(composerText[..<at]) + "@\(person.name) "
        composerText = updatedDraft
        composerIsFocused = true
    }

    private func persistDraft() {
        guard chat.draft != composerText
                || chat.draftAttachments != queuedAttachments
                || chat.suppressedDraftLinkURL != suppressedLinkPreviewURL
        else { return }
        updateChat { chat in
            chat.draft = composerText
            chat.draftAttachments = queuedAttachments
            chat.suppressedDraftLinkURL = suppressedLinkPreviewURL
            chat.listState.activityDate = .now
        }
    }

    private func openPendingMediaMessage() {
        guard let messageID = pendingMediaMessageID else { return }
        pendingMediaMessageID = nil
        Task { @MainActor in
            await Task.yield()
            requestedScroll = TimelineScrollRequest(
                messageID: messageID,
                highlightsTarget: false
            )
        }
    }

    private func preparePhotoItems() async {
        let items = selectedPhotoItems
        guard !items.isEmpty else { return }
        composerIsFocused = false
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self), !Task.isCancelled else { continue }
            if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                guard let prepared = await ConversationVideoProcessor.prepare(data: data),
                      !Task.isCancelled
                else { continue }
                queuedAttachments.append(
                    .video(
                        id: UUID().uuidString,
                        url: prepared.url,
                        thumbnail: prepared.thumbnailData.map(PrototypeImageSource.data)
                            ?? .asset("FiatjafMediaBadger"),
                        duration: prepared.duration,
                        dimensions: prepared.dimensions
                    )
                )
            } else if let prepared = await ConversationImageProcessor.preparedDataAsync(from: data) {
                queuedAttachments.append(
                    .photo(
                        id: UUID().uuidString,
                        source: .data(prepared),
                        label: "Selected photo",
                        dimensions: PrototypeImageSource.data(prepared).prototypeDimensions
                    )
                )
            }
        }
        if !Task.isCancelled { selectedPhotoItems = [] }
    }

    private func handleCameraCapture(_ capture: ConversationCameraCapture) {
        composerIsFocused = false

        switch capture.content {
        case let .photo(data):
            Task {
                guard let prepared = await ConversationImageProcessor
                    .preparedDataAsync(from: data),
                      !Task.isCancelled
                else { return }
                queuedAttachments.append(
                    .photo(
                        id: UUID().uuidString,
                        source: .data(prepared),
                        label: "Camera photo",
                        dimensions: PrototypeImageSource.data(prepared).prototypeDimensions
                    )
                )
            }
        case let .video(url):
            Task {
                defer { try? FileManager.default.removeItem(at: url) }
                guard let prepared = await ConversationVideoProcessor
                    .prepare(fileAt: url),
                      !Task.isCancelled
                else { return }
                queuedAttachments.append(
                    .video(
                        id: UUID().uuidString,
                        url: prepared.url,
                        thumbnail: prepared.thumbnailData.map(PrototypeImageSource.data)
                            ?? .asset("FiatjafMediaBadger"),
                        duration: prepared.duration,
                        dimensions: prepared.dimensions
                    )
                )
            }
        }
    }

    private func importFiles(_ result: Result<[URL], Error>) {
        guard case let .success(urls) = result else { return }
        fileImportTask?.cancel()
        fileImportTask = Task {
            for source in urls {
                guard !Task.isCancelled else { return }
                let accessed = source.startAccessingSecurityScopedResource()
                defer { if accessed { source.stopAccessingSecurityScopedResource() } }
                let destination = FileManager.default.temporaryDirectory
                    .appending(path: "\(UUID().uuidString)-\(source.lastPathComponent)")
                do {
                    try await Task.detached {
                        try FileManager.default.copyItem(at: source, to: destination)
                    }.value
                    try Task.checkCancellation()
                    let values = try destination.resourceValues(forKeys: [.fileSizeKey])
                    queuedAttachments.append(
                        .file(
                            id: UUID().uuidString,
                            name: source.lastPathComponent,
                            size: values.fileSize ?? 0,
                            url: destination
                        )
                    )
                } catch {
                    try? FileManager.default.removeItem(at: destination)
                    continue
                }
            }
        }
    }
}

@MainActor
private struct ConversationKeyboardLayoutReader: UIViewRepresentable {
    let onAvailableHeightChange: (CGFloat) -> Void

    func makeUIView(context: Context) -> ReportingView {
        let view = ReportingView()
        view.onAvailableHeightChange = onAvailableHeightChange
        return view
    }

    func updateUIView(_ uiView: ReportingView, context: Context) {
        uiView.onAvailableHeightChange = onAvailableHeightChange
        uiView.setNeedsLayout()
    }

    final class ReportingView: UIView {
        var onAvailableHeightChange: ((CGFloat) -> Void)?
        private var lastAvailableHeight: CGFloat?
        private let keyboardProbe = UIView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            isUserInteractionEnabled = false
            backgroundColor = .clear
            keyboardProbe.translatesAutoresizingMaskIntoConstraints = false
            keyboardProbe.isUserInteractionEnabled = false
            keyboardProbe.isHidden = true
            addSubview(keyboardProbe)
            NSLayoutConstraint.activate([
                keyboardProbe.topAnchor.constraint(
                    equalTo: keyboardLayoutGuide.topAnchor
                ),
                keyboardProbe.leadingAnchor.constraint(equalTo: leadingAnchor),
                keyboardProbe.widthAnchor.constraint(equalToConstant: 0),
                keyboardProbe.heightAnchor.constraint(equalToConstant: 0),
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            setNeedsLayout()
        }

        override func safeAreaInsetsDidChange() {
            super.safeAreaInsetsDidChange()
            setNeedsLayout()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            reportAvailableHeight()
        }

        private func reportAvailableHeight() {
            guard window != nil, bounds.height > 0 else { return }

            let keyboardTop = keyboardLayoutGuide.layoutFrame.minY
            let bottomBoundary = keyboardTop.isFinite && keyboardTop > 0
                ? min(bounds.height, keyboardTop)
                : bounds.height - safeAreaInsets.bottom
            let availableHeight = max(0, bottomBoundary - safeAreaInsets.top)
            guard lastAvailableHeight.map({ abs($0 - availableHeight) > 0.5 })
                    ?? true
            else { return }

            lastAvailableHeight = availableHeight
            let onChange = onAvailableHeightChange
            DispatchQueue.main.async {
                onChange?(availableHeight)
            }
        }
    }
}

private struct PrototypeVoiceReviewStatus: View {
    let id: String
    let duration: TimeInterval
    let onSend: () -> Void

    @ObservedObject private var playback = PrototypePlaybackCoordinator.shared

    private var isActive: Bool { playback.activeVoiceID == id }
    private var isPlaying: Bool { isActive && !playback.isPaused }
    private var progress: Double {
        guard isActive, duration > 0 else { return 0 }
        return min(max(playback.elapsed / duration, 0), 1)
    }
    private var displayedDuration: TimeInterval {
        isActive ? max(0, duration - playback.elapsed) : duration
    }

    var body: some View {
        HStack(spacing: 4) {
            Button {
                playback.toggleVoice(id: id, duration: duration)
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
                    .background(.quaternary, in: .circle)
                    .frame(width: 44, height: 44)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPlaying ? "Pause Voice Message" : "Play Voice Message")
            .accessibilityIdentifier("conversation.voice.review.toggle")

            PrototypeAudioWaveform(
                samples: playback.waveform(for: id),
                progress: progress
            )
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 28)

            Text(prototypeDurationString(displayedDuration))
                .font(.body.monospacedDigit())
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Button(action: onSend) {
                ZStack {
                    Circle().fill(Color.accentColor)
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.white)
                }
                .frame(width: 32, height: 32)
                .frame(width: 44, height: 44)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Send Voice Message")
            .accessibilityIdentifier("conversation.voice.review.send")
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .contain)
    }
}

private enum ComposerAttachmentDestination {
    case camera
    case photosAndVideos
    case files
    case contact
}

private struct ConversationContactPicker: View {
    let people: [PrototypePerson]
    let onSelect: (PrototypePerson) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        List(filteredPeople) { person in
            Button {
                onSelect(person)
                dismiss()
            } label: {
                PersonRow(person: person)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shares this contact in the current chat.")
        }
        .overlay {
            if filteredPeople.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .navigationTitle("Share Contact")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Name or Public Key")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private var filteredPeople: [PrototypePerson] {
        let value = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return people }
        return people.filter {
            $0.name.localizedCaseInsensitiveContains(value)
                || $0.publicKey.localizedCaseInsensitiveContains(value)
        }
    }
}

private struct ChatMessageSearchView: View {
    let chat: PrototypeChat
    let people: [PrototypePerson]
    let profileID: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissSearch) private var dismissSearch
    @State private var query = ""

    var body: some View {
        List(results) { message in
            Button {
                dismissSearch()
                onSelect(message.id)
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    highlightedText(authorName(message)).font(.headline)
                    highlightedText(preview(message))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Text(message.sentAt, format: .dateTime.month().day().hour().minute())
                        .font(.caption).foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("message-search-result.\(message.id)")
        }
        .overlay {
            if results.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Messages")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
        }
    }

    private var results: [PrototypeMessage] {
        chat.matchingMessages(
            query: query,
            people: people,
            currentProfileID: profileID
        )
    }

    private func authorName(_ message: PrototypeMessage) -> String {
        if message.authorID == profileID { return "You" }
        return people.first { $0.id == message.authorID }?.name ?? "Unknown"
    }

    private func preview(_ message: PrototypeMessage) -> String {
        if message.isDeleted { return "Message deleted" }
        if !message.text.isEmpty { return message.text }
        return message.attachments.map(\.accessibilityLabel).joined(separator: ", ")
    }

    private func highlightedText(_ text: String) -> Text {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return Text(text) }

        var result = Text("")
        var cursor = text.startIndex
        while cursor < text.endIndex,
              let match = text.range(
                  of: needle,
                  options: [.caseInsensitive, .diacriticInsensitive],
                  range: cursor..<text.endIndex
              ) {
            result = result + Text(String(text[cursor..<match.lowerBound]))
                + Text(String(text[match])).bold().underline()
            cursor = match.upperBound
        }
        return result + Text(String(text[cursor...]))
    }
}
