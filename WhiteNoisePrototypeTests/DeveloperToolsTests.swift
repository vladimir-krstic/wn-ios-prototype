import Testing
@testable import WhiteNoisePrototype

@Suite("Developer tools")
struct DeveloperToolsTests {
    @Test("Developer tools start disabled for each profile")
    func toolsStartDisabled() {
        let marmota = PrototypeProfile.marmota
        let pebble = PrototypeProfile.pebble

        #expect(!marmota.developerTools.isEnabled)
        #expect(!pebble.developerTools.isEnabled)
        #expect(!marmota.developerTools.debugMode)
        #expect(!marmota.developerTools.anonymousTelemetry)
        #expect(!marmota.developerTools.auditLogging)
    }

    @Test("Developer preferences are independent between profiles")
    func preferencesAreProfileScoped() {
        var marmota = PrototypeProfile.marmota
        var pebble = PrototypeProfile.pebble

        marmota.developerTools.setEnabled(true)
        marmota.developerTools.debugMode = true
        marmota.developerTools.anonymousTelemetry = true

        #expect(marmota.developerTools.isEnabled)
        #expect(marmota.developerTools.debugMode)
        #expect(marmota.developerTools.anonymousTelemetry)
        #expect(!pebble.developerTools.isEnabled)
        #expect(!pebble.developerTools.debugMode)
        #expect(!pebble.developerTools.anonymousTelemetry)

        pebble.developerTools.setEnabled(true)
        pebble.developerTools.auditLogging = true

        #expect(pebble.developerTools.auditLogging)
        #expect(!marmota.developerTools.auditLogging)
    }

    @Test("Disabling developer tools stops features but preserves artifacts")
    func disablingToolsPreservesArtifacts() {
        var tools = PrototypeDeveloperToolsState.fixtures()
        tools.setEnabled(true)
        tools.debugMode = true
        tools.anonymousTelemetry = true
        tools.auditLogging = true
        let files = tools.auditFiles
        let keyPackage = tools.keyPackage

        tools.setEnabled(false)

        #expect(!tools.isEnabled)
        #expect(!tools.debugMode)
        #expect(!tools.anonymousTelemetry)
        #expect(!tools.auditLogging)
        #expect(tools.auditFiles == files)
        #expect(tools.keyPackage == keyPackage)
    }

    @Test("Turning audit logging off preserves existing files")
    func disablingLoggingPreservesFiles() {
        var tools = PrototypeDeveloperToolsState.fixtures()
        tools.auditLogging = true
        let files = tools.auditFiles

        tools.auditLogging = false

        #expect(tools.auditFiles == files)
        #expect(tools.auditFileCount == 2)
        #expect(tools.auditLogTotalByteCount == 32_000)
    }

    @Test("Clearing audit logs preserves files and logging")
    func clearingLogsPreservesFilesAndLogging() {
        var tools = PrototypeDeveloperToolsState.fixtures()
        tools.auditLogging = true
        let originalFiles = tools.auditFiles
        #expect(tools.auditLogsContainData)

        tools.clearAuditLogContents()

        #expect(tools.auditLogging)
        #expect(tools.auditFileCount == originalFiles.count)
        #expect(tools.auditFiles.map(\.id) == originalFiles.map(\.id))
        #expect(
            tools.auditFiles.map(\.filename)
                == originalFiles.map(\.filename)
        )
        #expect(
            tools.auditFiles.map(\.creationDate)
                == originalFiles.map(\.creationDate)
        )
        #expect(tools.auditLogTotalByteCount == 0)
        #expect(!tools.auditLogsContainData)
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

    @Test("Conversation debug records are deterministic and local")
    func conversationDebugRecordsAreDeterministic() {
        let first = PrototypeConversationDebugInfo.fiatjaf(
            messageCount: 11,
            pushDiagnosticsStatus: "Enabled"
        )
        let second = PrototypeConversationDebugInfo.fiatjaf(
            messageCount: 11,
            pushDiagnosticsStatus: "Enabled"
        )
        let support = PrototypeConversationDebugInfo.support(
            messageCount: 1,
            pushDiagnosticsStatus: "Disabled"
        )

        #expect(first == second)
        #expect(first.type == "Direct")
        #expect(first.participantCount == 2)
        #expect(first.routingRelaySummary == "2 chat relays · 2 connected")
        #expect(first.recentEvents.count == 3)
        #expect(support.type == "Support")
        #expect(support.messageCount == 1)
    }

    @Test("Build metadata records the approved integration baseline")
    func buildMetadata() {
        #expect(PrototypeBuildMetadata.builtOn == "MarmotKit (790eb860)")
    }
}
