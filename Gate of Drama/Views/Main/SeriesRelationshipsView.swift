import SwiftUI

struct SeriesRelationshipsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var localSeries: Series

    var onUpdate: (Series) -> Void

    @State private var showAddCharacterField = false
    @State private var newCharacterName = ""
    @State private var showAddRelationship = false
    @State private var relChar1ID: UUID? = nil
    @State private var relChar2ID: UUID? = nil
    @State private var relType: RelationshipType? = nil

    init(series: Series, onUpdate: @escaping (Series) -> Void) {
        self._localSeries = State(initialValue: series)
        self.onUpdate = onUpdate
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
        ZStack {
            gradient.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, screenHeight * 0.025)
                    .padding(.top, screenHeight * 0.015)
                    .padding(.bottom, screenHeight * 0.01)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        seriesHeader
                            .padding(.horizontal, screenHeight * 0.025)
                            .padding(.bottom, screenHeight * 0.025)

                        charactersSection
                            .padding(.horizontal, screenHeight * 0.025)

                        if showAddCharacterField {
                            addCharacterField
                                .padding(.horizontal, screenHeight * 0.025)
                                .padding(.top, screenHeight * 0.014)
                        }

                        Divider()
                            .background(Color.white.opacity(0.08))
                            .padding(.vertical, screenHeight * 0.022)
                            .padding(.horizontal, screenHeight * 0.025)

                        relationshipsSection
                            .padding(.horizontal, screenHeight * 0.025)

                        if showAddRelationship {
                            addRelationshipForm
                                .padding(.horizontal, screenHeight * 0.025)
                                .padding(.top, screenHeight * 0.016)
                        }

                        if !localSeries.relationships.isEmpty {
                            relationshipsList
                                .padding(.horizontal, screenHeight * 0.025)
                                .padding(.top, screenHeight * 0.018)
                        } else if !showAddRelationship {
                            Text(localSeries.characters.count < 2
                                 ? "At least 2 characters required to add relationships"
                                 : "No relationships added yet")
                                .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.top, screenHeight * 0.02)
                                .padding(.horizontal, screenHeight * 0.025)
                        }
                    }
                    .padding(.bottom, screenHeight * 0.12)
                }
            }
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
        }
    }

    private var seriesHeader: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.004) {
            Text(localSeries.title)
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.030))
                .foregroundColor(.white)
            Text("Character Relationships")
                .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private var charactersSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            HStack {
                Text("Characters")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.020))
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    withAnimation { showAddCharacterField.toggle() }
                }) {
                    HStack(spacing: screenHeight * 0.007) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: screenHeight * 0.015))
                        Text("Add Character")
                            .font(Font.custom("Inter-Bold", size: screenHeight * 0.015))
                    }
                    .foregroundColor(AppColors.darkNavy)
                    .padding(.horizontal, screenHeight * 0.018)
                    .padding(.vertical, screenHeight * 0.011)
                    .background(AppColors.gold)
                    .cornerRadius(screenHeight * 0.012)
                }
            }

            if localSeries.characters.isEmpty {
                Text("No characters added yet")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                    .foregroundColor(AppColors.textSecondary)
            } else {
                FlowLayout(spacing: screenHeight * 0.01) {
                    ForEach(localSeries.characters) { character in
                        Text(character.name)
                            .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                            .foregroundColor(.white)
                            .padding(.horizontal, screenHeight * 0.016)
                            .padding(.vertical, screenHeight * 0.009)
                            .background(AppColors.cardDark)
                            .cornerRadius(screenHeight * 0.022)
                            .overlay(
                                RoundedRectangle(cornerRadius: screenHeight * 0.022)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    private var addCharacterField: some View {
        HStack(spacing: screenHeight * 0.012) {
            TextField("", text: $newCharacterName, prompt:
                Text("Character name")
                    .foregroundColor(Color.white.opacity(0.30))
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
            )
            .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
            .foregroundColor(.white)
            .padding(.horizontal, screenHeight * 0.018)
            .frame(height: screenHeight * 0.054)
            .background(AppColors.cardDark)
            .cornerRadius(screenHeight * 0.014)
            .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.014)
                .stroke(Color.white.opacity(0.10), lineWidth: 1))

            Button(action: addCharacter) {
                Text("Add")
                    .font(Font.custom("Inter-Bold", size: screenHeight * 0.016))
                    .foregroundColor(AppColors.darkNavy)
                    .padding(.horizontal, screenHeight * 0.02)
                    .frame(height: screenHeight * 0.054)
                    .background(newCharacterName.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AppColors.gold.opacity(0.45) : AppColors.gold)
                    .cornerRadius(screenHeight * 0.014)
            }
            .disabled(newCharacterName.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    private var relationshipsSection: some View {
        HStack {
            Text("Relationships")
                .font(Font.custom("Inter-Bold", size: screenHeight * 0.020))
                .foregroundColor(.white)
            Spacer()
            if localSeries.characters.count >= 2 {
                Button(action: { withAnimation { showAddRelationship.toggle() } }) {
                    HStack(spacing: screenHeight * 0.007) {
                        Image(systemName: "plus")
                            .font(.system(size: screenHeight * 0.014, weight: .semibold))
                        Text("Add Relationship")
                            .font(Font.custom("Inter-Bold", size: screenHeight * 0.015))
                    }
                    .foregroundColor(AppColors.darkNavy)
                    .padding(.horizontal, screenHeight * 0.018)
                    .padding(.vertical, screenHeight * 0.011)
                    .background(AppColors.gold)
                    .cornerRadius(screenHeight * 0.012)
                }
            }
        }
    }

    private var addRelationshipForm: some View {
        VStack(spacing: screenHeight * 0.016) {
            HStack(spacing: screenHeight * 0.012) {
                characterPicker(selected: $relChar1ID, exclude: relChar2ID)
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.system(size: screenHeight * 0.016))
                characterPicker(selected: $relChar2ID, exclude: relChar1ID)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: screenHeight * 0.012), count: 3),
                      spacing: screenHeight * 0.012) {
                ForEach(RelationshipType.allCases, id: \.self) { type in
                    let isSelected = relType == type
                    Button(action: { relType = type }) {
                        VStack(spacing: screenHeight * 0.006) {
                            Text(type.emoji)
                                .font(.system(size: screenHeight * 0.028))
                            Text(type.rawValue)
                                .font(Font.custom("Inter-Regular", size: screenHeight * 0.013))
                                .foregroundColor(isSelected ? .white : AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, screenHeight * 0.014)
                        .background(isSelected ? AppColors.badgePurple : AppColors.cardDark)
                        .cornerRadius(screenHeight * 0.014)
                        .overlay(
                            RoundedRectangle(cornerRadius: screenHeight * 0.014)
                                .stroke(isSelected ? AppColors.gold.opacity(0.5) : Color.clear, lineWidth: 1.5)
                        )
                    }
                }
            }

            HStack(spacing: screenHeight * 0.012) {
                Button(action: addRelationship) {
                    Text("Add")
                        .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                        .foregroundColor(AppColors.darkNavy)
                        .frame(maxWidth: .infinity)
                        .frame(height: screenHeight * 0.058)
                        .background(canAddRelationship ? AppColors.gold : AppColors.gold.opacity(0.45))
                        .cornerRadius(screenHeight * 0.014)
                }
                .disabled(!canAddRelationship)

                Button(action: { withAnimation { showAddRelationship = false } }) {
                    Text("Cancel")
                        .font(Font.custom("Inter-Regular", size: screenHeight * 0.018))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: screenHeight * 0.058)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(screenHeight * 0.014)
                }
            }
        }
        .padding(screenHeight * 0.018)
        .background(AppColors.cardDark)
        .cornerRadius(screenHeight * 0.018)
    }

    private func characterPicker(selected: Binding<UUID?>, exclude: UUID?) -> some View {
        Menu {
            ForEach(localSeries.characters.filter { $0.id != exclude }) { char in
                Button(char.name) { selected.wrappedValue = char.id }
            }
        } label: {
            HStack {
                Text(localSeries.characters.first(where: { $0.id == selected.wrappedValue })?.name ?? "Select")
                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.015))
                    .foregroundColor(selected.wrappedValue == nil ? AppColors.textSecondary : .white)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: screenHeight * 0.012))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, screenHeight * 0.014)
            .frame(height: screenHeight * 0.052)
            .background(Color.white.opacity(0.07))
            .cornerRadius(screenHeight * 0.012)
            .overlay(RoundedRectangle(cornerRadius: screenHeight * 0.012)
                .stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
    }

    private var canAddRelationship: Bool {
        relChar1ID != nil && relChar2ID != nil && relType != nil
    }

    private var relationshipsList: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.014) {
            ForEach(localSeries.characters) { character in
                let rels = relationshipsFor(character)
                if !rels.isEmpty {
                    VStack(alignment: .leading, spacing: screenHeight * 0.012) {
                        Text(character.name)
                            .font(Font.custom("Inter-Bold", size: screenHeight * 0.018))
                            .foregroundColor(.white)
                            .padding(.bottom, screenHeight * 0.004)

                        ForEach(rels, id: \.0.id) { (other, type) in
                            HStack(spacing: screenHeight * 0.012) {
                                Text(type.emoji)
                                    .font(.system(size: screenHeight * 0.022))
                                    .frame(width: screenHeight * 0.04, height: screenHeight * 0.04)
                                    .background(AppColors.badgePurple.opacity(0.6))
                                    .cornerRadius(screenHeight * 0.008)

                                Text(other.name)
                                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.016))
                                    .foregroundColor(.white)

                                Text("(\(type.rawValue))")
                                    .font(Font.custom("Inter-Regular", size: screenHeight * 0.014))
                                    .foregroundColor(AppColors.textSecondary)

                                Spacer()
                            }
                            .padding(.horizontal, screenHeight * 0.016)
                            .padding(.vertical, screenHeight * 0.012)
                            .background(AppColors.cardDark)
                            .cornerRadius(screenHeight * 0.014)
                            .overlay(
                                RoundedRectangle(cornerRadius: screenHeight * 0.014)
                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            )
                        }
                    }
                    .padding(screenHeight * 0.018)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(screenHeight * 0.018)
                    .overlay(
                        RoundedRectangle(cornerRadius: screenHeight * 0.018)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
                }
            }
        }
    }

    private func relationshipsFor(_ character: Character) -> [(Character, RelationshipType)] {
        localSeries.relationships.compactMap { rel in
            if rel.character1ID == character.id,
               let other = localSeries.characters.first(where: { $0.id == rel.character2ID }) {
                return (other, rel.type)
            } else if rel.character2ID == character.id,
                      let other = localSeries.characters.first(where: { $0.id == rel.character1ID }) {
                return (other, rel.type)
            }
            return nil
        }
    }

    private func addCharacter() {
        let name = newCharacterName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        localSeries.characters.append(Character(name: name))
        newCharacterName = ""
        showAddCharacterField = false
        onUpdate(localSeries)
    }

    private func addRelationship() {
        guard let c1 = relChar1ID, let c2 = relChar2ID, let type = relType else { return }
        let rel = CharacterRelationship(character1ID: c1, character2ID: c2, type: type)
        localSeries.relationships.append(rel)
        relChar1ID = nil
        relChar2ID = nil
        relType = nil
        showAddRelationship = false
        onUpdate(localSeries)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }
            .reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(subview)
            rowWidth += size.width + spacing
        }
        return rows
    }
}
