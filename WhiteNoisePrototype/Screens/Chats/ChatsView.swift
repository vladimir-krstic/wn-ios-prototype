import SwiftUI

struct ChatsView: View {
    enum ChatScope: String, CaseIterable, Identifiable {
        case all
        case unread
        case archived

        var id: Self {
            self
        }

        var title: String {
            switch self {
            case .all:
                "Chats"
            case .unread:
                "Unread"
            case .archived:
                "Archived"
            }
        }

        var symbol: String {
            switch self {
            case .all:
                "bubble.left.and.bubble.right"
            case .unread:
                "message.badge"
            case .archived:
                "archivebox"
            }
        }
    }

    @State private var chats: [ChatListItem]
    @State private var scope = ChatScope.all
    @State private var searchText = ""
    @State private var isSearchMounted = false
    @State private var isSearchPresented = false
    @FocusState private var isSearchFocused: Bool

    let onNewMessage: () -> Void

    init(
        chats: [ChatListItem],
        initialScope: ChatScope = .all,
        initialSearchText: String = "",
        onNewMessage: @escaping () -> Void
    ) {
        self.onNewMessage = onNewMessage
        _chats = State(initialValue: chats)
        _scope = State(initialValue: initialScope)
        _searchText = State(initialValue: initialSearchText)
    }

    var body: some View {
        Group {
            if visibleChats.isEmpty {
                ContentUnavailableView {
                    Label(emptyTitle, systemImage: emptySymbol)
                } description: {
                    Text(emptyDescription)
                }
            } else {
                NativeChatList(
                    chats: visibleChats,
                    actions: NativeChatList.Actions(
                        markRead: markChatRead,
                        markUnread: markChatUnread,
                        mute: muteChat,
                        unmute: unmuteChat,
                        toggleArchive: toggleArchive,
                        leave: leaveChat,
                        delete: deleteChat
                    )
                )
                .ignoresSafeArea(
                    .container,
                    edges: [.top, .bottom]
                )
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(
            OnDemandChatSearch(
                searchText: $searchText,
                isMounted: $isSearchMounted,
                isPresented: $isSearchPresented,
                isFocused: $isSearchFocused
            )
        )
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ZStack {
                    Circle()
                        .fill(.primary)

                    Text("M")
                        .font(.headline)
                        .foregroundStyle(.background)
                }
                .frame(width: 44, height: 44)
                .accessibilityLabel("Profile")
            }
            .sharedBackgroundVisibility(.hidden)

            ToolbarItemGroup(placement: .topBarTrailing) {
                filterMenu

                Button {
                    isSearchMounted = true
                } label: {
                    Label("Search Chats", systemImage: "magnifyingglass")
                        .labelStyle(.iconOnly)
                }
            }

            ToolbarSpacer(.fixed, placement: .topBarTrailing)

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onNewMessage) {
                    Label(
                        "New Message",
                        systemImage: "plus.bubble"
                    )
                    .labelStyle(.iconOnly)
                }
                .buttonStyle(.glassProminent)
            }

        }
        .modifier(
            ReadAllBottomBar(
                isVisible: readAllIsVisible,
                action: markAllChatsRead
            )
        )
    }

    private func markChatRead(_ id: String) {
        updateChat(id: id) { chat in
            chat.unreadCount = 0
            chat.isMarkedUnread = false
        }
    }

    private func markAllChatsRead() {
        for index in chats.indices
        where !chats[index].isArchived && chats[index].isUnread {
            chats[index].unreadCount = 0
            chats[index].isMarkedUnread = false
        }
    }

    private func markChatUnread(_ id: String) {
        updateChat(id: id) { chat in
            chat.unreadCount = 0
            chat.isMarkedUnread = true
        }
    }

    private func muteChat(
        _ id: String,
        _ duration: ChatListItem.MuteDuration
    ) {
        updateChat(id: id) { chat in
            chat.muteDuration = duration
        }
    }

    private func unmuteChat(_ id: String) {
        updateChat(id: id) { chat in
            chat.muteDuration = nil
        }
    }

    private func toggleArchive(_ id: String) {
        updateChat(id: id) { chat in
            chat.isArchived.toggle()
        }
    }

    private func leaveChat(_ id: String) {
        updateChat(id: id) { chat in
            chat.membershipState = .left
            chat.unreadCount = 0
            chat.isMarkedUnread = false
            chat.muteDuration = nil
            chat.deliveryState = .none
        }
    }

    private func deleteChat(_ id: String) {
        chats.removeAll { chat in
            chat.id == id
        }
    }

    private func updateChat(
        id: String,
        mutation: (inout ChatListItem) -> Void
    ) {
        guard let index = chats.firstIndex(where: { chat in
            chat.id == id
        }) else {
            return
        }

        mutation(&chats[index])
    }

    private var visibleChats: [ChatListItem] {
        let scopedChats = chats.filter { chat in
            switch scope {
            case .all:
                !chat.isArchived
            case .unread:
                !chat.isArchived && chat.isUnread
            case .archived:
                chat.isArchived
            }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return scopedChats
        }

        return scopedChats.filter { chat in
            chat.title.range(
                of: query,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) != nil
            || chat.searchablePreview.range(
                of: query,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) != nil
        }
    }

    private var hasUnreadChats: Bool {
        chats.contains { chat in
            !chat.isArchived && chat.isUnread
        }
    }

    private var readAllIsVisible: Bool {
        scope == .unread && hasUnreadChats
    }

    private var filterMenu: some View {
        Menu {
            Picker("Filter Chats", selection: $scope) {
                ForEach(ChatScope.allCases) { scope in
                    Label(scope.title, systemImage: scope.symbol)
                        .tag(scope)
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color("AccentColor"))
                    .opacity(scope == .all ? 0 : 1)

                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundStyle(
                        scope == .all
                            ? Color.primary
                            : Color(uiColor: .systemBackground)
                    )
            }
            .frame(width: 36, height: 36)
            .offset(x: -7)
            .frame(width: 34, height: 34)
            .accessibilityLabel("Filter Chats")
        }
        .menuIndicator(.hidden)
        .accessibilityValue(scope.title)
    }

    private var emptyTitle: LocalizedStringKey {
        guard searchText.isEmpty else {
            return "No Results"
        }

        return switch scope {
        case .all:
            "No Chats"
        case .unread:
            "No Unread Chats"
        case .archived:
            "No Archived Chats"
        }
    }

    private var emptyDescription: LocalizedStringKey {
        guard searchText.isEmpty else {
            return "Check the spelling or try a different search."
        }

        return switch scope {
        case .all:
            "Start a new chat to send a message."
        case .unread:
            "You’re all caught up."
        case .archived:
            "Chats you archive will appear here."
        }
    }

    private var emptySymbol: String {
        guard searchText.isEmpty else {
            return "magnifyingglass"
        }

        return scope.symbol
    }
}

private struct ReadAllBottomBar: ViewModifier {
    let isVisible: Bool
    let action: () -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        if isVisible {
            content
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Read All", action: action)
                    }

                    ToolbarSpacer(.flexible, placement: .bottomBar)
                }
        } else {
            content
        }
    }
}

private struct OnDemandChatSearch: ViewModifier {
    @Binding var searchText: String
    @Binding var isMounted: Bool
    @Binding var isPresented: Bool
    var isFocused: FocusState<Bool>.Binding

    @ViewBuilder
    func body(content: Content) -> some View {
        if isMounted {
            content
                .searchable(
                    text: $searchText,
                    isPresented: $isPresented,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Chats"
                )
                .searchFocused(isFocused)
                .task {
                    await Task.yield()
                    isPresented = true
                    await Task.yield()
                    isFocused.wrappedValue = true
                }
                .onChange(of: isPresented) { _, presented in
                    if !presented {
                        isFocused.wrappedValue = false
                        isMounted = false
                    }
                }
        } else {
            content
        }
    }
}

#Preview("Chats — Empty") {
    NavigationStack {
        ChatsView(chats: ChatListFixtures.empty, onNewMessage: {})
    }
    .tint(Color("AccentColor"))
}

#Preview("Chats — Populated") {
    NavigationStack {
        ChatsView(chats: ChatListFixtures.populated, onNewMessage: {})
    }
    .tint(Color("AccentColor"))
}

#Preview("Chats — Empty Unread") {
    NavigationStack {
        ChatsView(
            chats: ChatListFixtures.empty,
            initialScope: .unread,
            onNewMessage: {}
        )
    }
    .tint(Color("AccentColor"))
}

#Preview("Chats — Empty Archived") {
    NavigationStack {
        ChatsView(
            chats: ChatListFixtures.empty,
            initialScope: .archived,
            onNewMessage: {}
        )
    }
    .tint(Color("AccentColor"))
}

#Preview("Chats — Search No Results") {
    NavigationStack {
        ChatsView(
            chats: ChatListFixtures.populated,
            initialSearchText: "No matching chat",
            onNewMessage: {}
        )
    }
    .tint(Color("AccentColor"))
}

#Preview("Chats — Empty Dark") {
    NavigationStack {
        ChatsView(chats: ChatListFixtures.empty, onNewMessage: {})
    }
    .tint(Color("AccentColor"))
    .preferredColorScheme(.dark)
}
