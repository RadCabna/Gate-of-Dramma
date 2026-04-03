import SwiftUI

struct OnboardingPage4View: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("onboardingImage_4")
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.32)

            Spacer()

            pageText(
                title: "See Your Emotional\nPatterns.",
                subtitle: "Discover your most dramatic series and dominant emotions."
            )
        }
    }
}
