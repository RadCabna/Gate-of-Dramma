import SwiftUI

extension View {
    func pageText(title: String, subtitle: String) -> some View {
        VStack(alignment: .center, spacing: screenHeight * 0.012) {
            Text(title)
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.038))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.018))
                .foregroundColor(.white.opacity(0.72))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, screenHeight * 0.04)
        .padding(.bottom, screenHeight * 0.04)
    }
}

enum OnboardingColors {
    static let cardBackground = Color(red: 0.16, green: 0.08, blue: 0.34)
    static let badgePurple = Color(red: 0.45, green: 0.22, blue: 0.78)
    static let accentGold = Color(red: 0.98, green: 0.77, blue: 0.18)
    static let deepPurple = Color(red: 0.33, green: 0.11, blue: 0.58)
    static let darkCircle = Color(red: 0.10, green: 0.05, blue: 0.22)
    static let badgeDark = Color(red: 0.20, green: 0.10, blue: 0.38)
}
