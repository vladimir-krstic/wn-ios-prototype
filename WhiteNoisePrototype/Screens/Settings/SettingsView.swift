import SwiftUI

enum SettingsDestination: String, CaseIterable, Hashable {
    case profile
    case profileKeys
    case notifications
    case appearance
    case privacyAndSecurity
    case dataUsage
    case relays
    case support
    case donate
    case developerTools
    case signOut

    var title: String {
        switch self {
        case .profile:
            "Profile"
        case .profileKeys:
            "Profile Keys"
        case .notifications:
            "Notifications"
        case .appearance:
            "Appearance"
        case .privacyAndSecurity:
            "Privacy & Security"
        case .dataUsage:
            "Data Usage"
        case .relays:
            "Relays"
        case .support:
            "Chat with support"
        case .donate:
            "Donate"
        case .developerTools:
            "Developer Tools"
        case .signOut:
            "Sign Out"
        }
    }

    var symbol: String {
        switch self {
        case .profile:
            "person.crop.circle"
        case .profileKeys:
            "key"
        case .notifications:
            "bell"
        case .appearance:
            "circle.lefthalf.filled"
        case .privacyAndSecurity:
            "hand.raised"
        case .dataUsage:
            "externaldrive"
        case .relays:
            "antenna.radiowaves.left.and.right"
        case .support:
            "message"
        case .donate:
            "heart"
        case .developerTools:
            "wrench.and.screwdriver"
        case .signOut:
            "rectangle.portrait.and.arrow.right"
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding private var profiles: [PrototypeProfile]
    @Binding private var activeProfileID: String
    @Binding private var settings: PrototypeSettingsState

    private let onSignOut: (String) -> Void
    private let onRemoveProfile: (String) -> Void

    @State private var isShowingProfileSwitcher = false
    @State private var isShowingAddProfile = false
    @State private var showAddProfileAfterSwitcherCloses = false
    @State private var switchingProfileID: String?
    @State private var switchTask: Task<Void, Never>?

    init(
        profiles: Binding<[PrototypeProfile]>,
        activeProfileID: Binding<String>,
        settings: Binding<PrototypeSettingsState>,
        onSignOut: @escaping (String) -> Void = { _ in },
        onRemoveProfile: @escaping (String) -> Void = { _ in }
    ) {
        _profiles = profiles
        _activeProfileID = activeProfileID
        _settings = settings
        self.onSignOut = onSignOut
        self.onRemoveProfile = onRemoveProfile
    }

    var body: some View {
        Form {
            Section {
                activeProfileNavigationRow
                profileManagementRow
            }

            destinationSection([
                .profile,
                .profileKeys,
                .notifications,
                .appearance,
                .privacyAndSecurity,
                .dataUsage,
                .relays,
            ])

            destinationSection([
                .support,
                .donate,
                .developerTools,
            ])

            Section {
                destinationLink(.signOut)
            } footer: {
                Text(appVersion)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingAddProfile) {
            AddProfileFlow { profile in
                addOrActivate(profile)
            }
        }
        .sheet(
            isPresented: $isShowingProfileSwitcher,
            onDismiss: {
                guard showAddProfileAfterSwitcherCloses else {
                    return
                }

                showAddProfileAfterSwitcherCloses = false
                isShowingAddProfile = true
            }
        ) {
            ProfileSwitcherSheet(
                profiles: profiles,
                activeProfileID: activeProfileID,
                switchingProfileID: switchingProfileID,
                onSelectProfile: switchProfile,
                onAddProfile: beginAddingProfile
            )
        }
        .onDisappear {
            switchTask?.cancel()
        }
    }

    @ViewBuilder
    private var activeProfileNavigationRow: some View {
        if let activeProfile {
            NavigationLink {
                ShareAndConnectView(profile: activeProfile)
            } label: {
                HStack {
                    ProfileSummary(
                        profile: activeProfile,
                        avatarSize: 56
                    )

                    Spacer()

                    Image(systemName: "qrcode")
                        .foregroundStyle(.primary)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityLabel(
                "Open Share and Connect for \(activeProfile.name)"
            )
        }
    }

    @ViewBuilder
    private var profileManagementRow: some View {
        if inactiveProfiles.isEmpty {
            addProfileButton
        } else if inactiveProfiles.count == 1,
                  let alternateProfile = inactiveProfiles.first {
            alternateProfileButton(alternateProfile)
        } else {
            switchProfileButton
        }
    }

    private var addProfileButton: some View {
        Button {
            isShowingAddProfile = true
        } label: {
            Label(
                "Add Profile",
                systemImage: "person.crop.circle.badge.plus"
            )
            .foregroundStyle(.primary)
            .contentShape(.rect)
        }
    }

    private func alternateProfileButton(
        _ profile: PrototypeProfile
    ) -> some View {
        Button {
            isShowingProfileSwitcher = true
        } label: {
            HStack {
                ProfileSummary(
                    profile: profile,
                    avatarSize: 56
                )

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.primary)
            .contentShape(.rect)
        }
        .accessibilityLabel("Switch to \(profile.name)")
        .accessibilityValue(profile.shortPublicKey)
    }

    private var switchProfileButton: some View {
        Button {
            isShowingProfileSwitcher = true
        } label: {
            HStack {
                ProfileAvatarStack(
                    profiles: inactiveProfiles
                )

                Text("Switch Profile")
                    .lineLimit(1)
                    .layoutPriority(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.primary)
            .contentShape(.rect)
        }
        .accessibilityLabel("Switch Profile")
        .accessibilityValue("\(profiles.count) profiles")
    }

    private func destinationSection(
        _ destinations: [SettingsDestination]
    ) -> some View {
        Section {
            ForEach(destinations, id: \.self) { destination in
                destinationLink(destination)
            }
        }
    }

    private func destinationLink(
        _ destination: SettingsDestination
    ) -> some View {
        NavigationLink {
            destinationView(destination)
        } label: {
            SettingsDestinationLabel(destination: destination)
        }
    }

    @ViewBuilder
    private func destinationView(
        _ destination: SettingsDestination
    ) -> some View {
        switch destination {
        case .profile:
            if let activeProfileBinding {
                ProfileSettingsView(profile: activeProfileBinding)
            }
        case .profileKeys:
            if let activeProfile {
                ProfileKeysSettingsView(profile: activeProfile)
            }
        case .notifications:
            NotificationSettingsPrototypeView(settings: $settings)
        case .appearance:
            AppearanceSettingsPrototypeView(settings: $settings)
        case .privacyAndSecurity:
            PrivacySecurityPrototypeView(settings: $settings)
        case .dataUsage:
            DataUsagePrototypeView(settings: $settings)
        case .relays:
            if let activeProfileBinding {
                RelaysPrototypeView(
                    configuration: activeProfileBinding.relayConfiguration
                )
            }
        case .support:
            SupportPrototypeView(
                relayConfiguration:
                    activeProfileBinding?.relayConfiguration
                        ?? .constant(.fixtures)
            )
        case .donate:
            DonatePrototypeView()
        case .developerTools:
            if let activeProfile {
                DeveloperToolsPrototypeView(
                    settings: $settings,
                    profile: activeProfile,
                    profileCount: profiles.count
                )
            }
        case .signOut:
            if let activeProfile {
                SignOutPrototypeView(
                    profile: activeProfile,
                    onSignOut: {
                        onSignOut(activeProfile.id)
                    },
                    onRemoveProfile: {
                        onRemoveProfile(activeProfile.id)
                    }
                )
            }
        }
    }

    private func switchProfile(to profileID: String) {
        guard switchingProfileID == nil,
              profileID != activeProfileID,
              profiles.contains(where: { $0.id == profileID })
        else {
            return
        }

        switchingProfileID = profileID
        switchTask?.cancel()
        switchTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled,
                  profiles.contains(where: { $0.id == profileID })
            else {
                return
            }

            activeProfileID = profileID
            switchingProfileID = nil
            isShowingProfileSwitcher = false
            dismiss()
        }
    }

    private func beginAddingProfile() {
        guard switchingProfileID == nil else {
            return
        }

        showAddProfileAfterSwitcherCloses = true
        isShowingProfileSwitcher = false
    }

    private func addOrActivate(_ profile: PrototypeProfile) {
        if !profiles.contains(where: { $0.id == profile.id }) {
            profiles.append(profile)
        }

        for pseudonym in PrototypeProfile.showcasePseudonyms
        where !profiles.contains(where: { $0.id == pseudonym.id }) {
            profiles.append(pseudonym)
        }

        activeProfileID = profile.id
        isShowingAddProfile = false

        Task {
            await Task.yield()
            dismiss()
        }
    }

    private var activeProfile: PrototypeProfile? {
        profiles.first { $0.id == activeProfileID }
    }

    private var activeProfileBinding: Binding<PrototypeProfile>? {
        guard let index = profiles.firstIndex(
            where: { $0.id == activeProfileID }
        ) else {
            return nil
        }

        return $profiles[index]
    }

    private var inactiveProfiles: [PrototypeProfile] {
        profiles.filter { $0.id != activeProfileID }
    }

    private var appVersion: String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "—"
        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "—"

        return "White Noise · \(version) (\(build))"
    }
}

private struct ProfileSwitcherSheet: View {
    @Environment(\.dismiss) private var dismiss

    let profiles: [PrototypeProfile]
    let activeProfileID: String
    let switchingProfileID: String?
    let onSelectProfile: (String) -> Void
    let onAddProfile: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(orderedProfiles) { profile in
                        Button {
                            onSelectProfile(profile.id)
                        } label: {
                            HStack {
                                ProfileSummary(
                                    profile: profile,
                                    avatarSize: 48
                                )

                                Spacer()

                                trailingState(for: profile)
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .disabled(switchingProfileID != nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaBar(edge: .bottom) {
                Button(action: onAddProfile) {
                    Label(
                        "Add Profile",
                        systemImage: "person.crop.circle.badge.plus"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.extraLarge)
                .disabled(switchingProfileID != nil)
                .padding()
            }
            .scrollEdgeEffectStyle(.soft, for: .bottom)
            .navigationTitle("Switch Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .presentationBackground(
            Color(uiColor: .systemGroupedBackground)
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.resizes)
    }

    @ViewBuilder
    private func trailingState(
        for profile: PrototypeProfile
    ) -> some View {
        if switchingProfileID == profile.id {
            ProgressView()
                .controlSize(.small)
                .accessibilityLabel("Switching profile")
        } else if profile.id == activeProfileID {
            Image(systemName: "checkmark")
                .fontWeight(.semibold)
                .accessibilityLabel("Current profile")
        } else if profile.unreadCount > 0 {
            ProfileUnreadBadge(count: profile.unreadCount)
        }
    }

    private var orderedProfiles: [PrototypeProfile] {
        profiles.filter { $0.id == activeProfileID }
            + profiles.filter { $0.id != activeProfileID }
    }
}

private struct SettingsDestinationLabel: View {
    let destination: SettingsDestination

    var body: some View {
        Label(destination.title, systemImage: destination.symbol)
            .foregroundStyle(
                destination == .signOut ? .red : .primary
            )
    }
}

private struct ProfileUnreadBadge: View {
    let count: Int

    private var label: String {
        count > 99 ? "99+" : count.formatted()
    }

    var body: some View {
        Text(label)
            .font(.caption2.weight(.bold))
            .monospacedDigit()
            .foregroundStyle(Color(uiColor: .systemBackground))
            .padding(.horizontal, 6)
            .frame(minWidth: 22, minHeight: 22)
            .background(Color("AccentColor"), in: Capsule())
            .accessibilityLabel("\(count) unread messages")
    }
}

private struct ProfileAvatarStack: View {
    let profiles: [PrototypeProfile]

    var body: some View {
        HStack(spacing: -10) {
            ForEach(profiles.prefix(3)) { profile in
                ProfileAvatarView(
                    profile: profile,
                    size: 32
                )
                .stackOutline()
            }

            if profiles.count > 3 {
                Text("+\(profiles.count - 3)")
                    .font(.caption2.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
                    .background(
                        Color(uiColor: .systemGray5),
                        in: Circle()
                    )
                    .stackOutline()
            }
        }
        .accessibilityHidden(true)
    }
}

private extension View {
    func stackOutline() -> some View {
        overlay {
            Circle()
                .stroke(
                    Color(uiColor: .secondarySystemGroupedBackground),
                    lineWidth: 2
                )
        }
    }
}

private struct SettingsPreviewHost: View {
    @State private var profiles: [PrototypeProfile]
    @State private var activeProfileID: String
    @State private var settings = PrototypeSettingsState()

    init(
        profiles: [PrototypeProfile] = PrototypeProfile.initialProfiles,
        activeProfileID: String = PrototypeProfile.marmota.id
    ) {
        _profiles = State(initialValue: profiles)
        _activeProfileID = State(initialValue: activeProfileID)
    }

    var body: some View {
        NavigationStack {
            SettingsView(
                profiles: $profiles,
                activeProfileID: $activeProfileID,
                settings: $settings
            )
        }
        .tint(Color("AccentColor"))
    }
}

#Preview("Settings") {
    SettingsPreviewHost()
}

#Preview("Settings — One Profile") {
    SettingsPreviewHost(profiles: [.marmota])
}

#Preview("Settings — Two Profiles") {
    SettingsPreviewHost(
        profiles: [
            .marmota,
            .signedUp(name: "Pebble"),
        ],
        activeProfileID: "added-profile"
    )
}

#Preview("Settings — Seven Profiles") {
    SettingsPreviewHost(
        profiles: PrototypeProfile.postAddProfileFixtures,
        activeProfileID: "added-profile"
    )
}

#Preview("Profile Switcher") {
    ProfileSwitcherSheet(
        profiles: PrototypeProfile.postAddProfileFixtures,
        activeProfileID: "added-profile",
        switchingProfileID: nil,
        onSelectProfile: { _ in },
        onAddProfile: {}
    )
    .tint(Color("AccentColor"))
}

#Preview("Profile Switcher — Switching") {
    ProfileSwitcherSheet(
        profiles: PrototypeProfile.postAddProfileFixtures,
        activeProfileID: "added-profile",
        switchingProfileID: PrototypeProfile.openQuill.id,
        onSelectProfile: { _ in },
        onAddProfile: {}
    )
    .tint(Color("AccentColor"))
}

#Preview("Settings — Open Quill") {
    SettingsAlternateProfilePreview()
}

private struct SettingsAlternateProfilePreview: View {
    @State private var profiles =
        PrototypeProfile.multipleProfileFixtures
    @State private var activeProfileID = PrototypeProfile.openQuill.id
    @State private var settings = PrototypeSettingsState()

    var body: some View {
        NavigationStack {
            SettingsView(
                profiles: $profiles,
                activeProfileID: $activeProfileID,
                settings: $settings
            )
        }
        .tint(Color("AccentColor"))
    }
}

#Preview("Share & Connect") {
    NavigationStack {
        ShareAndConnectView(profile: .marmota)
    }
    .tint(Color("AccentColor"))
}
