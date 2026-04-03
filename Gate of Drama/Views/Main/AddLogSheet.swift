import SwiftUI

struct AddLogSheet: View {
    @Environment(\.dismiss) private var dismiss

    var onAdd: (EpisodeLog) -> Void

    @State private var episodeNumber = ""
    @State private var selectedEmotion: Emotion? = nil
    @State private var note = ""

    var body: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.022) {
            Text("Add Episode Log")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.024))
                .foregroundColor(.white)
                .padding(.top, screenHeight * 0.01)

            fieldSection(label: "Episode Number") {
                styledTextField("1", text: $episodeNumber)
                    .keyboardType(.numberPad)
            }

            fieldSection(label: "Emotions") {
                HStack(spacing: 0) {
                    ForEach(Emotion.allCases) { emotion in
                        emotionButton(emotion)
                    }
                }
            }

            fieldSection(label: "Note") {
                styledTextEditor
            }

            Spacer()

            Button(action: handleSave) {
                Text("Save Log")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.020))
                    .foregroundColor(AppColors.darkNavy)
                    .frame(maxWidth: .infinity)
                    .frame(height: screenHeight * 0.066)
                    .background(canSave ? AppColors.gold : AppColors.gold.opacity(0.45))
                    .cornerRadius(screenHeight * 0.016)
            }
            .disabled(!canSave)
            .padding(.bottom, screenHeight * 0.02)
        }
        .padding(.horizontal, screenHeight * 0.025)
        .padding(.top, screenHeight * 0.025)
    }

    private var canSave: Bool {
        Int(episodeNumber) != nil
    }

    private func emotionButton(_ emotion: Emotion) -> some View {
        let isSelected = selectedEmotion == emotion
        return Button(action: {
            selectedEmotion = isSelected ? nil : emotion
        }) {
            VStack(spacing: screenHeight * 0.006) {
                Text(emotion.emoji)
                    .font(.system(size: screenHeight * 0.032))
                    .padding(screenHeight * 0.009)
                    .background(isSelected ? AppColors.badgePurple : Color.white.opacity(0.07))
                    .cornerRadius(screenHeight * 0.012)
                    .overlay(
                        RoundedRectangle(cornerRadius: screenHeight * 0.012)
                            .stroke(isSelected ? AppColors.gold.opacity(0.6) : Color.clear, lineWidth: 1.5)
                    )

                Text(emotion.label)
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.012))
                    .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var styledTextEditor: some View {
        ZStack(alignment: .topLeading) {
            if note.isEmpty {
                Text("How did this episode make you feel?")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                    .foregroundColor(Color.white.opacity(0.28))
                    .padding(.top, screenHeight * 0.014)
                    .padding(.leading, screenHeight * 0.016)
            }
            TextEditor(text: $note)
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(.white)
                .frame(height: screenHeight * 0.1)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, screenHeight * 0.012)
                .padding(.vertical, screenHeight * 0.008)
        }
        .background(Color.white.opacity(0.07))
        .cornerRadius(screenHeight * 0.014)
        .overlay(
            RoundedRectangle(cornerRadius: screenHeight * 0.014)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func styledTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField("", text: text, prompt: Text(placeholder)
            .foregroundColor(Color.white.opacity(0.28))
            .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
        )
        .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
        .foregroundColor(.white)
        .padding(.horizontal, screenHeight * 0.018)
        .frame(height: screenHeight * 0.055)
        .background(Color.white.opacity(0.07))
        .cornerRadius(screenHeight * 0.014)
        .overlay(
            RoundedRectangle(cornerRadius: screenHeight * 0.014)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.01) {
            Text(label)
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                .foregroundColor(AppColors.textSecondary)
            content()
        }
    }

    private func handleSave() {
        guard let num = Int(episodeNumber) else { return }
        let log = EpisodeLog(episodeNumber: num, emotion: selectedEmotion, note: note)
        onAdd(log)
        dismiss()
    }
}
