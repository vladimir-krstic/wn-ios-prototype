import PhotosUI
import SwiftUI

struct NewChatView: View {
    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    @State private var query = ""

    var body: some View {
        List {
            Section {
                NavigationLink(value: ChatsRoute.newGroup) {
                    Label("New Group", systemImage: "person.3")
                }
            }

            Section {
                ForEach(filteredPeople) { person in
                    NavigationLink(value: ChatsRoute.person(person.id)) {
                        PersonRow(person: person)
                    }
                }
            }
        }
        .overlay {
            if filteredPeople.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .navigationTitle("New Chat")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Name or npub")
    }

    private var filteredPeople: [PrototypePerson] {
        let value = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return profile.selectableChatPeople }
        return profile.selectableChatPeople.filter {
            $0.name.localizedCaseInsensitiveContains(value)
                || $0.publicKey.localizedCaseInsensitiveContains(value)
        }
    }
}

struct PersonRow: View {
    let person: PrototypePerson
    var showsCheckmark = false

    var body: some View {
        HStack {
            PrototypeChatAvatarView(avatar: person.avatar, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name).font(.headline)
                Text(person.shortPublicKey).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer()
            if showsCheckmark {
                Image(systemName: "checkmark").foregroundStyle(.tint)
            }
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(showsCheckmark ? .isSelected : [])
    }
}

struct PersonProfileView: View {
    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    let personID: String
    var contextGroupID: String?
    let onMessagePerson: (String) -> Void

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

            if !person.about.isEmpty {
                Section("About") { Text(person.about) }
            }

            if !person.nostrAddress.isEmpty || !person.lightningAddress.isEmpty {
                Section("Addresses") {
                    if !person.nostrAddress.isEmpty { LabeledContent("Nostr", value: person.nostrAddress) }
                    if !person.lightningAddress.isEmpty { LabeledContent("Lightning", value: person.lightningAddress) }
                }
            }

            Section {
                Button(person.isFollowing ? "Unfollow" : "Follow") { toggleFollow() }
                Button("Add to Group", systemImage: "person.badge.plus") { isShowingAddToGroup = true }
                if canOpenDirectChat {
                    Button("Message", systemImage: "message") { onMessagePerson(personID) }
                } else {
                    NavigationLink {
                        RelaysPrototypeView(configuration: $profile.relayConfiguration)
                    } label: {
                        Label("Check Profile Relays", systemImage: "exclamationmark.triangle")
                    }
                }
            }

            Section {
                Button(person.isBlocked ? "Unblock" : "Block", role: person.isBlocked ? nil : .destructive) {
                    if person.isBlocked { setBlocked(false) } else { isShowingBlockConfirmation = true }
                }
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Block \(person.name)?",
            isPresented: $isShowingBlockConfirmation,
            titleVisibility: .visible
        ) {
            Button("Block", role: .destructive) { setBlocked(true) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You’ll keep the chat history, but you won’t be able to send messages until you unblock them.")
        }
        .sheet(isPresented: $isShowingAddToGroup) {
            NavigationStack {
                AddPersonToGroupView(profile: $profile, personID: personID)
            }
        }
    }

    private var personIndex: Int { profile.people.firstIndex { $0.id == personID }! }
    private var person: PrototypePerson { profile.people[personIndex] }
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

    private func toggleFollow() { profile.people[personIndex].isFollowing.toggle() }
    private func setBlocked(_ blocked: Bool) { profile.people[personIndex].isBlocked = blocked }

}

struct NewGroupView: View {
    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    @State private var query = ""
    @State private var selectedIDs: Set<String> = []

    var body: some View {
        List {
            if !selectedPeople.isEmpty {
                Section("Selected") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedPeople) { person in
                                Button { selectedIDs.remove(person.id) } label: {
                                    VStack {
                                        PrototypeChatAvatarView(avatar: person.avatar, size: 48)
                                            .overlay(alignment: .topTrailing) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .symbolRenderingMode(.palette)
                                                    .foregroundStyle(.white, .black)
                                                    .offset(x: 4, y: -4)
                                            }
                                        Text(person.name).font(.caption).lineLimit(1)
                                    }
                                    .frame(width: 72)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Remove \(person.name)")
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }

            Section {
                ForEach(filteredPeople) { person in
                    Button {
                        if selectedIDs.contains(person.id) { selectedIDs.remove(person.id) }
                        else { selectedIDs.insert(person.id) }
                    } label: {
                        PersonRow(person: person, showsCheckmark: selectedIDs.contains(person.id))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("New Group")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Search People")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                NavigationLink(value: ChatsRoute.newGroupSetup(selectedPeople.map(\.id))) {
                    Text("Continue")
                }
                .disabled(selectedIDs.isEmpty)
            }
        }
    }

    private var selectedPeople: [PrototypePerson] {
        profile.selectableChatPeople.filter { selectedIDs.contains($0.id) }
    }
    private var filteredPeople: [PrototypePerson] {
        let value = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return profile.selectableChatPeople.filter {
            value.isEmpty || $0.name.localizedCaseInsensitiveContains(value)
                || $0.publicKey.localizedCaseInsensitiveContains(value)
        }
    }
}

struct NewGroupSetupView: View {
    @Binding var profile: PrototypeProfile
    @Binding var settings: PrototypeSettingsState
    let selectedPersonIDs: [String]
    let onCreateGroup: (String, String, ChatListItem.Avatar, [String]) -> Void

    @State private var name = ""
    @State private var description = ""
    @State private var avatar: ChatListItem.Avatar = .systemSymbol("person.3.fill")
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isWebPickerPresented = false

    var body: some View {
        Form {
            Section {
                VStack(spacing: 10) {
                    PrototypeChatAvatarView(avatar: avatar, size: 92)
                    Menu {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Choose Photo", systemImage: "photo.on.rectangle")
                        }
                        Button { isWebPickerPresented = true } label: {
                            Label("Find Image on Web", systemImage: "globe")
                        }
                        if avatar != .systemSymbol("person.3.fill") {
                            Button("Remove Photo", systemImage: "trash", role: .destructive) {
                                avatar = .systemSymbol("person.3.fill")
                            }
                        }
                    } label: {
                        Text(avatar == .systemSymbol("person.3.fill") ? "Add Photo" : "Change Photo")
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section("Group Details") {
                TextField("Group Name", text: $name)
                    .accessibilityIdentifier("new-group.name")
                TextField("Description (Optional)", text: $description, axis: .vertical).lineLimit(2...5)
            }

            Section("People") {
                ForEach(selectedPeople) { PersonRow(person: $0) }
            }

            Section {
                Button("Create Group") { createGroup() }
                    .frame(maxWidth: .infinity)
                    .disabled(trimmedName.isEmpty)
            }
        }
        .navigationTitle("Set Up Group")
        .navigationBarTitleDisplayMode(.inline)
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

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var selectedPeople: [PrototypePerson] {
        profile.selectableChatPeople.filter { selectedPersonIDs.contains($0.id) }
    }
    private var currentWebChoice: AvatarWebImageChoice? {
        guard case let .asset(name) = avatar else { return nil }
        return AvatarWebImageCatalog.choices.first { $0.assetName == name }
    }

    private func createGroup() {
        onCreateGroup(trimmedName, description, avatar, selectedPersonIDs)
    }
}

struct AddPersonToGroupView: View {
    @Binding var profile: PrototypeProfile
    let personID: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(availableGroups) { chat in
            Button(chat.groupName) {
                guard let index = profile.chats.firstIndex(where: { $0.id == chat.id }) else { return }
                _ = profile.chats[index].addMembers(
                    personIDs: [personID],
                    actorID: profile.id
                )
                dismiss()
            }
        }
        .overlay {
            if availableGroups.isEmpty {
                ContentUnavailableView("No Available Groups", systemImage: "person.3")
            }
        }
        .navigationTitle("Add to Group")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
        }
    }

    private var availableGroups: [PrototypeChat] {
        profile.chats.filter {
            $0.isGroup && $0.listState.membershipState == .active
                && $0.isCurrentProfileAdmin(profile.id)
                && !$0.members.contains(where: { $0.personID == personID })
        }
    }
}
