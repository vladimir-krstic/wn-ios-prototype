import SwiftUI

@main
struct WhiteNoisePrototypeApp: App {
    var body: some Scene {
        WindowGroup {
            PrototypeRootView()
            .tint(Color("AccentColor"))
        }
    }
}

private struct PrototypeRootView: View {
    @State private var isShowingChats = false
    @State private var isShowingLogin = false
    @State private var isShowingSignUp = false
    @State private var profiles = PrototypeProfile.initialProfiles
    @State private var activeProfileID = PrototypeProfile.mochi.id
    @State private var settings = PrototypeSettingsState()

    var body: some View {
        Group {
            if isShowingChats {
                NavigationStack {
                    ChatsView(
                        chats: activeProfile.chats,
                        profileInitial: activeProfile.initial,
                        settingsDestination: {
                            SettingsView(
                                profiles: $profiles,
                                activeProfileID: $activeProfileID,
                                settings: $settings,
                                onSignOut: signOut,
                                onRemoveProfile: removeProfile
                            )
                        },
                        onNewMessage: {}
                    )
                    .id(activeProfile.id)
                }
            } else {
                NavigationStack {
                    WelcomeView(
                        onLogin: {
                            isShowingLogin = true
                        },
                        onSignUp: {
                            isShowingSignUp = true
                        }
                    )
                }
            }
        }
        .preferredColorScheme(settings.appearance.colorScheme)
        .sheet(isPresented: $isShowingLogin) {
            InitialSignInSheet {
                isShowingLogin = false
                isShowingChats = true
            }
        }
        .sheet(isPresented: $isShowingSignUp) {
            InitialSignUpSheet { name in
                updateInitialProfileName(name)
                isShowingSignUp = false
                isShowingChats = true
            }
        }
    }

    private var activeProfile: PrototypeProfile {
        profiles.first { $0.id == activeProfileID }
            ?? PrototypeProfile.mochi
    }

    private func updateInitialProfileName(_ name: String) {
        let normalizedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !normalizedName.isEmpty,
              let index = profiles.firstIndex(
                where: { $0.id == PrototypeProfile.mochi.id }
              )
        else {
            return
        }

        profiles[index].name = normalizedName
    }

    private func signOut(_ profileID: String) {
        if let nextProfile = profiles.first(where: { $0.id != profileID }) {
            activeProfileID = nextProfile.id
        } else {
            isShowingChats = false
        }
    }

    private func removeProfile(_ profileID: String) {
        profiles.removeAll { $0.id == profileID }

        if let nextProfile = profiles.first {
            activeProfileID = nextProfile.id
        } else {
            isShowingChats = false
        }
    }
}

private struct InitialSignInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDetent = PresentationDetent.medium

    let onSignIn: () -> Void

    var body: some View {
        NavigationStack {
            LoginView(
                onScannerPresentationChange: { isPresented in
                    selectedDetent = isPresented ? .large : .medium
                },
                onSignIn: onSignIn
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .presentationDetents(
            [.medium, .large],
            selection: $selectedDetent
        )
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.resizes)
    }
}

private struct InitialSignUpSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSignUp: (String) -> Void

    var body: some View {
        NavigationStack {
            SignUpView(onSignUp: onSignUp)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel("Close")
                    }
                }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
