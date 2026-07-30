import UIKit

enum ProfileAvatarImageProcessor {
    private static let maximumPixelDimension: CGFloat = 512

    static func preparedData(from sourceData: Data) -> Data? {
        guard let sourceImage = UIImage(data: sourceData) else {
            return nil
        }

        let largestDimension = max(
            sourceImage.size.width,
            sourceImage.size.height
        )
        guard largestDimension > 0 else {
            return nil
        }

        let scale = min(1, maximumPixelDimension / largestDimension)
        let outputSize = CGSize(
            width: max(1, sourceImage.size.width * scale),
            height: max(1, sourceImage.size.height * scale)
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(
            size: outputSize,
            format: format
        )
        let resizedImage = renderer.image { _ in
            sourceImage.draw(in: CGRect(origin: .zero, size: outputSize))
        }

        return resizedImage.jpegData(compressionQuality: 0.88)
    }
}
