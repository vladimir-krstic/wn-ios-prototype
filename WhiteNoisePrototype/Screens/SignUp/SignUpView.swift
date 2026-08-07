import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct SignUpView: View {
    @State private var name: String
    @State private var about = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var selectedAvatar: PrototypeAvatar?
    @State private var selectedWebChoice: AvatarWebImageChoice?
    @State private var isPhotosPickerPresented = false
    @State private var isFileImporterPresented = false
    @State private var isWebImagePickerPresented = false
    @State private var photoError: String?
    @State private var isSigningUp = false

    @FocusState private var focusedField: Field?

    let onSignUp: (String, PrototypeAvatar?) -> Void

    init(
        initialName: String = "Marmota",
        onSignUp: @escaping (String) -> Void
    ) {
        _name = State(initialValue: initialName)
        self.onSignUp = { name, _ in onSignUp(name) }
    }

    init(
        initialName: String = "Marmota",
        onSignUp: @escaping (String, PrototypeAvatar?) -> Void
    ) {
        _name = State(initialValue: initialName)
        self.onSignUp = onSignUp
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
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .name)
                    .onSubmit {
                        focusedField = .about
                    }
                    .listRowBackground(Color(uiColor: .secondarySystemFill))
            }

            Section("About") {
                TextField(
                    "A little about you",
                    text: $about,
                    axis: .vertical
                )
                .lineLimit(3...6)
                .focused($focusedField, equals: .about)
                .accessibilityLabel("About")
                .listRowBackground(Color(uiColor: .secondarySystemFill))
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button(action: signUp) {
                OnboardingPrimaryActionLabel(
                    title: "Sign Up",
                    isLoading: isSigningUp
                )
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
            .buttonSizing(.flexible)
            .allowsHitTesting(!isSigningUp)
            .accessibilityLabel(isSigningUp ? "Signing Up" : "Sign Up")
            .accessibilityIdentifier("sign-up.create")
            .accessibilityValue(isSigningUp ? "In progress" : "")
            .safeAreaPadding(.horizontal)
            .safeAreaPadding(.bottom)
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
        .onChange(of: selectedPhotoItem) {
            loadSelectedPhoto()
        }
        .sheet(isPresented: $isWebImagePickerPresented) {
            AvatarWebImagePickerView(
                currentChoice: selectedWebChoice,
                onUseImage: useWebImage
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .background(.background)
    }

    private var avatarSection: some View {
        VStack(spacing: 0) {
            avatar
                .containerRelativeFrame(
                    .horizontal,
                    count: 3,
                    span: 1,
                    spacing: 0
                )

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

                if avatarImage != nil {
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
                Text(avatarImage == nil ? "Add Photo" : "Change Photo")
            }
            .buttonStyle(.glass)
            .padding(.top)

            if let photoError {
                Text(photoError)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
        }
    }

    private var avatar: some View {
        ProfileEditorAvatarView(
            name: name,
            image: avatarImage
        )
    }

    private var destructiveTrashSymbol: UIImage {
        UIImage(systemName: "trash")?
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            ?? UIImage()
    }

    private func loadSelectedPhoto() {
        guard let selectedPhotoItem else {
            return
        }

        photoError = nil

        Task {
            do {
                guard
                    let data = try await selectedPhotoItem.loadTransferable(
                        type: Data.self
                    ),
                    let image = UIImage(data: data)
                else {
                    showPhotoError()
                    return
                }

                avatarImage = image
                selectedAvatar = .imageData(data)
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
                guard let image = UIImage(data: data) else {
                    showPhotoError()
                    return
                }

                avatarImage = image
                selectedAvatar = .imageData(data)
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
        avatarImage = nil
        selectedAvatar = nil
        selectedWebChoice = nil
        selectedPhotoItem = nil
        photoError = nil
    }

    private func showPhotoError() {
        avatarImage = nil
        selectedAvatar = nil
        selectedWebChoice = nil
        selectedPhotoItem = nil
        photoError = "Couldn't use that photo. Choose another image and try again."
    }

    private func signUp() {
        guard !isSigningUp else {
            return
        }

        focusedField = nil
        isSigningUp = true

        Task {
            try? await Task.sleep(for: .seconds(2))
            isSigningUp = false
            onSignUp(
                name.trimmingCharacters(in: .whitespacesAndNewlines),
                selectedAvatar
            )
        }
    }

    private func useWebImage(_ choice: AvatarWebImageChoice) {
        guard let image = UIImage(named: choice.assetName) else {
            showPhotoError()
            return
        }

        avatarImage = image
        selectedAvatar = .webImage(
            assetName: choice.assetName,
            choiceID: choice.id
        )
        selectedWebChoice = choice
        selectedPhotoItem = nil
        photoError = nil
    }
}

#Preview("Sign Up — Light") {
    NavigationStack {
        SignUpView(onSignUp: { _ in })
    }
    .tint(Color("AccentColor"))
}

#Preview("Sign Up — Dark") {
    NavigationStack {
        SignUpView(onSignUp: { _ in })
    }
    .tint(Color("AccentColor"))
    .preferredColorScheme(.dark)
}
