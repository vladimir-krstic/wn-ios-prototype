import Foundation
import SwiftUI

struct PrototypeConversationDebugInfo: Equatable {
    let identifier: String
    let type: String
    let participantCount: Int
    let messageCount: Int
    let routingRelaySummary: String
    let pushDiagnosticsStatus: String
    let recentEvents: [String]

    static func fiatjaf(
        messageCount: Int,
        pushDiagnosticsStatus: String
    ) -> PrototypeConversationDebugInfo {
        PrototypeConversationDebugInfo(
            identifier: "conversation-fiatjaf-001",
            type: "Direct",
            participantCount: 2,
            messageCount: messageCount,
            routingRelaySummary: "2 chat relays · 2 connected",
            pushDiagnosticsStatus: pushDiagnosticsStatus,
            recentEvents: [
                "18:45:02  timeline projection ready",
                "18:45:04  delivery state synchronized",
                "18:45:06  attachment metadata indexed",
            ]
        )
    }

    static func support(
        messageCount: Int,
        pushDiagnosticsStatus: String
    ) -> PrototypeConversationDebugInfo {
        PrototypeConversationDebugInfo(
            identifier: "conversation-support-001",
            type: "Support",
            participantCount: 2,
            messageCount: messageCount,
            routingRelaySummary: "2 chat relays · 2 connected",
            pushDiagnosticsStatus: pushDiagnosticsStatus,
            recentEvents: [
                "15:02:10  support conversation opened",
                "15:02:11  guidance event projected",
                "15:02:12  composer state ready",
            ]
        )
    }
}

struct ConversationDebugPrototypeView: View {
    let info: PrototypeConversationDebugInfo

    var body: some View {
        Form {
            Section("Conversation") {
                LabeledContent("Identifier", value: info.identifier)
                LabeledContent("Type", value: info.type)
                LabeledContent(
                    "Participants",
                    value: info.participantCount.formatted()
                )
                LabeledContent(
                    "Messages",
                    value: info.messageCount.formatted()
                )
            }

            Section("Delivery") {
                LabeledContent(
                    "Routing Relays",
                    value: info.routingRelaySummary
                )
                LabeledContent(
                    "Push Diagnostics",
                    value: info.pushDiagnosticsStatus
                )
            }

            Section("Recent Events") {
                ForEach(info.recentEvents, id: \.self) { event in
                    Text(event)
                        .font(.caption.monospaced())
                }
            }
        }
        .navigationTitle("Conversation Debug")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DeveloperToolsPrototypeView: View {
    @Binding var developerTools: PrototypeDeveloperToolsState
    let profile: PrototypeProfile
    @State private var isShowingClearLogsConfirmation = false

    var body: some View {
        Form {
            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("For development and testing only")
                            .foregroundStyle(.primary)

                        Text(
                            "These tools can expose technical information "
                                + "and change how the app behaves."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Toggle(
                    "Developer Tools",
                    isOn: developerToolsEnabled
                )
            } footer: {
                Text("Enable technical tools for this profile.")
            }

            if developerTools.isEnabled {
                Section {
                    Toggle(
                        "Debug Mode",
                        isOn: $developerTools.debugMode
                    )

                    NavigationLink {
                        DiagnosticsPrototypeView()
                    } label: {
                        Label("Diagnostics", systemImage: "stethoscope")
                    }
                } header: {
                    Text("Debugging")
                } footer: {
                    Text(
                        "Debug Mode adds technical conversation details "
                            + "intended for development and testing."
                    )
                }

                Section {
                    NavigationLink {
                        KeyPackagesPrototypeView(
                            developerTools: $developerTools
                        )
                    } label: {
                        Label("Key Packages", systemImage: "shippingbox")
                    }
                }

                Section {
                    Toggle(
                        "Anonymous Telemetry",
                        isOn: $developerTools.anonymousTelemetry
                    )
                } header: {
                    Text("Telemetry")
                } footer: {
                    Text(
                        "Shares anonymous reliability and performance data. "
                            + "It doesn’t include messages or profile keys."
                    )
                }

                Section {
                    Toggle(
                        "Audit Logging",
                        isOn: $developerTools.auditLogging
                    )

                    if developerTools.auditLogging {
                        ForEach(developerTools.auditFiles) { file in
                            auditFileRow(file)
                        }

                        Button(
                            "Clear Audit Logs",
                            role: .destructive
                        ) {
                            isShowingClearLogsConfirmation = true
                        }
                        .disabled(!developerTools.auditLogsContainData)
                    }
                } header: {
                    Text("Audit Logging")
                } footer: {
                    Text(
                        "Stores sanitized technical activity locally for "
                            + "troubleshooting. Turning logging off hides "
                            + "the files but keeps them. Clearing removes "
                            + "their contents without deleting the files."
                    )
                }
            }

            Section("About") {
                LabeledContent("Version", value: versionAndBuild)
                LabeledContent(
                    "Built on",
                    value: PrototypeBuildMetadata.builtOn
                )
            }
        }
        .navigationTitle("Developer Tools")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Clear all audit logs?",
            isPresented: $isShowingClearLogsConfirmation
        ) {
            Button("Clear Logs", role: .destructive) {
                developerTools.clearAuditLogContents()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "This removes all recorded activity from the audit log "
                    + "files. The files remain and Audit Logging stays on."
            )
        }
    }

    private var versionAndBuild: String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "—"
        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "—"
        return "\(version) (\(build))"
    }

    private var developerToolsEnabled: Binding<Bool> {
        Binding {
            developerTools.isEnabled
        } set: { isEnabled in
            developerTools.setEnabled(isEnabled)
        }
    }

    private func auditFileRow(_ file: PrototypeAuditFile) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(file.filename)
                .font(.body.monospaced())
                .lineLimit(1)

            Text(fileDetails(file))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func fileDetails(_ file: PrototypeAuditFile) -> String {
        let size = ByteCountFormatter.string(
            fromByteCount: Int64(file.byteCount),
            countStyle: .file
        )
        let date = file.creationDate.formatted(
            date: .abbreviated,
            time: .shortened
        )
        return "\(size) · \(date) · \(file.profileName)"
    }
}

private struct KeyPackagesPrototypeView: View {
    @Binding var developerTools: PrototypeDeveloperToolsState
    @State private var isPublishing = false

    var body: some View {
        Form {
            Section("Current Key Package") {
                keyPackageRow(developerTools.keyPackage)
            }

            Section {
                Button(action: publish) {
                    if isPublishing {
                        HStack {
                            ProgressView()
                                .controlSize(.small)
                            Text("Publishing…")
                        }
                    } else {
                        Label(
                            "Publish New Key Package",
                            systemImage: "shippingbox.and.arrow.backward"
                        )
                    }
                }
                .disabled(isPublishing)
            } footer: {
                Text(
                    "Publishes a new key package so this profile can "
                        + "receive group invitations."
                )
            }
        }
        .navigationTitle("Key Packages")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func keyPackageRow(
        _ package: PrototypeKeyPackage
    ) -> some View {
        VStack(alignment: .leading) {
            Text(package.id)
                .font(.body.monospaced())

            Text("Published \(package.published) · \(package.size)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func publish() {
        guard !isPublishing else {
            return
        }

        isPublishing = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            developerTools.publishKeyPackage()
            isPublishing = false
        }
    }
}

private struct DiagnosticsPrototypeView: View {
    private let consoleContentInset: CGFloat = 20

    @State private var isTesting = false
    @State private var recentEvents = [
        "18:42:10  runtime started",
        "18:42:11  relay connected",
        "18:42:12  profile projection ready",
    ]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Events")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .foregroundStyle(Color(uiColor: .systemGreen))
                        .symbolEffect(
                            .variableColor.iterative,
                            options: .repeating
                        )
                        .accessibilityHidden(true)

                    Text("Live")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Live event stream")
            }
            .padding(.horizontal, consoleContentInset)

            ZStack {
                Color(uiColor: .systemBackground)

                eventContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, consoleContentInset)
                    .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 24,
                    style: .continuous
                )
            )
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Diagnostics")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: test) {
                        Label(
                            isTesting ? "Testing…" : "Test",
                            systemImage: "checkmark.circle"
                        )
                    }
                    .disabled(isTesting)

                    Button {
                        recentEvents.removeAll()
                    } label: {
                        Label("Clear Events", systemImage: "trash")
                    }
                    .disabled(recentEvents.isEmpty)
                } label: {
                    Label("Event Actions", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                }
            }
        }
    }

    @ViewBuilder
    private var eventContent: some View {
        if recentEvents.isEmpty {
            ContentUnavailableView(
                "No Events",
                systemImage: "waveform.path.ecg"
            )
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(recentEvents.indices, id: \.self) { index in
                        Text(recentEvents[index])
                            .font(.caption.monospaced())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical)

                        if index < recentEvents.index(before: recentEvents.endIndex) {
                            Divider()
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func test() {
        guard !isTesting else {
            return
        }

        isTesting = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            recentEvents.append("18:42:15  diagnostic test passed")
            isTesting = false
        }
    }
}

#Preview("Developer Tools") {
    @Previewable @State var developerTools = {
        var state = PrototypeDeveloperToolsState.fixtures()
        state.isEnabled = true
        return state
    }()

    NavigationStack {
        DeveloperToolsPrototypeView(
            developerTools: $developerTools,
            profile: .marmota
        )
    }
}
