import SwiftUI

struct SignOutPrototypeView: View {
    @State private var confirmation: SignOutConfirmation?
    @State private var progress: SignOutProgress?

    let profile: PrototypeProfile
    let onSignOut: () -> Void
    let onRemoveProfile: () -> Void

    var body: some View {
        Group {
            if let progress {
                ContentUnavailableView {
                    ProgressView()
                } description: {
                    Text(progress.label)
                }
                .interactiveDismissDisabled()
            } else {
                Form {
                    Section {
                        Button {
                            confirmation = .signOut
                        } label: {
                            choiceLabel(
                                title: "Sign Out",
                                detail: "Keep this profile, its chats, and settings on this device.",
                                symbol: "rectangle.portrait.and.arrow.right"
                            )
                        }
                        .foregroundStyle(.primary)

                        Button(role: .destructive) {
                            confirmation = .remove
                        } label: {
                            choiceLabel(
                                title: "Sign Out and Remove Data",
                                detail: "Permanently remove this profile and its local data from this device.",
                                symbol: "trash"
                            )
                        }
                    } header: {
                        ProfileSummary(
                            profile: profile,
                            avatarSize: 48
                        )
                    } footer: {
                        Text(
                            "Choose whether to keep this profile on this device or remove its local data."
                        )
                    }
                }
            }
        }
        .navigationTitle("Sign Out")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Sign out of \(profile.name)?",
            isPresented: Binding {
                confirmation == .signOut
            } set: { presented in
                if !presented {
                    confirmation = nil
                }
            },
            titleVisibility: .visible
        ) {
            Button("Sign Out") {
                run(.signingOut)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "You can select this profile again without importing its private key."
            )
        }
        .confirmationDialog(
            "Sign out and remove \(profile.name)?",
            isPresented: Binding {
                confirmation == .remove
            } set: { presented in
                if !presented {
                    confirmation = nil
                }
            },
            titleVisibility: .visible
        ) {
            Button("Sign Out and Remove Data", role: .destructive) {
                run(.removing)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "This permanently removes this profile and its local chats, media, drafts, keys, settings, and audit data from this device. You'll leave your groups, and this history can't be recovered. You can sign in again with your private key."
            )
        }
    }

    private func choiceLabel(
        title: String,
        detail: String,
        symbol: String
    ) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(title)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: symbol)
        }
    }

    private func run(_ nextProgress: SignOutProgress) {
        confirmation = nil
        progress = nextProgress

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            switch nextProgress {
            case .signingOut:
                onSignOut()
            case .removing:
                onRemoveProfile()
            }
        }
    }
}

private enum SignOutConfirmation {
    case signOut
    case remove
}

private enum SignOutProgress {
    case signingOut
    case removing

    var label: String {
        switch self {
        case .signingOut: "Signing Out…"
        case .removing: "Removing Profile…"
        }
    }
}

#Preview("Sign Out") {
    NavigationStack {
        SignOutPrototypeView(
            profile: .marmota,
            onSignOut: {},
            onRemoveProfile: {}
        )
    }
}
