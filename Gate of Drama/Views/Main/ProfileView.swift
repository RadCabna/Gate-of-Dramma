import SwiftUI
import PhotosUI
import PDFKit
struct ProfileView: View {
    @EnvironmentObject private var profileStore: UserProfileStore
    @EnvironmentObject private var seriesStore: SeriesStore
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var isEditingUsername = false
    @State private var usernameInput = ""
    @State private var selectedSeriesIDs: Set<UUID> = []
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false
    @State private var isPDFExport = false
    @State private var showPDFSuccess = false

    private var seriesCount: Int { seriesStore.seriesList.count }
    private var completedCount: Int { seriesStore.seriesList.filter { $0.status == .completed }.count }
    private var watchingCount: Int { seriesStore.seriesList.filter { $0.status == .watching }.count }
    private var dramaLevel: DramaLevel { profileStore.dramaLevel(seriesCount: seriesCount) }
    private var progress: Double { profileStore.progressToNextLevel(seriesCount: seriesCount) }
    private var needed: Int { profileStore.seriesNeededForNextLevel(seriesCount: seriesCount) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: screenHeight * 0.025) {
                header
                profileCard
                dramaLevelCard
                collectionCard
                shareYourTasteCard
                settingsCard
            }
            .padding(.horizontal, screenHeight * 0.025)
            .padding(.top, screenHeight * 0.015)
            .padding(.bottom, screenHeight * 0.14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: selectedPhoto) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    profileStore.avatarData = data
                }
            }
        }
        .sheet(isPresented: $showShareSheet, onDismiss: {
            if isPDFExport {
                isPDFExport = false
                withAnimation(.easeInOut(duration: 0.3)) { showPDFSuccess = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.3)) { showPDFSuccess = false }
                }
            }
        }) {
            if !shareItems.isEmpty {
                ShareSheet(items: shareItems)
            }
        }
        .overlay(alignment: .bottom) {
            if showPDFSuccess {
                HStack(spacing: screenHeight * 0.012) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: screenHeight * 0.022))
                        .foregroundColor(Color(red: 0.18, green: 0.72, blue: 0.48))
                    Text("PDF exported successfully!")
                        .font(Font.custom("Inter-Bold", size: screenHeight * 0.016))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, screenHeight * 0.022)
                .padding(.vertical, screenHeight * 0.018)
                .background(
                    RoundedRectangle(cornerRadius: screenHeight * 0.016)
                        .fill(Color(red: 0.13, green: 0.11, blue: 0.26))
                        .overlay(
                            RoundedRectangle(cornerRadius: screenHeight * 0.016)
                                .stroke(Color(red: 0.18, green: 0.72, blue: 0.48).opacity(0.5), lineWidth: 1)
                        )
                )
                .padding(.horizontal, screenHeight * 0.025)
                .padding(.bottom, screenHeight * 0.13)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
            HStack(spacing: screenHeight * 0.008) {
                Text("Your")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.032))
                    .foregroundColor(.white)
                Text("Profile")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.032))
                    .foregroundColor(AppColors.gold)
            }
            Text("Your viewing identity")
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private var profileCard: some View {
        VStack(spacing: screenHeight * 0.016) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(AppColors.cardDark)
                        .frame(width: screenHeight * 0.11, height: screenHeight * 0.11)
                        .overlay(
                            Group {
                                if let data = profileStore.avatarData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: screenHeight * 0.045))
                                        .foregroundColor(AppColors.gold.opacity(0.8))
                                }
                            }
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        colors: [AppColors.gold, AppColors.gold.opacity(0.3), AppColors.gold],
                                        center: .center
                                    ),
                                    lineWidth: screenHeight * 0.004
                                )
                        )

                    ZStack {
                        Circle()
                            .fill(AppColors.gold)
                            .frame(width: screenHeight * 0.032, height: screenHeight * 0.032)
                        Image(systemName: "camera.fill")
                            .font(.system(size: screenHeight * 0.014))
                            .foregroundColor(AppColors.darkNavy)
                    }
                }
            }

            VStack(spacing: screenHeight * 0.006) {
                if isEditingUsername {
                    HStack(spacing: screenHeight * 0.01) {
                        TextField("Your name", text: $usernameInput)
                            .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(.white)
                            .padding(.horizontal, screenHeight * 0.016)
                            .padding(.vertical, screenHeight * 0.012)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(screenHeight * 0.022)
                            .frame(maxWidth: screenHeight * 0.22)

                        Button(action: {
                            let trimmed = usernameInput.trimmingCharacters(in: .whitespaces)
                            if !trimmed.isEmpty { profileStore.username = trimmed }
                            isEditingUsername = false
                        }) {
                            Text("Save")
                                .font(Font.custom("Inter-Bold", size: screenHeight * 0.016))
                                .foregroundColor(AppColors.darkNavy)
                                .padding(.horizontal, screenHeight * 0.018)
                                .padding(.vertical, screenHeight * 0.012)
                                .background(AppColors.gold)
                                .cornerRadius(screenHeight * 0.022)
                        }
                    }
                } else {
                    Text(profileStore.username)
                        .font(Font.custom("Inter-Bold", size: screenHeight * 0.022))
                        .foregroundColor(.white)
                        .onTapGesture {
                            usernameInput = profileStore.username
                            isEditingUsername = true
                        }
                }
                Text("Drama enthusiast since \(profileStore.joinYear, format: .number.grouping(.never))")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.014))
                    .foregroundColor(AppColors.textSecondary)
            }

            HStack(spacing: screenHeight * 0.006) {
                Text(dramaLevel.emoji)
                    .font(.system(size: screenHeight * 0.016))
                Text(dramaLevel.rawValue)
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.015))
                    .foregroundColor(AppColors.darkNavy)
            }
            .padding(.horizontal, screenHeight * 0.022)
            .padding(.vertical, screenHeight * 0.01)
            .background(AppColors.gold)
            .cornerRadius(screenHeight * 0.022)
        }
        .frame(maxWidth: .infinity)
        .padding(screenHeight * 0.022)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.018)
            .stroke(AppColors.gold.opacity(0.25), lineWidth: 1))
    }

    private var dramaLevelCard: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            HStack {
                Text("Drama Level Progress")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                    .foregroundColor(.white)
                Spacer()
                HStack(spacing: screenHeight * 0.008) {
                    Text("✅ \(completedCount)")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                        .foregroundColor(Color(red: 0.18, green: 0.72, blue: 0.48))
                    Text("▶ \(watchingCount)")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                        .foregroundColor(AppColors.gold)
                }
            }

            levelProgressBar

            HStack(spacing: 0) {
                ForEach([DramaLevel.beginner, .enthusiast, .legend], id: \.rawValue) { level in
                    VStack(spacing: screenHeight * 0.006) {
                        Text(level.emoji)
                            .font(.system(size: screenHeight * 0.022))
                            .opacity(dramaLevel == level ? 1 : 0.4)
                        Text(level.rawValue)
                            .font(Font.custom(dramaLevel == level ? "Inter-Bold" : "Inter-Regular",
                                             size: screenHeight * 0.012))
                            .foregroundColor(dramaLevel == level ? .white : AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if dramaLevel != .legend {
                Text("Complete \(needed) more series to level up!")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(screenHeight * 0.02)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.018)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private var levelProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: screenHeight * 0.005)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: screenHeight * 0.008)

                RoundedRectangle(cornerRadius: screenHeight * 0.005)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gold.opacity(0.7), AppColors.gold],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(progress), height: screenHeight * 0.008)
            }
        }
        .frame(height: screenHeight * 0.008)
    }

    private var collectionCard: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.016) {
            HStack {
                Text("Your Collection")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { selectedSeriesIDs = Set(seriesStore.seriesList.map(\.id)) }) {
                    Text("Select All")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                        .foregroundColor(AppColors.gold)
                }
                Text("|").foregroundColor(AppColors.textSecondary)
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                Button(action: { selectedSeriesIDs = [] }) {
                    Text("Clear")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            if seriesStore.seriesList.isEmpty {
                Text("No series added yet")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, screenHeight * 0.02)
            } else {
                VStack(spacing: screenHeight * 0.01) {
                    ForEach(seriesStore.seriesList) { series in
                        CollectionRow(
                            series: series,
                            isSelected: selectedSeriesIDs.contains(series.id),
                            onToggle: {
                                if selectedSeriesIDs.contains(series.id) {
                                    selectedSeriesIDs.remove(series.id)
                                } else {
                                    selectedSeriesIDs.insert(series.id)
                                }
                            }
                        )
                    }
                }

                HStack(spacing: screenHeight * 0.014) {
                    Button(action: exportPDF) {
                        HStack(spacing: screenHeight * 0.009) {
                            Image("pdfIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(height: screenHeight * 0.022)
                            Text("Export PDF")
                                .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                        }
                        .foregroundColor(AppColors.darkNavy)
                        .frame(maxWidth: .infinity)
                        .frame(height: screenHeight * 0.065)
                        .background(selectedSeriesIDs.isEmpty ? AppColors.gold.opacity(0.45) : AppColors.gold)
                        .cornerRadius(screenHeight * 0.016)
                    }
                    .disabled(selectedSeriesIDs.isEmpty)

                    Button(action: shareSeries) {
                        HStack(spacing: screenHeight * 0.009) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: screenHeight * 0.017))
                            Text("Share")
                                .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: screenHeight * 0.065)
                        .background(Color(red: 0.28, green: 0.30, blue: 0.42))
                        .cornerRadius(screenHeight * 0.016)
                    }
                }
                .padding(.top, screenHeight * 0.006)
            }
        }
        .padding(screenHeight * 0.02)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.018)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private var shareYourTasteCard: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            Text("Share Your Taste")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                .foregroundColor(.white)

            VStack(spacing: screenHeight * 0.008) {
                Text(selectedSeriesIDs.isEmpty ? "Select series to preview" :
                     selectedSeriesIDs.compactMap { id in
                         seriesStore.seriesList.first { $0.id == id }?.title
                     }.joined(separator: ", "))
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                    .foregroundColor(selectedSeriesIDs.isEmpty ? AppColors.textSecondary : .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)

                if selectedSeriesIDs.isEmpty {
                    Text("Let others discover dramas through your curated collection")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(screenHeight * 0.016)
            .background(Color.white.opacity(0.04))
            .cornerRadius(screenHeight * 0.014)
            .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.014)
                .stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .padding(screenHeight * 0.02)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.018)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.004) {
            Text("Settings")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                .foregroundColor(.white)
                .padding(.bottom, screenHeight * 0.008)

            Button(action: { onboardingCompleted = false }) {
                HStack(spacing: screenHeight * 0.012) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: screenHeight * 0.018))
                        .foregroundColor(AppColors.textSecondary)
                    Text("Replay Onboarding")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: screenHeight * 0.013))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(screenHeight * 0.016)
                .background(Color.white.opacity(0.04))
                .cornerRadius(screenHeight * 0.014)
                .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.014)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1))
            }
        }
        .padding(screenHeight * 0.02)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
        .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.018)
            .stroke(Color.white.opacity(0.07), lineWidth: 1))
    }

    private func exportPDF() {
        let selected = seriesStore.seriesList.filter { selectedSeriesIDs.contains($0.id) }
        guard !selected.isEmpty else { return }

        let pdfData = buildPDF(for: selected, username: profileStore.username)
        if let url = savePDFToTemp(data: pdfData) {
            shareItems = [url]
            isPDFExport = true
            showShareSheet = true
        }
    }

    private func shareSeries() {
        let selected = seriesStore.seriesList.filter { selectedSeriesIDs.contains($0.id) }
        guard !selected.isEmpty else { return }

        let text = "🎭 My Drama Collection — \(profileStore.username)\n\n" +
            selected.enumerated().map { idx, s in
                "\(idx + 1). \(s.title) [\(s.status.rawValue)] \(s.rating > 0 ? "⭐ \(s.rating)/5" : "")"
            }.joined(separator: "\n")

        shareItems = [text]
        showShareSheet = true
    }

    private func buildPDF(for series: [Series], username: String) -> Data {
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let margin: CGFloat = 44
        let contentWidth = pageWidth - margin * 2
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let navy = UIColor(red: 0.09, green: 0.07, blue: 0.20, alpha: 1)
        let gold = UIColor(red: 0.93, green: 0.75, blue: 0.32, alpha: 1)
        let cardBg = UIColor(red: 0.13, green: 0.11, blue: 0.26, alpha: 1)
        let textSecondary = UIColor(red: 0.60, green: 0.58, blue: 0.75, alpha: 1)
        let white = UIColor.white
        let green = UIColor(red: 0.18, green: 0.72, blue: 0.48, alpha: 1)
        let orange = UIColor(red: 0.95, green: 0.60, blue: 0.25, alpha: 1)
        let red = UIColor(red: 0.85, green: 0.32, blue: 0.32, alpha: 1)

        let titleFont = UIFont.boldSystemFont(ofSize: 26)
        let subtitleFont = UIFont.systemFont(ofSize: 13)
        let bodyBoldFont = UIFont.boldSystemFont(ofSize: 14)
        let bodyFont = UIFont.systemFont(ofSize: 12)
        let smallFont = UIFont.systemFont(ofSize: 11)
        let tinyFont = UIFont.systemFont(ofSize: 10)

        func statusColor(for status: SeriesStatus) -> UIColor {
            switch status {
            case .completed: return green
            case .watching:  return orange
            case .dropped:   return red
            }
        }

        func drawRoundedRect(_ rect: CGRect, color: UIColor, radius: CGFloat) {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            color.setFill()
            path.fill()
        }

        func drawRoundedBorder(_ rect: CGRect, color: UIColor, radius: CGFloat, lineWidth: CGFloat = 1) {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            color.setStroke()
            path.lineWidth = lineWidth
            path.stroke()
        }

        func drawText(_ text: String, at point: CGPoint, attrs: [NSAttributedString.Key: Any]) {
            text.draw(at: point, withAttributes: attrs)
        }

        func drawTextInRect(_ text: String, in rect: CGRect, attrs: [NSAttributedString.Key: Any]) {
            let str = NSAttributedString(string: text, attributes: attrs)
            str.draw(in: rect)
        }

        return renderer.pdfData { ctx in
            ctx.beginPage()

            var y: CGFloat = 0

            drawRoundedRect(CGRect(x: 0, y: 0, width: pageWidth, height: 110), color: navy, radius: 0)

            let titleAttrs: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: white]
            let goldAttrs: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: gold]
            "Gate of ".draw(at: CGPoint(x: margin, y: 24), withAttributes: titleAttrs)
            let gateWidth = ("Gate of " as NSString).size(withAttributes: titleAttrs).width
            "Drama".draw(at: CGPoint(x: margin + gateWidth, y: 24), withAttributes: goldAttrs)

            let subAttrs: [NSAttributedString.Key: Any] = [.font: subtitleFont, .foregroundColor: textSecondary]
            drawText("Collection of \(username)", at: CGPoint(x: margin, y: 60), attrs: subAttrs)
            drawText("Generated \(formattedDate())  •  \(series.count) series", at: CGPoint(x: margin, y: 78), attrs: subAttrs)

            let completedCount = series.filter { $0.status == .completed }.count
            let watchingCount = series.filter { $0.status == .watching }.count
            let droppedCount = series.filter { $0.status == .dropped }.count

            let statsText = "✅ \(completedCount) completed   ▶ \(watchingCount) watching   ✗ \(droppedCount) dropped"
            let statsAttrs: [NSAttributedString.Key: Any] = [.font: tinyFont, .foregroundColor: white]
            drawText(statsText, at: CGPoint(x: margin, y: 92), attrs: statsAttrs)

            y = 126

            for (idx, s) in series.enumerated() {
                let cardHeight: CGFloat = s.notes.isEmpty ? 74 : 94
                if y + cardHeight > pageHeight - margin {
                    ctx.beginPage()
                    drawRoundedRect(CGRect(x: 0, y: 0, width: pageWidth, height: 36), color: navy, radius: 0)
                    let contAttrs: [NSAttributedString.Key: Any] = [.font: tinyFont, .foregroundColor: gold]
                    drawText("Gate of Drama — continued", at: CGPoint(x: margin, y: 10), attrs: contAttrs)
                    y = 48
                }

                let cardRect = CGRect(x: margin, y: y, width: contentWidth, height: cardHeight)
                drawRoundedRect(cardRect, color: cardBg, radius: 10)
                drawRoundedBorder(cardRect, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.08), radius: 10)

                let numAttrs: [NSAttributedString.Key: Any] = [.font: tinyFont, .foregroundColor: textSecondary]
                drawText("\(idx + 1)", at: CGPoint(x: margin + 12, y: y + 12), attrs: numAttrs)

                let titleAttrsCard: [NSAttributedString.Key: Any] = [.font: bodyBoldFont, .foregroundColor: white]
                let titleRect = CGRect(x: margin + 28, y: y + 10, width: contentWidth - 36 - 80, height: 20)
                drawTextInRect(s.title, in: titleRect, attrs: titleAttrsCard)

                let sc = statusColor(for: s.status)
                let badgeText = s.status.rawValue
                let badgeAttrs: [NSAttributedString.Key: Any] = [.font: tinyFont, .foregroundColor: sc]
                let badgeWidth = (badgeText as NSString).size(withAttributes: badgeAttrs).width + 14
                let badgeX = margin + contentWidth - badgeWidth - 4
                drawRoundedRect(CGRect(x: badgeX, y: y + 10, width: badgeWidth, height: 16), color: sc.withAlphaComponent(0.15), radius: 8)
                drawText(badgeText, at: CGPoint(x: badgeX + 7, y: y + 12), attrs: badgeAttrs)

                var detailParts: [String] = []
                if s.rating > 0 { detailParts.append(String(repeating: "★", count: s.rating) + " \(s.rating)/5") }
                if let ep = s.totalEpisodes { detailParts.append("\(ep) episodes") }
                if !s.logs.isEmpty { detailParts.append("\(s.logs.count) logs") }

                let detailStr = detailParts.joined(separator: "  •  ")
                let detailAttrs: [NSAttributedString.Key: Any] = [.font: bodyFont, .foregroundColor: gold]
                let infoAttrs: [NSAttributedString.Key: Any] = [.font: smallFont, .foregroundColor: textSecondary]
                if !detailStr.isEmpty {
                    drawText(detailStr, at: CGPoint(x: margin + 28, y: y + 32), attrs: detailAttrs)
                }

                if !s.notes.isEmpty {
                    let noteRect = CGRect(x: margin + 28, y: y + 52, width: contentWidth - 40, height: 34)
                    let noteText = "\" \(s.notes) \""
                    drawTextInRect(noteText, in: noteRect, attrs: infoAttrs)
                } else if detailStr.isEmpty {
                    drawText("No details added", at: CGPoint(x: margin + 28, y: y + 32), attrs: infoAttrs)
                }

                y += cardHeight + 10
            }

            let footerY = pageHeight - 28
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.08).setFill()
            UIRectFill(CGRect(x: margin, y: footerY - 8, width: contentWidth, height: 0.5))
            let footerAttrs: [NSAttributedString.Key: Any] = [.font: tinyFont, .foregroundColor: textSecondary]
            drawText("Gate of Drama  •  Your personal drama catalogue", at: CGPoint(x: margin, y: footerY), attrs: footerAttrs)
        }
    }

    private func savePDFToTemp(data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("GateOfDrama_Collection.pdf")
        try? data.write(to: url)
        return url
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: Date())
    }
}

private struct CollectionRow: View {
    let series: Series
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: screenHeight * 0.014) {
                RoundedRectangle(cornerRadius: screenHeight * 0.004)
                    .stroke(isSelected ? AppColors.gold : Color.white.opacity(0.3), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: screenHeight * 0.004)
                            .fill(isSelected ? AppColors.gold : Color.clear)
                    )
                    .frame(width: screenHeight * 0.022, height: screenHeight * 0.022)
                    .overlay(
                        Group {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: screenHeight * 0.013, weight: .bold))
                                    .foregroundColor(AppColors.darkNavy)
                            }
                        }
                    )

                VStack(alignment: .leading, spacing: screenHeight * 0.003) {
                    Text(series.title)
                        .font(Font.custom("Inter-Bold", size: screenHeight * 0.015))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: screenHeight * 0.006) {
                        Text(series.status.rawValue)
                            .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                            .foregroundColor(AppColors.textSecondary)
                        if series.rating > 0 {
                            Text("•")
                                .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                                .foregroundColor(AppColors.textSecondary)
                            Text("\(series.rating)/5")
                                .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                                .foregroundColor(AppColors.textSecondary)
                            Text("⭐")
                                .font(.system(size: screenHeight * 0.013))
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical, screenHeight * 0.012)
            .padding(.horizontal, screenHeight * 0.012)
            .background(isSelected ? AppColors.gold.opacity(0.06) : Color.white.opacity(0.03))
            .cornerRadius(screenHeight * 0.014)
            .overlay(
                RoundedRectangle(cornerRadius: screenHeight * 0.014)
                    .stroke(
                        isSelected ? AppColors.gold.opacity(0.5) : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
