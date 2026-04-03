import SwiftUI

struct SeriesDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var localSeries: Series
    @State private var showAddLog = false
    @State private var showEdit = false
    @State private var showRelationships = false

    var onUpdate: (Series) -> Void
    var onDelete: (() -> Void)? = nil

    init(series: Series, onUpdate: @escaping (Series) -> Void, onDelete: (() -> Void)? = nil) {
        self._localSeries = State(initialValue: series)
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    private let gradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.09, blue: 0.20),
            Color(red: 0.12, green: 0.07, blue: 0.25)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack(alignment: .top) {
            gradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    coverSection
                    logsSection
                        .padding(.horizontal, screenHeight * 0.025)
                        .padding(.top, screenHeight * 0.025)
                        .padding(.bottom, screenHeight * 0.12)
                }
            }

            topBar
                .padding(.horizontal, screenHeight * 0.025)
                .padding(.top, screenHeight * 0.015)
        }
        .fullScreenCover(isPresented: $showRelationships) {
            SeriesRelationshipsView(series: localSeries) { updated in
                localSeries = updated
                onUpdate(updated)
            }
        }
        .fullScreenCover(isPresented: $showEdit) {
            EditSeriesView(series: localSeries) { updated in
                localSeries = updated
                onUpdate(updated)
            } onDelete: {
                onDelete?()
                dismiss()
            }
        }
        .sheet(isPresented: $showAddLog) {
            AddLogSheet { log in
                localSeries.logs.append(log)
                onUpdate(localSeries)
            }
            .presentationDetents([.fraction(0.78)])
            .presentationBackground(Color(red: 0.10, green: 0.09, blue: 0.22))
            .presentationCornerRadius(screenHeight * 0.03)
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: screenHeight * 0.008) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: screenHeight * 0.018, weight: .medium))
                    Text("Back")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.018))
                }
                .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: screenHeight * 0.014) {
                iconButton("shareIcon", action: { showRelationships = true })
                iconButton("editIcon", action: { showEdit = true })
            }
        }
    }

    private func iconButton(_ name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight * 0.024, height: screenHeight * 0.024)
                .foregroundColor(.white)
                .padding(screenHeight * 0.012)
                .background(Color.white.opacity(0.08))
                .cornerRadius(screenHeight * 0.012)
                .overlay(
                    RoundedRectangle(cornerRadius: screenHeight * 0.012)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        }
    }

    private var coverSection: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let url = URL(string: localSeries.imageURL), localSeries.imageURL.hasPrefix("http") {
                    AsyncImage(url: url) { phase in
                        if case .success(let image) = phase {
                            image
                                .resizable()
                                .scaledToFill()
                                .opacity(0.82)
                        } else {
                            coverPlaceholder
                        }
                    }
                } else {
                    coverPlaceholder
                }
            }
            .frame(width: screenWidth, height: screenHeight * 0.42)
            .clipped()

            LinearGradient(
                colors: [.clear, Color(red: 0.07, green: 0.09, blue: 0.20)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: screenWidth, height: screenHeight * 0.28)

            VStack(alignment: .leading, spacing: screenHeight * 0.008) {
                statusBadge

                Text(localSeries.title)
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.034))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 4)

                HStack(spacing: screenHeight * 0.008) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= localSeries.rating ? "star.fill" : "star")
                            .font(.system(size: screenHeight * 0.018))
                            .foregroundColor(star <= localSeries.rating ? AppColors.gold : Color.white.opacity(0.35))
                    }

                    if localSeries.rating > 0 {
                        Text("\(localSeries.rating)/5")
                            .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    if let eps = localSeries.totalEpisodes, eps > 0 {
                        Text("•")
                            .foregroundColor(AppColors.textSecondary)
                        Text("\(eps) Episodes")
                            .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, screenHeight * 0.025)
            .padding(.bottom, screenHeight * 0.022)
        }
    }

    private var coverPlaceholder: some View {
        Rectangle()
            .fill(AppColors.cardDark)
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: screenHeight * 0.05, weight: .light))
                    .foregroundColor(AppColors.textSecondary)
            )
    }

    private var statusBadge: some View {
        let color: Color
        switch localSeries.status {
        case .watching:  color = AppColors.gold
        case .completed: color = Color(red: 0.18, green: 0.72, blue: 0.48)
        case .dropped:   color = Color(red: 0.85, green: 0.32, blue: 0.32)
        }
        return Text(localSeries.status.rawValue)
            .font(Font.custom("Inter-Bold", size: screenHeight * 0.013))
            .foregroundColor(.white)
            .padding(.horizontal, screenHeight * 0.013)
            .padding(.vertical, screenHeight * 0.007)
            .background(color.opacity(0.72))
            .cornerRadius(screenHeight * 0.01)
    }

    private var logsSection: some View {
        VStack(spacing: screenHeight * 0.018) {
            HStack {
                Text("Episode Logs")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.024))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { showAddLog = true }) {
                    HStack(spacing: screenHeight * 0.007) {
                        Image(systemName: "plus")
                            .font(.system(size: screenHeight * 0.015, weight: .semibold))
                        Text("Add Log")
                            .font(Font.custom("Inter-Bold", size: screenHeight * 0.016))
                    }
                    .foregroundColor(AppColors.darkNavy)
                    .padding(.horizontal, screenHeight * 0.022)
                    .padding(.vertical, screenHeight * 0.013)
                    .background(AppColors.gold)
                    .cornerRadius(screenHeight * 0.014)
                }
            }

            if localSeries.logs.isEmpty {
                Text("No episode logs yet")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, screenHeight * 0.04)
            } else {
                ForEach(localSeries.logs) { log in
                    EpisodeLogCard(log: log)
                }
            }
        }
    }
}

struct EpisodeLogCard: View {
    let log: EpisodeLog

    var body: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            Text("Episode \(log.episodeNumber)")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.014))
                .foregroundColor(AppColors.darkNavy)
                .padding(.horizontal, screenHeight * 0.016)
                .padding(.vertical, screenHeight * 0.008)
                .background(AppColors.gold.opacity(0.88))
                .cornerRadius(screenHeight * 0.022)

            if let emotion = log.emotion {
                Text(emotion.emoji)
                    .font(.system(size: screenHeight * 0.034))
            }

            if !log.note.isEmpty {
                Text(log.note)
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(screenHeight * 0.02)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.016)
    }
}
