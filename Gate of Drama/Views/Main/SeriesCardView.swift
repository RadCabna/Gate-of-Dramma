import SwiftUI

struct SeriesCardView: View {
    let series: Series

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            coverImage
            infoRow
                .padding(.horizontal, screenHeight * 0.018)
                .padding(.vertical, screenHeight * 0.016)
        }
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
    }

    private var coverImage: some View {
        ZStack(alignment: .topTrailing) {
            let cardWidth = screenWidth - screenHeight * 0.05

            Group {
                if let url = URL(string: series.imageURL), series.imageURL.hasPrefix("http") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            imagePlaceholder
                        }
                    }
                } else {
                    imagePlaceholder
                }
            }
            .frame(width: cardWidth, height: screenHeight * 0.26)
            .clipped()

            statusBadge
                .padding(screenHeight * 0.015)
        }
        .cornerRadius(screenHeight * 0.018)
    }

    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: screenHeight * 0.035, weight: .light))
                    .foregroundColor(AppColors.textSecondary)
            )
    }

    private var statusBadge: some View {
        Text(series.status.rawValue)
            .font(Font.custom("Inter-Bold", size: screenHeight * 0.013))
            .foregroundColor(.white)
            .padding(.horizontal, screenHeight * 0.013)
            .padding(.vertical, screenHeight * 0.007)
            .background(badgeColor.opacity(0.72))
            .cornerRadius(screenHeight * 0.01)
    }

    private var badgeColor: Color {
        switch series.status {
        case .watching: return AppColors.gold
        case .completed: return Color(red: 0.18, green: 0.72, blue: 0.48)
        case .dropped: return Color(red: 0.85, green: 0.32, blue: 0.32)
        }
    }

    private var infoRow: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.009) {
            Text(series.title)
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.022))
                .foregroundColor(.white)
                .lineLimit(1)

            HStack(spacing: 0) {
                starsRow
                Spacer()
                if let eps = series.totalEpisodes, eps > 0 {
                    Text("\(eps) Episodes")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    private var starsRow: some View {
        HStack(spacing: screenHeight * 0.005) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= series.rating ? "star.fill" : "star")
                    .font(.system(size: screenHeight * 0.019))
                    .foregroundColor(star <= series.rating ? AppColors.gold : Color.white.opacity(0.25))
            }
        }
    }
}
