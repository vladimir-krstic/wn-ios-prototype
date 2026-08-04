import SwiftUI
import UIKit

struct SupportPrototypeView: View {
    @State private var isShowingSupportConversation = false
    @Binding private var chats: [ChatListItem]
    @Binding private var supportMessages: [SupportConversationMessage]
    @Binding private var settings: PrototypeSettingsState
    @Binding private var relayConfiguration: PrototypeRelayConfiguration
    private let profileName: String

    init(
        chats: Binding<[ChatListItem]> = .constant([]),
        supportMessages: Binding<[SupportConversationMessage]> = .constant([]),
        settings: Binding<PrototypeSettingsState> = .constant(
            PrototypeSettingsState()
        ),
        relayConfiguration: Binding<PrototypeRelayConfiguration> = .constant(
            .fixtures
        ),
        profileName: String = "Marmota"
    ) {
        _chats = chats
        _supportMessages = supportMessages
        _settings = settings
        _relayConfiguration = relayConfiguration
        self.profileName = profileName
    }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 12) {
                    WhiteNoiseSupportAvatar(size: 56)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("White Noise Support")
                            .font(.headline)

                        Text("Questions, problems, and suggestions")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            } footer: {
                Text(
                    "Ask how something works, report a problem, or share a suggestion."
                )
            }

            Section {
                Button(action: openSupportChat) {
                    Label("Start Chat", systemImage: "plus.bubble")
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(
                            Color(uiColor: .systemBackground)
                        )
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .disabled(!canOpenSupportChat)
                .accessibilityHint(startChatAccessibilityHint)
            }
        }
        .navigationTitle("Chat with support")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(
            isPresented: $isShowingSupportConversation
        ) {
            WhiteNoiseSupportConversationView(
                messages: $supportMessages,
                chats: $chats,
                settings: $settings,
                senderName: profileName
            )
        }
    }

    private var supportChatExists: Bool {
        chats.contains(where: { chat in
            chat.id == ChatListFixtures.supportChatID
        })
    }

    private var canOpenSupportChat: Bool {
        supportChatExists
            || relayConfiguration.isAvailable(for: .chatMessages)
    }

    private func openSupportChat() {
        if !supportChatExists {
            ChatListFixtures.ensureSupportChat(in: &chats)
        }

        isShowingSupportConversation = true
    }

    private var startChatAccessibilityHint: String {
        if supportChatExists {
            return "Opens your existing conversation with White Noise Support."
        }

        if relayConfiguration.isAvailable(for: .chatMessages) {
            return "Starts a conversation with White Noise Support."
        }

        return "Check your profile relays to start a support chat."
    }
}

struct DonatePrototypeView: View {
    @State private var copiedMethod: DonationMethod?
    @State private var copyResetTask: Task<Void, Never>?

    var body: some View {
        Form {
            Section {
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundStyle(.pink)

                    Text(
                        "White Noise is free and open source. Donations keep it that way."
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .listRowBackground(Color.clear)

            donationSection(.lightning)
            donationSection(.bitcoin)
        }
        .navigationTitle("Donate")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            copyResetTask?.cancel()
        }
    }

    private func donationSection(
        _ method: DonationMethod
    ) -> some View {
        Section(method.title) {
            VStack {
                if let image = QRCodeImageGenerator.image(
                    for: method.address,
                    scale: 8
                ) {
                    Image(uiImage: image)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(maxWidth: 180)
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .accessibilityLabel("\(method.title) QR code")
                }

                Button {
                    UIPasteboard.general.string = method.address
                    copiedMethod = method
                    scheduleCopyReset()
                } label: {
                    Label(
                        copiedMethod == method
                            ? "Copied"
                            : method.displayAddress,
                        systemImage: copiedMethod == method
                            ? "checkmark"
                            : "doc.on.doc"
                    )
                    .font(.callout.monospaced())
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
    }

    private func scheduleCopyReset() {
        copyResetTask?.cancel()
        copyResetTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))

            guard !Task.isCancelled else {
                return
            }

            copiedMethod = nil
            copyResetTask = nil
        }
    }
}

private enum DonationMethod: CaseIterable, Equatable {
    case lightning
    case bitcoin

    var title: String {
        switch self {
        case .lightning: "Lightning Address"
        case .bitcoin: "Bitcoin Silent Payment"
        }
    }

    var address: String {
        switch self {
        case .lightning:
            "whitenoise@donate.ipf.dev"
        case .bitcoin:
            "sp1qqvp56mxcj9pz9xudvlch5g4ah5hrc8rj6neu25p34rc9gxhp38cwqqlmld28u57w2srgckr34dkyg3q02phu8tm05cyj483q026xedp0s5f5j40p"
        }
    }

    var displayAddress: String {
        guard address.count > 36 else {
            return address
        }
        return "\(address.prefix(18))…\(address.suffix(12))"
    }
}

#Preview("Chat with Support") {
    NavigationStack {
        SupportPrototypeView()
    }
}

#Preview("Donate") {
    NavigationStack {
        DonatePrototypeView()
    }
}
