import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DeveloperToolsPrototypeView: View {
    @Binding var developerTools: PrototypeDeveloperToolsState
    @Binding var diagnostics: PrototypeDiagnosticsState
    let profile: PrototypeProfile
    @State private var exportDocument = DiagnosticLogExportDocument(text: "")
    @State private var isFileExporterPresented = false
    @State private var isShowingExportError = false

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
                        Label("Debug Events", systemImage: "stethoscope")
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
                    LabeledContent(
                        "Diagnostic Logging",
                        value: diagnostics.preferences.savesDiagnosticLogs
                            ? "On"
                            : "Off"
                    )

                    if diagnostics.auditLogsContainData {
                        ForEach(nonemptyAuditFiles) { file in
                            auditFileRow(file)
                        }

                        Button(action: prepareDiagnosticLogExport) {
                            Label(
                                "Export Diagnostic Logs",
                                systemImage: "arrow.down.document"
                            )
                        }
                    } else {
                        Text("There are no logs.")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Diagnostic Logs")
                } footer: {
                    Text(
                        "Configure or clear diagnostic logs in Privacy & "
                            + "Security. Existing sanitized files remain "
                            + "available here after logging is turned off."
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
        .fileExporter(
            isPresented: $isFileExporterPresented,
            document: exportDocument,
            contentType: .plainText,
            defaultFilename: "White Noise Diagnostic Logs",
            onCompletion: handleExportResult
        )
        .alert(
            "Couldn’t Save Diagnostic Logs",
            isPresented: $isShowingExportError
        ) {
            Button("Dismiss", role: .cancel) {}
        } message: {
            Text("Choose another location and try again.")
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

    private var nonemptyAuditFiles: [PrototypeAuditFile] {
        diagnostics.auditFiles.filter { file in
            file.byteCount > 0
        }
    }

    private var developerToolsEnabled: Binding<Bool> {
        Binding {
            developerTools.isEnabled
        } set: { isEnabled in
            developerTools.setEnabled(isEnabled)
        }
    }

    private func prepareDiagnosticLogExport() {
        guard diagnostics.auditLogsContainData else {
            return
        }

        exportDocument = DiagnosticLogExportDocument(
            text: diagnostics.diagnosticLogExportText
        )
        isFileExporterPresented = true
    }

    private func handleExportResult(_ result: Result<URL, Error>) {
        if case .failure = result {
            isShowingExportError = true
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

struct DiagnosticsPrototypeView: View {
    private let consoleContentInset: CGFloat = 20
    let diagnosticSummary: String?

    @State private var isTesting = false
    @State private var didCopyDiagnosticSummary = false
    @State private var recentEvents = [
        "18:42:10  runtime started",
        "18:42:11  relay connected",
        "18:42:12  profile projection ready",
    ]

    init(diagnosticSummary: String? = nil) {
        self.diagnosticSummary = diagnosticSummary
    }

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
        .navigationTitle("Debug Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    if let diagnosticSummary {
                        Button {
                            UIPasteboard.general.string = diagnosticSummary
                            didCopyDiagnosticSummary = true
                        } label: {
                            Label(
                                didCopyDiagnosticSummary
                                    ? "Diagnostic Summary Copied"
                                    : "Copy Diagnostic Summary",
                                systemImage: didCopyDiagnosticSummary
                                    ? "checkmark"
                                    : "doc.on.doc"
                            )
                        }

                        Divider()
                    }

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
                    Label("Diagnostic Actions", systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sensoryFeedback(.success, trigger: didCopyDiagnosticSummary)
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

private struct DiagnosticLogExportDocument: FileDocument {
    static let readableContentTypes: [UTType] = [.plainText]

    let data: Data

    init(text: String) {
        data = Data(text.utf8)
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

#Preview("Developer Tools") {
    @Previewable @State var developerTools = {
        var state = PrototypeDeveloperToolsState.fixtures()
        state.isEnabled = true
        return state
    }()
    @Previewable @State var diagnostics = {
        var state = PrototypeDiagnosticsState()
        state.apply(
            PrototypeDiagnosticsPreferences(
                sharesAnonymousAnalytics: true,
                savesDiagnosticLogs: true
            ),
            profileID: PrototypeProfile.marmota.id,
            profileName: PrototypeProfile.marmota.name
        )
        return state
    }()

    NavigationStack {
        DeveloperToolsPrototypeView(
            developerTools: $developerTools,
            diagnostics: $diagnostics,
            profile: .marmota
        )
    }
}
