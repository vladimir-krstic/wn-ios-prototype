import SwiftUI
import UIKit

struct SupportPrototypeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var state = SupportState.ready

    var body: some View {
        Group {
            switch state {
            case .ready:
                Form {
                    Section {
                        Label {
                            VStack(alignment: .leading) {
                                Text("White Noise Support")
                                    .font(.headline)
                                Text("Help with White Noise")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                                .font(.title2)
                        }
                    }

                    Section {
                        Button(action: startChat) {
                            Label(
                                "Start Chat",
                                systemImage: "message"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                        .listRowBackground(Color.clear)
                    } footer: {
                        Text(
                            "If a support chat already exists, White Noise opens that conversation."
                        )
                    }
                }
            case .loading:
                ContentUnavailableView {
                    ProgressView()
                } description: {
                    Text("Opening support chat…")
                }
            case .complete:
                ContentUnavailableView {
                    Label("Support Chat Ready", systemImage: "checkmark.message")
                } description: {
                    Text("Your conversation with White Noise Support is ready.")
                } actions: {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
        .navigationTitle("Chat with support")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func startChat() {
        state = .loading
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            state = .complete
        }
    }
}

private enum SupportState {
    case ready
    case loading
    case complete
}

struct DonatePrototypeView: View {
    @State private var copiedMethod: DonationMethod?
    @State private var copyResetTask: Task<Void, Never>?

    var body: some View {
        Form {
            Section {
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundStyle(.pink)

                    Text(
                        "White Noise is free and open source. Donations keep it that way."
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .listRowBackground(Color.clear)

            donationSection(.lightning)
            donationSection(.bitcoin)
        }
        .navigationTitle("Donate")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            copyResetTask?.cancel()
        }
    }

    private func donationSection(
        _ method: DonationMethod
    ) -> some View {
        Section(method.title) {
            VStack {
                if let image = QRCodeImageGenerator.image(
                    for: method.address,
                    scale: 8
                ) {
                    Image(uiImage: image)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(maxWidth: 180)
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .accessibilityLabel("\(method.title) QR code")
                }

                Button {
                    UIPasteboard.general.string = method.address
                    copiedMethod = method
                    scheduleCopyReset()
                } label: {
                    Label(
                        copiedMethod == method
                            ? "Copied"
                            : method.displayAddress,
                        systemImage: copiedMethod == method
                            ? "checkmark"
                            : "doc.on.doc"
                    )
                    .font(.callout.monospaced())
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
    }

    private func scheduleCopyReset() {
        copyResetTask?.cancel()
        copyResetTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))

            guard !Task.isCancelled else {
                return
            }

            copiedMethod = nil
            copyResetTask = nil
        }
    }
}

private enum DonationMethod: CaseIterable, Equatable {
    case lightning
    case bitcoin

    var title: String {
        switch self {
        case .lightning: "Lightning Address"
        case .bitcoin: "Bitcoin Silent Payment"
        }
    }

    var address: String {
        switch self {
        case .lightning:
            "whitenoise@donate.ipf.dev"
        case .bitcoin:
            "sp1qqvp56mxcj9pz9xudvlch5g4ah5hrc8rj6neu25p34rc9gxhp38cwqqlmld28u57w2srgckr34dkyg3q02phu8tm05cyj483q026xedp0s5f5j40p"
        }
    }

    var displayAddress: String {
        guard address.count > 36 else {
            return address
        }
        return "\(address.prefix(18))…\(address.suffix(12))"
    }
}

#Preview("Chat with Support") {
    NavigationStack {
        SupportPrototypeView()
    }
}

#Preview("Donate") {
    NavigationStack {
        DonatePrototypeView()
    }
}
