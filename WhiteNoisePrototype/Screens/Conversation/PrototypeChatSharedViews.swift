import AVKit
import SwiftUI

@MainActor
private enum PrototypePreparedImageCache {
    static let cache = NSCache<NSData, UIImage>()

    static func image(from data: Data) -> UIImage? {
        let key = data as NSData
        if let cached = cache.object(forKey: key) { return cached }
        guard let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: key)
        return image
    }
}

struct PrototypeChatAvatarView: View {
    let avatar: ChatListItem.Avatar
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            Circle().fill(Color(uiColor: .systemGray5))
            switch avatar {
            case let .asset(name):
                Image(name).resizable().scaledToFill()
            case let .imageData(data):
                if let image = PrototypePreparedImageCache.image(from: data) {
                    Image(uiImage: image).resizable().scaledToFill()
                }
            case let .monogram(value):
                Text(value).font(.headline).foregroundStyle(.primary)
            case let .systemSymbol(name):
                Image(systemName: name).font(.title3)
            }
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
        .accessibilityHidden(true)
    }
}

struct PrototypeImageSourceView: View {
    let source: PrototypeImageSource

    var body: some View {
        switch source {
        case let .asset(name):
            Image(name).resizable()
        case let .data(data):
            if let image = PrototypePreparedImageCache.image(from: data) {
                Image(uiImage: image).resizable()
            } else {
                unavailable
            }
        }
    }

    private var unavailable: some View {
        ZStack {
            Color(uiColor: .secondarySystemFill)
            Image(systemName: "photo.badge.exclamationmark")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
}

enum PrototypeGroupEventFormatter {
    static func text(
        for kind: PrototypeGroupEventKind,
        profileID: String,
        profileName: String,
        people: [PrototypePerson]
    ) -> String {
        func name(_ id: String, subject: Bool = false) -> String {
            if id == profileID { return subject ? "You" : "you" }
            return people.first { $0.id == id }?.name ?? id
        }
        func actor(_ id: String) -> String { name(id, subject: true) }
        func verb(_ id: String, you: String, other: String) -> String {
            id == profileID ? you : other
        }
        func names(_ ids: [String]) -> String {
            let values = ids.map { name($0, subject: true) }
            guard values.count > 1 else { return values.first ?? "" }
            return values.dropLast().joined(separator: ", ") + " and " + values.last!
        }

        switch kind {
        case let .created(actorID):
            return "\(actor(actorID)) \(verb(actorID, you: "created", other: "created")) the group."
        case let .added(actorID, personIDs):
            return "\(actor(actorID)) added \(names(personIDs))."
        case let .joined(personID):
            return "\(actor(personID)) joined the group."
        case let .left(personID):
            return "\(actor(personID)) left the group."
        case let .removed(actorID, personID):
            return "\(actor(actorID)) removed \(name(personID, subject: true))."
        case let .madeAdmin(actorID, personID):
            return "\(actor(actorID)) made \(name(personID, subject: true)) an admin."
        case let .removedAdmin(actorID, personID):
            return "\(actor(actorID)) removed \(name(personID, subject: true)) as an admin."
        case let .changedName(actorID, value):
            return "\(actor(actorID)) changed the group name to \(value)."
        case let .changedPhoto(actorID):
            return "\(actor(actorID)) changed the group photo."
        case let .changedDescription(actorID):
            return "\(actor(actorID)) changed the group description."
        case let .removedDescription(actorID):
            return "\(actor(actorID)) removed the group description."
        }
    }
}

enum PrototypeDateFormatter {
    static func separator(for date: Date, now: Date = .now) -> String {
        let calendar = Calendar.autoupdatingCurrent
        if calendar.isDate(date, inSameDayAs: now) { return "Today" }
        let startOfToday = calendar.startOfDay(for: now)
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        if let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: startOfToday
        ).day,
           days > 1,
           days < 7 {
            return date.formatted(.dateTime.weekday(.wide))
        }
        let year = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: now)
        if year == currentYear {
            return date.formatted(.dateTime.month(.wide).day())
        }
        return date.formatted(.dateTime.month(.wide).day().year())
    }

    static func time(for date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

struct PrototypeMediaSelection: Identifiable {
    let id: String
    let attachments: [PrototypeAttachment]
    let initialIndex: Int
}

struct PrototypeMediaViewer: View {
    let selection: PrototypeMediaSelection
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int

    init(selection: PrototypeMediaSelection) {
        self.selection = selection
        _selectedIndex = State(initialValue: selection.initialIndex)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedIndex) {
                ForEach(Array(selection.attachments.enumerated()), id: \.element.id) { index, attachment in
                    viewer(for: attachment).tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .background(.black)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func viewer(for attachment: PrototypeAttachment) -> some View {
        switch attachment {
        case let .photo(_, source, label):
            ZoomablePrototypeImage(source: source)
                .accessibilityLabel(label)
        case let .video(_, url, thumbnail, _):
            if let url {
                PrototypeVideoPage(url: url)
            } else {
                ZStack {
                    PrototypeImageSourceView(source: thumbnail).scaledToFit()
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Video unavailable")
            }
        default:
            ContentUnavailableView("Preview Unavailable", systemImage: "doc")
        }
    }
}

private struct PrototypeVideoPage: View {
    let url: URL
    @State private var player: AVPlayer

    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                PrototypePlaybackCoordinator.shared.stopAll()
            }
            .onDisappear {
                player.pause()
                player.seek(to: .zero)
            }
    }
}

private struct ZoomablePrototypeImage: View {
    let source: PrototypeImageSource

    var body: some View {
        PrototypeZoomScrollView(source: source)
            .accessibilityHint("Pinch or double-tap to zoom.")
    }
}

private struct PrototypeZoomScrollView: UIViewRepresentable {
    let source: PrototypeImageSource

    final class Coordinator: NSObject, UIScrollViewDelegate {
        let imageView = UIImageView()
        var currentSource: PrototypeImageSource?

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }

        @objc func toggleZoom(_ recognizer: UITapGestureRecognizer) {
            guard let scrollView = recognizer.view as? UIScrollView else { return }
            if scrollView.zoomScale > scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
                return
            }

            let point = recognizer.location(in: imageView)
            let targetScale = min(2, scrollView.maximumZoomScale)
            let width = scrollView.bounds.width / targetScale
            let height = scrollView.bounds.height / targetScale
            scrollView.zoom(
                to: CGRect(
                    x: point.x - width / 2,
                    y: point.y - height / 2,
                    width: width,
                    height: height
                ),
                animated: true
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.bouncesZoom = true
        scrollView.backgroundColor = .black

        let imageView = context.coordinator.imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = false
        scrollView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
        ])

        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.toggleZoom(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard context.coordinator.currentSource != source else { return }
        context.coordinator.currentSource = source
        context.coordinator.imageView.image = image(for: source)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }

    private func image(for source: PrototypeImageSource) -> UIImage? {
        switch source {
        case let .asset(name):
            UIImage(named: name)
        case let .data(data):
            PrototypePreparedImageCache.image(from: data)
        }
    }
}
