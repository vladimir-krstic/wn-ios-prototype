import Foundation
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
    @Environment(\.editMode) private var editMode
    @State private var isShowingAddRelay = false

    var body: some View {
        Form {
            Section {
                if settings.relays.isEmpty {
                    Text("No relays added")
                        .foregroundStyle(.secondary)
                }

                ForEach(settings.relays) { relay in
                    relayRow(relay)
                        .deleteDisabled(!isEditing)
                }
                .onDelete(perform: deleteRelays)

                if isEditing {
                    Button {
                        isShowingAddRelay = true
                    } label: {
                        Label("Add Relay", systemImage: "plus.circle")
                    }
                }
            } header: {
                Text("Profile Relays")
            } footer: {
                Text(
                    "Relays help White Noise find profiles and exchange messages."
                )
            }

            Section {
                NavigationLink {
                    AdvancedRelaysView(settings: $settings)
                } label: {
                    Label("Advanced", systemImage: "slider.horizontal.3")
                }
            } footer: {
                Text("Choose how White Noise uses each relay.")
            }
        }
        .navigationTitle("Relays")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $isShowingAddRelay) {
            AddRelaySheet(existingRelays: settings.relays) { url in
                addRelay(url)
            }
            .presentationDetents([.medium])
        }
    }

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    private func relayRow(_ relay: PrototypeRelay) -> some View {
        LabeledContent {
            RelayConnectionStatusView(state: relay.connectionState)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(relay.displayName)

                Text(relayDisplayURL(relay))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(relay.displayName), \(relay.url)")
        .accessibilityValue(relayAccessibilityValue(relay))
    }

    private func relayAccessibilityValue(_ relay: PrototypeRelay) -> String {
        let status: String

        switch relay.connectionState {
        case .connected:
            status = "Connected"
        case .reconnecting:
            status = "Reconnecting"
        case .disconnected:
            status = "Disconnected"
        }

        if relay.capability == .readOnly {
            return "\(status), Read Only"
        }

        return status
    }

    private func relayDisplayURL(_ relay: PrototypeRelay) -> String {
        if relay.capability == .readOnly {
            return "\(relay.url) (Read Only)"
        }

        return relay.url
    }

    private func addRelay(_ url: String) {
        let relayID = "custom-\(url.lowercased())"
        let displayName = URL(string: url)?.host ?? "Custom Relay"

        settings.relays.append(
            PrototypeRelay(
                id: relayID,
                displayName: displayName,
                url: url,
                capability: .readWrite,
                connectionState: .reconnecting,
                usages: Set(PrototypeRelayUsage.allCases)
            )
        )

        Task {
            try? await Task.sleep(for: .seconds(1.5))

            guard let relayIndex = settings.relays.firstIndex(
                where: { $0.id == relayID }
            ) else {
                return
            }

            withAnimation {
                settings.relays[relayIndex].connectionState = .connected
            }
        }
    }

    private func deleteRelays(at offsets: IndexSet) {
        settings.relays.remove(atOffsets: offsets)
    }
}

private struct RelayConnectionStatusView: View {
    let state: PrototypeRelayConnectionState

    var body: some View {
        Group {
            switch state {
            case .connected:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)

            case .reconnecting:
                ProgressView()
                    .controlSize(.regular)
                    .tint(.secondary)

            case .disconnected:
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .imageScale(.medium)
        .accessibilityHidden(true)
    }
}

private struct AdvancedRelaysView: View {
    @Binding var settings: PrototypeSettingsState

    var body: some View {
        Form {
            ForEach(PrototypeRelayUsage.allCases) { usage in
                Section {
                    ForEach($settings.relays) { $relay in
                        Button {
                            toggleUsage(for: &relay, usage: usage)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(relay.displayName)
                                        .foregroundStyle(.primary)

                                    Text(relayDisplayURL(relay))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }

                                Spacer()

                                if relay.usages.contains(usage) {
                                    Image(systemName: "checkmark")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .disabled(
                            relay.capability == .readOnly
                                || isOnlySelection(relay, for: usage)
                        )
                        .accessibilityValue(
                            relay.usages.contains(usage)
                                ? "Selected"
                                : "Not selected"
                        )
                    }
                } header: {
                    Text(usage.rawValue)
                } footer: {
                    Text(
                        "\(usage.explanation) Read-only relays can’t be selected. At least one relay must remain selected."
                    )
                }
            }
        }
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func relayDisplayURL(_ relay: PrototypeRelay) -> String {
        if relay.capability == .readOnly {
            return "\(relay.url) (Read Only)"
        }

        return relay.url
    }

    private func isOnlySelection(
        _ relay: PrototypeRelay,
        for usage: PrototypeRelayUsage
    ) -> Bool {
        relay.usages.contains(usage)
            && settings.relays.count { $0.usages.contains(usage) } == 1
    }

    private func toggleUsage(
        for relay: inout PrototypeRelay,
        usage: PrototypeRelayUsage
    ) {
        if relay.usages.contains(usage) {
            relay.usages.remove(usage)
        } else {
            relay.usages.insert(usage)
        }
    }
}

private struct AddRelaySheet: View {
    let existingRelays: [PrototypeRelay]
    let onAdd: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var relayURL = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        "wss://relay.example.com",
                        text: $relayURL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                } header: {
                    Text("Relay URL")
                } footer: {
                    Text("Enter a relay URL beginning with wss://.")
                }
            }
            .navigationTitle("Add Relay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(normalizedRelayURL)
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!canAddRelay)
                }
            }
        }
    }

    private var canAddRelay: Bool {
        guard
            !normalizedRelayURL.contains(where: { $0.isWhitespace }),
            let components = URLComponents(string: normalizedRelayURL),
            components.scheme?.lowercased() == "wss",
            components.host?.isEmpty == false
        else {
            return false
        }

        return !existingRelays.contains {
            normalizedKey(for: $0.url) == normalizedKey(for: normalizedRelayURL)
        }
    }

    private var normalizedRelayURL: String {
        var relay = relayURL.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        while relay.hasSuffix("/") {
            relay.removeLast()
        }

        return relay
    }

    private func normalizedKey(for relay: String) -> String {
        var key = relay.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        while key.hasSuffix("/") {
            key.removeLast()
        }

        return key
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

#Preview("Relays — Edit") {
    @Previewable @State var settings = PrototypeSettingsState()

    NavigationStack {
        RelaysPrototypeView(settings: $settings)
    }
    .environment(\.editMode, .constant(.active))
}
