import PhotosUI
import SwiftUI

struct ProfileSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding private var profile: PrototypeProfile

    @State private var name: String
    @State private var about: String
    @State private var nostrAddress: String
    @State private var lightningAddress: String
    @State private var imageURL: String
    @State private var avatarData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isShowingImageURL = false
    @State private var pendingImageURL = ""
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
        _imageURL = State(initialValue: profile.wrappedValue.imageURL)
        _avatarData = State(initialValue: profile.wrappedValue.avatarData)
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
        .sheet(isPresented: $isShowingImageURL) {
            NavigationStack {
                Form {
                    TextField(
                        "Image URL",
                        text: $pendingImageURL,
                        prompt: Text("https://example.com/avatar.jpg")
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                }
                .navigationTitle("Enter Image URL")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isShowingImageURL = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            imageURL = pendingImageURL
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            avatarData = nil
                            isShowingImageURL = false
                        }
                        .disabled(!pendingImageURLIsValid)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onChange(of: selectedPhoto) { _, newValue in
            guard let newValue else {
                return
            }

            Task {
                avatarData = try? await newValue.loadTransferable(
                    type: Data.self
                )
                if avatarData != nil {
                    imageURL = ""
                }
            }
        }
    }

    private var editableAvatar: some View {
        Group {
            if let avatarData,
               let image = UIImage(data: avatarData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(.primary)

                    Text(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .first
                        .map { String($0).uppercased() }
                        ?? "?"
                    )
                    .font(.title)
                    .foregroundStyle(.background)
                }
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
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

            Button {
                pendingImageURL = imageURL
                isShowingImageURL = true
            } label: {
                Label("Enter Image URL", systemImage: "link")
            }

            if avatarData != nil || !imageURL.isEmpty {
                Button(role: .destructive) {
                    avatarData = nil
                    imageURL = ""
                } label: {
                    Label("Remove Avatar", systemImage: "trash")
                }
            }
        } label: {
            Text(
                avatarData == nil && imageURL.isEmpty
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
            || imageURL != profile.imageURL
            || avatarData != profile.avatarData
    }

    private var pendingImageURLIsValid: Bool {
        let value = pendingImageURL.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return value.isEmpty || value.hasPrefix("https://")
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
            profile.imageURL = imageURL
            profile.avatarData = avatarData
            isSaving = false
            dismiss()
        }
    }
}

#Preview("Profile Settings") {
    @Previewable @State var profile = PrototypeProfile.marmota

    NavigationStack {
        ProfileSettingsView(profile: $profile)
    }
    .tint(Color("AccentColor"))
}
