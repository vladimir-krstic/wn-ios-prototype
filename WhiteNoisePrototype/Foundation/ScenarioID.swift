enum ScenarioID: String, CaseIterable, Codable, Sendable {
    case onboardingWelcomeDefault = "onboarding.welcome.default"
    case onboardingSignInEmpty = "onboarding.sign-in.empty"
    case onboardingSignInPopulated = "onboarding.sign-in.populated"
    case onboardingSignInInvalid = "onboarding.sign-in.invalid"
    case onboardingSignInExistingProfile = "onboarding.sign-in.existing-profile"
    case onboardingSignInLoading = "onboarding.sign-in.loading"
    case onboardingSignInError = "onboarding.sign-in.error"
    case onboardingSignInOffline = "onboarding.sign-in.offline"
    case onboardingSignInAccessibilityStress = "onboarding.sign-in.accessibility-stress"
    case onboardingQRReady = "onboarding.qr.ready"
    case onboardingQRPermissionDenied = "onboarding.qr.permission-denied"
    case onboardingQRPermissionRestricted = "onboarding.qr.permission-restricted"
    case onboardingQRUnavailable = "onboarding.qr.unavailable"
    case onboardingQRCameraError = "onboarding.qr.camera-error"
    case onboardingQRInvalidCode = "onboarding.qr.invalid-code"
    case onboardingSignUpEmpty = "onboarding.sign-up.empty"
    case onboardingSignUpPopulated = "onboarding.sign-up.populated"
    case onboardingSignUpLoading = "onboarding.sign-up.loading"
    case onboardingSignUpError = "onboarding.sign-up.error"
    case onboardingSignUpPartialError = "onboarding.sign-up.partial-error"
    case onboardingSignUpPhotoUnavailable = "onboarding.sign-up.photo-unavailable"
    case onboardingSignUpAccessibilityStress = "onboarding.sign-up.accessibility-stress"
    case chatsPopulated = "chats.populated"
    case chatsEmpty = "chats.empty"
    case chatsLoading = "chats.loading"
    case chatsOffline = "chats.offline"
    case chatsError = "chats.error"
    case chatsUnread = "chats.unread"
    case chatsArchived = "chats.archived"
    case chatsLongContent = "chats.long-content"
    case chatsAccessibilityStress = "chats.accessibility-stress"
    case creationNewDirectResults = "creation.new-direct.results"
    case creationNewDirectEmpty = "creation.new-direct.empty"
    case creationNewDirectLoading = "creation.new-direct.loading"
    case creationNewDirectError = "creation.new-direct.error"
    case creationNewGroupMembers = "creation.new-group.members"
    case creationNewGroupDetails = "creation.new-group.details"
    case creationNewGroupError = "creation.new-group.error"
    case conversationPopulated = "conversation.populated"
    case conversationEmpty = "conversation.empty"
    case conversationLoading = "conversation.loading"
    case conversationOffline = "conversation.offline"
    case conversationError = "conversation.error"
    case conversationLongContent = "conversation.long-content"
    case conversationFailedSend = "conversation.failed-send"
    case conversationAttachments = "conversation.attachments"
    case conversationVoice = "conversation.voice"
    case conversationAccessibilityStress = "conversation.accessibility-stress"
    case groupDetailsAdmin = "group.details.admin"
    case groupDetailsMember = "group.details.member"
    case groupDetailsLongContent = "group.details.long-content"
    case profilePublicDefault = "profile.public.default"
    case profilePublicLongContent = "profile.public.long-content"
    case settingsDefault = "settings.default"
    case settingsPermissionDenied = "settings.permission-denied"
    case settingsDestructive = "settings.destructive"
    case teamScenarioLabDefault = "team.scenario-lab.default"

    var startScreen: ScreenID {
        switch self {
        case .onboardingWelcomeDefault: .onboardingWelcome
        case .onboardingSignInEmpty, .onboardingSignInPopulated, .onboardingSignInInvalid,
             .onboardingSignInExistingProfile, .onboardingSignInLoading, .onboardingSignInError,
             .onboardingSignInOffline, .onboardingSignInAccessibilityStress:
            .onboardingSignIn
        case .onboardingQRReady, .onboardingQRPermissionDenied, .onboardingQRPermissionRestricted,
             .onboardingQRUnavailable, .onboardingQRCameraError, .onboardingQRInvalidCode:
            .onboardingQRScanner
        case .onboardingSignUpEmpty, .onboardingSignUpPopulated, .onboardingSignUpLoading,
             .onboardingSignUpError, .onboardingSignUpPartialError,
             .onboardingSignUpPhotoUnavailable, .onboardingSignUpAccessibilityStress:
            .onboardingSignUp
        case .chatsPopulated, .chatsEmpty, .chatsLoading, .chatsOffline, .chatsError,
             .chatsUnread, .chatsArchived, .chatsLongContent, .chatsAccessibilityStress:
            .chatsList
        case .creationNewDirectResults, .creationNewDirectEmpty, .creationNewDirectLoading,
             .creationNewDirectError:
            .chatsNewDirect
        case .creationNewGroupMembers: .chatsNewGroupMembers
        case .creationNewGroupDetails, .creationNewGroupError: .chatsNewGroupDetails
        case .conversationPopulated, .conversationEmpty, .conversationLoading,
             .conversationOffline, .conversationError, .conversationLongContent,
             .conversationFailedSend, .conversationAttachments, .conversationVoice,
             .conversationAccessibilityStress:
            .conversationTimeline
        case .groupDetailsAdmin, .groupDetailsMember, .groupDetailsLongContent: .groupDetails
        case .profilePublicDefault, .profilePublicLongContent: .profilePublic
        case .settingsDefault: .settingsHub
        case .settingsPermissionDenied: .settingsNotifications
        case .settingsDestructive: .settingsSignOutRemove
        case .teamScenarioLabDefault: .teamScenarioLab
        }
    }
}
