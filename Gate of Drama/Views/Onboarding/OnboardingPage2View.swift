import SwiftUI

struct OnboardingPage2View: View {
    @State private var emoji1Offset: CGFloat = 0
    @State private var emoji2Offset: CGFloat = 0
    @State private var emoji3Offset: CGFloat = 0
    @State private var emoji4Scale: CGFloat = 1
    @State private var emoji5Rotation: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Image("onboardingImage_2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.32)

                Text("😢")
                    .font(.system(size: screenHeight * 0.038))
                    .offset(x: -screenHeight * 0.14, y: -screenHeight * 0.06 + emoji1Offset)

                Text("😤")
                    .font(.system(size: screenHeight * 0.032))
                    .offset(x: screenHeight * 0.14, y: -screenHeight * 0.08 + emoji2Offset)

                Text("😱")
                    .font(.system(size: screenHeight * 0.028))
                    .offset(x: -screenHeight * 0.16, y: screenHeight * 0.08 + emoji3Offset)

                Text("🤍")
                    .font(.system(size: screenHeight * 0.034))
                    .scaleEffect(emoji4Scale)
                    .offset(x: screenHeight * 0.15, y: screenHeight * 0.06)

                Text("😊")
                    .font(.system(size: screenHeight * 0.03))
                    .rotationEffect(.degrees(emoji5Rotation))
                    .offset(x: 0, y: -screenHeight * 0.13)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    emoji1Offset = -screenHeight * 0.018
                }
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(0.4)) {
                    emoji2Offset = screenHeight * 0.015
                }
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.8)) {
                    emoji3Offset = -screenHeight * 0.02
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.2)) {
                    emoji4Scale = 1.25
                }
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.6)) {
                    emoji5Rotation = 12
                }
            }

            Spacer()

            pageText(
                title: "Every Episode Has\na Feeling.",
                subtitle: "Log how each episode made you feel — from tears to shock."
            )
        }
    }
}
