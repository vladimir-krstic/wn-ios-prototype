import PhotosUI
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

    @State private var isShowingBlockConfirmation = false
    @State private var isShowingAddToGroup = false

    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    PrototypeChatAvatarView(avatar: person.avatar, size: 88)
                    Text(person.name).font(.title2.bold())
                    Button {
                        UIPasteboard.general.string = person.publicKey
                    } label: {
                        Label(person.shortPublicKey, systemImage: "doc.on.doc")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section {
                Button("Search", systemImage: "magnifyingglass", action: onSearch)
                Button(person.isFollowing ? "Unfollow" : "Follow", systemImage: "person.badge.plus") {
                    profile.people[personIndex].isFollowing.toggle()
                }
                Button("Add to Group", systemImage: "person.2.badge.plus") { isShowingAddToGroup = true }
            }

            Section {
                muteMenu
                Button(chat.listState.isArchived ? "Unarchive" : "Archive", systemImage: "archivebox") {
                    updateChat { $0.listState.isArchived.toggle() }
                }
                NavigationLink {
                    ChatRelaysView(profile: $profile, chatID: chatID)
                } label: {
                    Label("Chat Relays", systemImage: "network")
                }
            }

            Section {
                Button(person.isBlocked ? "Unblock" : "Block", role: person.isBlocked ? nil : .destructive) {
                    if person.isBlocked { profile.people[personIndex].isBlocked = false }
                    else { isShowingBlockConfirmation = true }
                }
            }
        }
        .navigationTitle("Chat Info")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Block \(person.name)?", isPresented: $isShowingBlockConfirmation, titleVisibility: .visible) {
            Button("Block", role: .destructive) { profile.people[personIndex].isBlocked = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You’ll keep the chat history, but you won’t be able to send messages until you unblock them.")
        }
        .sheet(isPresented: $isShowingAddToGroup) {
            NavigationStack { AddPersonToGroupView(profile: $profile, personID: person.id) }
        }
    }

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var chat: PrototypeChat { profile.chats[chatIndex] }
    private var personID: String {
        if case let .direct(id) = chat.kind { return id }
        return ""
    }
    private var personIndex: Int { profile.people.firstIndex { $0.id == personID }! }
    private var person: PrototypePerson { profile.people[personIndex] }

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
            Label(chat.listState.muteDuration == nil ? "Mute Notifications" : "Unmute Notifications", systemImage: "bell.slash")
        }
    }

    private func updateChat(_ mutation: (inout PrototypeChat) -> Void) { mutation(&profile.chats[chatIndex]) }
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
            Section {
                VStack(spacing: 10) {
                    PrototypeChatAvatarView(avatar: chat.avatar, size: 88)
                    Text(chat.groupName).font(.title2.bold())
                    if !chat.groupDescription.isEmpty {
                        Text(chat.groupDescription).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                    Text("\(chat.members.count) members").font(.footnote).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section {
                Button("Search", systemImage: "magnifyingglass", action: onSearch)
                muteMenu
                Button(chat.listState.isArchived ? "Unarchive" : "Archive", systemImage: "archivebox") {
                    updateChat { $0.listState.isArchived.toggle() }
                }
                NavigationLink {
                    ChatRelaysView(profile: $profile, chatID: chatID)
                } label: {
                    Label("Chat Relays", systemImage: "network")
                }
            }

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
                                Text("Admin").font(.caption).foregroundStyle(.secondary)
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

            if chat.listState.membershipState == .active {
                Section {
                    Button("Leave Group", role: .destructive) {
                        if isOnlyAdmin { isShowingOnlyAdminAlert = true }
                        else { isShowingLeaveConfirmation = true }
                    }
                }
            }
        }
        .navigationTitle("Group Info")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Leave \(chat.groupName)?", isPresented: $isShowingLeaveConfirmation, titleVisibility: .visible) {
            Button("Leave Group", role: .destructive, action: leaveGroup)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You’ll keep the chat history, but you won’t be able to send messages.")
        }
        .alert("Can’t Leave Group", isPresented: $isShowingOnlyAdminAlert) {
            Button("OK") {}
        } message: {
            Text("You’re the only admin in this group. Make another member an admin before you leave.")
        }
    }

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var chat: PrototypeChat { profile.chats[chatIndex] }
    private var canManage: Bool { chat.listState.membershipState == .active && chat.isCurrentProfileAdmin(profile.id) }
    private var isOnlyAdmin: Bool { canManage && chat.members.filter { $0.role == .admin }.count == 1 }

    @ViewBuilder private func memberAvatar(_ id: String) -> some View {
        if id == profile.id { ProfileAvatarView(profile: profile, size: 36) }
        else { PrototypeChatAvatarView(avatar: profile.people.first { $0.id == id }?.avatar ?? .monogram("?"), size: 36) }
    }
    private func memberName(_ id: String) -> String {
        id == profile.id ? "You" : (profile.people.first { $0.id == id }?.name ?? "Unknown")
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
            Label(chat.listState.muteDuration == nil ? "Mute Notifications" : "Unmute Notifications", systemImage: "bell.slash")
        }
    }
    private func updateChat(_ mutation: (inout PrototypeChat) -> Void) { mutation(&profile.chats[chatIndex]) }
    private func leaveGroup() {
        updateChat { _ = $0.leave(currentProfileID: profile.id) }
    }
}

struct ChatRelaysView: View {
    @Binding var profile: PrototypeProfile
    let chatID: String
    @State private var newRelay = ""
    @State private var validationMessage: String?
    @State private var relayPendingRemoval: String?

    var body: some View {
        Form {
            Section {
                Text("Messages in this chat use these relays.")
                    .foregroundStyle(.secondary)
            }

            Section("Relays") {
                ForEach(chat.routing.relayURLs, id: \.self) { relay in
                    HStack {
                        Text(relay).textSelection(.enabled)
                        Spacer()
                        Button(role: .destructive) { relayPendingRemoval = relay } label: {
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
                    Text(validationMessage).font(.footnote).foregroundStyle(.red)
                }
                Button("Add Relay", action: addRelay)
                    .disabled(newRelay.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Chat Relays")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            chat.routing.relayURLs.count == 1 ? "Remove Final Relay?" : "Remove Relay?",
            isPresented: Binding(
                get: { relayPendingRemoval != nil },
                set: { if !$0 { relayPendingRemoval = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Remove Relay", role: .destructive) { removePendingRelay() }
            Button("Cancel", role: .cancel) { relayPendingRemoval = nil }
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
                        Button("Remove Photo", systemImage: "trash", role: .destructive) {
                            avatar = .systemSymbol("person.3.fill")
                        }
                    } label: { Text("Change Photo") }
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
        .toolbar {
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
        profile.people.filter {
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
                    Button("Message", systemImage: "message", action: openDirectChat)
                    Button(person.isFollowing ? "Unfollow" : "Follow") {
                        profile.people[personIndex].isFollowing.toggle()
                    }
                    Button("Add to Another Group", systemImage: "person.badge.plus") { isShowingAddToGroup = true }
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

    private var chatIndex: Int { profile.chats.firstIndex { $0.id == chatID }! }
    private var memberIndex: Int { profile.chats[chatIndex].members.firstIndex { $0.personID == personID }! }
    private var member: PrototypeGroupMember { profile.chats[chatIndex].members[memberIndex] }
    private var personIndex: Int { profile.people.firstIndex { $0.id == personID }! }
    private var person: PrototypePerson { profile.people[personIndex] }
    private var displayName: String { personID == profile.id ? profile.name : person.name }
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
