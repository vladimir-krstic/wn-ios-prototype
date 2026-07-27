import SwiftUI
import UIKit

struct ProfileKeysSettingsView: View {
    @State private var copied = false
    @State private var isShowingEncryptedBackup = false
    @State private var isShowingRawConfirmation = false
    @State private var exportResult: KeyExportResult?

    let profile: PrototypeProfile

    var body: some View {
        Form {
            Section {
                Button {
                    UIPasteboard.general.string = profile.publicKey
                    copied = true
                } label: {
                    LabeledContent {
                        Label(
                            copied ? "Copied" : "Copy",
                            systemImage: copied
                                ? "checkmark"
                                : "doc.on.doc"
                        )
                    } label: {
                        Text(profile.shortPublicKey)
                            .font(.body.monospaced())
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
            } header: {
                Text("Public Key")
            } footer: {
                Text("Your public key is safe to share.")
            }

            Section {
                Label(
                    "Anyone with your private key can use your profile. Keep it private. White Noise can't recover it if you lose it.",
                    systemImage: "exclamationmark.shield"
                )
                .font(.callout)
            }

            Section {
                Button {
                    isShowingEncryptedBackup = true
                } label: {
                    Label(
                        "Create Encrypted Backup",
                        systemImage: "lock.doc"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .listRowBackground(Color.clear)

                Button {
                    isShowingRawConfirmation = true
                } label: {
                    Label(
                        "Export Private Key",
                        systemImage: "square.and.arrow.up"
                    )
                }
            } footer: {
                Text(
                    "An encrypted backup is the recommended way to keep a copy."
                )
            }
        }
        .navigationTitle("Profile Keys")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingEncryptedBackup) {
            EncryptedBackupSheet { passphrase in
                isShowingEncryptedBackup = false
                exportResult = KeyExportResult(
                    title: "Encrypted Backup Ready",
                    message: "Store this backup somewhere safe.",
                    shareValue: "ncryptsec1-whitenoise-\(profile.id)-\(passphrase.count)"
                )
            }
        }
        .sheet(item: $exportResult) { result in
            NavigationStack {
                ContentUnavailableView {
                    Label(result.title, systemImage: "checkmark.shield")
                } description: {
                    Text(result.message)
                } actions: {
                    ShareLink(item: result.shareValue) {
                        Label("Share Backup", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.glassProminent)
                }
                .navigationTitle("Profile Keys")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            exportResult = nil
                        }
                    }
                }
            }
        }
        .confirmationDialog(
            "Export your private key?",
            isPresented: $isShowingRawConfirmation,
            titleVisibility: .visible
        ) {
            Button("Export Private Key", role: .destructive) {
                exportResult = KeyExportResult(
                    title: "Private Key Export Ready",
                    message: "Keep this unencrypted copy private.",
                    shareValue: "nsec1-fictional-\(profile.id)-private-key"
                )
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "This creates an unencrypted copy. Anyone who gets it can use your profile. White Noise permanently records that this key was handled without encryption."
            )
        }
    }
}

private struct EncryptedBackupSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var passphrase = ""
    @State private var confirmation = ""
    @State private var isCreating = false

    let onCreate: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Passphrase", text: $passphrase)
                        .textContentType(.newPassword)
                    SecureField(
                        "Confirm Passphrase",
                        text: $confirmation
                    )
                    .textContentType(.newPassword)
                } footer: {
                    Text("Use at least 12 characters and keep it somewhere safe.")
                }

                Section("Strength") {
                    LabeledContent(strength.label) {
                        ProgressView(
                            value: Double(strength.rawValue),
                            total: 3
                        )
                        .frame(maxWidth: 120)
                    }
                }

                if !confirmation.isEmpty && passphrase != confirmation {
                    Section {
                        Label(
                            "Passphrases don't match.",
                            systemImage: "exclamationmark.circle"
                        )
                        .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Encrypted Backup")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(isCreating)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isCreating)
                }

                ToolbarItem(placement: .confirmationAction) {
                    if isCreating {
                        ProgressView()
                            .controlSize(.small)
                            .accessibilityLabel("Creating backup")
                    } else {
                        Button("Create Backup", action: create)
                            .disabled(!isValid)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var isValid: Bool {
        passphrase.count >= 12 && passphrase == confirmation
    }

    private var strength: PassphraseStrength {
        guard passphrase.count >= 12 else {
            return .weak
        }

        let hasLetters = passphrase.rangeOfCharacter(
            from: .letters
        ) != nil
        let hasDigits = passphrase.rangeOfCharacter(
            from: .decimalDigits
        ) != nil
        let hasSymbols = passphrase.rangeOfCharacter(
            from: .alphanumerics.inverted
        ) != nil

        if passphrase.count >= 16 && hasLetters && hasDigits && hasSymbols {
            return .strong
        }
        return .fair
    }

    private func create() {
        guard isValid else {
            return
        }

        isCreating = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            onCreate(passphrase)
        }
    }
}

private enum PassphraseStrength: Int {
    case weak = 1
    case fair = 2
    case strong = 3

    var label: String {
        switch self {
        case .weak: "Weak"
        case .fair: "Fair"
        case .strong: "Strong"
        }
    }
}

private struct KeyExportResult: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let shareValue: String
}

#Preview("Profile Keys") {
    NavigationStack {
        ProfileKeysSettingsView(profile: .marmota)
    }
    .tint(Color("AccentColor"))
}
