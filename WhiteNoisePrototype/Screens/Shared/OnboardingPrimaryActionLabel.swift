import SwiftUI
import UIKit

struct OnboardingPrimaryActionLabel: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: LocalizedStringKey
    let isLoading: Bool

    private var contentColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var body: some View {
        ZStack {
            Text(title)
                .foregroundStyle(contentColor)
                .opacity(isLoading ? 0 : 1)

            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .tint(contentColor)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: isLoading)
    }
}
