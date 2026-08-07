import Testing
@testable import WhiteNoisePrototype

@Suite("Profile lifecycle")
struct ProfileLifecycleTests {
    @Test("Initial Sign Up restores Marmota without borrowing Pebble's identity")
    func initialSignUpUsesMarmotaIdentity() {
        let profile = PrototypeProfile.initialSignUp(name: "Marmota")

        #expect(profile.id == PrototypeProfile.marmota.id)
        #expect(profile.name == "Marmota")
        #expect(profile.avatar == .asset("ProfileAvatarMarmota"))
    }

    @Test("Add Profile Sign Up uses a distinct Pebble identity")
    func addedSignUpUsesPebbleIdentity() {
        let initialProfile = PrototypeProfile.initialSignUp(name: "Marmota")
        let addedProfile = PrototypeProfile.addedSignUp(name: "Pebble")

        #expect(addedProfile.id == PrototypeProfile.pebble.id)
        #expect(addedProfile.id != initialProfile.id)
        #expect(addedProfile.name == "Pebble")
        #expect(addedProfile.avatar == .asset("ProfileAvatarPebble"))
    }

    @Test("Sign Up carries About and an explicit avatar into the profile")
    func signUpCarriesEditableProfileValues() {
        let avatar = PrototypeAvatar.webImage(
            assetName: "AvatarWebAionyHaust",
            choiceID: "3TLl_97HNJo"
        )
        let profile = PrototypeProfile.initialSignUp(
            name: "  River  ",
            about: "Available for quiet conversations.",
            avatar: avatar
        )

        #expect(profile.name == "River")
        #expect(profile.about == "Available for quiet conversations.")
        #expect(profile.avatar == avatar)
    }

    @Test("Re-onboarding updates editable values without replacing local data")
    func reactivationUpdatesOnlyEditableProfileValues() {
        var stored = PrototypeProfile.marmota
        stored.supportMessages = [
            SupportConversationMessage(id: 1, content: .text("Saved locally")),
        ]
        stored.developerTools.setEnabled(true)
        stored.developerTools.debugMode = true
        let relayConfiguration = stored.relayConfiguration
        let avatar = PrototypeAvatar.webImage(
            assetName: "AvatarWebAionyHaust",
            choiceID: "3TLl_97HNJo"
        )
        let reactivated = PrototypeProfile.initialSignUp(
            name: "River",
            about: "A refreshed profile.",
            avatar: avatar
        )

        stored.updateEditableValues(from: reactivated)

        #expect(stored.name == "River")
        #expect(stored.about == "A refreshed profile.")
        #expect(stored.avatar == avatar)
        #expect(stored.supportMessages.count == 1)
        #expect(stored.relayConfiguration == relayConfiguration)
        #expect(stored.developerTools.isConversationDebugEnabled)
    }

    @Test("Wiping then recreating and adding preserves both canonical profiles")
    func wipeRecreateAndAddPreservesProfiles() {
        var profiles = [PrototypeProfile.marmota]
        profiles.removeAll()

        let recreated = PrototypeProfile.initialSignUp(name: "Marmota")
        profiles.append(recreated)

        let added = PrototypeProfile.addedSignUp(name: "Pebble")
        if !profiles.contains(where: { $0.id == added.id }) {
            profiles.append(added)
        }

        #expect(profiles.map(\.id) == ["marmota", "pebble"])
        #expect(
            profiles.first { $0.id == "marmota" }?.avatar
                == .asset("ProfileAvatarMarmota")
        )
        #expect(
            profiles.first { $0.id == "pebble" }?.avatar
                == .asset("ProfileAvatarPebble")
        )
    }
}
