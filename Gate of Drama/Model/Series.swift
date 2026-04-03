import Foundation

enum SeriesStatus: String, CaseIterable, Codable {
    case watching = "Watching"
    case completed = "Completed"
    case dropped = "Dropped"
}

enum Emotion: String, CaseIterable, Identifiable, Codable {
    case cried, furious, amazed, shocked, touched

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .cried:   return "😢"
        case .furious: return "😡"
        case .amazed:  return "🤩"
        case .shocked: return "😮"
        case .touched: return "🤍"
        }
    }

    var label: String {
        switch self {
        case .cried:   return "Cried"
        case .furious: return "Furious"
        case .amazed:  return "Amazed"
        case .shocked: return "Shocked"
        case .touched: return "Touched"
        }
    }
}

enum RelationshipType: String, CaseIterable, Codable {
    case lovers   = "Lovers"
    case sisters  = "Sisters"
    case enemies  = "Enemies"
    case friends  = "Friends"
    case family   = "Family"
    case rivals   = "Rivals"

    var emoji: String {
        switch self {
        case .lovers:  return "💕"
        case .sisters: return "👯"
        case .enemies: return "⚔️"
        case .friends: return "🤝"
        case .family:  return "👨‍👩‍👧"
        case .rivals:  return "🥊"
        }
    }
}

struct Character: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
}

struct CharacterRelationship: Identifiable, Codable {
    var id: UUID = UUID()
    var character1ID: UUID
    var character2ID: UUID
    var type: RelationshipType
}

struct EpisodeLog: Identifiable, Codable {
    var id: UUID = UUID()
    var episodeNumber: Int
    var emotion: Emotion?
    var note: String
}

struct Series: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var imageURL: String
    var status: SeriesStatus
    var totalEpisodes: Int?
    var rating: Int
    var notes: String
    var logs: [EpisodeLog] = []
    var characters: [Character] = []
    var relationships: [CharacterRelationship] = []
}
