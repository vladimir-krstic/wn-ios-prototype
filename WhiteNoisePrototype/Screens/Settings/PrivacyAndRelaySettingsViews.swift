import SwiftUI

struct PrivacySecurityPrototypeView: View {
    @Binding var settings: PrototypeSettingsState
    @State private var isShowingDeleteLogsConfirmation = false

    var body: some View {
        Form {
            Section {
                Toggle(
                    "App Lock",
                    isOn: $settings.appLockEnabled
                )

                if settings.appLockEnabled {
                    Picker("Auto-Lock", selection: $settings.autoLock) {
                        ForEach(PrototypeAutoLock.allCases) { period in
                            Text(period.rawValue)
                                .tag(period)
                        }
                    }
                }
            } header: {
                Text("App Lock")
            } footer: {
                Text(
                    "Hides content in the app switcher and requires unlocking when you return."
                )
            }

            Section {
                Toggle(
                    "Block Screenshots",
                    isOn: $settings.blockScreenshots
                )
            } header: {
                Text("Screen Capture")
            } footer: {
                Text(
                    "Screenshots and recordings show a blank screen. The app-switcher preview is hidden too."
                )
            }

            Section {
                Toggle(
                    "Anonymous Telemetry",
                    isOn: $settings.anonymousTelemetry
                )
            } footer: {
                Text(
                    "Anonymous telemetry helps improve reliability and performance."
                )
            }

            Section {
                Toggle(
                    "Audit Logging",
                    isOn: $settings.auditLogging
                )

                if settings.auditLogging {
                    LabeledContent(
                        "white-noise-audit-01.jsonl",
                        value: "24 KB"
                    )
                    LabeledContent(
                        "white-noise-audit-02.jsonl",
                        value: "8 KB"
                    )

                    Button(
                        "Delete All Audit Logs",
                        role: .destructive
                    ) {
                        isShowingDeleteLogsConfirmation = true
                    }
                } else {
                    Text("No audit logs on this device.")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Audit Logging")
            } footer: {
                Text(
                    "Audit logs are stored locally for troubleshooting and forensic review."
                )
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Delete all audit logs?",
            isPresented: $isShowingDeleteLogsConfirmation
        ) {
            Button("Delete All Audit Logs", role: .destructive) {
                settings.auditLogging = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "This permanently removes every local audit log on this device."
            )
        }
    }
}

struct RelaysPrototypeView: View {
    @Binding var settings: PrototypeSettingsState
    @State private var pendingRelay = ""
    @State private var saved = false

    var body: some View {
        Form {
            Section {
                if settings.relays.isEmpty {
                    Text("No relays added")
                        .foregroundStyle(.secondary)
                }

                ForEach(settings.relays, id: \.self) { relay in
                    Text(relay)
                        .font(.body.monospaced())
                }
                .onDelete(perform: deleteRelays)

                HStack {
                    TextField(
                        "wss://relay.example.com",
                        text: $pendingRelay
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .font(.body.monospaced())

                    Button(action: addRelay) {
                        Label("Add Relay", systemImage: "plus.circle.fill")
                            .labelStyle(.iconOnly)
                    }
                    .disabled(!canAddRelay)
                }

                if saved {
                    Label("Saved", systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                        .font(.callout)
                }
            } header: {
                Text("Profile Relays")
            } footer: {
                Text(
                    "White Noise uses these relays to find your profile and deliver messages."
                )
            }

            Section("Published Relay Lists") {
                DisclosureGroup {
                    relayRows
                } label: {
                    LabeledContent("Profile") {
                        Text(settings.relays.count, format: .number)
                    }
                }

                DisclosureGroup {
                    relayRows
                } label: {
                    LabeledContent("Inbox") {
                        Text(settings.relays.count, format: .number)
                    }
                }
            }
        }
        .navigationTitle("Relays")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
    }

    @ViewBuilder
    private var relayRows: some View {
        if settings.relays.isEmpty {
            Text("Not published")
                .foregroundStyle(.secondary)
        } else {
            ForEach(settings.relays, id: \.self) { relay in
                Text(relay)
                    .font(.caption.monospaced())
            }
        }
    }

    private var canAddRelay: Bool {
        let relay = normalizedRelay
        return relay.hasPrefix("wss://")
            && !settings.relays.contains(relay)
    }

    private var normalizedRelay: String {
        pendingRelay.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addRelay() {
        guard canAddRelay else {
            return
        }

        settings.relays.append(normalizedRelay)
        pendingRelay = ""
        showSavedFeedback()
    }

    private func deleteRelays(at offsets: IndexSet) {
        settings.relays.remove(atOffsets: offsets)
        showSavedFeedback()
    }

    private func showSavedFeedback() {
        saved = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            saved = false
        }
    }
}

#Preview("Privacy & Security") {
    @Previewable @State var settings = PrototypeSettingsState()

    NavigationStack {
        PrivacySecurityPrototypeView(settings: $settings)
    }
}

#Preview("Relays") {
    @Previewable @State var settings = PrototypeSettingsState()

    NavigationStack {
        RelaysPrototypeView(settings: $settings)
    }
}
