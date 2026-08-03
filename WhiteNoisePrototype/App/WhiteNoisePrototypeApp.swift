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
    private enum RootDestination {
        case welcome
        case chats
    }

    private enum OnboardingPresentation: String, Identifiable {
        case signIn
        case signUp

        var id: Self { self }
    }

    @State private var rootDestination = RootDestination.welcome
    @State private var onboardingPresentation: OnboardingPresentation?
    @State private var profiles = PrototypeProfile.initialProfiles
    @State private var activeProfileID = PrototypeProfile.marmota.id
    @State private var settings = PrototypeSettingsState()

    var body: some View {
        Group {
            if rootDestination == .chats {
                NavigationStack {
                    ChatsView(
                        chats: activeChats,
                        settings: $settings,
                        relayConfiguration:
                            activeProfileBinding.relayConfiguration,
                        profile: activeProfile,
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
                            onboardingPresentation = .signIn
                        },
                        onSignUp: {
                            onboardingPresentation = .signUp
                        }
                    )
                }
            }
        }
        .preferredColorScheme(settings.appearance.colorScheme)
        .sheet(item: $onboardingPresentation) { presentation in
            switch presentation {
            case .signIn:
                InitialSignInSheet {
                    completeInitialSignIn()
                }
            case .signUp:
                InitialSignUpSheet { name in
                    completeInitialSignUp(name: name)
                }
            }
        }
    }

    private var activeProfile: PrototypeProfile {
        profiles.first { $0.id == activeProfileID }
            ?? PrototypeProfile.marmota
    }

    private var activeProfileBinding: Binding<PrototypeProfile> {
        Binding {
            activeProfile
        } set: { profile in
            guard let index = profiles.firstIndex(
                where: { $0.id == activeProfileID }
            ) else {
                return
            }

            profiles[index] = profile
        }
    }

    private var activeChats: Binding<[ChatListItem]> {
        Binding {
            guard let index = profiles.firstIndex(
                where: { $0.id == activeProfileID }
            ) else {
                return []
            }

            return profiles[index].chats
        } set: { chats in
            guard let index = profiles.firstIndex(
                where: { $0.id == activeProfileID }
            ) else {
                return
            }

            profiles[index].chats = chats
        }
    }

    private func completeInitialSignIn() {
        if profiles.isEmpty {
            profiles = [.marmota]
            activeProfileID = PrototypeProfile.marmota.id
        } else if !profiles.contains(where: { $0.id == activeProfileID }),
                  let firstProfile = profiles.first {
            activeProfileID = firstProfile.id
        }

        onboardingPresentation = nil
        rootDestination = .chats
    }

    private func completeInitialSignUp(name: String) {
        if profiles.isEmpty {
            let profile = PrototypeProfile.signedUp(name: name)
            profiles = [profile]
            activeProfileID = profile.id
        } else {
            updateInitialProfileName(name)
        }

        onboardingPresentation = nil
        rootDestination = .chats
    }

    private func updateInitialProfileName(_ name: String) {
        let normalizedName = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !normalizedName.isEmpty,
              let index = profiles.firstIndex(
                where: { $0.id == PrototypeProfile.marmota.id }
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
            rootDestination = .welcome
        }
    }

    private func removeProfile(_ profileID: String) {
        profiles.removeAll { $0.id == profileID }

        if let nextProfile = profiles.first {
            activeProfileID = nextProfile.id
        } else {
            rootDestination = .welcome
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
                onInputFocusChange: { isFocused in
                    selectedDetent = isFocused ? .large : .medium
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
