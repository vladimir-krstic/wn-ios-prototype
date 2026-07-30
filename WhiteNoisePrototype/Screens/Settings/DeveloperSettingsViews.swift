import SwiftUI
import UIKit

struct DeveloperToolsPrototypeView: View {
    @Binding var settings: PrototypeSettingsState
    @State private var copied = false
    @State private var copyResetTask: Task<Void, Never>?

    let profile: PrototypeProfile
    let profileCount: Int

    var body: some View {
        Form {
            Section("Runtime") {
                LabeledContent("Status", value: "Active")
                LabeledContent("Local Signing", value: "Available")
                LabeledContent("Active Profile", value: profile.name)
                LabeledContent("Runtime", value: "Prototype")
                LabeledContent("MarmotKit", value: "Not connected")
            }

            Section("Identity") {
                Button {
                    UIPasteboard.general.string = fictionalHexKey
                    copied = true
                    scheduleCopyReset()
                } label: {
                    LabeledContent {
                        Label(
                            copied ? "Copied" : "Copy",
                            systemImage: copied
                                ? "checkmark"
                                : "doc.on.doc"
                        )
                    } label: {
                        Text(shortHexKey)
                            .font(.body.monospaced())
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
            }

            Section {
                Toggle(
                    "Developer Mode",
                    isOn: $settings.developerMode
                )

                Toggle(
                    "Streaming Debug",
                    isOn: $settings.streamingDebug
                )
                .disabled(!settings.developerMode)

                NavigationLink {
                    KeyPackagesPrototypeView(settings: $settings)
                } label: {
                    Label("Key Packages", systemImage: "shippingbox")
                }

                NavigationLink {
                    DiagnosticsPrototypeView(
                        settings: settings,
                        profileCount: profileCount
                    )
                } label: {
                    Label("Diagnostics", systemImage: "stethoscope")
                }
            } footer: {
                Text(
                    "Developer tools can expose technical event and profile details on this device."
                )
            }

            Section("Build") {
                LabeledContent("Version", value: version)
                LabeledContent("Build", value: build)
                LabeledContent("SDK", value: "iOS 27")
            }
        }
        .navigationTitle("Developer Tools")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            copyResetTask?.cancel()
        }
    }

    private var fictionalHexKey: String {
        "7a4c1e8d9f3206b5a7d4c8e1f9032b6a5d7c4e8f1a9b3d6c2e5f7081a4b9c3d6"
    }

    private var shortHexKey: String {
        "\(fictionalHexKey.prefix(10))…\(fictionalHexKey.suffix(6))"
    }

    private var version: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "—"
    }

    private var build: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "—"
    }

    private func scheduleCopyReset() {
        copyResetTask?.cancel()
        copyResetTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else {
                return
            }

            copied = false
            copyResetTask = nil
        }
    }
}

private struct KeyPackagesPrototypeView: View {
    @Binding var settings: PrototypeSettingsState
    @State private var isPublishing = false

    var body: some View {
        Form {
            if settings.keyPackages.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Key Packages",
                        systemImage: "shippingbox"
                    )
                }
                .listRowBackground(Color.clear)
            } else {
                Section("Published from This Device") {
                    ForEach(settings.keyPackages) { package in
                        keyPackageRow(package)
                    }
                    .onDelete { offsets in
                        settings.keyPackages.remove(atOffsets: offsets)
                    }
                }
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
                            systemImage: "plus.square.on.square"
                        )
                    }
                }
                .disabled(isPublishing)
            } footer: {
                Text(
                    "Key packages let another profile invite this profile to a group."
                )
            }
        }
        .navigationTitle("Key Packages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
    }

    private func keyPackageRow(
        _ package: PrototypeKeyPackage
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(package.id)
                    .font(.body.monospaced())
                Spacer()
                Text(package.location.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("\(package.published) · \(package.size)")
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
            settings.keyPackages.insert(
                PrototypeKeyPackage(
                    id: "d48e1a7c9b320f",
                    published: "Just now",
                    size: "4 KB",
                    location: .synced
                ),
                at: 0
            )
            isPublishing = false
        }
    }
}

private struct DiagnosticsPrototypeView: View {
    @State private var isRefreshing = false
    @State private var isRunningSelfCheck = false
    @State private var selfCheckPassed = false

    let settings: PrototypeSettingsState
    let profileCount: Int

    var body: some View {
        Form {
            Section("Relay Health") {
                LabeledContent(
                    "Total",
                    value: settings.relays.count.formatted()
                )
                LabeledContent(
                    "Connected",
                    value: relayCount(for: .connected).formatted()
                )
                LabeledContent(
                    "Connecting",
                    value: relayCount(for: .reconnecting).formatted()
                )
                LabeledContent(
                    "Disconnected",
                    value: relayCount(for: .disconnected).formatted()
                )
                LabeledContent("Connection Attempts", value: "6")
                LabeledContent("Successful Connections", value: "5")

                Button(action: refresh) {
                    if isRefreshing {
                        HStack {
                            ProgressView()
                                .controlSize(.small)
                            Text("Refreshing…")
                        }
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(isRefreshing)
            }

            Section("Runtime") {
                LabeledContent("Active Profiles", value: "1")
                LabeledContent(
                    "Stored Profiles",
                    value: profileCount.formatted()
                )
                LabeledContent("Bootstrap Relays", value: "2")
            }

            Section("Self Check") {
                Button(action: runSelfCheck) {
                    if isRunningSelfCheck {
                        HStack {
                            ProgressView()
                                .controlSize(.small)
                            Text("Running…")
                        }
                    } else {
                        Label(
                            selfCheckPassed
                                ? "Run Again"
                                : "Run Self Check",
                            systemImage: selfCheckPassed
                                ? "checkmark.circle"
                                : "paperplane"
                        )
                    }
                }
                .disabled(isRunningSelfCheck)

                if selfCheckPassed {
                    Label(
                        "Self check passed.",
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                }
            }

            Section("Recent Events") {
                Text("18:42:10  runtime started")
                Text("18:42:11  relay connected")
                Text("18:42:12  profile projection ready")
            }
            .font(.caption.monospaced())
        }
        .navigationTitle("Diagnostics")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func refresh() {
        isRefreshing = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            isRefreshing = false
        }
    }

    private func runSelfCheck() {
        isRunningSelfCheck = true
        selfCheckPassed = false
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            isRunningSelfCheck = false
            selfCheckPassed = true
        }
    }

    private func relayCount(
        for state: PrototypeRelayConnectionState
    ) -> Int {
        settings.relays.count { $0.connectionState == state }
    }
}

#Preview("Developer Tools") {
    @Previewable @State var settings = PrototypeSettingsState()

    NavigationStack {
        DeveloperToolsPrototypeView(
            settings: $settings,
            profile: .marmota,
            profileCount: 7
        )
    }
}
