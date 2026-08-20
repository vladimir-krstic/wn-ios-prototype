import Foundation

struct PrototypeDiagnosticsPreferences: Equatable {
    var sharesAnonymousAnalytics = false
    var savesDiagnosticLogs = false

    var summary: String {
        switch (sharesAnonymousAnalytics, savesDiagnosticLogs) {
        case (false, false):
            "Off"
        case (true, false):
            "Analytics"
        case (false, true):
            "Logs"
        case (true, true):
            "On"
        }
    }
}

struct PrototypeAuditFile: Identifiable, Equatable {
    let id: String
    let filename: String
    var byteCount: Int
    let creationDate: Date
    let profileName: String

    static func fixtures(
        profileID: String,
        profileName: String
    ) -> [PrototypeAuditFile] {
        [
            PrototypeAuditFile(
                id: "audit-\(profileID)-01",
                filename: "audit-\(profileID)-20260806-01.jsonl",
                byteCount: 24_000,
                creationDate: Date(timeIntervalSince1970: 1_786_022_820),
                profileName: profileName
            ),
            PrototypeAuditFile(
                id: "audit-\(profileID)-02",
                filename: "audit-\(profileID)-20260805-01.jsonl",
                byteCount: 8_000,
                creationDate: Date(timeIntervalSince1970: 1_785_917_640),
                profileName: profileName
            ),
        ]
    }
}

struct PrototypeDiagnosticsState: Equatable {
    private(set) var preferences = PrototypeDiagnosticsPreferences()
    private(set) var hasPresentedChoices = false
    var auditFiles: [PrototypeAuditFile] = []

    init(
        preferences: PrototypeDiagnosticsPreferences =
            PrototypeDiagnosticsPreferences(),
        hasPresentedChoices: Bool = false,
        auditFiles: [PrototypeAuditFile] = []
    ) {
        self.preferences = preferences
        self.hasPresentedChoices = hasPresentedChoices
        self.auditFiles = auditFiles
    }

    var auditFileCount: Int {
        auditFiles.count
    }

    var auditLogTotalByteCount: Int {
        auditFiles.reduce(0) { partialResult, file in
            partialResult + file.byteCount
        }
    }

    var auditLogsContainData: Bool {
        auditFiles.contains { file in
            file.byteCount > 0
        }
    }

    var diagnosticLogExportText: String {
        var lines = [
            "White Noise Diagnostic Logs",
            "Sanitized local troubleshooting records.",
        ]

        let filesWithData = auditFiles.filter { file in
            file.byteCount > 0
        }

        for (index, file) in filesWithData.enumerated() {
            let created = file.creationDate.formatted(.iso8601)
            lines.append(contentsOf: [
                "",
                "Log file: \(index + 1)",
                "Created: \(created)",
                "Recorded size: \(file.byteCount) bytes",
            ])

            lines.append(contentsOf: [
                "info | app.ready",
                "info | relay.connected",
                "info | message.pipeline.ready",
            ])
        }

        return lines.joined(separator: "\n") + "\n"
    }

    mutating func apply(
        _ preferences: PrototypeDiagnosticsPreferences,
        profileID: String,
        profileName: String
    ) {
        let beginsLogging = !self.preferences.savesDiagnosticLogs
            && preferences.savesDiagnosticLogs

        self.preferences = preferences

        if beginsLogging && auditFiles.isEmpty {
            auditFiles = PrototypeAuditFile.fixtures(
                profileID: profileID,
                profileName: profileName
            )
        }
    }

    mutating func clearAuditLogContents() {
        for index in auditFiles.indices {
            auditFiles[index].byteCount = 0
        }
    }

    mutating func markChoicesPresented() {
        hasPresentedChoices = true
    }
}
