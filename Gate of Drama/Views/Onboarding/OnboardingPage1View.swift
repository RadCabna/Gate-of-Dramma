import SwiftUI

struct OnboardingPage1View: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("appLogo")
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.38)
                .shadow(color: .black.opacity(0.3), radius: screenHeight * 0.03)

            Spacer()

            pageText(
                title: "Enter the World\nof Drama.",
                subtitle: "Track emotions. Map relationships. Analyze your dramatic journey."
            )
        }
    }
}
