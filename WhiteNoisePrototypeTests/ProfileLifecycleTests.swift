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
