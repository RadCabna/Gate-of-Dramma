import SwiftUI

enum AppTab {
    case series, relationships, stats
}

struct MainView: View {
    @StateObject private var store = SeriesStore()
    @State private var selectedTab: AppTab = .series

    private let gradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.09, blue: 0.20),
            Color(red: 0.12, green: 0.07, blue: 0.25)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            gradient.ignoresSafeArea()

            switch selectedTab {
            case .series:
                SeriesView()
            case .relationships:
                RelationshipsView()
            case .stats:
                StatsView()
            }

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
        .environmentObject(store)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    private let tabs: [(tab: AppTab, icon: String, label: String)] = [
        (.series, "series", "Series"),
        (.relationships, "relationships", "Relationships"),
        (.stats, "stats", "Stats")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(tabs, id: \.label) { item in
                    tabButton(item.tab, icon: item.icon, label: item.label)
                }
            }
            .padding(.top, screenHeight * 0.012)
            .padding(.bottom, screenHeight * 0.034)
            .background(Color(red: 0.07, green: 0.08, blue: 0.17))
        }
    }

    private func tabButton(_ tab: AppTab, icon: String, label: String) -> some View {
        let isActive = selectedTab == tab
        return Button(action: { selectedTab = tab }) {
            VStack(spacing: screenHeight * 0.006) {
                Image(isActive ? "\(icon)On" : "\(icon)Off")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.030)

                Text(label)
                    .font(Font.custom(isActive ? "Inter-Bold" : "Inter-Regular", size: screenHeight * 0.013))
                    .foregroundColor(isActive ? AppColors.gold : Color.white.opacity(0.40))

                Rectangle()
                    .fill(isActive ? AppColors.gold : Color.clear)
                    .frame(width: screenHeight * 0.05, height: screenHeight * 0.003)
                    .cornerRadius(screenHeight * 0.002)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

enum AppColors {
    static let gold = Color(red: 0.96, green: 0.76, blue: 0.22)
    static let darkNavy = Color(red: 0.07, green: 0.09, blue: 0.20)
    static let cardDark = Color(red: 0.11, green: 0.10, blue: 0.24)
    static let badgePurple = Color(red: 0.38, green: 0.28, blue: 0.68)
    static let textSecondary = Color.white.opacity(0.50)
}
