import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    var onComplete: () -> Void

    private let gradient = LinearGradient(
        colors: [
            Color(red: 0.33, green: 0.11, blue: 0.58),
            Color(red: 0.48, green: 0.20, blue: 0.72),
            Color(red: 0.88, green: 0.56, blue: 0.08)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack {
            gradient.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") { onComplete() }
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.018))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.trailing, screenHeight * 0.025)
                }
                .frame(height: screenHeight * 0.06)

                TabView(selection: $currentPage) {
                    OnboardingPage1View().tag(0)
                    OnboardingPage2View().tag(1)
                    OnboardingPage3View().tag(2)
                    OnboardingPage4View().tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicators
                    .padding(.bottom, screenHeight * 0.028)

                actionButton
                    .padding(.horizontal, screenHeight * 0.04)
                    .padding(.bottom, screenHeight * 0.055)
            }
        }
    }

    private var pageIndicators: some View {
        HStack(spacing: screenHeight * 0.009) {
            ForEach(0..<4) { index in
                Capsule()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.35))
                    .frame(
                        width: index == currentPage ? screenHeight * 0.045 : screenHeight * 0.009,
                        height: screenHeight * 0.009
                    )
                    .animation(.easeInOut(duration: 0.25), value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        Button(action: handleTap) {
            HStack(spacing: screenHeight * 0.01) {
                if currentPage == 3 {
                    Image(systemName: "play.fill")
                        .font(.system(size: screenHeight * 0.017))
                }
                Text(buttonTitle)
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.022))
            }
            .foregroundColor(Color(red: 0.33, green: 0.11, blue: 0.58))
            .frame(maxWidth: .infinity)
            .frame(height: screenHeight * 0.072)
            .background(Color(red: 0.98, green: 0.77, blue: 0.18))
            .cornerRadius(screenHeight * 0.036)
        }
    }

    private var buttonTitle: String {
        switch currentPage {
        case 0: return "Begin"
        case 3: return "Start Watching"
        default: return "Next"
        }
    }

    private func handleTap() {
        if currentPage < 3 {
            withAnimation(.easeInOut(duration: 0.3)) { currentPage += 1 }
        } else {
            onComplete()
        }
    }
}
