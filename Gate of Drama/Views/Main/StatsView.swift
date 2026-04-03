import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: SeriesStore

    private var totalSeries: Int {
        store.seriesList.count
    }

    private var avgRating: Double {
        let rated = store.seriesList.filter { $0.rating > 0 }
        guard !rated.isEmpty else { return 0 }
        return Double(rated.map(\.rating).reduce(0, +)) / Double(rated.count)
    }

    private var avgRatingText: String {
        avgRating > 0 ? String(format: "%.1f", avgRating) : "—"
    }

    private var completedCount: Int {
        store.seriesList.filter { $0.status == .completed }.count
    }

    private var droppedCount: Int {
        store.seriesList.filter { $0.status == .dropped }.count
    }

    private var emotionCounts: [(Emotion, Int)] {
        var counts: [Emotion: Int] = [:]
        for series in store.seriesList {
            for log in series.logs {
                if let e = log.emotion { counts[e, default: 0] += 1 }
            }
        }
        return Emotion.allCases.compactMap { e in counts[e].map { (e, $0) } }
            .sorted { $0.1 > $1.1 }
    }

    private var emotionTotal: Int {
        emotionCounts.map(\.1).reduce(0, +)
    }

    private var ratingDistribution: [Int: Int] {
        var dist: [Int: Int] = [:]
        for series in store.seriesList where series.rating > 0 {
            dist[series.rating, default: 0] += 1
        }
        return dist
    }

    private var ratingMax: Int {
        max((1...5).map { ratingDistribution[$0, default: 0] }.max() ?? 1, 1)
    }

    private var mostEmotionalSeries: [(Series, Int)] {
        store.seriesList
            .map { ($0, $0.logs.count) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: screenHeight * 0.025) {
                header
                statsGrid
                emotionalAnalysisCard
                ratingDistributionCard
                if !mostEmotionalSeries.isEmpty {
                    mostEmotionalSeriesCard
                }
            }
            .padding(.horizontal, screenHeight * 0.025)
            .padding(.top, screenHeight * 0.015)
            .padding(.bottom, screenHeight * 0.14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
            HStack(spacing: screenHeight * 0.008) {
                Text("Statistics")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.032))
                    .foregroundColor(.white)
                Text("& Analytics")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.032))
                    .foregroundColor(AppColors.gold)
            }
            Text("Summary of your watching journey")
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: screenHeight * 0.014),
                      GridItem(.flexible(), spacing: screenHeight * 0.014)],
            spacing: screenHeight * 0.014
        ) {
            StatCard(icon: "tv", label: "Total Series",
                     value: "\(totalSeries)", valueColor: .white)
            StatCard(icon: "star", label: "Avg Rating",
                     value: avgRatingText, suffix: avgRating > 0 ? "/5" : nil,
                     valueColor: .white)
            StatCard(icon: "chart.line.uptrend.xyaxis", label: "Completed",
                     value: "\(completedCount)",
                     valueColor: Color(red: 0.18, green: 0.82, blue: 0.55))
            StatCard(icon: "calendar", label: "Dropped",
                     value: "\(droppedCount)", valueColor: AppColors.textSecondary)
        }
    }

    private var emotionalAnalysisCard: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.02) {
            Text("Emotional Analysis")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.020))
                .foregroundColor(.white)

            if emotionCounts.isEmpty {
                Text("No emotional logs yet")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, screenHeight * 0.03)
            } else {
                DonutChart(segments: emotionCounts.map { (emotionColor($0.0), $0.1) })
                    .frame(width: screenHeight * 0.2, height: screenHeight * 0.2)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, screenHeight * 0.01)

                emotionLegend
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(screenHeight * 0.02)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.018)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private var emotionLegend: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.01) {
            ForEach(emotionCounts, id: \.0.id) { item in
                EmotionLegendRow(
                    emotion: item.0,
                    count: item.1,
                    total: emotionTotal,
                    color: emotionColor(item.0)
                )
            }
        }
    }

    private var ratingDistributionCard: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.018) {
            Text("Rating Distribution")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.020))
                .foregroundColor(.white)

            RatingBarChart(distribution: ratingDistribution, maxVal: ratingMax)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(screenHeight * 0.02)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.018)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private var mostEmotionalSeriesCard: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            Text("Most Emotional Series")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.020))
                .foregroundColor(.white)

            ForEach(Array(mostEmotionalSeries.prefix(5).enumerated()), id: \.offset) { idx, item in
                EmotionalSeriesRow(rank: idx + 1, series: item.0, count: item.1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(screenHeight * 0.02)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.018)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private func emotionColor(_ emotion: Emotion) -> Color {
        switch emotion {
        case .cried:   return Color(red: 0.35, green: 0.55, blue: 0.95)
        case .furious: return Color(red: 0.90, green: 0.25, blue: 0.28)
        case .amazed:  return Color(red: 0.95, green: 0.60, blue: 0.20)
        case .shocked: return Color(red: 0.62, green: 0.45, blue: 0.95)
        case .touched: return Color(red: 0.90, green: 0.45, blue: 0.68)
        }
    }
}

private struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    var suffix: String? = nil
    let valueColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            HStack(spacing: screenHeight * 0.007) {
                Image(systemName: icon)
                    .font(.system(size: screenHeight * 0.016))
                    .foregroundColor(AppColors.gold)
                Text(label)
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.014))
                    .foregroundColor(AppColors.textSecondary)
            }
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.036))
                    .foregroundColor(valueColor)
                if let suffix = suffix {
                    Text(suffix)
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(screenHeight * 0.018)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.016)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.016)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    }
}

private struct EmotionLegendRow: View {
    let emotion: Emotion
    let count: Int
    let total: Int
    let color: Color

    private var percentage: Int {
        guard total > 0 else { return 0 }
        return Int(Double(count) / Double(total) * 100)
    }

    var body: some View {
        HStack(spacing: screenHeight * 0.01) {
            Circle()
                .fill(color)
                .frame(width: screenHeight * 0.012, height: screenHeight * 0.012)
            Text(emotion.label)
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                .foregroundColor(.white)
            Text("\(percentage)%")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.015))
                .foregroundColor(.white)
        }
    }
}

private struct RatingBarChart: View {
    let distribution: [Int: Int]
    let maxVal: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            yAxis
                .padding(.trailing, screenHeight * 0.01)
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(1...5, id: \.self) { star in
                    RatingBar(star: star, count: distribution[star, default: 0], maxVal: maxVal)
                }
            }
        }
        .frame(height: screenHeight * 0.185)
    }

    private var yAxis: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("1").font(Font.custom("Inter-Regular", size: screenHeight * 0.011))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text("0.75").font(Font.custom("Inter-Regular", size: screenHeight * 0.011))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text("0.5").font(Font.custom("Inter-Regular", size: screenHeight * 0.011))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text("0.25").font(Font.custom("Inter-Regular", size: screenHeight * 0.011))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text("0").font(Font.custom("Inter-Regular", size: screenHeight * 0.011))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(height: screenHeight * 0.16)
    }
}

private struct RatingBar: View {
    let star: Int
    let count: Int
    let maxVal: Int

    private var fraction: CGFloat {
        count > 0 ? CGFloat(count) / CGFloat(maxVal) : 0
    }

    var body: some View {
        VStack(spacing: screenHeight * 0.008) {
            RoundedRectangle(cornerRadius: screenHeight * 0.006)
                .fill(AppColors.gold)
                .frame(maxWidth: .infinity)
                .frame(height: fraction > 0 ? fraction * screenHeight * 0.15 : screenHeight * 0.004)
            HStack(spacing: 2) {
                Text("\(star)")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.012))
                    .foregroundColor(AppColors.textSecondary)
                Image(systemName: "star.fill")
                    .font(.system(size: screenHeight * 0.010))
                    .foregroundColor(AppColors.gold)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct EmotionalSeriesRow: View {
    let rank: Int
    let series: Series
    let count: Int

    var body: some View {
        HStack(spacing: screenHeight * 0.014) {
            ZStack {
                Circle()
                    .fill(AppColors.gold)
                    .frame(width: screenHeight * 0.038, height: screenHeight * 0.038)
                Text("\(rank)")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.016))
                    .foregroundColor(AppColors.darkNavy)
            }
            VStack(alignment: .leading, spacing: screenHeight * 0.003) {
                Text(series.title)
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.016))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("\(count) emotional log\(count == 1 ? "" : "s")")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "heart")
                .font(.system(size: screenHeight * 0.018))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(screenHeight * 0.016)
        .background(Color.white.opacity(0.05))
        .cornerRadius(screenHeight * 0.014)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.014)
            .stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct DonutChart: View {
    let segments: [(Color, Int)]

    private var total: Int { segments.map(\.1).reduce(0, +) }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.05), lineWidth: screenHeight * 0.038)
            ForEach(Array(segments.enumerated()), id: \.offset) { idx, segment in
                DonutSegment(
                    color: segment.0,
                    start: startFraction(for: idx),
                    end: endFraction(for: idx),
                    gap: total > 1 ? 0.008 : 0
                )
            }
        }
        .padding(screenHeight * 0.02)
    }

    private func startFraction(for idx: Int) -> Double {
        segments[0..<idx].map { Double($0.1) / Double(total) }.reduce(0, +)
    }

    private func endFraction(for idx: Int) -> Double {
        startFraction(for: idx) + Double(segments[idx].1) / Double(total)
    }
}

private struct DonutSegment: View {
    let color: Color
    let start: Double
    let end: Double
    let gap: Double

    var body: some View {
        Circle()
            .trim(from: start + gap, to: end - gap)
            .stroke(color, style: StrokeStyle(lineWidth: screenHeight * 0.038, lineCap: .butt))
            .rotationEffect(.degrees(-90))
    }
}
