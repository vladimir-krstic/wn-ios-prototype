import Testing
@testable import WhiteNoisePrototype

@Suite("Prototype foundation")
@MainActor
struct FoundationTests {
    @Test("Default launch is Welcome with live system mode")
    func defaultLaunch() {
        #expect(LaunchConfiguration.default.scenarioID == .onboardingWelcomeDefault)
        #expect(LaunchConfiguration.default.systemMode == .live)
        #expect(LaunchConfiguration.default.isUITesting == false)
    }

    @Test("UI testing forces simulated system capabilities")
    func uiTestingLaunch() {
        let configuration = LaunchConfiguration.parse(arguments: [
            "WhiteNoisePrototype",
            "-WNScenario", "chats.populated",
            "-WNSystemMode", "live",
            "-WNUITesting"
        ])

        #expect(configuration.scenarioID == .chatsPopulated)
        #expect(configuration.systemMode == .simulated)
        #expect(configuration.isUITesting)
    }

    @Test("Fixtures use the fixed clock and stable IDs")
    func deterministicFixtures() {
        let first = PrototypeState.seed(for: .chatsPopulated)
        let second = PrototypeState.seed(for: .chatsPopulated)

        #expect(first == second)
        #expect(first.fixedClock == FixtureUniverse.fixedClock)
        #expect(first.people.first?.id == "person.maya")
    }

    @Test("Reset recreates the selected scenario")
    func reset() {
        let store = PrototypeStore(scenarioID: .chatsPopulated)
        store.send(.markChatRead("chat.maya-noor"))
        #expect(store.state.chats.first?.unreadCount == 0)

        store.send(.reset)
        #expect(store.state.chats.first?.unreadCount == 1)
        #expect(store.state.scenarioID == .chatsPopulated)
    }

    @Test("Onboarding fixtures classify only at the fixed completion threshold")
    func onboardingCredentialFixtures() {
        let fixtures = FixtureUniverse.Onboarding.self

        #expect(fixtures.acceptedCredential.count == fixtures.credentialCompletionLength)
        #expect(fixtures.existingProfileCredential.count == fixtures.credentialCompletionLength)
        #expect(fixtures.invalidCompleteCredential.count == fixtures.credentialCompletionLength)
        #expect(fixtures.classifyCredential(String(fixtures.acceptedCredential.dropLast())) == .neutral)
        #expect(fixtures.classifyCredential(fixtures.acceptedCredential) == .accepted(profileID: "profile.maya"))
        #expect(fixtures.classifyCredential(fixtures.existingProfileCredential) == .existingProfile(profileID: "profile.maya"))
        #expect(fixtures.classifyCredential(fixtures.invalidCompleteCredential) == .invalid)
        #expect(fixtures.classifyCredential(fixtures.acceptedCredential + "X") == .invalid)
    }

    @Test("Onboarding QR and empty-name Profile fixtures stay deterministic")
    func onboardingOutcomeFixtures() {
        let fixtures = FixtureUniverse.Onboarding.self

        #expect(fixtures.classifyQRCodePayload(fixtures.acceptedQRCodePayload) == .accepted(profileID: "profile.maya"))
        #expect(fixtures.classifyQRCodePayload(fixtures.invalidQRCodePayload) == .invalid)
        #expect(fixtures.defaultSignUpPerson.name == "Quiet Pine")
        #expect(fixtures.defaultSignUpInitials == "QP")
        #expect(fixtures.defaultSignUpProfile.id == OnboardingFixtureID.profileQuietPine.rawValue)
        #expect(fixtures.defaultSignUpProfile.personID == fixtures.defaultSignUpPerson.id)
    }
}
