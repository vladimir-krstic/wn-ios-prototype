import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct WhiteNoiseSupportConversationView: View {
    private let bottomID = "white-noise-support-conversation-bottom"

    @Binding private var messages: [SupportConversationMessage]
    @Binding private var chats: [ChatListItem]
    @Binding private var settings: PrototypeSettingsState
    @Binding private var developerTools: PrototypeDeveloperToolsState
    private let senderName: String
    @State private var draft = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isFileImporterPresented = false
    @State private var isVoiceRecording = false
    @FocusState private var isComposerFocused: Bool

    init(
        messages: Binding<[SupportConversationMessage]> = .constant([]),
        chats: Binding<[ChatListItem]> = .constant([]),
        settings: Binding<PrototypeSettingsState>,
        developerTools: Binding<PrototypeDeveloperToolsState> = .constant(
            .fixtures()
        ),
        senderName: String = "Marmota"
    ) {
        _messages = messages
        _chats = chats
        _settings = settings
        _developerTools = developerTools
        self.senderName = senderName
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    supportGuidance

                    if !messages.isEmpty {
                        Text("Today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .accessibilityAddTraits(.isHeader)
                    }

                    ForEach(messages) { message in
                        sentMessageView(message)
                    }

                    Color.clear
                        .frame(height: 16)
                        .id(bottomID)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
            .defaultScrollAnchor(.bottom)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                composer
            }
            .scrollEdgeEffectStyle(.soft, for: .bottom)
            .onChange(of: messages.count) {
                withAnimation {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            }
        }
        .environment(
            \.incomingPrototypeMessageColor,
            settings.incomingMessageColor
        )
        .environment(
            \.outgoingPrototypeMessageColor,
            settings.outgoingMessageColor
        )
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    WhiteNoiseSupportAvatar(size: 30)

                    Text("White Noise Support")
                        .font(.headline)
                }
                .accessibilityElement(children: .combine)
            }

            if developerTools.isConversationDebugEnabled {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ConversationDebugPrototypeView(info: debugInfo)
                    } label: {
                        Image(systemName: "ladybug")
                    }
                    .accessibilityLabel("Conversation Debug")
                }
            }
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.item]
        ) { result in
            guard case let .success(url) = result else {
                return
            }

            append(.file(url.lastPathComponent))
        }
        .task(id: selectedPhotoItem) {
            guard
                let selectedPhotoItem,
                let data = try? await selectedPhotoItem.loadTransferable(
                    type: Data.self
                )
            else {
                return
            }

            append(.photo(data))
            self.selectedPhotoItem = nil
        }
    }

    private var debugInfo: PrototypeConversationDebugInfo {
        PrototypeConversationDebugInfo.support(
            messageCount: messages.count + 1,
            pushDiagnosticsStatus: settings.nativePushEnabled
                ? "Enabled"
                : "Disabled"
        )
    }

    private var supportGuidance: some View {
        Text(
            "How can we help? Ask a question, report a problem, "
                + "or share a suggestion. We’ll reply here."
        )
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: 280)
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Support information. How can we help? Ask a question, "
                + "report a problem, "
                + "or share a suggestion. We’ll reply here."
        )
    }

    private var composer: some View {
        GlassEffectContainer {
            HStack(alignment: .bottom, spacing: 8) {
                Menu {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images
                    ) {
                        Label(
                            "Choose from Photos",
                            systemImage: "photo.on.rectangle.angled"
                        )
                    }

                    Button {
                        isFileImporterPresented = true
                    } label: {
                        Label("Choose from Files", systemImage: "folder")
                    }
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .accessibilityLabel("Add Attachment")

                HStack(alignment: .bottom, spacing: 4) {
                    composerTextField

                    if !canSend {
                        Button {
                            isVoiceRecording.toggle()
                        } label: {
                            Image(
                                systemName: isVoiceRecording
                                    ? "stop.fill"
                                    : "waveform"
                            )
                            .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                        .frame(minWidth: 44, minHeight: 44)
                        .foregroundStyle(
                            isVoiceRecording ? Color.red : Color.secondary
                        )
                        .accessibilityLabel(
                            isVoiceRecording
                                ? "Stop Recording"
                                : "Record Voice Message"
                        )
                    }
                }
                .padding(.leading, 14)
                .padding(.trailing, 4)
                .glassEffect(.regular.interactive(), in: .capsule)

                if canSend {
                    Button(action: sendDraft) {
                        Image(systemName: "arrow.up")
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)
                    .accessibilityLabel("Send")
                    .transition(.opacity)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var composerTextField: some View {
        if settings.returnKeyBehavior == .send {
            baseComposerTextField
                .submitLabel(.send)
                .onSubmit(sendDraft)
        } else {
            baseComposerTextField
        }
    }

    private var baseComposerTextField: some View {
        TextField("Message", text: $draft, axis: .vertical)
            .lineLimit(1...5)
            .frame(minHeight: 44, alignment: .center)
            .focused($isComposerFocused)
            .textFieldStyle(.plain)
    }

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSend: Bool {
        !trimmedDraft.isEmpty
    }

    private func sendDraft() {
        guard canSend else {
            return
        }

        append(.text(trimmedDraft))
        draft = ""
    }

    private func append(_ content: SupportConversationMessage.Content) {
        let message = SupportConversationMessage(
            id: (messages.last?.id ?? -1) + 1,
            content: content
        )
        messages.append(message)
        updateChatPreview(with: content)
    }

    private func updateChatPreview(
        with content: SupportConversationMessage.Content
    ) {
        guard let index = chats.firstIndex(where: { chat in
            chat.id == ChatListFixtures.supportChatID
        }) else {
            return
        }

        chats[index].previewAuthor = "You"
        chats[index].timestamp = "Now"

        switch content {
        case let .text(text):
            chats[index].preview = text
            chats[index].attachmentPreview = nil
        case .photo:
            chats[index].preview = ""
            chats[index].attachmentPreview = .photo
        case let .file(name):
            chats[index].preview = ""
            chats[index].attachmentPreview = .file(name)
        }
    }

    @ViewBuilder
    private func sentMessageView(
        _ message: SupportConversationMessage
    ) -> some View {
        switch message.content {
        case let .text(text):
            MessageRow(outgoing: true, time: "Now") {
                Text(text)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(senderName), now. \(text)")

        case let .photo(data):
            MessageRow(outgoing: true, time: "Now") {
                if let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 190)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                        )
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(senderName), now. Photo.")

        case let .file(name):
            MessageRow(outgoing: true, time: "Now") {
                Label(name, systemImage: "doc.fill")
                    .lineLimit(2)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(senderName), now. File: \(name).")
        }
    }
}

#Preview("White Noise Support Conversation") {
    NavigationStack {
        WhiteNoiseSupportConversationView(
            settings: .constant(PrototypeSettingsState())
        )
    }
    .tint(Color("AccentColor"))
}
