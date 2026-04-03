import SwiftUI

struct ContentView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    var body: some View {
        if onboardingCompleted {
            MainView()
        } else {
            OnboardingView {
                onboardingCompleted = true
            }
        }
    }
}

#Preview {
    ContentView()
}
