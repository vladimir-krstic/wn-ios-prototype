import AVFoundation
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit
import Vision
import VisionKit

struct ProfileCodeScannerView: View {
    @State private var foundProfile: PrototypeProfile?
    @State private var scanSessionID = UUID()

    let onDone: () -> Void

    var body: some View {
        Group {
            if let foundProfile {
                ContentUnavailableView {
                    Label(
                        "Profile Found",
                        systemImage:
                            "person.crop.circle.badge.checkmark"
                    )
                } description: {
                    ProfileSummary(
                        profile: foundProfile,
                        avatarSize: 64
                    )
                } actions: {
                    Button("Done", action: onDone)
                        .buttonStyle(.glassProminent)

                    Button("Scan Another") {
                        self.foundProfile = nil
                        scanSessionID = UUID()
                    }
                    .buttonStyle(.glass)
                }
            } else {
                scanner
                    .id(scanSessionID)
            }
        }
    }

    @ViewBuilder
    private var scanner: some View {
#if targetEnvironment(simulator)
        SimulatedProfileCodeScanner {
            foundProfile = .quietCurrent
        }
#else
        PhysicalProfileCodeScanner {
            foundProfile = .quietCurrent
        }
#endif
    }
}

private struct SimulatedProfileCodeScanner: View {
    let onProfileFound: () -> Void

    var body: some View {
        Button(action: onProfileFound) {
            GeometryReader { proxy in
                ZStack {
                    Image("QRScannerBackdrop")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                        .clipped()

                    profileQRCode
                        .frame(
                            width: proxy.size.width * 0.28,
                            height: proxy.size.width * 0.28
                        )

                    VStack {
                        Spacer()

                        Label(
                            "Scan a profile QR code",
                            systemImage: "qrcode.viewfinder"
                        )
                        .font(.callout.weight(.medium))
                        .padding()
                        .background(.regularMaterial, in: Capsule())
                        .padding()
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Scan Profile QR Code")
        .background(.black)
    }

    private var profileQRCode: some View {
        Group {
            if let image = makeProfileQRCode(
                payload:
                    "white-noise-prototype:profile:quiet-current"
            ) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
            } else {
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
            }
        }
        .background(.white)
    }
}

private struct PhysicalProfileCodeScanner: View {
    private enum ScannerState {
        case checking
        case scanning
        case denied
        case restricted
        case unsupported
        case unavailable
    }

    @Environment(\.openURL) private var openURL
    @State private var state: ScannerState = .checking
    @State private var isShowingInvalidCodeAlert = false

    let onProfileFound: () -> Void

    var body: some View {
        Group {
            switch state {
            case .checking:
                ProgressView("Preparing Camera")
            case .scanning:
                LiveProfileCodeScanner(
                    onProfileFound: onProfileFound,
                    onInvalidPayload: {
                        isShowingInvalidCodeAlert = true
                    },
                    onUnavailable: {
                        state = .unavailable
                    }
                )
            case .denied:
                ContentUnavailableView {
                    Label(
                        "Camera Access Is Off",
                        systemImage: "camera.fill"
                    )
                } description: {
                    Text(
                        "Allow camera access in Settings to scan "
                            + "profile QR codes."
                    )
                } actions: {
                    Button("Open Settings", action: openSettings)
                        .buttonStyle(.glassProminent)
                }
            case .restricted:
                unavailableView(
                    description:
                        "Camera access is restricted on this iPhone."
                )
            case .unsupported:
                unavailableView(
                    description:
                        "QR scanning isn’t available on this iPhone."
                )
            case .unavailable:
                unavailableView(
                    description:
                        "QR scanning isn’t available right now. "
                        + "Try again later."
                )
            }
        }
        .task {
            await prepareCamera()
        }
        .alert(
            "Can’t Use This QR Code",
            isPresented: $isShowingInvalidCodeAlert
        ) {
            Button("Try Again") {}
        } message: {
            Text("This QR code doesn’t contain a White Noise profile.")
        }
    }

    private func unavailableView(
        description: String
    ) -> some View {
        ContentUnavailableView {
            Label(
                "QR Scanning Unavailable",
                systemImage: "qrcode.viewfinder"
            )
        } description: {
            Text(description)
        }
    }

    private func prepareCamera() async {
        guard DataScannerViewController.isSupported else {
            state = .unsupported
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            state = DataScannerViewController.isAvailable
                ? .scanning
                : .unavailable
        case .notDetermined:
            let isAuthorized = await AVCaptureDevice.requestAccess(
                for: .video
            )
            state = isAuthorized
                && DataScannerViewController.isAvailable
                ? .scanning
                : .denied
        case .denied:
            state = .denied
        case .restricted:
            state = .restricted
        @unknown default:
            state = .unavailable
        }
    }

    private func openSettings() {
        guard let url = URL(
            string: UIApplication.openSettingsURLString
        ) else {
            return
        }

        openURL(url)
    }
}

private struct LiveProfileCodeScanner:
    UIViewControllerRepresentable {
    let onProfileFound: () -> Void
    let onInvalidPayload: () -> Void
    let onUnavailable: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onProfileFound: onProfileFound,
            onInvalidPayload: onInvalidPayload,
            onUnavailable: onUnavailable
        )
    }

    func makeUIViewController(
        context: Context
    ) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [
                .barcode(symbologies: [.qr])
            ],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

        scanner.delegate = context.coordinator
        startScanning(scanner, coordinator: context.coordinator)
        return scanner
    }

    func updateUIViewController(
        _ scanner: DataScannerViewController,
        context: Context
    ) {
        guard !scanner.isScanning else {
            return
        }

        startScanning(scanner, coordinator: context.coordinator)
    }

    static func dismantleUIViewController(
        _ scanner: DataScannerViewController,
        coordinator: Coordinator
    ) {
        scanner.stopScanning()
    }

    private func startScanning(
        _ scanner: DataScannerViewController,
        coordinator: Coordinator
    ) {
        do {
            try scanner.startScanning()
        } catch {
            coordinator.reportUnavailable()
        }
    }

    @MainActor
    final class Coordinator: NSObject,
        DataScannerViewControllerDelegate {
        private let onProfileFound: () -> Void
        private let onInvalidPayload: () -> Void
        private let onUnavailable: () -> Void
        private var didScan = false

        init(
            onProfileFound: @escaping () -> Void,
            onInvalidPayload: @escaping () -> Void,
            onUnavailable: @escaping () -> Void
        ) {
            self.onProfileFound = onProfileFound
            self.onInvalidPayload = onInvalidPayload
            self.onUnavailable = onUnavailable
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            guard !didScan else {
                return
            }

            for item in addedItems {
                guard case .barcode(let barcode) = item,
                      let payload = barcode.payloadStringValue else {
                    continue
                }

                let normalizedPayload = payload.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                let isProfileCode =
                    normalizedPayload.hasPrefix("npub")
                    || normalizedPayload.hasPrefix(
                        "white-noise-prototype:profile:"
                    )

                guard isProfileCode else {
                    onInvalidPayload()
                    return
                }

                didScan = true
                dataScanner.stopScanning()
                onProfileFound()
                return
            }
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            becameUnavailableWithError error:
                DataScannerViewController.ScanningUnavailable
        ) {
            reportUnavailable()
        }

        func reportUnavailable() {
            Task { @MainActor in
                onUnavailable()
            }
        }
    }
}

private func makeProfileQRCode(payload: String) -> UIImage? {
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(payload.utf8)
    filter.correctionLevel = "M"

    guard let outputImage = filter.outputImage else {
        return nil
    }

    let scaledImage = outputImage.transformed(
        by: CGAffineTransform(scaleX: 10, y: 10)
    )
    let context = CIContext()

    guard let image = context.createCGImage(
        scaledImage,
        from: scaledImage.extent
    ) else {
        return nil
    }

    return UIImage(cgImage: image)
}

#Preview("Scan Profile") {
    NavigationStack {
        ProfileCodeScannerView {}
    }
    .tint(Color("AccentColor"))
}
