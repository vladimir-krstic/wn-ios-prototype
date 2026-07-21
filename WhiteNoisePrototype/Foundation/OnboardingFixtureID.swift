enum OnboardingFixtureID: String, CaseIterable, Codable, Sendable {
    case credentialMayaAccepted = "credential.maya.accepted"
    case credentialMayaExisting = "credential.maya.existing"
    case credentialInvalidComplete = "credential.invalid.complete"
    case qrPrivateKeyMayaAccepted = "qr.private-key.maya.accepted"
    case qrPrivateKeyUnknown = "qr.private-key.unknown"
    case profileQuietPine = "profile.quiet-pine"
}
