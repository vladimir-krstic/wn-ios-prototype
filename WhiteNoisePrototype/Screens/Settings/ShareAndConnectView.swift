import SwiftUI
import UIKit

struct ShareAndConnectView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case share = "Share"
        case scan = "Connect"

        var id: Self { self }
    }

    @State private var copied = false
    @State private var copyFeedbackTrigger = 0
    @State private var copyResetTask: Task<Void, Never>?
    @State private var mode = Mode.share

    let profile: PrototypeProfile

    private let qrImage: UIImage?

    init(profile: PrototypeProfile) {
        self.profile = profile
        qrImage = QRCodeImageGenerator.image(
            for: profile.publicKey
        )
    }

    var body: some View {
        ZStack {
            if mode == .share {
                shareContent
                    .transition(.opacity)
            } else {
                ProfileCodeScannerView {
                    mode = .share
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .transition(.opacity)
                .ignoresSafeArea()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: mode)
        .navigationTitle("Share & Connect")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            mode == .scan ? .hidden : .automatic,
            for: .navigationBar
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { mode in
                        Text(mode.rawValue)
                            .tag(mode)
                    }
                }
                .labelsHidden()
                .pickerStyle(.palette)
                .controlSize(.extraLarge)
                .frame(width: 180)
            }

            if mode == .share {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: shareText) {
                        Label(
                            "Share Profile",
                            systemImage: "square.and.arrow.up"
                        )
                        .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: copyFeedbackTrigger)
        .onChange(of: mode) { _, newMode in
            if newMode == .scan {
                resetCopyFeedback()
            }
        }
        .onDisappear {
            resetCopyFeedback()
        }
    }

    private var shareContent: some View {
        Form {
            Section {
                profileHeader
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section {
                qrCodeContent
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 8) {
            profileAvatar

            Text(profile.name)
                .font(.title2.weight(.semibold))

            copyPublicKeyButton
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }

    private var copyPublicKeyButton: some View {
        Button(action: copyPublicKey) {
            HStack {
                Text(compactPublicKey)
                    .lineLimit(1)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)

                copyStateSymbol
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Color(uiColor: .secondarySystemFill),
                in: .capsule
            )
            .padding(.bottom, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            copied ? "Public key copied" : "Copy public key"
        )
        .accessibilityValue(profile.shortPublicKey)
    }

    private var compactPublicKey: String {
        guard profile.publicKey.count > 19 else {
            return profile.publicKey
        }

        return "\(profile.publicKey.prefix(14))…\(profile.publicKey.suffix(4))"
    }

    private var copyStateSymbol: some View {
        Image(systemName: copied ? "checkmark" : "doc.on.doc")
            .font(.caption2.weight(.medium))
            .foregroundStyle(.secondary)
            .frame(width: 14, height: 14)
            .contentTransition(.symbolEffect(.replace))
            .animation(.default, value: copied)
    }

    private var profileAvatar: some View {
        GeometryReader { geometry in
            ProfileAvatarView(
                profile: profile,
                size: geometry.size.width
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .containerRelativeFrame(
            .horizontal,
            count: 3,
            span: 1,
            spacing: 0
        )
    }

    @ViewBuilder
    private var qrCodeContent: some View {
        VStack(spacing: 6) {
            if let qrImage {
                Image(uiImage: qrImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .containerRelativeFrame(.horizontal) { length, _ in
                        length * 0.81
                    }
                    .padding(4)
                    .background(
                        .white,
                        in: RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                    .accessibilityLabel(
                        "\(profile.name)’s profile QR code"
                    )

                Text("Scan to connect.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                ContentUnavailableView(
                    "QR Code Unavailable",
                    systemImage: "qrcode"
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 32)
    }

    private var shareText: String {
        "\(profile.name) on White Noise\n\(profile.publicKey)"
    }

    private func copyPublicKey() {
        UIPasteboard.general.string = profile.publicKey
        copied = true
        copyFeedbackTrigger += 1
        UIAccessibility.post(
            notification: .announcement,
            argument: "Public key copied"
        )

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

    private func resetCopyFeedback() {
        copyResetTask?.cancel()
        copyResetTask = nil
        copied = false
    }
}
