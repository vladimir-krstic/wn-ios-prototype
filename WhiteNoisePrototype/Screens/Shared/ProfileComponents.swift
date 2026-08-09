import SwiftUI
import UIKit

struct ProfileAvatarView: View {
    let profile: PrototypeProfile
    let size: CGFloat
    var isDecorative = true

    var body: some View {
        avatar
            .frame(width: size, height: size)
            .clipShape(Circle())
            .accessibilityHidden(isDecorative)
    }

    @ViewBuilder
    private var avatar: some View {
        switch profile.avatar {
        case let .asset(name):
            Image(name)
                .resizable()
                .scaledToFill()
        case let .webImage(assetName, _):
            Image(assetName)
                .resizable()
                .scaledToFill()
        case let .imageData(data):
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                monogram
            }
        case .monogram:
            monogram
        }
    }

    private var monogram: some View {
        ZStack {
            Circle()
                .fill(.primary)

            Text(profile.initial)
                .font(.headline)
                .foregroundStyle(.background)
        }
    }
}

struct ProfileEditorAvatarView: View {
    @Environment(\.colorScheme) private var colorScheme

    let name: String
    let image: UIImage?
    var emptySystemImage: String? = nil
    var accessibilityName = "Profile photo"

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(
                        showsEmptySystemImage
                            ? Color(uiColor: .secondarySystemFill)
                            : Color("AccentColor")
                    )

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                } else if let emptySystemImage, showsEmptySystemImage {
                    Image(systemName: emptySystemImage)
                        .font(.largeTitle)
                        .foregroundStyle(.primary)
                } else {
                    Text(initial)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            colorScheme == .dark
                                ? Color.black
                                : Color.white
                        )
                }
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .clipShape(.circle)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            image == nil && !showsEmptySystemImage
                ? "\(accessibilityName), \(initial)"
                : accessibilityName
        )
    }

    private var initial: String {
        return name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .first
            .map { String($0).uppercased() }
            ?? "?"
    }

    private var showsEmptySystemImage: Bool {
        image == nil
            && emptySystemImage != nil
            && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct ProfileSummary: View {
    let profile: PrototypeProfile
    let avatarSize: CGFloat

    var body: some View {
        HStack {
            ProfileAvatarView(
                profile: profile,
                size: avatarSize
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(profile.shortPublicKey)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
