import Foundation
import Combine

class SeriesStore: ObservableObject {
    @Published var seriesList: [Series] = [] {
        didSet { save() }
    }

    private let storageKey = "gate_of_drama_series"

    init() {
        load()
    }

    func add(_ series: Series) {
        seriesList.append(series)
    }

    func update(_ series: Series) {
        guard let idx = seriesList.firstIndex(where: { $0.id == series.id }) else { return }
        seriesList[idx] = series
    }

    func delete(at offsets: IndexSet) {
        seriesList.remove(atOffsets: offsets)
    }

    func delete(id: UUID) {
        seriesList.removeAll { $0.id == id }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(seriesList) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([Series].self, from: data)
        else { return }
        seriesList = decoded
    }
}
