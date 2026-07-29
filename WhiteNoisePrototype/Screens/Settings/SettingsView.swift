import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

enum SettingsDestination: String, CaseIterable, Hashable {
    case profile
    case profileKeys
    case notifications
    case appearance
    case privacyAndSecurity
    case dataAndStorage
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
        case .dataAndStorage:
            "Data & Storage"
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
        case .dataAndStorage:
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
                .dataAndStorage,
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
        case .dataAndStorage:
            DataStoragePrototypeView(settings: $settings)
        case .relays:
            RelaysPrototypeView(settings: $settings)
        case .support:
            SupportPrototypeView()
        case .donate:
            DonatePrototypeView()
        case .developerTools:
            if let activeProfile {
                DeveloperToolsPrototypeView(
                    settings: $settings,
                    profile: activeProfile
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
                ProfileMonogram(
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

struct ProfileMonogram: View {
    let profile: PrototypeProfile
    let size: CGFloat

    var body: some View {
        Group {
            if let avatarData = profile.avatarData,
               let image = UIImage(data: avatarData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle()
                        .fill(.primary)

                    Text(profile.initial)
                        .font(.headline)
                        .foregroundStyle(.background)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}

struct ProfileSummary: View {
    let profile: PrototypeProfile
    let avatarSize: CGFloat

    var body: some View {
        HStack {
            ProfileMonogram(
                profile: profile,
                size: avatarSize
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(profile.shortPublicKey)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct ShareAndConnectView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case share = "Share"
        case scan = "Connect"

        var id: Self { self }
    }

    @State private var copied = false
    @State private var copyFeedbackTrigger = 0
    @State private var copyResetTask: Task<Void, Never>?
    @State private var mode = Mode.share

    let profile: PrototypeProfile

    private let qrImage: UIImage?

    fileprivate init(profile: PrototypeProfile) {
        self.profile = profile
        qrImage = Self.makeQRCode(
            from: "white-noise-prototype:profile:\(profile.id)"
        )
    }

    var body: some View {
        ZStack {
            if mode == .share {
                shareContent
                    .transition(.opacity)
            } else {
                ProfileCodeScannerView {
                    mode = .share
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .transition(.opacity)
                .ignoresSafeArea()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: mode)
        .navigationTitle("Share & Connect")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            mode == .scan ? .hidden : .automatic,
            for: .navigationBar
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
                .labelsHidden()
                .pickerStyle(.palette)
                .controlSize(.extraLarge)
                .frame(width: 180)
            }

            if mode == .share {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: shareText) {
                        Label(
                            "Share Profile",
                            systemImage: "square.and.arrow.up"
                        )
                        .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: copyFeedbackTrigger)
        .onChange(of: mode) { _, newMode in
            if newMode == .scan {
                resetCopyFeedback()
            }
        }
        .onDisappear {
            resetCopyFeedback()
        }
    }

    private var shareContent: some View {
        Form {
            Section {
                profileHeader
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section {
                qrCodeContent
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }

    private var profileHeader: some View {
        VStack {
            profileAvatar

            Text(profile.name)
                .font(.title2.weight(.semibold))

            glassCopyButton
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }

    private var glassCopyButton: some View {
        Button(action: copyPublicKey) {
            HStack {
                Text(compactPublicKey)
                    .lineLimit(1)
                    .font(.body.monospaced())

                copyStateSymbol
            }
        }
        .buttonStyle(.glass)
        .controlSize(.regular)
        .accessibilityLabel(
            copied ? "Public key copied" : "Copy public key"
        )
        .accessibilityValue(profile.shortPublicKey)
    }

    private var compactPublicKey: String {
        guard profile.publicKey.count > 25 else {
            return profile.publicKey
        }

        return "\(profile.publicKey.prefix(20))…\(profile.publicKey.suffix(4))"
    }

    private var copyStateSymbol: some View {
        Image(systemName: copied ? "checkmark" : "doc.on.doc")
            .contentTransition(.symbolEffect(.replace))
            .animation(.default, value: copied)
    }

    private var profileAvatar: some View {
        GeometryReader { geometry in
            ProfileMonogram(
                profile: profile,
                size: geometry.size.width
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .containerRelativeFrame(
            .horizontal,
            count: 3,
            span: 1,
            spacing: 0
        )
    }

    @ViewBuilder
    private var qrCodeContent: some View {
        VStack(spacing: 4) {
            if let qrImage {
                VStack(spacing: 0) {
                    Image(uiImage: qrImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .containerRelativeFrame(
                            .horizontal,
                            count: 5,
                            span: 4,
                            spacing: 0
                        )
                        .padding([.top, .horizontal], 8)
                        .accessibilityLabel(
                            "\(profile.name)’s profile QR code"
                        )

                    Text("Scan to connect.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 6)
                }
                .padding(.bottom, 8)
                .background(
                    .white,
                    in: RoundedRectangle(
                        cornerRadius: 16,
                        style: .continuous
                    )
                )
            } else {
                ContentUnavailableView(
                    "QR Code Unavailable",
                    systemImage: "qrcode"
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 32)
    }

    private var shareText: String {
        "\(profile.name) on White Noise\n\(profile.publicKey)"
    }

    private func copyPublicKey() {
        UIPasteboard.general.string = profile.publicKey
        copied = true
        copyFeedbackTrigger += 1
        UIAccessibility.post(
            notification: .announcement,
            argument: "Public key copied"
        )

        copyResetTask?.cancel()
        copyResetTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))

            guard !Task.isCancelled else {
                return
            }

            copied = false
            copyResetTask = nil
        }
    }

    private func resetCopyFeedback() {
        copyResetTask?.cancel()
        copyResetTask = nil
        copied = false
    }

    private static func makeQRCode(from payload: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(payload.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let quietZoneExtent = CGRect(
            x: outputImage.extent.minX - 4,
            y: outputImage.extent.minY,
            width: outputImage.extent.width + 8,
            height: outputImage.extent.height + 4
        )
        let whiteBackground = CIImage(
            color: CIColor(red: 1, green: 1, blue: 1)
        )
        .cropped(to: quietZoneExtent)
        let imageWithQuietZone = outputImage.composited(
            over: whiteBackground
        )
        let scaledImage = imageWithQuietZone.transformed(
            by: CGAffineTransform(scaleX: 12, y: 12)
        )
        let context = CIContext()

        guard let image = context.createCGImage(
            scaledImage,
            from: scaledImage.extent
        ) else {
            return nil
        }

        return UIImage(cgImage: image)
    }
}

private struct AddProfileFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingLogin = false
    @State private var isShowingSignUp = false
    @State private var selectedDetent = PresentationDetent.large

    let onCompletion: (PrototypeProfile) -> Void

    var body: some View {
        NavigationStack {
            WelcomeView(
                onLogin: {
                    selectedDetent = .medium
                    isShowingLogin = true
                },
                onSignUp: {
                    selectedDetent = .large
                    isShowingSignUp = true
                }
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingLogin) {
                LoginView(
                    onScannerPresentationChange: { isPresented in
                        selectedDetent = isPresented ? .large : .medium
                    },
                    onInputFocusChange: { isFocused in
                        selectedDetent = isFocused ? .large : .medium
                    },
                    onSignIn: {
                        onCompletion(.openCircuit)
                    }
                )
            }
            .navigationDestination(isPresented: $isShowingSignUp) {
                SignUpView(initialName: "Pebble") { name in
                    onCompletion(.signedUp(name: name))
                }
            }
        }
        .tint(Color("AccentColor"))
        .presentationDetents(
            supportedDetents,
            selection: $selectedDetent
        )
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.resizes)
        .onChange(of: isShowingLogin) {
            if !isShowingLogin {
                selectedDetent = .large
            }
        }
    }

    private var supportedDetents: Set<PresentationDetent> {
        isShowingLogin ? [.medium, .large] : [.large]
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
