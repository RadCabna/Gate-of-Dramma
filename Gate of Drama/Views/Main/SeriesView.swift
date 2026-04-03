import SwiftUI

struct SeriesView: View {
    @EnvironmentObject private var store: SeriesStore
    @State private var showAddSeries = false
    @State private var selectedSeries: Series? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, screenHeight * 0.025)
                    .padding(.top, screenHeight * 0.015)
                    .padding(.bottom, screenHeight * 0.01)

                if store.seriesList.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: screenHeight * 0.018) {
                            ForEach(store.seriesList) { series in
                                SeriesCardView(series: series)
                                    .onTapGesture { selectedSeries = series }
                            }
                        }
                        .padding(.horizontal, screenHeight * 0.025)
                        .padding(.top, screenHeight * 0.012)
                        .padding(.bottom, screenHeight * 0.14)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !store.seriesList.isEmpty {
                floatingAddButton
                    .padding(.trailing, screenHeight * 0.025)
                    .padding(.bottom, screenHeight * 0.11)
            }
        }
        .fullScreenCover(isPresented: $showAddSeries) {
            AddSeriesView { newSeries in
                store.add(newSeries)
            }
        }
        .fullScreenCover(item: $selectedSeries) { series in
            SeriesDetailView(series: series) { updated in
                store.update(updated)
            } onDelete: {
                store.delete(id: series.id)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.006) {
            HStack(spacing: 0) {
                Text("Gate of ")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.034))
                    .foregroundColor(.white)
                Text("Drama")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.034))
                    .foregroundColor(AppColors.gold)
            }
            Text("Discover your emotional journey")
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.017))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: screenHeight * 0.022) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: screenHeight * 0.11, height: screenHeight * 0.11)
                Image(systemName: "plus")
                    .font(.system(size: screenHeight * 0.038, weight: .light))
                    .foregroundColor(AppColors.gold)
            }
            .onTapGesture { showAddSeries = true }

            VStack(spacing: screenHeight * 0.01) {
                Text("No series added yet")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.022))
                    .foregroundColor(.white)
                Text("Start your emotional journey by adding\nyour first series")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { showAddSeries = true }) {
                Text("Add Series")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.020))
                    .foregroundColor(AppColors.darkNavy)
                    .padding(.horizontal, screenHeight * 0.055)
                    .padding(.vertical, screenHeight * 0.018)
                    .background(AppColors.gold)
                    .cornerRadius(screenHeight * 0.018)
                    .shadow(color: AppColors.gold.opacity(0.45), radius: screenHeight * 0.025, x: 0, y: screenHeight * 0.008)
            }
            .padding(.top, screenHeight * 0.008)
        }
    }

    private var floatingAddButton: some View {
        Button(action: { showAddSeries = true }) {
            ZStack {
                Circle()
                    .fill(AppColors.gold)
                    .frame(width: screenHeight * 0.072, height: screenHeight * 0.072)
                    .shadow(color: AppColors.gold.opacity(0.50), radius: screenHeight * 0.022, x: 0, y: screenHeight * 0.008)
                Image(systemName: "plus")
                    .font(.system(size: screenHeight * 0.028, weight: .medium))
                    .foregroundColor(AppColors.darkNavy)
            }
        }
    }
}
