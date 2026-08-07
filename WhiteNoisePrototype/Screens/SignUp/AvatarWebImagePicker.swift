import SwiftUI

struct AvatarWebImageChoice: Identifiable, Equatable {
    let id: String
    let assetName: String
    let accessibilityLabel: String
}

enum AvatarWebImageCatalog {
    static let choices = [
        AvatarWebImageChoice(
            id: "badger",
            assetName: "FiatjafMediaBadger",
            accessibilityLabel: "Badger"
        ),
        AvatarWebImageChoice(
            id: "3TLl_97HNJo",
            assetName: "AvatarWebAionyHaust",
            accessibilityLabel: "Portrait"
        ),
        AvatarWebImageChoice(
            id: "open-circuit",
            assetName: "ProfileAvatarOpenCircuit",
            accessibilityLabel: "Open circuit"
        ),
        AvatarWebImageChoice(
            id: "fox",
            assetName: "FiatjafMediaFox",
            accessibilityLabel: "Fox"
        ),
        AvatarWebImageChoice(
            id: "rDEOVtE7vOs",
            assetName: "AvatarWebChristopherCampbell",
            accessibilityLabel: "Portrait"
        ),
        AvatarWebImageChoice(
            id: "cipher-wheel",
            assetName: "ProfileAvatarCipherWheel",
            accessibilityLabel: "Cipher wheel"
        ),
        AvatarWebImageChoice(
            id: "marmot",
            assetName: "FiatjafMediaMarmot",
            accessibilityLabel: "Marmot"
        ),
        AvatarWebImageChoice(
            id: "d1UPkiFd04A",
            assetName: "AvatarWebIanDooley",
            accessibilityLabel: "Portrait"
        ),
        AvatarWebImageChoice(
            id: "pebble",
            assetName: "ProfileAvatarPebble",
            accessibilityLabel: "Pebbles"
        ),
        AvatarWebImageChoice(
            id: "ostrich",
            assetName: "FiatjafMediaOstrich",
            accessibilityLabel: "Ostrich"
        ),
        AvatarWebImageChoice(
            id: "c_GmwfHBDzk",
            assetName: "AvatarWebSergioDePaula",
            accessibilityLabel: "Portrait"
        ),
        AvatarWebImageChoice(
            id: "open-quill",
            assetName: "ProfileAvatarOpenQuill",
            accessibilityLabel: "Open quill"
        ),
        AvatarWebImageChoice(
            id: "sloth",
            assetName: "FiatjafMediaSloth",
            accessibilityLabel: "Sloth"
        ),
        AvatarWebImageChoice(
            id: "sibVwORYqs0",
            assetName: "AvatarWebAyoOgunseinde",
            accessibilityLabel: "Portrait"
        ),
        AvatarWebImageChoice(
            id: "free-signal",
            assetName: "ProfileAvatarFreeSignal",
            accessibilityLabel: "Free signal"
        ),
        AvatarWebImageChoice(
            id: "garden-club",
            assetName: "AvatarGardenClub",
            accessibilityLabel: "Garden club"
        ),
        AvatarWebImageChoice(
            id: "j3lf-Jn6deo",
            assetName: "AvatarWebVinceFleming",
            accessibilityLabel: "Portrait"
        ),
        AvatarWebImageChoice(
            id: "liberty-relay",
            assetName: "ProfileAvatarLibertyRelay",
            accessibilityLabel: "Liberty relay"
        ),
        AvatarWebImageChoice(
            id: "public-voice",
            assetName: "ProfileAvatarPublicVoice",
            accessibilityLabel: "Public voice"
        ),
        AvatarWebImageChoice(
            id: "5aGUyCW_PJw",
            assetName: "AvatarWebPhilipMartin",
            accessibilityLabel: "Portrait"
        ),
        AvatarWebImageChoice(
            id: "marmota",
            assetName: "ProfileAvatarMarmota",
            accessibilityLabel: "Marmot portrait"
        ),
    ]

    static func choice(matching input: String) -> AvatarWebImageChoice? {
        let normalizedInput = input.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard let url = URL(string: normalizedInput),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil
        else {
            return nil
        }

        if let exactChoice = choices.first(where: { choice in
            normalizedInput.localizedCaseInsensitiveContains(choice.id)
        }) {
            return exactChoice
        }

        return choices[deterministicOffset(for: normalizedInput)]
    }

    static func results(for query: String) -> [AvatarWebImageChoice] {
        let normalizedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !normalizedQuery.isEmpty else {
            return choices
        }

        let offset = deterministicOffset(for: normalizedQuery)
        return Array(choices[offset...]) + Array(choices[..<offset])
    }

    private static func deterministicOffset(for value: String) -> Int {
        value.unicodeScalars.reduce(0) {
            ($0 + Int($1.value)) % choices.count
        }
    }
}

struct AvatarWebImagePickerView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case search
        case url

        var id: Self { self }

        var title: String {
            switch self {
            case .search: "Search"
            case .url: "URL"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isURLFocused: Bool
    @State private var mode = Mode.search
    @State private var query = ""
    @State private var imageURL = ""
    @State private var selectedChoice: AvatarWebImageChoice?

    let onUseImage: (AvatarWebImageChoice) -> Void

    init(
        currentChoice: AvatarWebImageChoice?,
        onUseImage: @escaping (AvatarWebImageChoice) -> Void
    ) {
        self.onUseImage = onUseImage
        _selectedChoice = State(initialValue: currentChoice)
    }

    var body: some View {
        NavigationStack {
            modeContent
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel("Close")
                    }

                    ToolbarItem(placement: .principal) {
                        Picker("Image Source", selection: $mode) {
                            ForEach(Mode.allCases) { mode in
                                Text(mode.title)
                                    .tag(mode)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.palette)
                        .controlSize(.extraLarge)
                        .frame(width: 180)
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            guard let activeChoice else {
                                return
                            }

                            onUseImage(activeChoice)
                            dismiss()
                        }
                        .disabled(activeChoice == nil)
                    }
                }
                .onChange(of: mode) {
                    isURLFocused = mode == .url
                }
        }
    }

    @ViewBuilder
    private var modeContent: some View {
        switch mode {
        case .search:
            searchContent
                .searchable(
                    text: $query,
                    placement: .automatic,
                    prompt: "Search Images"
                )
        case .url:
            urlContent
        }
    }

    private var searchContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                privacyDisclosure(
                    title: "Search privacy",
                    detail: "Your search is sent to DuckDuckGo. Image providers can see your IP address when results load."
                )
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemBackground))

                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(AvatarWebImageCatalog.results(for: query)) { choice in
                        choiceButton(choice)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var urlContent: some View {
        Form {
            Section {
                privacyDisclosure(
                    title: "Image privacy",
                    detail: "The image provider can see your IP address when the preview loads."
                )
            }

            Section {
                TextField(
                    "https://example.com/image.jpg",
                    text: $imageURL
                )
                .textContentType(.URL)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isURLFocused)
            } header: {
                Text("Image URL")
            } footer: {
                Text(urlHelpText)
            }

            if let urlChoice {
                Section("Preview") {
                    imageTile(urlChoice, showsSelection: true)
                        .listRowInsets(EdgeInsets())
                        .accessibilityLabel(urlChoice.accessibilityLabel)
                        .accessibilityValue("Selected")
                        .accessibilityAddTraits(.isSelected)
                }
            }
        }
        .formStyle(.grouped)
        .scrollDismissesKeyboard(.interactively)
    }

    private func privacyDisclosure(
        title: String,
        detail: String
    ) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "hand.raised")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(title)
                    .foregroundStyle(.primary)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 1),
            count: 3
        )
    }

    private var urlChoice: AvatarWebImageChoice? {
        AvatarWebImageCatalog.choice(matching: imageURL)
    }

    private var activeChoice: AvatarWebImageChoice? {
        switch mode {
        case .search: selectedChoice
        case .url: urlChoice
        }
    }

    private var urlHelpText: String {
        guard !imageURL.isEmpty else {
            return "Enter an image URL."
        }

        return urlChoice == nil
            ? "Enter a valid web address."
            : "Preview shown below."
    }

    private func choiceButton(_ choice: AvatarWebImageChoice) -> some View {
        Button {
            selectedChoice = choice
        } label: {
            imageTile(
                choice,
                showsSelection: selectedChoice == choice
            )
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(choice.accessibilityLabel)
        .accessibilityValue(selectedChoice == choice ? "Selected" : "")
        .accessibilityAddTraits(
            selectedChoice == choice ? .isSelected : []
        )
    }

    private func imageTile(
        _ choice: AvatarWebImageChoice,
        showsSelection: Bool
    ) -> some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(choice.assetName)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                if showsSelection {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)

                        Circle()
                            .stroke(Color.white, lineWidth: 2)

                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 26, height: 26)
                    .padding(6)
                }
            }
    }
}

#Preview("Find Image on Web") {
    AvatarWebImagePickerView(currentChoice: nil) { _ in }
}
