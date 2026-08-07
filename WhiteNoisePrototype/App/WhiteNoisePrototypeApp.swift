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
        case profileSwitcher
    }

    private enum OnboardingPresentation: String, Identifiable {
        case signIn
        case signUp
        case addProfile

        var id: Self { self }
    }

    @State private var rootDestination = RootDestination.welcome
    @State private var onboardingPresentation: OnboardingPresentation?
    @State private var profiles = PrototypeProfile.initialProfiles
    @State private var activeProfileID = PrototypeProfile.marmota.id
    @State private var signedInProfileIDs = Set(
        PrototypeProfile.initialProfiles.map(\.id)
    )
    @State private var settings = PrototypeSettingsState()
    @State private var isShowingSettings = false
    @State private var dismissesAddProfileAfterSettingsRemoval = false

    var body: some View {
        Group {
            switch rootDestination {
            case .chats:
                NavigationStack {
                    ChatsView(
                        chats: activeChats,
                        fiatjafMessages:
                            activeProfileBinding.fiatjafMessages,
                        supportMessages:
                            activeProfileBinding.supportMessages,
                        settings: $settings,
                        relayConfiguration:
                            activeProfileBinding.relayConfiguration,
                        developerTools:
                            activeProfileBinding.developerTools,
                        profile: activeProfile,
                        onOpenSettings: {
                            isShowingSettings = true
                        },
                        onNewMessage: {}
                    )
                    .navigationDestination(
                        isPresented: $isShowingSettings
                    ) {
                            SettingsView(
                                profiles: $profiles,
                                activeProfileID: $activeProfileID,
                                signedInProfileIDs: $signedInProfileIDs,
                                settings: $settings,
                                onSignOut: signOut,
                                onWipeProfile: wipeProfile,
                                onEraseAllAppData: eraseAllAppData,
                                onAddProfile: {
                                    onboardingPresentation = .addProfile
                                }
                            )
                    }
                }
            case .profileSwitcher:
                ProfileSwitcherSheet(
                    profiles: signedInProfiles,
                    activeProfileID: nil,
                    showsCloseButton: false,
                    onSelectProfile: activateProfile,
                    onAddProfile: nil
                )
            case .welcome:
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
                InitialSignUpSheet { name, about, avatar in
                    completeInitialSignUp(
                        name: name,
                        about: about,
                        avatar: avatar
                    )
                }
            case .addProfile:
                AddProfileFlow { profile, updatesStoredProfile in
                    completeAddedProfile(
                        profile,
                        updatesStoredProfile: updatesStoredProfile
                    )
                }
            }
        }
        .onChange(of: isShowingSettings) { _, isShowingSettings in
            guard !isShowingSettings,
                  dismissesAddProfileAfterSettingsRemoval
            else {
                return
            }

            dismissesAddProfileAfterSettingsRemoval = false

            Task { @MainActor in
                await Task.yield()
                guard onboardingPresentation == .addProfile else {
                    return
                }
                onboardingPresentation = nil
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
        activateStoredOrNewProfile(.marmota)

        onboardingPresentation = nil
        isShowingSettings = false
        rootDestination = .chats
    }

    private func completeInitialSignUp(
        name: String,
        about: String,
        avatar: PrototypeAvatar?
    ) {
        let profile = PrototypeProfile.initialSignUp(
            name: name,
            about: about,
            avatar: avatar
        )
        activateStoredOrNewProfile(profile, updatesStoredProfile: true)

        onboardingPresentation = nil
        isShowingSettings = false
        rootDestination = .chats
    }

    private func signOut(_ profileID: String) {
        signedInProfileIDs.remove(profileID)
        finishProfileExit()
    }

    private func wipeProfile(_ profileID: String) {
        signedInProfileIDs.remove(profileID)
        profiles.removeAll { $0.id == profileID }
        finishProfileExit()
    }

    private func eraseAllAppData() {
        signedInProfileIDs.removeAll()
        profiles.removeAll()
        activeProfileID = PrototypeProfile.marmota.id
        settings = PrototypeSettingsState()
        onboardingPresentation = nil
        isShowingSettings = false
        rootDestination = .welcome
    }

    private func completeAddedProfile(
        _ profile: PrototypeProfile,
        updatesStoredProfile: Bool
    ) {
        activateStoredOrNewProfile(
            profile,
            updatesStoredProfile: updatesStoredProfile
        )

        for pseudonym in PrototypeProfile.showcasePseudonyms {
            if !profiles.contains(where: { $0.id == pseudonym.id }) {
                profiles.append(pseudonym)
            }
            signedInProfileIDs.insert(pseudonym.id)
        }

        dismissesAddProfileAfterSettingsRemoval = true

        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            rootDestination = .chats
            isShowingSettings = false
        }
    }

    private func activateStoredOrNewProfile(
        _ profile: PrototypeProfile,
        updatesStoredProfile: Bool = false
    ) {
        if let index = profiles.firstIndex(
            where: { $0.id == profile.id }
        ) {
            if updatesStoredProfile {
                profiles[index].updateEditableValues(from: profile)
            }
        } else {
            profiles.append(profile)
        }

        activeProfileID = profile.id
        signedInProfileIDs.insert(profile.id)
    }

    private func finishProfileExit() {
        isShowingSettings = false

        switch ProfileExitRouting.destination(
            remainingSignedInProfileIDs: signedInProfileIDs
        ) {
        case .profileSwitcher:
            rootDestination = .profileSwitcher
        case .welcome:
            rootDestination = .welcome
        }
    }

    private func activateProfile(_ profileID: String) {
        guard profiles.contains(where: { $0.id == profileID }) else {
            return
        }

        signedInProfileIDs.insert(profileID)
        activeProfileID = profileID
        rootDestination = .chats
        isShowingSettings = true
    }

    private var signedInProfiles: [PrototypeProfile] {
        profiles.filter { signedInProfileIDs.contains($0.id) }
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

    let onSignUp: (String, String, PrototypeAvatar?) -> Void

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
