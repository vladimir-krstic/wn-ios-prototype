import PhotosUI
import QuickLook
import SwiftUI
import UniformTypeIdentifiers

struct ConversationView: View {
    private let bottomID = "conversation-bottom"
    @ObservedObject private var playback = PrototypePlaybackCoordinator.shared

    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    let chatID: String
    let authoritativeChatReplacement: ((String, PrototypeChat) -> Void)?

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isPhotoPickerPresented = false
    @State private var isCameraPresented = false
    @State private var queuedAttachments: [PrototypeAttachment] = []
    @State private var isFileImporterPresented = false
    @State private var mediaSelection: PrototypeMediaSelection?
    @State private var quickLookURL: URL?
    @State private var messagePendingDeletion: String?
    @State private var highlightedMessageID: String?
    @State private var requestedScrollID: String?
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
    @FocusState private var composerIsFocused: Bool

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
            conversationBottomSurface {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(chat.timeline.enumerated()), id: \.element.id) { index, entry in
                            if showsDateSeparator(at: index) {
                                Text(PrototypeDateFormatter.separator(for: entry.date))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .accessibilityAddTraits(.isHeader)
                            }

                            timelineEntry(entry, at: index)
                                .id(entry.id)
                        }

                        Color.clear.frame(height: 8).id(bottomID)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .defaultScrollAnchor(.bottom)
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
                .scrollEdgeEffectStyle(.soft, for: .bottom)
            }
            .task {
                await Task.yield()
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
            .onChange(of: chat.timeline.count) {
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
            .onChange(of: requestedScrollID) { _, id in
                guard let id else { return }
                withAnimation { proxy.scrollTo(id, anchor: .center) }
                highlightedMessageID = id
                requestedScrollID = nil
                Task {
                    try? await Task.sleep(for: .seconds(1.2))
                    if highlightedMessageID == id { highlightedMessageID = nil }
                }
            }
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
        .toolbar { conversationToolbar }
        .fullScreenCover(item: $mediaSelection) { PrototypeMediaViewer(selection: $0) }
        .sheet(isPresented: $isCameraPresented) {
            ConversationCameraCaptureView(onCapture: handleCameraCapture)
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
        .task(id: selectedPhotoItems) { await preparePhotoItems() }
        .confirmationDialog(
            "Delete Message?",
            isPresented: Binding(
                get: { messagePendingDeletion != nil },
                set: { if !$0 { messagePendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete Message", role: .destructive) { deletePendingMessage() }
            Button("Cancel", role: .cancel) { messagePendingDeletion = nil }
        } message: {
            Text("This message will remain in the chat as deleted.")
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
                requestedScrollID = messageID
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
        }
    }

    @ViewBuilder
    private func conversationBottomSurface<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        switch chat.listState.membershipState {
        case .left:
            content()
                .safeAreaBar(edge: .bottom, spacing: 0) {
                    recoveryView(.left)
                }
        case .removed:
            content()
                .safeAreaBar(edge: .bottom, spacing: 0) {
                    recoveryView(.removed)
                }
        case .active:
            content()
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    composerArea
                }
        }
    }

    @ToolbarContentBuilder
    private var conversationToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Button {
                isShowingChatInfo = true
            } label: {
                HStack(spacing: 8) {
                    PrototypeChatAvatarView(
                        avatar: chat.resolvedAvatar(people: profile.people),
                        size: 44
                    )
                    VStack(alignment: .leading, spacing: 0) {
                        Text(chat.title(people: profile.people))
                            .font(.headline).lineLimit(1)
                        if chat.isGroup {
                            Text("\(chat.members.count) members")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens chat information.")
            .accessibilityIdentifier("conversation.info")
        }
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
            requestedScrollID = messageID
        }
    }

    @ViewBuilder
    private func timelineEntry(_ entry: PrototypeTimelineEntry, at index: Int) -> some View {
        switch entry {
        case let .event(event):
            Text(
                PrototypeGroupEventFormatter.text(
                    for: event.kind,
                    profileID: profile.id,
                    profileName: profile.name,
                    people: profile.people
                )
            )
            .font(.caption)
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
                onReply: { updateChat { $0.replyToMessageID = message.id }; composerIsFocused = true },
                onDelete: { messagePendingDeletion = message.id },
                onRetry: {
                    updateChat {
                        $0.retryMessage(message.id, currentProfileID: profile.id)
                    }
                },
                onToggleReaction: { toggleReaction($0, messageID: message.id) },
                onOpenReply: {
                    if let target = message.replyToMessageID { requestedScrollID = target }
                },
                onOpenPerson: { selectedPersonID = $0 },
                onOpenMedia: { attachments, index in
                    PrototypePlaybackCoordinator.shared.stopAll()
                    mediaSelection = PrototypeMediaSelection(
                        id: UUID().uuidString,
                        attachments: attachments,
                        initialIndex: index
                    )
                },
                onOpenFile: { quickLookURL = $0 }
            )
        }
    }

    @ViewBuilder
    private var composerArea: some View {
        VStack(spacing: 0) {
            if mentionQuery != nil, !mentionMatches.isEmpty {
                mentionSuggestions
            }

            if !queuedAttachments.isEmpty {
                queuedAttachmentStrip
            }

            if let replyID = chat.replyToMessageID {
                replyComposerQuote(replyID)
            }

            if let recovery = composerRecovery {
                recoveryView(recovery)
            } else {
                composer
            }
        }
    }

    private var composer: some View {
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
                        onMenuVisibilityChanged: { shown in
                            attachmentMenuVisibilityDidChange(shown)
                        }
                    )
                    .frame(width: 44, height: 44)
                    .contentShape(.circle)
                    .glassEffect(.regular.interactive(), in: .circle)
                }

                HStack(alignment: .bottom, spacing: 4) {
                    if isRecording {
                        recordingStatus
                    } else if let voiceReview {
                        voiceReviewStatus(
                            id: voiceReview.id,
                            duration: voiceReview.duration
                        )
                    } else {
                        TextField("Message", text: composerTextBinding, axis: .vertical)
                            .lineLimit(1...10)
                            .padding(.vertical, 10)
                            .onGeometryChange(for: CGFloat.self) { proxy in
                                proxy.size.height
                            } action: { height in
                                composerTextHeight = height
                            }
                            .focused($composerIsFocused)
                            .submitLabel(settings.returnKeyBehavior == .send ? .send : .return)
                            .onSubmit {
                                if settings.returnKeyBehavior == .send { send() }
                            }
                            .accessibilityIdentifier("conversation.composer")

                        trailingComposerControl
                    }
                }
                .frame(minHeight: 44)
                .padding(.leading, isReviewingVoice ? 0 : 14)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 22))
                .disabled(isComposerInteractionBlocked)
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
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var trailingComposerControl: some View {
        if canSend {
            Button(action: send) {
                ZStack {
                    Circle()
                        .fill(Color.primary)
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(uiColor: .systemBackground))
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
        let isActive = playback.activeVoiceID == id
        let isPlaying = isActive && !playback.isPaused
        let progress = isActive && duration > 0
            ? min(max(playback.elapsed / duration, 0), 1)
            : 0
        let displayedDuration = isActive
            ? max(0, duration - playback.elapsed)
            : duration

        return HStack(spacing: 4) {
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

            Button {
                confirmVoiceMessage(id: id, duration: duration)
            } label: {
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

    private var queuedAttachmentStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(queuedAttachments) { attachment in
                    ZStack(alignment: .topTrailing) {
                        queuedPreview(attachment)
                        Button {
                            queuedAttachments.removeAll { $0.id == attachment.id }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .black)
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .offset(x: 5, y: -5)
                        .accessibilityLabel("Remove \(attachment.accessibilityLabel)")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 6)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private func queuedPreview(_ attachment: PrototypeAttachment) -> some View {
        switch attachment {
        case let .photo(_, source, _):
            PrototypeImageSourceView(source: source).scaledToFill()
                .frame(width: 72, height: 72).clipShape(.rect(cornerRadius: 10))
        case let .video(_, _, thumbnail, _):
            ZStack {
                PrototypeImageSourceView(source: thumbnail).scaledToFill()
                Image(systemName: "play.circle.fill").foregroundStyle(.white)
            }
            .frame(width: 72, height: 72).clipShape(.rect(cornerRadius: 10))
        case let .file(_, name, _, _):
            VStack { Image(systemName: "doc"); Text(name).font(.caption2).lineLimit(2) }
                .frame(width: 72, height: 72).background(.secondary.opacity(0.12), in: .rect(cornerRadius: 10))
        default:
            Label(attachment.accessibilityLabel, systemImage: "paperclip")
        }
    }

    private func replyComposerQuote(_ replyID: String) -> some View {
        let target = chat.messages.first { $0.id == replyID }
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Replying to \(target.map(authorName(for:)) ?? "message")")
                    .font(.caption.weight(.semibold))
                Text(target.map(replyPreview) ?? "Message unavailable")
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            Button {
                updateChat { $0.replyToMessageID = nil }
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cancel Reply")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
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
                "You left this group.",
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
            composerText = value
        }
    }

    private var canSend: Bool {
        !composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !queuedAttachments.isEmpty
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
            }
        }
    }

    private func attachmentMenuVisibilityDidChange(_ shown: Bool) {
        isAttachmentMenuPresented = shown
        attachmentMenuDismissalTask?.cancel()
        attachmentMenuDismissalTask = nil
        if shown {
            isComposerInteractionBlocked = true
            composerIsFocused = false
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

    private var chatIndex: Int? { profile.chats.firstIndex { $0.id == chatID } }
    private var chat: PrototypeChat {
        if let renderedChat { return renderedChat }
        return profile.chats[chatIndex!]
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
        let attachments = queuedAttachments
        queuedAttachments.removeAll()
        updateChat { $0.appendMessage(authorID: profile.id, text: text, attachments: attachments) }
        composerText = ""
    }

    private func beginVoiceMessage() {
        guard voiceState == .idle else { return }
        playback.stopAll()
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

    private func deletePendingMessage() {
        guard let id = messagePendingDeletion else { return }
        updateChat {
            $0.deleteMessage(id, currentProfileID: profile.id)
        }
        messagePendingDeletion = nil
    }

    private func toggleReaction(_ emoji: String, messageID: String) {
        updateChat {
            $0.toggleReaction(
                emoji: emoji,
                messageID: messageID,
                currentProfileID: profile.id
            )
        }
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

    private func showsDateSeparator(at index: Int) -> Bool {
        if case .notice = chat.timeline[index] { return false }
        guard index > 0 else { return true }
        if case .notice = chat.timeline[index - 1] { return true }
        return !Calendar.autoupdatingCurrent.isDate(
            chat.timeline[index - 1].date,
            inSameDayAs: chat.timeline[index].date
        )
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
        guard chat.draft != composerText else { return }
        updateChat { chat in
            chat.draft = composerText
            chat.listState.activityDate = .now
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
                        duration: prepared.duration
                    )
                )
            } else if let prepared = await ConversationImageProcessor.preparedDataAsync(from: data) {
                queuedAttachments.append(
                    .photo(id: UUID().uuidString, source: .data(prepared), label: "Selected photo")
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
                        label: "Camera photo"
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
                        duration: prepared.duration
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

private enum ComposerAttachmentDestination {
    case camera
    case photosAndVideos
    case files
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
