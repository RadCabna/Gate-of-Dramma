import SwiftUI

struct OnboardingPage3View: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("onboardingImage_3")
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.32)

            Spacer()

            pageText(
                title: "Drama Lives in\nRelationships.",
                subtitle: "Map lovers, enemies, sisters, rivals — and uncover the complexity."
            )
        }
    }
}
