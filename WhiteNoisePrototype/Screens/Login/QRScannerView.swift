import AVFoundation
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit
import Vision
import VisionKit

enum SimulatedQRScanOutcome: CaseIterable {
    case wrongContent
    case validKey

    var next: Self {
        switch self {
        case .wrongContent:
            .validKey
        case .validKey:
            .wrongContent
        }
    }
}

enum SimulatedCameraPermissionState {
    case requesting
    case allowed
    case denied
}

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding private var simulatedPermission:
        SimulatedCameraPermissionState
    let simulatedOutcome: SimulatedQRScanOutcome
    let onSimulatedAttempt: () -> Void
    let onScan: (String) -> Void

    init(
        simulatedPermission:
            Binding<SimulatedCameraPermissionState> = .constant(.requesting),
        simulatedOutcome: SimulatedQRScanOutcome = .wrongContent,
        onSimulatedAttempt: @escaping () -> Void = {},
        onScan: @escaping (String) -> Void
    ) {
        _simulatedPermission = simulatedPermission
        self.simulatedOutcome = simulatedOutcome
        self.onSimulatedAttempt = onSimulatedAttempt
        self.onScan = onScan
    }

    var body: some View {
        Group {
#if targetEnvironment(simulator)
            SimulatedQRScannerView(
                permissionState: $simulatedPermission,
                outcome: simulatedOutcome,
                onAttempt: onSimulatedAttempt,
                onScan: completeScan
            )
#else
            PhysicalQRScannerView(onScan: completeScan)
#endif
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func completeScan(_ payload: String) {
        onScan(payload)
        dismiss()
    }
}

private struct SimulatedQRScannerView: View {
    private enum Metrics {
        static let cardCenterYRatio: CGFloat = 0.435
        static let qrWidthRatio: CGFloat = 0.28
    }

    @Binding var permissionState: SimulatedCameraPermissionState
    let outcome: SimulatedQRScanOutcome
    let onAttempt: () -> Void
    let onScan: (String) -> Void

    @State private var isShowingWrongContentAlert: Bool

    init(
        permissionState: Binding<SimulatedCameraPermissionState>,
        outcome: SimulatedQRScanOutcome,
        initiallyShowsWrongContentAlert: Bool = false,
        onAttempt: @escaping () -> Void,
        onScan: @escaping (String) -> Void
    ) {
        _permissionState = permissionState
        self.outcome = outcome
        self.onAttempt = onAttempt
        self.onScan = onScan
        _isShowingWrongContentAlert = State(
            initialValue: initiallyShowsWrongContentAlert
        )
    }

    var body: some View {
        Group {
            switch permissionState {
            case .requesting:
                Color.black
                    .ignoresSafeArea()
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(.hidden, for: .navigationBar)
            case .allowed:
                scannerCanvas
            case .denied:
                ContentUnavailableView {
                    Label(
                        "Camera Access Is Off",
                        systemImage: "camera.fill"
                    )
                } description: {
                    Text(
                        "Camera access was denied. Relaunch the prototype "
                            + "to reset this simulated permission."
                    )
                }
            }
        }
        .alert(
            "Allow Camera Access?",
            isPresented: permissionAlertIsPresented
        ) {
            Button("Don’t Allow", role: .cancel) {
                permissionState = .denied
            }

            Button("Allow Camera") {
                permissionState = .allowed
            }
        } message: {
            Text("Use the camera to scan a private key QR code.")
        }
        .alert(
            "Can’t Use This QR Code",
            isPresented: $isShowingWrongContentAlert
        ) {
            Button("Try Again") {}
        } message: {
            Text("This QR code doesn’t contain a private key.")
        }
    }

    private var permissionAlertIsPresented: Binding<Bool> {
        Binding {
            permissionState == .requesting
        } set: { _ in }
    }

    private var scannerCanvas: some View {
        Button(action: performAttempt) {
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

                    qrCode
                        .frame(
                            width: proxy.size.width
                                * Metrics.qrWidthRatio,
                            height: proxy.size.width
                                * Metrics.qrWidthRatio
                        )
                        .position(
                            x: proxy.size.width / 2,
                            y: proxy.size.height
                                * Metrics.cardCenterYRatio
                        )
                }
            }
        }
        .buttonStyle(.plain)
        .allowsHitTesting(permissionState == .allowed)
        .accessibilityLabel("Scan QR Code")
        .ignoresSafeArea()
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .background(.black)
    }

    private var qrCode: some View {
        Group {
            if let image = makeQRCodeImage(
                payload: LoginPrototypeData.privateKey
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

    private func performAttempt() {
        guard permissionState == .allowed else {
            return
        }

        onAttempt()

        switch outcome {
        case .wrongContent:
            isShowingWrongContentAlert = true
        case .validKey:
            onScan(LoginPrototypeData.privateKey)
        }
    }
}

private struct PhysicalQRScannerView: View {
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
    @State private var isShowingWrongContentAlert = false

    let onScan: (String) -> Void

    var body: some View {
        Group {
            switch state {
            case .checking:
                ProgressView("Preparing Camera")
            case .scanning:
                LiveQRScannerView(
                    onPayload: onScan,
                    onInvalidPayload: {
                        isShowingWrongContentAlert = true
                    },
                    onUnavailable: {
                        state = .unavailable
                    }
                )
                .ignoresSafeArea()
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.hidden, for: .navigationBar)
            case .denied:
                ContentUnavailableView {
                    Label(
                        "Camera Access Is Off",
                        systemImage: "camera.fill"
                    )
                } description: {
                    Text(
                        "Allow camera access in Settings to scan "
                            + "a private key QR code."
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
            isPresented: $isShowingWrongContentAlert
        ) {
            Button("Try Again") {}
        } message: {
            Text("This QR code doesn’t contain a private key.")
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

private struct LiveQRScannerView: UIViewControllerRepresentable {
    let onPayload: (String) -> Void
    let onInvalidPayload: () -> Void
    let onUnavailable: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onPayload: onPayload,
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
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onPayload: (String) -> Void
        private let onInvalidPayload: () -> Void
        private let onUnavailable: () -> Void
        private var didScan = false

        init(
            onPayload: @escaping (String) -> Void,
            onInvalidPayload: @escaping () -> Void,
            onUnavailable: @escaping () -> Void
        ) {
            self.onPayload = onPayload
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

                guard normalizedPayload.hasPrefix("nsec") else {
                    onInvalidPayload()
                    return
                }

                didScan = true
                dataScanner.stopScanning()
                onPayload(normalizedPayload)
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

private func makeQRCodeImage(payload: String) -> UIImage? {
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

    guard let cgImage = context.createCGImage(
        scaledImage,
        from: scaledImage.extent
    ) else {
        return nil
    }

    return UIImage(cgImage: cgImage)
}

#Preview("QR Scanner — Ready") {
    NavigationStack {
        SimulatedQRScannerView(
            permissionState: .constant(.allowed),
            outcome: .wrongContent,
            onAttempt: {},
            onScan: { _ in }
        )
    }
    .tint(Color("AccentColor"))
}

#Preview("QR Scanner — Permission Denied") {
    NavigationStack {
        SimulatedQRScannerView(
            permissionState: .constant(.denied),
            outcome: .wrongContent,
            onAttempt: {},
            onScan: { _ in }
        )
    }
    .tint(Color("AccentColor"))
}

#Preview("QR Scanner — Permission Request") {
    NavigationStack {
        SimulatedQRScannerView(
            permissionState: .constant(.requesting),
            outcome: .wrongContent,
            onAttempt: {},
            onScan: { _ in }
        )
    }
    .tint(Color("AccentColor"))
}

#Preview("QR Scanner — Wrong Content") {
    NavigationStack {
        SimulatedQRScannerView(
            permissionState: .constant(.allowed),
            outcome: .wrongContent,
            initiallyShowsWrongContentAlert: true,
            onAttempt: {},
            onScan: { _ in }
        )
    }
    .tint(Color("AccentColor"))
}
