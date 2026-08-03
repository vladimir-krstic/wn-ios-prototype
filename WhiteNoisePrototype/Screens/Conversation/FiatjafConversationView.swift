import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct FiatjafConversationView: View {
    private struct SentMessage: Identifiable {
        enum Content {
            case text(String)
            case photo(Data)
            case file(String)
        }

        let id = UUID()
        let content: Content
    }

    private let bottomID = "fiatjaf-conversation-bottom"

    @State private var draft = ""
    @State private var sentMessages: [SentMessage] = []
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isFileImporterPresented = false
    @State private var isVoiceRecording = false
    @FocusState private var isComposerFocused: Bool

    @Binding var settings: PrototypeSettingsState
    @Binding var relayConfiguration: PrototypeRelayConfiguration

    init(
        settings: Binding<PrototypeSettingsState>,
        relayConfiguration: Binding<PrototypeRelayConfiguration> = .constant(
            .fixtures
        )
    ) {
        _settings = settings
        _relayConfiguration = relayConfiguration
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        dayMarker

                        outgoingTextMessage(
                            "I’m moving from Feather to White Noise.",
                            time: "18:31",
                            accessibilityLabel:
                                "Marmota, 18:31. I’m moving from "
                                + "Feather to White Noise."
                        )

                        incomingTextMessage(
                            "Let me know how it goes.",
                            time: "18:32",
                            accessibilityLabel:
                                "Fiatjaf, 18:32. Let me know how it goes."
                        )

                        outgoingTextMessage(
                            "Signing in now.\n"
                                + "I’ll send a test next.",
                            time: "18:33",
                            accessibilityLabel:
                                "Marmota, 18:33. Signing in now. "
                                + "I’ll send a test next."
                        )

                        outgoingTextMessage(
                            "Switched from Feather to White Noise. "
                                + "Same key, same contacts.",
                            time: "18:36",
                            accessibilityLabel:
                                "Marmota, 18:36. Switched from Feather to "
                                + "White Noise. Same key, same contacts."
                        )

                        incomingReplyMessage

                        reactedOutgoingMessage

                        incomingTextMessage(
                            "Perfect!",
                            time: "18:45",
                            accessibilityLabel: "Fiatjaf, 18:45. Perfect!"
                        )

                        incomingMediaMessage(
                            maximumContentWidth:
                                max(8, geometry.size.width - 112)
                        )

                        ForEach(sentMessages) { message in
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
                .onChange(of: sentMessages.count) {
                    withAnimation {
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
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
                    Image("AvatarFiatjaf")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .accessibilityHidden(true)

                    Text("Fiatjaf")
                        .font(.headline)
                }
                .accessibilityElement(children: .combine)
            }

        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.item]
        ) { result in
            guard case let .success(url) = result else {
                return
            }

            sentMessages.append(
                SentMessage(content: .file(url.lastPathComponent))
            )
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

            sentMessages.append(SentMessage(content: .photo(data)))
            self.selectedPhotoItem = nil
        }
    }

    private var dayMarker: some View {
        Text("Today")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .accessibilityAddTraits(.isHeader)
    }

    private var incomingReplyMessage: some View {
        MessageRow(outgoing: false, time: "18:37") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Capsule()
                        .fill(.secondary)
                        .frame(width: 3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Marmota")
                            .font(.caption.weight(.semibold))

                        Text(
                            "Switched from Feather to White Noise. "
                                + "Same key, same contacts."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    }
                }
                .padding(8)
                .background(
                    Color(uiColor: .tertiarySystemFill),
                    in: RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                )

                Text(
                    "Yep, I still see you on Primal. "
                        + "No extra setup on my side."
                )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Fiatjaf, 18:37. Replying to Marmota: "
                + "Switched from Feather to White Noise. "
                + "Same key, same contacts. Yep, I still see you on "
                + "Primal. No extra setup on my side."
        )
    }

    private var reactedOutgoingMessage: some View {
        MessageRow(
            outgoing: true,
            time: "18:44",
            reaction: "🔥"
        ) {
            Text(
                "Exactly. Moved apps, kept everything. "
                    + "Didn’t have to re-add anyone."
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Marmota, 18:44. Exactly. Moved apps, kept "
                + "everything. Didn’t have to re-add anyone. "
                + "Reacted with fire."
        )
    }

    private func incomingMediaMessage(
        maximumContentWidth: CGFloat
    ) -> some View {
        let interitemSpacing: CGFloat = 2
        let topTileWidth =
            (maximumContentWidth - (interitemSpacing * 2)) / 3
        let bottomTileWidth =
            (maximumContentWidth - interitemSpacing) / 2

        return MessageRow(outgoing: false, time: "12:29") {
            VStack(alignment: .leading, spacing: 8) {
                VStack(spacing: interitemSpacing) {
                    HStack(spacing: interitemSpacing) {
                        mediaTile(
                            "FiatjafMediaSloth",
                            width: topTileWidth,
                            height: 86
                        )
                        mediaTile(
                            "FiatjafMediaBadger",
                            width: topTileWidth,
                            height: 86
                        )
                        mediaTile(
                            "FiatjafMediaOstrich",
                            width: topTileWidth,
                            height: 86
                        )
                    }

                    HStack(spacing: interitemSpacing) {
                        mediaTile(
                            "FiatjafMediaFox",
                            width: bottomTileWidth,
                            height: 106
                        )
                        mediaTile(
                            "FiatjafMediaMarmot",
                            width: bottomTileWidth,
                            height: 106
                        )
                    }
                }
                .frame(width: maximumContentWidth)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12,
                        style: .continuous
                    )
                )
                .accessibilityHidden(true)

                Text("Portable identity for the win.")
            }
            .frame(width: maximumContentWidth)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Fiatjaf, 12:29. Five photos. "
                + "Portable identity for the win."
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
                    if !canSend && hasRelayIssue && !isVoiceRecording {
                        relayComposerLink
                    } else {
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
                                .contentTransition(
                                    .symbolEffect(.replace)
                                )
                            }
                            .buttonStyle(.plain)
                            .frame(minWidth: 44, minHeight: 44)
                            .foregroundStyle(
                                isVoiceRecording
                                    ? Color.red
                                    : Color.secondary
                            )
                            .accessibilityLabel(
                                isVoiceRecording
                                    ? "Stop Recording"
                                    : "Record Voice Message"
                            )
                        }
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

    private var canSend: Bool {
        !trimmedDraft.isEmpty
    }

    private var hasRelayIssue: Bool {
        relayConfiguration.needsAttention
    }

    private var relayComposerLink: some View {
        NavigationLink {
            RelaysPrototypeView(configuration: $relayConfiguration)
        } label: {
            HStack(spacing: 4) {
                Text("Check your profile relays")
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile relays need attention")
        .accessibilityValue(relayConfiguration.recoverySummary)
        .accessibilityHint("Opens Relays.")
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

    private func sendDraft() {
        guard canSend else {
            return
        }

        sentMessages.append(
            SentMessage(content: .text(trimmedDraft))
        )
        draft = ""
    }

    @ViewBuilder
    private func sentMessageView(_ message: SentMessage) -> some View {
        switch message.content {
        case let .text(text):
            outgoingTextMessage(
                text,
                time: "Now",
                accessibilityLabel:
                    "Marmota, now. \(text)."
            )
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
            .accessibilityLabel(
                "Marmota, now. Photo."
            )
        case let .file(name):
            MessageRow(outgoing: true, time: "Now") {
                Label(name, systemImage: "doc.fill")
                    .lineLimit(2)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "Marmota, now. File: \(name)."
            )
        }
    }

    private func outgoingTextMessage(
        _ text: String,
        time: String,
        accessibilityLabel: String
    ) -> some View {
        MessageRow(outgoing: true, time: time) {
            Text(text)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private func incomingTextMessage(
        _ text: String,
        time: String,
        accessibilityLabel: String
    ) -> some View {
        MessageRow(outgoing: false, time: time) {
            Text(text)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private func mediaTile(
        _ name: String,
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
    }
}

#Preview("Fiatjaf Conversation") {
    NavigationStack {
        FiatjafConversationView(
            settings: .constant(PrototypeSettingsState())
        )
    }
    .tint(Color("AccentColor"))
}

#Preview("Fiatjaf Conversation — Dark") {
    NavigationStack {
        FiatjafConversationView(
            settings: .constant(PrototypeSettingsState())
        )
    }
    .tint(Color("AccentColor"))
    .preferredColorScheme(.dark)
}
