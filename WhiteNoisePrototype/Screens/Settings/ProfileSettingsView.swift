import PhotosUI
import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding private var profile: PrototypeProfile

    @State private var name: String
    @State private var about: String
    @State private var nostrAddress: String
    @State private var lightningAddress: String
    @State private var avatar: PrototypeAvatar
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isSaving = false

    init(profile: Binding<PrototypeProfile>) {
        _profile = profile
        _name = State(initialValue: profile.wrappedValue.name)
        _about = State(initialValue: profile.wrappedValue.about)
        _nostrAddress = State(
            initialValue: profile.wrappedValue.nostrAddress
        )
        _lightningAddress = State(
            initialValue: profile.wrappedValue.lightningAddress
        )
        _avatar = State(initialValue: profile.wrappedValue.avatar)
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    editableAvatar
                    avatarMenu
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section {
                Label {
                    VStack(alignment: .leading) {
                        Text("Profile is public")
                        Text(
                            "Your profile information will be visible to everyone on the network."
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "globe")
                }
            }

            Section {
                HStack {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .disabled(isSaving)

                    Button {
                        name = generatedName
                    } label: {
                        Label(
                            "Generate Name",
                            systemImage: "dice"
                        )
                        .labelStyle(.iconOnly)
                    }
                    .disabled(isSaving)
                }

                TextField(
                    "About",
                    text: $about,
                    prompt: Text("A little about you"),
                    axis: .vertical
                )
                .lineLimit(3...6)
                .disabled(isSaving)
            }

            Section {
                TextField(
                    "Nostr Address",
                    text: $nostrAddress,
                    prompt: Text("name@example.com")
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .disabled(isSaving)

                TextField(
                    "Lightning Address",
                    text: $lightningAddress,
                    prompt: Text("name@example.com")
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .disabled(isSaving)
            } footer: {
                if let validationMessage {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel("Saving profile")
                } else {
                    Button("Save", action: save)
                        .disabled(!canSave)
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            guard let newValue else {
                return
            }

            Task {
                defer {
                    selectedPhoto = nil
                }

                guard let data = try? await newValue.loadTransferable(
                    type: Data.self
                ) else {
                    return
                }

                guard let preparedData = ProfileAvatarImageProcessor
                    .preparedData(from: data) else {
                    return
                }

                avatar = .imageData(preparedData)
            }
        }
    }

    private var editableAvatar: some View {
        ProfileAvatarView(
            profile: editableProfile,
            size: 72,
            isDecorative: false
        )
        .accessibilityLabel("Profile avatar")
    }

    private var avatarMenu: some View {
        Menu {
            PhotosPicker(
                selection: $selectedPhoto,
                matching: .images
            ) {
                Label("Choose from Photos", systemImage: "photo")
            }

            if avatar != .monogram {
                Button(role: .destructive) {
                    avatar = .monogram
                } label: {
                    Label("Remove Avatar", systemImage: "trash")
                }
            }
        } label: {
            Text(
                avatar == .monogram
                    ? "Choose Avatar"
                    : "Edit Avatar"
            )
        }
        .buttonStyle(.bordered)
        .disabled(isSaving)
    }

    private var validationMessage: String? {
        if !nostrAddress.isEmpty && !isAddressValid(nostrAddress) {
            return "Enter a valid Nostr Address like name@example.com."
        }

        if !lightningAddress.isEmpty && !isAddressValid(lightningAddress) {
            return "Enter a valid Lightning Address like name@example.com."
        }

        return nil
    }

    private var canSave: Bool {
        !isSaving
            && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && validationMessage == nil
            && hasChanges
    }

    private var hasChanges: Bool {
        name != profile.name
            || about != profile.about
            || nostrAddress != profile.nostrAddress
            || lightningAddress != profile.lightningAddress
            || avatar != profile.avatar
    }

    private var generatedName: String {
        let names = [
            "Gentle Badger",
            "Brisk Heron",
            "Quiet Otter",
            "Silver Finch",
        ]
        return names.first { $0 != name } ?? names[0]
    }

    private func isAddressValid(_ value: String) -> Bool {
        let parts = value.split(separator: "@", omittingEmptySubsequences: false)
        return parts.count == 2
            && !parts[0].isEmpty
            && parts[1].contains(".")
    }

    private func save() {
        guard canSave else {
            return
        }

        isSaving = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            profile.name = name.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            profile.about = about
            profile.nostrAddress = nostrAddress
            profile.lightningAddress = lightningAddress
            profile.avatar = avatar
            isSaving = false
            dismiss()
        }
    }

    private var editableProfile: PrototypeProfile {
        var editableProfile = profile
        editableProfile.name = name
        editableProfile.avatar = avatar
        return editableProfile
    }
}

#Preview("Profile Settings") {
    @Previewable @State var profile = PrototypeProfile.marmota

    NavigationStack {
        ProfileSettingsView(profile: $profile)
    }
    .tint(Color("AccentColor"))
}
