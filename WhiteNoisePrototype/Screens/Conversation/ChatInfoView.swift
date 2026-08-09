import PhotosUI
import QuickLook
import SwiftUI

struct ChatInfoView: View {
    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    let chatID: String
    let onSearch: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let index = profile.chats.firstIndex(where: { $0.id == chatID }) {
            if profile.chats[index].isGroup {
                GroupInfoView(profile: $profile, settings: $settings, chatID: chatID, onSearch: search)
            } else {
                DirectChatInfoView(profile: $profile, settings: $settings, chatID: chatID, onSearch: search)
            }
        } else {
            ContentUnavailableView("Chat Unavailable", systemImage: "bubble.left")
        }
    }

    private func search() {
        dismiss()
        Task { @MainActor in
            await Task.yield()
            onSearch()
        }
    }
}

private struct DirectChatInfoView: View {
    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    let chatID: String
    let onSearch: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isShowingContact = false
    @State private var isShowingLeaveConfirmation = false

    var body: some View {
        List {
            identityHeader
                .listRowInsets(.init(top: 24, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            ChatInfoSharedContentLinks(profile: $profile, chatID: chatID)
            ChatInfoTechnicalLinks(profile: $profile, chatID: chatID)

            Section {
                Button(
                    chat.listState.isArchived ? "Unarchive" : "Archive",
                    systemImage: "archivebox"
                ) {
                    updateChat { $0.listState.isArchived.toggle() }
                }

                if chat.listState.membershipState == .active {
                    Button(
                        "Leave Chat",
                        systemImage: "rectangle.portrait.and.arrow.right",
                        role: .destructive
                    ) {
                        isShowingLeaveConfirmation = true
                    }
                }
            }
        }
        .navigationTitle("Chat Info")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingContact) {
            PersonProfileView(
                profile: $profile,
                settings: $settings,
                personID: person.id,
                onMessagePerson: { _ in dismiss() }
            )
        }
        .confirmationDialog(
            "Leave \(person.name)?",
            isPresented: $isShowingLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Leave Chat", role: .destructive, action: leaveChat)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "You’ll stop receiving new messages. This chat will remain "
                    + "on this device as read-only history until you delete it."
            )
        }
    }

    private var identityHeader: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                PrototypeChatAvatarView(avatar: person.avatar, size: 104)
                Text(person.name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 20) {
                ChatInfoQuickAction {
                    Button {
                        isShowingContact = true
                    } label: {
                        ChatInfoQuickActionIcon(systemName: "person.crop.circle")
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Contact")
                }

                ChatInfoQuickAction {
                    muteMenu
                }

                ChatInfoQuickAction {
                    disappearingMessagesMenu
                }

                ChatInfoQuickAction {
                    Button(action: onSearch) {
                        ChatInfoQuickActionIcon(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Search")
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var chat: PrototypeChat { profile.chats[chatIndex] }
    private var personID: String {
        if case let .direct(id) = chat.kind { return id }
        return ""
    }
    private var personIndex: Int { profile.people.firstIndex { $0.id == personID }! }
    private var person: PrototypePerson { profile.people[personIndex] }
    private var muteActionTitle: String {
        chat.listState.muteDuration == nil ? "Mute" : "Unmute"
    }

    private var disappearingMessagesMenu: some View {
        Menu {
            Picker("Disappearing Messages", selection: disappearingMessageDuration) {
                ForEach(PrototypeDisappearingMessageDuration.allCases) { duration in
                    Text(duration.title).tag(duration)
                }
            }
        } label: {
            ChatInfoQuickActionIcon(systemName: "timer")
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Disappearing Messages")
        .accessibilityValue(chat.disappearingMessageDuration.title)
    }

    private var disappearingMessageDuration: Binding<PrototypeDisappearingMessageDuration> {
        Binding {
            chat.disappearingMessageDuration
        } set: { duration in
            updateChat { $0.disappearingMessageDuration = duration }
        }
    }

    private var muteMenu: some View {
        Menu {
            if chat.listState.muteDuration != nil {
                Button("Unmute") { updateChat { $0.listState.muteDuration = nil } }
            } else {
                ForEach(ChatListItem.MuteDuration.allCases) { duration in
                    Button(duration.title) { updateChat { $0.listState.muteDuration = duration } }
                }
            }
        } label: {
            ChatInfoQuickActionIcon(
                systemName: chat.listState.muteDuration == nil ? "bell.slash" : "bell"
            )
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel(muteActionTitle)
    }

    private func updateChat(_ mutation: (inout PrototypeChat) -> Void) {
        mutation(&profile.chats[chatIndex])
    }

    private func leaveChat() {
        updateChat { _ = $0.leave(currentProfileID: profile.id) }
    }
}

private struct GroupInfoView: View {
    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    let chatID: String
    let onSearch: () -> Void

    @State private var isShowingLeaveConfirmation = false
    @State private var isShowingOnlyAdminAlert = false

    var body: some View {
        List {
            identityHeader
                .listRowInsets(.init(top: 24, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            ChatInfoSharedContentLinks(profile: $profile, chatID: chatID)
            ChatInfoTechnicalLinks(profile: $profile, chatID: chatID)

            Section("Members") {
                ForEach(chat.members) { member in
                    NavigationLink {
                        GroupMemberView(
                            profile: $profile,
                            settings: $settings,
                            chatID: chatID,
                            personID: member.personID
                        )
                    } label: {
                        HStack {
                            memberAvatar(member.personID)
                            Text(memberName(member.personID))
                            Spacer()
                            if member.role == .admin {
                                Text("Admin")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .accessibilityIdentifier("group-member.\(member.personID)")
                }
            }

            if canManage {
                Section {
                    NavigationLink {
                        EditGroupView(profile: $profile, chatID: chatID)
                    } label: {
                        Label("Edit Group", systemImage: "pencil")
                    }
                    NavigationLink {
                        AddPeopleToGroupView(profile: $profile, chatID: chatID)
                    } label: {
                        Label("Add People", systemImage: "person.badge.plus")
                    }
                }
            }

            Section {
                Button(
                    chat.listState.isArchived ? "Unarchive" : "Archive",
                    systemImage: "archivebox"
                ) {
                    updateChat { $0.listState.isArchived.toggle() }
                }

                if chat.listState.membershipState == .active {
                    Button(
                        "Leave Group",
                        systemImage: "rectangle.portrait.and.arrow.right",
                        role: .destructive
                    ) {
                        if isOnlyAdmin {
                            isShowingOnlyAdminAlert = true
                        } else {
                            isShowingLeaveConfirmation = true
                        }
                    }
                }
            }
        }
        .navigationTitle("Group Info")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Leave \(chat.groupName)?",
            isPresented: $isShowingLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Leave Group", role: .destructive, action: leaveGroup)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You’ll keep the chat history, but you won’t be able to send messages.")
        }
        .alert("Can’t Leave Group", isPresented: $isShowingOnlyAdminAlert) {
            Button("Done") {}
        } message: {
            Text("You’re the only admin in this group. Make another member an admin before you leave.")
        }
    }

    private var identityHeader: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                PrototypeChatAvatarView(avatar: chat.avatar, size: 104)
                Text(chat.groupName)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                if !chat.groupDescription.isEmpty {
                    Text(chat.groupDescription)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                Text("\(chat.members.count) members")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 28) {
                ChatInfoQuickAction {
                    muteMenu
                }

                ChatInfoQuickAction {
                    disappearingMessagesMenu
                }

                ChatInfoQuickAction {
                    Button(action: onSearch) {
                        ChatInfoQuickActionIcon(systemName: "magnifyingglass")
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Search")
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var chat: PrototypeChat { profile.chats[chatIndex] }
    private var canManage: Bool {
        chat.listState.membershipState == .active
            && chat.isCurrentProfileAdmin(profile.id)
    }
    private var isOnlyAdmin: Bool {
        canManage && chat.members.filter { $0.role == .admin }.count == 1
    }
    private var muteActionTitle: String {
        chat.listState.muteDuration == nil ? "Mute" : "Unmute"
    }

    @ViewBuilder
    private func memberAvatar(_ id: String) -> some View {
        if id == profile.id {
            ProfileAvatarView(profile: profile, size: 36)
        } else {
            PrototypeChatAvatarView(
                avatar: profile.people.first { $0.id == id }?.avatar ?? .monogram("?"),
                size: 36
            )
        }
    }

    private func memberName(_ id: String) -> String {
        id == profile.id ? "You" : (profile.people.first { $0.id == id }?.name ?? "Unknown")
    }

    private var disappearingMessagesMenu: some View {
        Menu {
            Picker("Disappearing Messages", selection: disappearingMessageDuration) {
                ForEach(PrototypeDisappearingMessageDuration.allCases) { duration in
                    Text(duration.title).tag(duration)
                }
            }
        } label: {
            ChatInfoQuickActionIcon(systemName: "timer")
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel("Disappearing Messages")
        .accessibilityValue(chat.disappearingMessageDuration.title)
    }

    private var disappearingMessageDuration: Binding<PrototypeDisappearingMessageDuration> {
        Binding {
            chat.disappearingMessageDuration
        } set: { duration in
            updateChat { $0.disappearingMessageDuration = duration }
        }
    }

    private var muteMenu: some View {
        Menu {
            if chat.listState.muteDuration != nil {
                Button("Unmute") { updateChat { $0.listState.muteDuration = nil } }
            } else {
                ForEach(ChatListItem.MuteDuration.allCases) { duration in
                    Button(duration.title) { updateChat { $0.listState.muteDuration = duration } }
                }
            }
        } label: {
            ChatInfoQuickActionIcon(
                systemName: chat.listState.muteDuration == nil ? "bell.slash" : "bell"
            )
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel(muteActionTitle)
    }

    private func updateChat(_ mutation: (inout PrototypeChat) -> Void) {
        mutation(&profile.chats[chatIndex])
    }

    private func leaveGroup() {
        updateChat { _ = $0.leave(currentProfileID: profile.id) }
    }
}

private enum ChatInfoSharedContent: String, CaseIterable, Identifiable {
    case photos = "Photos"
    case links = "Links"
    case documents = "Documents"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .photos: "photo.on.rectangle"
        case .links: "link"
        case .documents: "doc"
        }
    }
}

private struct ChatInfoQuickAction<Control: View>: View {
    let control: Control

    init(@ViewBuilder control: () -> Control) {
        self.control = control()
    }

    var body: some View {
        control
    }
}

private struct ChatInfoQuickActionIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.title3)
            .frame(width: 44, height: 44)
    }
}

private struct ChatInfoSharedContentLinks: View {
    @Binding var profile: PrototypeProfile
    let chatID: String

    var body: some View {
        Section {
            ForEach(ChatInfoSharedContent.allCases) { category in
                NavigationLink {
                    ChatInfoSharedContentView(
                        profile: $profile,
                        chatID: chatID,
                        category: category
                    )
                } label: {
                    Label(category.rawValue, systemImage: category.systemImage)
                }
            }
        }
    }
}

private struct ChatInfoTechnicalLinks: View {
    @Binding var profile: PrototypeProfile
    let chatID: String

    var body: some View {
        Section {
            NavigationLink {
                ChatRelaysView(profile: $profile, chatID: chatID)
            } label: {
                Label("Relays", systemImage: "network")
            }

            NavigationLink {
                DeveloperToolsPrototypeView(
                    developerTools: $profile.developerTools,
                    profile: profile
                )
            } label: {
                Label("Developer Tools", systemImage: "wrench.and.screwdriver")
            }
        }
    }
}

private struct ChatInfoSharedContentView: View {
    @Binding var profile: PrototypeProfile
    let chatID: String
    let category: ChatInfoSharedContent
    @State private var mediaSelection: PrototypeMediaSelection?
    @State private var quickLookURL: URL?

    var body: some View {
        List {
            ChatInfoSharedCategorySections(
                profile: $profile,
                chatID: chatID,
                category: category,
                mediaSelection: $mediaSelection,
                quickLookURL: $quickLookURL
            )
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $mediaSelection) {
            PrototypeMediaViewer(selection: $0)
        }
        .quickLookPreview($quickLookURL)
    }
}

private struct ChatInfoSharedCategorySections: View {
    @Binding var profile: PrototypeProfile
    let chatID: String
    let category: ChatInfoSharedContent
    @Binding var mediaSelection: PrototypeMediaSelection?
    @Binding var quickLookURL: URL?

    var body: some View {
        switch category {
        case .photos:
            ChatInfoMediaSection(attachments: mediaAttachments) { index in
                mediaSelection = PrototypeMediaSelection(
                    id: "\(chatID)-info-media-\(UUID().uuidString)",
                    attachments: mediaAttachments,
                    initialIndex: index
                )
            }
        case .links:
            ChatInfoLinksSection(attachments: linkAttachments)
        case .documents:
            ChatInfoDocumentsSection(attachments: documentAttachments) { url in
                quickLookURL = url
            }
        }
    }

    private var chat: PrototypeChat {
        profile.chats.first { $0.id == chatID }!
    }
    private var attachments: [PrototypeAttachment] {
        chat.messages
            .filter { !$0.isDeleted }
            .flatMap(\.attachments)
    }
    private var mediaAttachments: [PrototypeAttachment] {
        attachments.filter {
            switch $0 {
            case .photo, .video, .gif, .sticker: true
            default: false
            }
        }
    }
    private var linkAttachments: [PrototypeAttachment] {
        attachments.filter {
            if case .link = $0 { return true }
            return false
        }
    }
    private var documentAttachments: [PrototypeAttachment] {
        attachments.filter {
            if case .file = $0 { return true }
            return false
        }
    }
}

private struct ChatInfoMediaSection: View {
    let attachments: [PrototypeAttachment]
    let onOpen: (Int) -> Void
    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 3)]

    var body: some View {
        Section {
            if attachments.isEmpty {
                ContentUnavailableView(
                    "No Photos",
                    systemImage: "photo.on.rectangle",
                    description: Text("Photos and videos shared in this chat will appear here.")
                )
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(Array(attachments.enumerated()), id: \.element.id) { index, attachment in
                        Button {
                            onOpen(index)
                        } label: {
                            mediaTile(attachment)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            "\(attachment.accessibilityLabel), \(index + 1) of \(attachments.count)"
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func mediaTile(_ attachment: PrototypeAttachment) -> some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground)
            switch attachment {
            case let .photo(_, source, _):
                PrototypeImageSourceView(source: source)
                    .scaledToFill()
            case let .video(_, _, thumbnail, duration):
                PrototypeImageSourceView(source: thumbnail)
                    .scaledToFill()
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                Text(prototypeDurationString(duration))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(.black.opacity(0.55), in: .capsule)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(5)
            case let .gif(_, assetName, _):
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                Text("GIF")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(.black.opacity(0.55), in: .capsule)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(5)
            case let .sticker(_, assetName, _):
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            default:
                EmptyView()
            }
        }
        .clipped()
        .clipShape(.rect(cornerRadius: 10))
    }
}

private struct ChatInfoLinksSection: View {
    let attachments: [PrototypeAttachment]

    var body: some View {
        Section {
            if attachments.isEmpty {
                ContentUnavailableView(
                    "No Links",
                    systemImage: "link",
                    description: Text("Links shared in this chat will appear here.")
                )
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(attachments) { attachment in
                    if case let .link(_, title, domain, summary, image) = attachment {
                        if let destination = chatInfoLinkDestination(domain: domain) {
                            Link(destination: destination) {
                                ChatInfoLinkRow(
                                    title: title,
                                    domain: domain,
                                    summary: summary,
                                    image: image
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            ChatInfoLinkRow(
                                title: title,
                                domain: domain,
                                summary: summary,
                                image: image
                            )
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Link unavailable, \(title), \(domain)")
                        }
                    }
                }
            }
        }
    }
}

private struct ChatInfoLinkRow: View {
    let title: String
    let domain: String
    let summary: String
    let image: PrototypeImageSource?

    var body: some View {
        HStack(spacing: 12) {
            if let image {
                PrototypeImageSourceView(source: image)
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipped()
                    .clipShape(.rect(cornerRadius: 8))
            } else {
                Image(systemName: "link")
                    .font(.title3)
                    .frame(width: 56, height: 56)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                Text(domain)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

private struct ChatInfoDocumentsSection: View {
    let attachments: [PrototypeAttachment]
    let onOpen: (URL) -> Void

    var body: some View {
        Section {
            if attachments.isEmpty {
                ContentUnavailableView(
                    "No Documents",
                    systemImage: "doc",
                    description: Text("Documents shared in this chat will appear here.")
                )
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(attachments) { attachment in
                    if case let .file(_, name, size, url) = attachment {
                        if let url {
                            Button {
                                onOpen(url)
                            } label: {
                                ChatInfoDocumentRow(name: name, size: size, isAvailable: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Opens a preview.")
                        } else {
                            ChatInfoDocumentRow(name: name, size: size, isAvailable: false)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Document, \(name), unavailable")
                        }
                    }
                }
            }
        }
    }
}

private struct ChatInfoDocumentRow: View {
    let name: String
    let size: Int
    let isAvailable: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .font(.title2)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .lineLimit(1)
                Text(chatInfoFileMetadata(name: name, size: size))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: isAvailable ? "chevron.right" : "exclamationmark.triangle")
                .foregroundStyle(.tertiary)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

private struct ChatInfoRelaysSections: View {
    @Binding var profile: PrototypeProfile
    let chatID: String
    @State private var newRelay = ""
    @State private var validationMessage: String?
    @State private var relayPendingRemoval: String?

    var body: some View {
        Group {
            Section {
                Text("Messages in this chat use these relays.")
                    .foregroundStyle(.secondary)
            }

            Section("Relays") {
                ForEach(chat.routing.relayURLs, id: \.self) { relay in
                    HStack {
                        Text(relay)
                            .textSelection(.enabled)
                        Spacer()
                        Button(role: .destructive) {
                            relayPendingRemoval = relay
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Remove \(relay)")
                    }
                }
            }

            Section("Add Relay") {
                TextField("wss://relay.example.com", text: $newRelay)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .accessibilityIdentifier("chat-relays.input")
                if let validationMessage {
                    Text(validationMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                Button("Add Relay", action: addRelay)
                    .disabled(newRelay.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .confirmationDialog(
            chat.routing.relayURLs.count == 1 ? "Remove Final Relay?" : "Remove Relay?",
            isPresented: Binding(
                get: { relayPendingRemoval != nil },
                set: { if !$0 { relayPendingRemoval = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Remove Relay", role: .destructive) {
                removePendingRelay()
            }
            Button("Cancel", role: .cancel) {
                relayPendingRemoval = nil
            }
        } message: {
            if chat.routing.relayURLs.count == 1 {
                Text("Sending will stop until you add a Chat Relay.")
            }
        }
    }

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var chat: PrototypeChat { profile.chats[chatIndex] }

    private func addRelay() {
        validationMessage = nil
        let normalized = PrototypeChatRouting.normalized(newRelay)
        guard normalized != nil else {
            validationMessage = "Enter a valid wss:// relay URL."
            return
        }
        guard profile.chats[chatIndex].routing.add(newRelay) else {
            validationMessage = "This relay is already in the chat."
            return
        }
        newRelay = ""
    }

    private func removePendingRelay() {
        guard let relayPendingRemoval else { return }
        profile.chats[chatIndex].routing.remove(relayPendingRemoval)
        self.relayPendingRemoval = nil
    }
}

private func chatInfoLinkDestination(domain: String) -> URL? {
    guard !domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          let url = URL(string: "https://\(domain)"),
          url.host?.isEmpty == false
    else { return nil }
    return url
}

private func chatInfoFileMetadata(name: String, size: Int) -> String {
    let fileType = URL(fileURLWithPath: name).pathExtension.uppercased()
    let formattedSize = size.formatted(.byteCount(style: .file))
    return fileType.isEmpty ? formattedSize : "\(fileType) • \(formattedSize)"
}

struct ChatRelaysView: View {
    @Binding var profile: PrototypeProfile
    let chatID: String

    var body: some View {
        Form {
            ChatInfoRelaysSections(profile: $profile, chatID: chatID)
        }
        .navigationTitle("Chat Relays")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct EditGroupView: View {
    @Binding var profile: PrototypeProfile
    let chatID: String
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var description: String
    @State private var avatar: ChatListItem.Avatar
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isWebPickerPresented = false

    init(profile: Binding<PrototypeProfile>, chatID: String) {
        _profile = profile
        self.chatID = chatID
        let chat = profile.wrappedValue.chats.first { $0.id == chatID }!
        _name = State(initialValue: chat.groupName)
        _description = State(initialValue: chat.groupDescription)
        _avatar = State(initialValue: chat.avatar)
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 10) {
                    PrototypeChatAvatarView(avatar: avatar, size: 88)
                    Menu {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Choose Photo", systemImage: "photo.on.rectangle")
                        }
                        Button { isWebPickerPresented = true } label: {
                            Label("Find Image on Web", systemImage: "globe")
                        }
                        if hasPhoto {
                            Button("Remove Photo", systemImage: "trash", role: .destructive) {
                                avatar = .systemSymbol("person.3.fill")
                            }
                        }
                    } label: { Text(hasPhoto ? "Change Photo" : "Add Photo") }
                }
                .frame(maxWidth: .infinity).listRowBackground(Color.clear)
            }
            Section("Group Details") {
                TextField("Group Name", text: $name)
                    .accessibilityIdentifier("edit-group.name")
                TextField("Description (Optional)", text: $description, axis: .vertical).lineLimit(2...5)
            }
        }
        .navigationTitle("Edit Group")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save).disabled(!hasValidChanges)
            }
        }
        .task(id: selectedPhotoItem) {
            guard let item = selectedPhotoItem,
                  let data = try? await item.loadTransferable(type: Data.self),
                  let prepared = await ConversationImageProcessor.preparedDataAsync(from: data)
            else { return }
            avatar = .imageData(prepared)
            selectedPhotoItem = nil
        }
        .sheet(isPresented: $isWebPickerPresented) {
            AvatarWebImagePickerView(currentChoice: currentWebChoice) { choice in
                avatar = .asset(choice.assetName)
                isWebPickerPresented = false
            }
        }
    }

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var original: PrototypeChat { profile.chats[chatIndex] }
    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedDescription: String { description.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var hasValidChanges: Bool {
        !trimmedName.isEmpty && (trimmedName != original.groupName || trimmedDescription != original.groupDescription || avatar != original.avatar)
    }
    private var currentWebChoice: AvatarWebImageChoice? {
        guard case let .asset(name) = avatar else { return nil }
        return AvatarWebImageCatalog.choices.first { $0.assetName == name }
    }
    private var hasPhoto: Bool {
        switch avatar {
        case .asset, .imageData: true
        case .monogram, .systemSymbol: false
        }
    }

    private func save() {
        let old = original
        if trimmedName != old.groupName {
            profile.chats[chatIndex].groupName = trimmedName
            profile.chats[chatIndex].appendEvent(.changedName(actorID: profile.id, name: trimmedName))
        }
        if avatar != old.avatar {
            profile.chats[chatIndex].avatar = avatar
            profile.chats[chatIndex].appendEvent(.changedPhoto(actorID: profile.id))
        }
        if trimmedDescription != old.groupDescription {
            profile.chats[chatIndex].groupDescription = trimmedDescription
            profile.chats[chatIndex].appendEvent(
                trimmedDescription.isEmpty ? .removedDescription(actorID: profile.id) : .changedDescription(actorID: profile.id)
            )
        }
        dismiss()
    }
}

private struct AddPeopleToGroupView: View {
    @Binding var profile: PrototypeProfile
    let chatID: String
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var selectedIDs: Set<String> = []

    var body: some View {
        List(filteredPeople) { person in
            Button {
                if selectedIDs.contains(person.id) { selectedIDs.remove(person.id) }
                else { selectedIDs.insert(person.id) }
            } label: {
                PersonRow(person: person, showsCheckmark: selectedIDs.contains(person.id))
            }
            .buttonStyle(.plain)
        }
        .overlay {
            if filteredPeople.isEmpty { ContentUnavailableView.search(text: query) }
        }
        .navigationTitle("Add People")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Search People")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add", action: add).disabled(selectedIDs.isEmpty)
            }
        }
    }

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var currentIDs: Set<String> { Set(profile.chats[chatIndex].members.map(\.personID)) }
    private var filteredPeople: [PrototypePerson] {
        profile.selectableChatPeople.filter {
            !currentIDs.contains($0.id) && (query.isEmpty || $0.name.localizedCaseInsensitiveContains(query) || $0.publicKey.localizedCaseInsensitiveContains(query))
        }
    }
    private func add() {
        let ids = profile.people.filter { selectedIDs.contains($0.id) }.map(\.id)
        _ = profile.chats[chatIndex].addMembers(personIDs: ids, actorID: profile.id)
        dismiss()
    }
}

struct GroupMemberView: View {
    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    let chatID: String
    let personID: String
    @Environment(\.dismiss) private var dismiss
    @State private var pendingAction: Action?
    @State private var isShowingAddToGroup = false
    @State private var directChatID: String?

    private enum Action: String, Identifiable {
        case promote, demote, remove
        var id: Self { self }
    }

    var body: some View {
        Group {
            if let member {
                memberList(member)
            } else {
                ContentUnavailableView("Member Unavailable", systemImage: "person.crop.circle.badge.questionmark")
            }
        }
        .navigationTitle("Group Member")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(actionTitle, isPresented: actionIsPresented, titleVisibility: .visible) {
            Button(actionButtonTitle, role: pendingAction == .remove ? .destructive : nil, action: performAction)
            Button("Cancel", role: .cancel) { pendingAction = nil }
        }
        .sheet(isPresented: $isShowingAddToGroup) {
            NavigationStack { AddPersonToGroupView(profile: $profile, personID: personID) }
        }
        .navigationDestination(isPresented: directChatIsPresented) {
            if let directChatID {
                ConversationView(profile: $profile, settings: $settings, chatID: directChatID)
            }
        }
    }

    private func memberList(_ member: PrototypeGroupMember) -> some View {
        List {
            Section {
                VStack(spacing: 10) {
                    memberAvatar
                    Text(displayName).font(.title2.bold())
                    Text(member.role == .admin ? "Admin" : "Member").foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity).listRowBackground(Color.clear)
            }

            if personID != profile.id {
                Section {
                    if canOpenDirectChat {
                        Button("Message", systemImage: "message", action: openDirectChat)
                    } else {
                        NavigationLink {
                            RelaysPrototypeView(configuration: $profile.relayConfiguration)
                        } label: {
                            Label("Check Profile Relays", systemImage: "exclamationmark.triangle")
                        }
                    }
                    Button(person.isFollowing ? "Unfollow" : "Follow") {
                        profile.people[personIndex].isFollowing.toggle()
                    }
                    Button("Add to Another Group", systemImage: "person.2.badge.plus") { isShowingAddToGroup = true }
                }
            }

            if canManageOtherMember {
                Section {
                    Button(member.role == .admin ? "Remove Admin" : "Make Admin") {
                        pendingAction = member.role == .admin ? .demote : .promote
                    }
                    Button("Remove from Group", role: .destructive) { pendingAction = .remove }
                }
            }
        }
    }

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var member: PrototypeGroupMember? {
        profile.chats[chatIndex].members.first { $0.personID == personID }
    }
    private var personIndex: Int { profile.people.firstIndex { $0.id == personID }! }
    private var person: PrototypePerson { profile.people[personIndex] }
    private var displayName: String { personID == profile.id ? profile.name : person.name }
    private var existingDirectChatID: String? {
        profile.chats.first { chat in
            if case let .direct(id) = chat.kind { return id == personID }
            return false
        }?.id
    }
    private var canOpenDirectChat: Bool {
        existingDirectChatID != nil
            || !profile.relayConfiguration.availableChatMessageRelayURLs.isEmpty
    }
    private var canManageOtherMember: Bool {
        personID != profile.id && profile.chats[chatIndex].isCurrentProfileAdmin(profile.id)
            && profile.chats[chatIndex].listState.membershipState == .active
    }
    @ViewBuilder private var memberAvatar: some View {
        if personID == profile.id { ProfileAvatarView(profile: profile, size: 88) }
        else { PrototypeChatAvatarView(avatar: person.avatar, size: 88) }
    }
    private var actionIsPresented: Binding<Bool> {
        Binding { pendingAction != nil } set: { if !$0 { pendingAction = nil } }
    }
    private var directChatIsPresented: Binding<Bool> {
        Binding { directChatID != nil } set: { if !$0 { directChatID = nil } }
    }
    private var actionTitle: String {
        switch pendingAction {
        case .promote: "Make \(displayName) an Admin?"
        case .demote: "Remove \(displayName) as an Admin?"
        case .remove: "Remove \(displayName)?"
        case nil: ""
        }
    }
    private var actionButtonTitle: String {
        switch pendingAction {
        case .promote: "Make Admin"
        case .demote: "Remove Admin"
        case .remove: "Remove from Group"
        case nil: ""
        }
    }
    private func performAction() {
        switch pendingAction {
        case .promote:
            _ = profile.chats[chatIndex].promoteMember(
                personID: personID,
                actorID: profile.id
            )
        case .demote:
            _ = profile.chats[chatIndex].demoteMember(
                personID: personID,
                actorID: profile.id
            )
        case .remove:
            _ = profile.chats[chatIndex].removeMember(
                personID: personID,
                actorID: profile.id
            )
            pendingAction = nil
            dismiss()
            return
        case nil:
            break
        }
        pendingAction = nil
    }
    private func openDirectChat() {
        directChatID = profile.openOrCreateDirectChat(personID: personID)
    }
}
