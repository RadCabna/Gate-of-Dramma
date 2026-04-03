import SwiftUI

struct RelationshipsView: View {
    @EnvironmentObject private var store: SeriesStore
    @State private var selectedSeries: Series? = nil

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, screenHeight * 0.025)
                .padding(.top, screenHeight * 0.015)
                .padding(.bottom, screenHeight * 0.022)

            if store.seriesList.isEmpty {
                Spacer()
                emptyState
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.014) {
                        ForEach(store.seriesList) { series in
                            seriesRow(series)
                                .onTapGesture { selectedSeries = series }
                        }
                    }
                    .padding(.horizontal, screenHeight * 0.025)
                    .padding(.bottom, screenHeight * 0.14)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(item: $selectedSeries) { series in
            SeriesRelationshipsView(series: series) { updated in
                store.update(updated)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.004) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Character")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.038))
                    .foregroundColor(.white)
                Text("Relationships")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.038))
                    .foregroundColor(AppColors.gold)
            }
            Text("Discover character connections in your series")
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: screenHeight * 0.012) {
            Text("No series yet")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.022))
                .foregroundColor(.white)
            Text("Add series in the Series tab first")
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func seriesRow(_ series: Series) -> some View {
        HStack(spacing: screenHeight * 0.016) {
            Group {
                if let url = URL(string: series.imageURL), series.imageURL.hasPrefix("http") {
                    AsyncImage(url: url) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                        } else {
                            RoundedRectangle(cornerRadius: screenHeight * 0.01)
                                .fill(Color.white.opacity(0.08))
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: screenHeight * 0.01)
                        .fill(Color.white.opacity(0.08))
                        .overlay(Image(systemName: "photo").foregroundColor(AppColors.textSecondary))
                }
            }
            .frame(width: screenHeight * 0.065, height: screenHeight * 0.065)
            .cornerRadius(screenHeight * 0.012)

            VStack(alignment: .leading, spacing: screenHeight * 0.006) {
                Text(series.title)
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: screenHeight * 0.006) {
                    Image(systemName: "person.2")
                        .font(.system(size: screenHeight * 0.013))
                        .foregroundColor(AppColors.textSecondary)
                    Text("\(series.characters.count) Characters")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.014))
                        .foregroundColor(AppColors.textSecondary)

                    Text("•").foregroundColor(AppColors.textSecondary)
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.014))

                    Image(systemName: "heart")
                        .font(.system(size: screenHeight * 0.013))
                        .foregroundColor(AppColors.textSecondary)
                    Text("\(series.relationships.count) Relations")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.014))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: screenHeight * 0.014, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(screenHeight * 0.018)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.016)
    }
}
