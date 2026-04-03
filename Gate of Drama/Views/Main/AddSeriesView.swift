import SwiftUI

struct AddSeriesView: View {
    @Environment(\.dismiss) private var dismiss

    var onAdd: (Series) -> Void

    @State private var imageURL = ""
    @State private var seriesTitle = ""
    @State private var status: SeriesStatus = .watching
    @State private var totalEpisodes = ""
    @State private var rating: Int = 0
    @State private var notes = ""

    private let gradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.09, blue: 0.20),
            Color(red: 0.12, green: 0.07, blue: 0.25)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack {
            gradient.ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                    .padding(.horizontal, screenHeight * 0.025)
                    .padding(.top, screenHeight * 0.015)
                    .padding(.bottom, screenHeight * 0.01)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: screenHeight * 0.025) {
                        Text("Add New Series")
                            .font(Font.custom("Inter-Bold", size: screenHeight * 0.034))
                            .foregroundColor(.white)

                        coverImageSection
                        fieldSection(label: "Series Title *") {
                            styledTextField("e.g., Love Story", text: $seriesTitle)
                        }
                        statusSection
                        fieldSection(label: "Total Episodes") {
                            styledTextField("120", text: $totalEpisodes)
                                .keyboardType(.numberPad)
                        }
                        ratingSection
                        fieldSection(label: "Personal Notes") {
                            styledTextEditor
                        }

                        addButton
                            .padding(.top, screenHeight * 0.01)
                            .padding(.bottom, screenHeight * 0.04)
                    }
                    .padding(.horizontal, screenHeight * 0.025)
                    .padding(.top, screenHeight * 0.01)
                }
            }
        }
    }

    private var backButton: some View {
        HStack(spacing: screenHeight * 0.008) {
            Image(systemName: "chevron.left")
                .font(.system(size: screenHeight * 0.018, weight: .medium))
            Text("Back")
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.018))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture { dismiss() }
    }

    private var coverImageSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.012) {
            Text("Cover Image")
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(AppColors.textSecondary)

            coverImagePreview

            styledTextField("https://example.com/image.jpg", text: $imageURL)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
    }

    @ViewBuilder
    private var coverImagePreview: some View {
        let url = URL(string: imageURL)
        let isValid = url?.scheme?.hasPrefix("http") == true

        Group {
            if isValid, let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: screenHeight * 0.2)
                            .clipped()
                    case .failure:
                        placeholder(icon: "exclamationmark.triangle", label: "Failed to load image")
                    case .empty:
                        placeholder(icon: nil, label: nil, loading: true)
                    @unknown default:
                        placeholder(icon: "square.and.arrow.up", label: "Add image URL")
                    }
                }
            } else {
                placeholder(icon: "square.and.arrow.up", label: "Add image URL")
            }
        }
        .frame(height: screenHeight * 0.2)
        .cornerRadius(screenHeight * 0.016)
        .overlay(
            RoundedRectangle(cornerRadius: screenHeight * 0.016)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func placeholder(icon: String?, label: String?, loading: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: screenHeight * 0.016)
            .fill(AppColors.cardDark)
            .overlay(
                Group {
                    if loading {
                        ProgressView().tint(AppColors.textSecondary)
                    } else {
                        VStack(spacing: screenHeight * 0.012) {
                            if let icon {
                                Image(systemName: icon)
                                    .font(.system(size: screenHeight * 0.032, weight: .light))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            if let label {
                                Text(label)
                                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }
            )
    }

    private var statusSection: some View {
        fieldSection(label: "Status") {
            HStack(spacing: screenHeight * 0.012) {
                ForEach(SeriesStatus.allCases, id: \.self) { s in
                    let isActive = status == s
                    Button(action: { status = s }) {
                        Text(s.rawValue)
                            .font(Font.custom(isActive ? "Inter-Bold" : "Inter-Regular", size: screenHeight * 0.016))
                            .foregroundColor(isActive ? AppColors.darkNavy : .white)
                            .padding(.horizontal, screenHeight * 0.02)
                            .padding(.vertical, screenHeight * 0.013)
                            .background(isActive ? AppColors.gold : AppColors.cardDark)
                            .cornerRadius(screenHeight * 0.014)
                    }
                }
                Spacer()
            }
        }
    }

    private var ratingSection: some View {
        fieldSection(label: "Rating") {
            HStack(spacing: screenHeight * 0.012) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: screenHeight * 0.030))
                        .foregroundColor(star <= rating ? AppColors.gold : Color.white.opacity(0.30))
                        .onTapGesture { rating = (rating == star) ? 0 : star }
                }
                Text(rating == 0 ? "Not rated" : "\(rating) / 5")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.leading, screenHeight * 0.006)
            }
        }
    }

    private var styledTextEditor: some View {
        ZStack(alignment: .topLeading) {
            if notes.isEmpty {
                Text("Favorite character: Ayşe")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                    .foregroundColor(Color.white.opacity(0.30))
                    .padding(.top, screenHeight * 0.014)
                    .padding(.leading, screenHeight * 0.016)
            }
            TextEditor(text: $notes)
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(.white)
                .frame(height: screenHeight * 0.12)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, screenHeight * 0.012)
                .padding(.vertical, screenHeight * 0.008)
        }
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.015)
        .overlay(
            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var addButton: some View {
        Button(action: handleAdd) {
            Text("Add Series")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.020))
                .foregroundColor(AppColors.darkNavy)
                .frame(maxWidth: .infinity)
                .frame(height: screenHeight * 0.072)
                .background(seriesTitle.isEmpty ? AppColors.gold.opacity(0.45) : AppColors.gold)
                .cornerRadius(screenHeight * 0.018)
                .shadow(color: AppColors.gold.opacity(0.40), radius: screenHeight * 0.022, x: 0, y: screenHeight * 0.008)
        }
        .disabled(seriesTitle.isEmpty)
    }

    private func handleAdd() {
        let series = Series(
            title: seriesTitle,
            imageURL: imageURL,
            status: status,
            totalEpisodes: Int(totalEpisodes),
            rating: rating,
            notes: notes
        )
        onAdd(series)
        dismiss()
    }

    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.01) {
            Text(label)
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(AppColors.textSecondary)
            content()
        }
    }

    private func styledTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField("", text: text, prompt: Text(placeholder)
            .foregroundColor(Color.white.opacity(0.30))
            .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
        )
        .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
        .foregroundColor(.white)
        .padding(.horizontal, screenHeight * 0.018)
        .frame(height: screenHeight * 0.058)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.015)
        .overlay(
            RoundedRectangle(cornerRadius: screenHeight * 0.015)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}
