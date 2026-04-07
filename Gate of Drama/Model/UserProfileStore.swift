import Foundation
import SwiftUI

class UserProfileStore: ObservableObject {
    @Published var username: String = "Drama Enthusiast" {
        didSet { save() }
    }
    @Published var avatarData: Data? = nil {
        didSet { save() }
    }
    @Published var joinYear: Int = Calendar.current.component(.year, from: Date()) {
        didSet { save() }
    }

    private let usernameKey = "profile_username"
    private let avatarKey   = "profile_avatar"
    private let joinYearKey = "profile_joinYear"

    init() { load() }

    func dramaLevel(seriesCount: Int) -> DramaLevel {
        if seriesCount >= 20 { return .legend }
        if seriesCount >= 10 { return .enthusiast }
        return .beginner
    }

    func progressToNextLevel(seriesCount: Int) -> Double {
        let level = dramaLevel(seriesCount: seriesCount)
        switch level {
        case .beginner:    return Double(seriesCount % 10) / 10.0
        case .enthusiast:  return Double(seriesCount % 10) / 10.0
        case .legend:      return 1.0
        }
    }

    func seriesNeededForNextLevel(seriesCount: Int) -> Int {
        let level = dramaLevel(seriesCount: seriesCount)
        switch level {
        case .legend:     return 0
        default:          return 10 - (seriesCount % 10)
        }
    }

    private func save() {
        UserDefaults.standard.set(username, forKey: usernameKey)
        UserDefaults.standard.set(joinYear, forKey: joinYearKey)
        if let data = avatarData {
            UserDefaults.standard.set(data, forKey: avatarKey)
        }
    }

    private func load() {
        if let name = UserDefaults.standard.string(forKey: usernameKey) {
            username = name
        }
        if let year = UserDefaults.standard.object(forKey: joinYearKey) as? Int {
            joinYear = year
        }
        avatarData = UserDefaults.standard.data(forKey: avatarKey)
    }
}

enum DramaLevel: String {
    case beginner    = "Beginner"
    case enthusiast  = "Enthusiast"
    case legend      = "Legend"

    var emoji: String {
        switch self {
        case .beginner:   return "⚡"
        case .enthusiast: return "✨"
        case .legend:     return "🏆"
        }
    }

    var threshold: Int {
        switch self {
        case .beginner:   return 0
        case .enthusiast: return 10
        case .legend:     return 20
        }
    }
}
