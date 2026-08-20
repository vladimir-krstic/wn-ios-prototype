import Foundation
import Testing
@testable import WhiteNoisePrototype

@Suite("Developer tools")
struct DeveloperToolsTests {
    @Test("Diagnostics summaries describe every independent choice")
    func diagnosticsSummaries() {
        #expect(PrototypeDiagnosticsPreferences().summary == "Off")
        #expect(
            PrototypeDiagnosticsPreferences(
                sharesAnonymousAnalytics: true
            ).summary == "Analytics"
        )
        #expect(
            PrototypeDiagnosticsPreferences(
                savesDiagnosticLogs: true
            ).summary == "Logs"
        )
        #expect(
            PrototypeDiagnosticsPreferences(
                sharesAnonymousAnalytics: true,
                savesDiagnosticLogs: true
            ).summary == "On"
        )
    }

    @Test("Diagnostics choice sheet is recorded independently of opt-ins")
    func diagnosticsChoiceSheetSeenState() {
        var diagnostics = PrototypeDiagnosticsState()

        #expect(!diagnostics.hasPresentedChoices)
        #expect(diagnostics.preferences == PrototypeDiagnosticsPreferences())

        diagnostics.markChoicesPresented()

        #expect(diagnostics.hasPresentedChoices)
        #expect(diagnostics.preferences == PrototypeDiagnosticsPreferences())
    }

    @Test("Developer tools start disabled for each profile")
    func toolsStartDisabled() {
        let marmota = PrototypeProfile.marmota
        let pebble = PrototypeProfile.pebble

        #expect(!marmota.developerTools.isEnabled)
        #expect(!pebble.developerTools.isEnabled)
        #expect(!marmota.developerTools.debugMode)
        #expect(!marmota.diagnostics.preferences.sharesAnonymousAnalytics)
        #expect(!marmota.diagnostics.preferences.savesDiagnosticLogs)
    }

    @Test("Developer preferences are independent between profiles")
    func preferencesAreProfileScoped() {
        var marmota = PrototypeProfile.marmota
        var pebble = PrototypeProfile.pebble

        marmota.developerTools.setEnabled(true)
        marmota.developerTools.debugMode = true
        marmota.diagnostics.apply(
            PrototypeDiagnosticsPreferences(
                sharesAnonymousAnalytics: true
            ),
            profileID: marmota.id,
            profileName: marmota.name
        )

        #expect(marmota.developerTools.isEnabled)
        #expect(marmota.developerTools.debugMode)
        #expect(marmota.diagnostics.preferences.sharesAnonymousAnalytics)
        #expect(!pebble.developerTools.isEnabled)
        #expect(!pebble.developerTools.debugMode)
        #expect(!pebble.diagnostics.preferences.sharesAnonymousAnalytics)

        pebble.developerTools.setEnabled(true)
        pebble.diagnostics.apply(
            PrototypeDiagnosticsPreferences(savesDiagnosticLogs: true),
            profileID: pebble.id,
            profileName: pebble.name
        )

        #expect(pebble.diagnostics.preferences.savesDiagnosticLogs)
        #expect(!marmota.diagnostics.preferences.savesDiagnosticLogs)
    }

    @Test("Disabling developer tools stops features but preserves artifacts")
    func disablingToolsPreservesArtifacts() {
        var tools = PrototypeDeveloperToolsState.fixtures()
        var diagnostics = PrototypeDiagnosticsState()
        tools.setEnabled(true)
        tools.debugMode = true
        diagnostics.apply(
            PrototypeDiagnosticsPreferences(
                sharesAnonymousAnalytics: true,
                savesDiagnosticLogs: true
            ),
            profileID: "marmota",
            profileName: "Marmota"
        )
        let files = diagnostics.auditFiles
        let keyPackage = tools.keyPackage

        tools.setEnabled(false)

        #expect(!tools.isEnabled)
        #expect(!tools.debugMode)
        #expect(diagnostics.preferences.sharesAnonymousAnalytics)
        #expect(diagnostics.preferences.savesDiagnosticLogs)
        #expect(diagnostics.auditFiles == files)
        #expect(tools.keyPackage == keyPackage)
    }

    @Test("Turning audit logging off preserves existing files")
    func disablingLoggingPreservesFiles() {
        var diagnostics = PrototypeDiagnosticsState()
        diagnostics.apply(
            PrototypeDiagnosticsPreferences(savesDiagnosticLogs: true),
            profileID: "marmota",
            profileName: "Marmota"
        )
        let files = diagnostics.auditFiles
        diagnostics.apply(
            PrototypeDiagnosticsPreferences(),
            profileID: "marmota",
            profileName: "Marmota"
        )

        #expect(!diagnostics.preferences.savesDiagnosticLogs)
        #expect(diagnostics.auditFiles == files)
        #expect(diagnostics.auditFileCount == 2)
        #expect(diagnostics.auditLogTotalByteCount == 32_000)
    }

    @Test("Clearing audit logs preserves files and logging")
    func clearingLogsPreservesFilesAndLogging() {
        var diagnostics = PrototypeDiagnosticsState()
        diagnostics.apply(
            PrototypeDiagnosticsPreferences(savesDiagnosticLogs: true),
            profileID: "marmota",
            profileName: "Marmota"
        )
        let originalFiles = diagnostics.auditFiles
        #expect(diagnostics.auditLogsContainData)

        diagnostics.clearAuditLogContents()

        #expect(diagnostics.preferences.savesDiagnosticLogs)
        #expect(diagnostics.auditFileCount == originalFiles.count)
        #expect(diagnostics.auditFiles.map(\.id) == originalFiles.map(\.id))
        #expect(
            diagnostics.auditFiles.map(\.filename)
                == originalFiles.map(\.filename)
        )
        #expect(
            diagnostics.auditFiles.map(\.creationDate)
                == originalFiles.map(\.creationDate)
        )
        #expect(diagnostics.auditLogTotalByteCount == 0)
        #expect(!diagnostics.auditLogsContainData)
    }

    @Test("Diagnostic export contains sanitized retained records")
    func diagnosticExportIsSanitized() {
        var diagnostics = PrototypeDiagnosticsState()
        diagnostics.apply(
            PrototypeDiagnosticsPreferences(savesDiagnosticLogs: true),
            profileID: "marmota",
            profileName: "Marmota"
        )

        let export = diagnostics.diagnosticLogExportText

        #expect(export.contains("White Noise Diagnostic Logs"))
        #expect(export.contains("Log file: 1"))
        #expect(export.contains("info | app.ready"))
        #expect(!export.contains("Marmota"))
        #expect(!export.contains("marmota"))
        #expect(!export.contains("/Users/"))
    }

    @Test("Publishing replaces the single current key package")
    func publishingReplacesKeyPackage() {
        var tools = PrototypeDeveloperToolsState.fixtures()
        let originalPackage = tools.keyPackage

        tools.publishKeyPackage()

        #expect(tools.keyPackage != originalPackage)
        #expect(tools.keyPackage == .publishedFixture)
        #expect(tools.keyPackage.published == "Just now")
    }

    @Test("Conversation debug access follows both profile switches")
    func conversationDebugAccessIsGated() {
        var profile = PrototypeProfile.marmota

        #expect(
            PrototypeConversationDebugAccess.resolve(
                profile: profile,
                chatID: "maya-chen",
                nativePushEnabled: true
            ) == .disabled
        )

        profile.developerTools.setEnabled(true)
        #expect(
            PrototypeConversationDebugAccess.resolve(
                profile: profile,
                chatID: "maya-chen",
                nativePushEnabled: true
            ) == .disabled
        )

        profile.developerTools.debugMode = true
        guard case .enabled = PrototypeConversationDebugAccess.resolve(
            profile: profile,
            chatID: "maya-chen",
            nativePushEnabled: true
        ) else {
            Issue.record("Expected chat debugging to be enabled")
            return
        }
    }

    @Test("Direct and group debug snapshots derive authoritative chat facts")
    func conversationSnapshotsDeriveChatFacts() throws {
        let profile = PrototypeProfile.marmota
        let directChat = try #require(
            profile.chats.first { $0.id == "maya-chen" }
        )
        let groupChat = try #require(
            profile.chats.first { $0.id == "weekend-walks" }
        )
        let direct = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: profile,
                chatID: directChat.id,
                nativePushEnabled: true
            )
        )
        let group = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: profile,
                chatID: groupChat.id,
                nativePushEnabled: true
            )
        )
        let notificationsOff = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: profile,
                chatID: directChat.id,
                nativePushEnabled: false
            )
        )

        #expect(direct.lifecycle == "Active")
        #expect(direct.memberCount == nil)
        #expect(direct.adminCount == nil)
        #expect(direct.relayCount == directChat.routing.relayURLs.count)
        #expect(direct.currentRole == nil)
        #expect(direct.push.notificationsEnabled)
        #expect(direct.push.registrationStatus == "Registered")
        #expect(!notificationsOff.push.notificationsEnabled)
        #expect(notificationsOff.push.registrationStatus == "Not Registered")

        #expect(group.memberCount == groupChat.members.count)
        #expect(
            group.adminCount
                == groupChat.members.filter { $0.role == .admin }.count
        )
        #expect(group.currentRole == "Admin")
        #expect(group.push.staleTokenCount == 1)
        #expect(
            group.requiredEventKinds.map(\.rawValue)
                == [32769, 32771, 32772, 32774, 32777, 32779, 32780]
        )
    }

    @Test("Snapshots are deterministic and reflect isolated chat updates")
    func conversationSnapshotsAreDeterministicAndIsolated() throws {
        var changedProfile = PrototypeProfile.marmota
        let untouchedProfile = PrototypeProfile.marmota
        let original = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: changedProfile,
                chatID: "maya-chen",
                nativePushEnabled: true
            )
        )
        let repeated = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: changedProfile,
                chatID: "maya-chen",
                nativePushEnabled: true
            )
        )
        let chatIndex = try #require(
            changedProfile.chats.firstIndex { $0.id == "maya-chen" }
        )
        changedProfile.chats[chatIndex].listState.membershipState = .left
        changedProfile.chats[chatIndex].routing.relayURLs.removeAll()
        let updated = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: changedProfile,
                chatID: "maya-chen",
                nativePushEnabled: true
            )
        )
        let untouched = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: untouchedProfile,
                chatID: "maya-chen",
                nativePushEnabled: true
            )
        )

        #expect(original == repeated)
        #expect(updated.lifecycle == "Left")
        #expect(updated.relayCount == 0)
        #expect(updated.push.registrationStatus == "Not Registered")
        #expect(updated.push.missingRelayHintCount == 2)
        #expect(untouched == original)

        changedProfile.chats[chatIndex].listState.membershipState = .removed
        let removed = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: changedProfile,
                chatID: "maya-chen",
                nativePushEnabled: true
            )
        )
        #expect(removed.lifecycle == "Removed")
        #expect(removed.memberCount == nil)
    }

    @Test("Copied diagnostic summaries exclude content and sensitive values")
    func diagnosticSummaryIsSanitized() throws {
        let profile = PrototypeProfile.marmota
        let info = try #require(
            PrototypeConversationDebugInfo.snapshot(
                profile: profile,
                chatID: "maya-chen",
                nativePushEnabled: true
            )
        )
        let messageText = try #require(
            profile.chats.first { $0.id == "maya-chen" }?.messages.first?.text
        )
        let unrelatedChatTitle = try #require(
            profile.chats.first { $0.id == "weekend-walks" }?
                .title(people: profile.people)
        )

        #expect(!info.diagnosticSummary.contains(messageText))
        #expect(!info.diagnosticSummary.contains(profile.publicKey))
        #expect(!info.diagnosticSummary.contains(unrelatedChatTitle))
        #expect(!info.diagnosticSummary.contains("npub1"))
        #expect(!info.diagnosticSummary.contains("Messages:"))
        #expect(!info.diagnosticSummary.contains("Protocol Profile"))
        #expect(!info.diagnosticSummary.contains("Push Tokens: 2 total"))
        #expect(info.diagnosticSummary.contains("Required Event Kinds"))
        #expect(info.diagnosticSummary.contains("Notifications: On"))
        #expect(!info.diagnosticSummary.contains("Protocol Activity"))
    }

    @Test("Build metadata records the approved integration baseline")
    func buildMetadata() {
        #expect(PrototypeBuildMetadata.builtOn == "MarmotKit (790eb860)")
    }
}
