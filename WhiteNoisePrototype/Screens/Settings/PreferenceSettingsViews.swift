import SwiftUI

struct NotificationSettingsPrototypeView: View {
    @Binding var settings: PrototypeSettingsState

    var body: some View {
        Form {
            Section {
                Toggle(
                    "Local Notifications",
                    isOn: $settings.localNotificationsEnabled
                )

                Toggle(
                    "Native Push",
                    isOn: $settings.nativePushEnabled
                )
                .disabled(!settings.localNotificationsEnabled)
            } header: {
                Text("Delivery")
            } footer: {
                Text(
                    "Native push sends generic notification wakes. White Noise prepares the notification on your device."
                )
            }

            Section {
                Picker(
                    "Notification Preview",
                    selection: $settings.notificationPreview
                ) {
                    ForEach(PrototypeNotificationPreview.allCases) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()

                Label(
                    settings.notificationPreview.example,
                    systemImage: "bell.badge"
                )
                .font(.callout)
                .foregroundStyle(.secondary)
            } header: {
                Text("Preview")
            } footer: {
                Text(
                    "Choose how much message information appears on the Lock Screen."
                )
            }

            Section("Status") {
                LabeledContent("Permission", value: "Allowed")
                LabeledContent("Push Service", value: "Ready")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppearanceSettingsPrototypeView: View {
    @Binding var settings: PrototypeSettingsState

    var body: some View {
        Form {
            Section {
                Picker("Theme", selection: $settings.appearance) {
                    ForEach(PrototypeAppearance.allCases) { appearance in
                        Text(appearance.rawValue)
                            .tag(appearance)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("Theme")
            } footer: {
                Text(
                    "System follows your device appearance. Light and Dark keep the selected appearance."
                )
            }

            Section {
                Picker("Language", selection: $settings.language) {
                    ForEach(PrototypeLanguage.allCases) { language in
                        Text(language.rawValue)
                            .tag(language)
                    }
                }
            }

            Section {
                Toggle(
                    "Return Key Sends",
                    isOn: Binding {
                        settings.returnKeyBehavior == .send
                    } set: { sends in
                        settings.returnKeyBehavior = sends
                            ? .send
                            : .newLine
                    }
                )

                NavigationLink {
                    MessageColorSettingsView(settings: $settings)
                } label: {
                    LabeledContent("Message Colors") {
                        HStack {
                            Circle()
                                .fill(settings.incomingMessageColor.color)
                            Circle()
                                .fill(settings.outgoingMessageColor.color)
                        }
                        .frame(height: 20)
                    }
                }
            } footer: {
                Text(
                    "When Return Key Sends is off, Return inserts a new line."
                )
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MessageColorSettingsView: View {
    @Binding var settings: PrototypeSettingsState

    var body: some View {
        Form {
            Section {
                messagePreview
            }
            .listRowBackground(Color.clear)

            Section {
                Picker(
                    "Incoming",
                    selection: $settings.incomingMessageColor
                ) {
                    ForEach(PrototypeMessageColor.allCases) { color in
                        Label {
                            Text(color.rawValue)
                        } icon: {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(color.color)
                        }
                        .tag(color)
                    }
                }

                Picker(
                    "Outgoing",
                    selection: $settings.outgoingMessageColor
                ) {
                    ForEach(PrototypeMessageColor.allCases) { color in
                        Label {
                            Text(color.rawValue)
                        } icon: {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(color.color)
                        }
                        .tag(color)
                    }
                }
            } footer: {
                Text(
                    "White Noise keeps text readable by choosing black or white automatically."
                )
            }

            Section {
                Button("Reset to Defaults") {
                    settings.incomingMessageColor = .gray
                    settings.outgoingMessageColor = .blue
                }
            }
        }
        .navigationTitle("Message Colors")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var messagePreview: some View {
        VStack(alignment: .leading) {
            Text("That works for me.")
                .padding()
                .background(
                    settings.incomingMessageColor.color,
                    in: RoundedRectangle(cornerRadius: 18)
                )

            Text("Great — see you then.")
                .foregroundStyle(
                    settings.outgoingMessageColor == .gray
                        ? Color.primary
                        : Color.white
                )
                .padding()
                .background(
                    settings.outgoingMessageColor.color,
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct DataStoragePrototypeView: View {
    @Binding var settings: PrototypeSettingsState

    var body: some View {
        Form {
            Section {
                ForEach(PrototypeMediaQuality.allCases) { quality in
                    Button {
                        settings.mediaQuality = quality
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(quality.rawValue)
                                    .foregroundStyle(.primary)
                                Text(quality.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if settings.mediaQuality == quality {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("Media Send Quality")
            } footer: {
                Text(
                    "Smaller media is never enlarged. Identifying photo metadata is removed before sending."
                )
            }

            Section {
                ForEach(PrototypeMediaType.allCases) { type in
                    NavigationLink {
                        AutoDownloadPrototypeView(
                            type: type,
                            settings: $settings
                        )
                    } label: {
                        LabeledContent {
                            Text(
                                settings.autoDownload[type, default: .never]
                                    .rawValue
                            )
                        } label: {
                            Label(type.rawValue, systemImage: type.symbol)
                        }
                    }
                }

                Button("Reset Auto-Download Settings", role: .destructive) {
                    settings.autoDownload = [
                        .photos: .wifi,
                        .audio: .wifi,
                        .videos: .never,
                        .files: .never,
                    ]
                }
            } header: {
                Text("Media Auto-Download")
            } footer: {
                Text(
                    "Media that isn't downloaded automatically shows a download button."
                )
            }
        }
        .navigationTitle("Data & Storage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AutoDownloadPrototypeView: View {
    let type: PrototypeMediaType
    @Binding var settings: PrototypeSettingsState

    var body: some View {
        List {
            Section {
                ForEach(PrototypeAutoDownloadLevel.allCases) { level in
                    Button {
                        settings.autoDownload[type] = level
                    } label: {
                        HStack {
                            Text(level.rawValue)
                                .foregroundStyle(.primary)
                            Spacer()
                            if settings.autoDownload[type] == level {
                                Image(systemName: "checkmark")
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(type.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Notifications") {
    @Previewable @State var settings = PrototypeSettingsState()

    NavigationStack {
        NotificationSettingsPrototypeView(settings: $settings)
    }
}

#Preview("Appearance") {
    @Previewable @State var settings = PrototypeSettingsState()

    NavigationStack {
        AppearanceSettingsPrototypeView(settings: $settings)
    }
}

#Preview("Data & Storage") {
    @Previewable @State var settings = PrototypeSettingsState()

    NavigationStack {
        DataStoragePrototypeView(settings: $settings)
    }
}
