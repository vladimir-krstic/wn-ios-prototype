import Foundation
import SwiftUI

struct DiagnosticsAndImprovementsPromptSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var profile: PrototypeProfile

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(
                        "Share Anonymous Analytics",
                        isOn: analyticsBinding
                    )

                    Toggle(
                        "Share Diagnostic Logs",
                        isOn: loggingBinding
                    )
                } header: {
                    Text(
                        "Help us make messaging without a central point "
                            + "of control more reliable. Anonymous "
                            + "analytics and diagnostic logs are optional "
                            + "and can be changed in Settings."
                    )
                    .font(.body)
                    .foregroundStyle(.primary)
                    .textCase(nil)
                    .padding(.bottom)
                } footer: {
                    Text(
                        "Analytics never include messages, media, "
                            + "contacts, profile details, or keys. "
                            + "Diagnostic logs obscure identifiers and "
                            + "are securely sent "
                            + "to White Noise for troubleshooting."
                    )
                }
            }
            .navigationTitle("Help Improve White Noise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    private var analyticsBinding: Binding<Bool> {
        preferenceBinding(\.sharesAnonymousAnalytics)
    }

    private var loggingBinding: Binding<Bool> {
        preferenceBinding(\.savesDiagnosticLogs)
    }

    private func preferenceBinding(
        _ keyPath: WritableKeyPath<PrototypeDiagnosticsPreferences, Bool>
    ) -> Binding<Bool> {
        Binding {
            profile.diagnostics.preferences[keyPath: keyPath]
        } set: { isEnabled in
            var preferences = profile.diagnostics.preferences
            preferences[keyPath: keyPath] = isEnabled
            profile.diagnostics.apply(
                preferences,
                profileID: profile.id,
                profileName: profile.name
            )
        }
    }
}

struct DiagnosticsAndImprovementsSettingsView: View {
    @Binding var profile: PrototypeProfile
    @State private var isShowingClearLogsConfirmation = false

    var body: some View {
        Form {
            DiagnosticsPreferenceSections(
                preferences: preferencesBinding
            )

            if profile.diagnostics.auditFileCount > 0 {
                Section {
                    LabeledContent(
                        "On This iPhone",
                        value: storedDiagnosticLogSize
                    )

                    Button("Clear Diagnostic Logs", role: .destructive) {
                        isShowingClearLogsConfirmation = true
                    }
                    .disabled(!profile.diagnostics.auditLogsContainData)
                } header: {
                    Text("Stored Diagnostic Logs")
                } footer: {
                    Text(
                        "Turning logging off keeps existing logs until "
                            + "you clear them."
                    )
                }
            }
        }
        .navigationTitle("Diagnostics & Improvements")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Clear diagnostic logs?",
            isPresented: $isShowingClearLogsConfirmation
        ) {
            Button("Clear Logs", role: .destructive) {
                profile.diagnostics.clearAuditLogContents()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "This permanently removes all recorded diagnostic "
                    + "activity from this iPhone. Your logging "
                    + "preference won’t change."
            )
        }
    }

    private var preferencesBinding: Binding<PrototypeDiagnosticsPreferences> {
        Binding {
            profile.diagnostics.preferences
        } set: { preferences in
            profile.diagnostics.apply(
                preferences,
                profileID: profile.id,
                profileName: profile.name
            )
        }
    }

    private var storedDiagnosticLogSize: String {
        guard profile.diagnostics.auditLogTotalByteCount > 0 else {
            return "None"
        }

        return ByteCountFormatter.string(
            fromByteCount: Int64(
                profile.diagnostics.auditLogTotalByteCount
            ),
            countStyle: .file
        )
    }
}

private struct DiagnosticsPreferenceSections: View {
    @Binding var preferences: PrototypeDiagnosticsPreferences

    var body: some View {
        Section {
            Toggle(
                "Share Anonymous Analytics",
                isOn: $preferences.sharesAnonymousAnalytics
            )
        } footer: {
            Text(
                "Shares anonymous reliability, performance, and "
                    + "feature-use data to help improve White Noise. "
                    + "Messages, media, contacts, profile details, "
                    + "and keys are never included."
            )
        }

        Section {
            Toggle(
                "Share Diagnostic Logs",
                isOn: $preferences.savesDiagnosticLogs
            )
        } footer: {
            Text(
                "Sends sanitized technical activity to White Noise "
                    + "to help troubleshoot problems. Message content "
                    + "is excluded and identifiers are obscured."
            )
        }
    }
}

#Preview("Diagnostics & Improvements — Prompt") {
    @Previewable @State var profile = PrototypeProfile.marmota

    DiagnosticsAndImprovementsPromptSheet(profile: $profile)
}

#Preview("Diagnostics & Improvements — Settings") {
    @Previewable @State var profile = PrototypeProfile.marmota

    NavigationStack {
        DiagnosticsAndImprovementsSettingsView(profile: $profile)
    }
}
