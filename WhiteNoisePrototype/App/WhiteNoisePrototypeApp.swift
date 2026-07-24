import SwiftUI

@main
struct WhiteNoisePrototypeApp: App {
    var body: some Scene {
        WindowGroup {
            PrototypeRootView()
            .tint(Color("AccentColor"))
        }
    }
}

private struct PrototypeRootView: View {
    @State private var isShowingChats = false
    @State private var isShowingLogin = false
    @State private var isShowingSignUp = false

    var body: some View {
        Group {
            if isShowingChats {
                NavigationStack {
                    ChatsView(
                        chats: ChatListFixtures.populated,
                        onNewMessage: {}
                    )
                }
            } else {
                NavigationStack {
                    WelcomeView(
                        onLogin: {
                            isShowingLogin = true
                        },
                        onSignUp: {
                            isShowingSignUp = true
                        }
                    )
                    .navigationDestination(
                        isPresented: $isShowingLogin
                    ) {
                        LoginView {
                            isShowingChats = true
                        }
                    }
                    .navigationDestination(
                        isPresented: $isShowingSignUp
                    ) {
                        SignUpView {
                            isShowingChats = true
                        }
                    }
                }
            }
        }
    }
}
