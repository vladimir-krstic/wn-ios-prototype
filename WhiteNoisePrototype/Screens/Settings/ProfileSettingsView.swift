import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ProfileSettingsView: View {
    @Binding private var profile: PrototypeProfile

    @State private var name: String
    @State private var about: String
    @State private var avatar: PrototypeAvatar
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedWebChoice: AvatarWebImageChoice?
    @State private var isPhotosPickerPresented = false
    @State private var isFileImporterPresented = false
    @State private var isWebImagePickerPresented = false
    @State private var photoError: String?
    @State private var isEditing = false

    @FocusState private var focusedField: Field?

    init(profile: Binding<PrototypeProfile>) {
        _profile = profile
        _name = State(initialValue: profile.wrappedValue.name)
        _about = State(initialValue: profile.wrappedValue.about)
        _avatar = State(initialValue: profile.wrappedValue.avatar)
        _selectedWebChoice = State(
            initialValue: Self.webChoice(for: profile.wrappedValue.avatar)
        )
    }

    private enum Field {
        case name
        case about
    }

    var body: some View {
        Form {
            avatarSection
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            Section("Name") {
                nameContent
                    .listRowBackground(
                        Color(uiColor: .secondarySystemFill)
                    )
            }

            Section("About") {
                aboutContent
                    .listRowBackground(
                        Color(uiColor: .secondarySystemFill)
                    )
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancelEditing)
                }
            }

            ToolbarItem(placement: .primaryAction) {
                if isEditing {
                    Button("Done", action: finishEditing)
                        .buttonStyle(.glassProminent)
                        .disabled(!canFinishEditing)
                } else {
                    Button("Edit", action: beginEditing)
                        .disabled(!canEditProfile)
                        .accessibilityHint(editAccessibilityHint)
                }
            }
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.image]
        ) { result in
            handleImportedFile(result)
        }
        .photosPicker(
            isPresented: $isPhotosPickerPresented,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .sheet(isPresented: $isWebImagePickerPresented) {
            AvatarWebImagePickerView(
                currentChoice: selectedWebChoice,
                onUseImage: useWebImage
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: selectedPhotoItem) {
            loadSelectedPhoto()
        }
        .background(.background)
    }

    private var avatarSection: some View {
        VStack(spacing: 0) {
            ProfileEditorAvatarView(
                name: name,
                image: avatarImage
            )
            .containerRelativeFrame(
                .horizontal,
                count: 3,
                span: 1,
                spacing: 0
            )

            if isEditing {
                avatarMenu
                    .padding(.top)
            }

            if let photoError {
                Text(photoError)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
        }
    }

    @ViewBuilder
    private var nameContent: some View {
        if isEditing {
            TextField("Name", text: $name)
                .textContentType(.name)
                .submitLabel(.next)
                .focused($focusedField, equals: .name)
                .onSubmit {
                    focusedField = .about
                }
        } else {
            Text(name)
        }
    }

    @ViewBuilder
    private var aboutContent: some View {
        if isEditing {
            TextField(
                "A little about you",
                text: $about,
                axis: .vertical
            )
            .lineLimit(3...6)
            .focused($focusedField, equals: .about)
            .accessibilityLabel("About")
        } else if about.isEmpty {
            Text("A little about you")
                .foregroundStyle(.secondary)
                .accessibilityLabel("About, not set")
        } else {
            Text(about)
                .accessibilityLabel("About, \(about)")
        }
    }

    private var avatarMenu: some View {
        Menu {
            Button {
                isPhotosPickerPresented = true
            } label: {
                Label(
                    "Choose from Photos",
                    systemImage: "photo.on.rectangle"
                )
            }

            Button {
                isFileImporterPresented = true
            } label: {
                Label("Choose from Files", systemImage: "folder")
            }

            Button {
                isWebImagePickerPresented = true
            } label: {
                Label("Find Image on Web", systemImage: "globe")
            }

            if avatar != .monogram {
                Divider()

                Button(role: .destructive) {
                    removePhoto()
                } label: {
                    Label {
                        Text("Remove Photo")
                    } icon: {
                        Image(uiImage: destructiveTrashSymbol)
                    }
                }
            }
        } label: {
            Text(avatar == .monogram ? "Add Photo" : "Change Photo")
        }
        .buttonStyle(.glass)
    }

    private var avatarImage: UIImage? {
        switch avatar {
        case let .asset(name):
            UIImage(named: name)
        case let .webImage(assetName, _):
            UIImage(named: assetName)
        case let .imageData(data):
            UIImage(data: data)
        case .monogram:
            nil
        }
    }

    private var destructiveTrashSymbol: UIImage {
        UIImage(systemName: "trash")?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            ?? UIImage()
    }

    private static func webChoice(
        for avatar: PrototypeAvatar
    ) -> AvatarWebImageChoice? {
        guard case let .webImage(_, choiceID) = avatar else {
            return nil
        }

        return AvatarWebImageCatalog.choice(forID: choiceID)
    }

    private var canFinishEditing: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var canEditProfile: Bool {
        profile.relayConfiguration.isAvailable(for: .profile)
    }

    private var editAccessibilityHint: String {
        if canEditProfile {
            return "Edits this profile."
        }

        return "Check your profile relays before editing this profile."
    }

    private func beginEditing() {
        name = profile.name
        about = profile.about
        avatar = profile.avatar
        selectedWebChoice = Self.webChoice(for: profile.avatar)
        photoError = nil
        isEditing = true
    }

    private func cancelEditing() {
        focusedField = nil
        name = profile.name
        about = profile.about
        avatar = profile.avatar
        selectedPhotoItem = nil
        selectedWebChoice = Self.webChoice(for: profile.avatar)
        photoError = nil
        isEditing = false
    }

    private func finishEditing() {
        guard canFinishEditing else {
            return
        }

        let normalizedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        focusedField = nil
        name = normalizedName
        profile.name = normalizedName
        profile.about = about
        profile.avatar = avatar
        isEditing = false
    }

    private func loadSelectedPhoto() {
        guard let selectedPhotoItem else {
            return
        }

        photoError = nil

        Task {
            defer {
                self.selectedPhotoItem = nil
            }

            do {
                guard
                    let data = try await selectedPhotoItem.loadTransferable(
                        type: Data.self
                    ),
                    let preparedData = ProfileAvatarImageProcessor
                        .preparedData(from: data)
                else {
                    showPhotoError()
                    return
                }

                avatar = .imageData(preparedData)
                selectedWebChoice = nil
            } catch {
                showPhotoError()
            }
        }
    }

    private func handleImportedFile(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let data = try Data(contentsOf: url)
                guard let preparedData = ProfileAvatarImageProcessor
                    .preparedData(from: data) else {
                    showPhotoError()
                    return
                }

                avatar = .imageData(preparedData)
                selectedWebChoice = nil
                selectedPhotoItem = nil
                photoError = nil
            } catch {
                showPhotoError()
            }
        case .failure:
            showPhotoError()
        }
    }

    private func removePhoto() {
        avatar = .monogram
        selectedWebChoice = nil
        selectedPhotoItem = nil
        photoError = nil
    }

    private func useWebImage(_ choice: AvatarWebImageChoice) {
        guard UIImage(named: choice.assetName) != nil else {
            showPhotoError()
            return
        }

        avatar = .webImage(
            assetName: choice.assetName,
            choiceID: choice.id
        )
        selectedWebChoice = choice
        selectedPhotoItem = nil
        photoError = nil
    }

    private func showPhotoError() {
        selectedPhotoItem = nil
        photoError = "Couldn't use that photo. Choose another image and try again."
    }
}

#Preview("Profile Settings") {
    @Previewable @State var profile = PrototypeProfile.marmota

    NavigationStack {
        ProfileSettingsView(profile: $profile)
    }
    .tint(Color("AccentColor"))
}
