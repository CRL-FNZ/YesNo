import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case classic = "Classico"
    case ocean = "Oceano"
    case sunset = "Tramonto"
    case forest = "Foresta"
    case neon = "Neon"

    var id: String { rawValue }

    func displayName(for language: Language) -> String {
        switch self {
        case .classic: return language == .italian ? "Classico" : "Klassisch"
        case .ocean: return language == .italian ? "Oceano" : "Ozean"
        case .sunset: return language == .italian ? "Tramonto" : "Sonnenuntergang"
        case .forest: return language == .italian ? "Foresta" : "Wald"
        case .neon: return language == .italian ? "Neon" : "Neon"
        }
    }

    var primaryColor: Color {
        switch self {
        case .classic: return .blue
        case .ocean: return Color(red: 0.0, green: 0.5, blue: 0.8)
        case .sunset: return Color(red: 1.0, green: 0.4, blue: 0.2)
        case .forest: return Color(red: 0.2, green: 0.6, blue: 0.3)
        case .neon: return Color(red: 0.9, green: 0.0, blue: 0.9)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .classic: return .purple
        case .ocean: return Color(red: 0.0, green: 0.3, blue: 0.6)
        case .sunset: return Color(red: 1.0, green: 0.6, blue: 0.0)
        case .forest: return Color(red: 0.1, green: 0.4, blue: 0.2)
        case .neon: return Color(red: 0.0, green: 0.8, blue: 1.0)
        }
    }

    var correctColor: Color {
        switch self {
        case .neon: return Color(red: 0.0, green: 1.0, blue: 0.4)
        default: return .green
        }
    }

    var wrongColor: Color {
        switch self {
        case .neon: return Color(red: 1.0, green: 0.0, blue: 0.3)
        default: return .red
        }
    }

    var backgroundColor: [Color] {
        switch self {
        case .classic: return [Color(.systemBackground), Color(.systemBackground)]
        case .ocean: return [Color(red: 0.0, green: 0.1, blue: 0.2), Color(red: 0.0, green: 0.2, blue: 0.4)]
        case .sunset: return [Color(red: 0.15, green: 0.05, blue: 0.1), Color(red: 0.3, green: 0.1, blue: 0.05)]
        case .forest: return [Color(red: 0.05, green: 0.1, blue: 0.05), Color(red: 0.1, green: 0.2, blue: 0.1)]
        case .neon: return [Color(red: 0.05, green: 0.0, blue: 0.1), Color(red: 0.1, green: 0.0, blue: 0.15)]
        }
    }

    var textColor: Color {
        switch self {
        case .classic: return .primary
        case .ocean, .sunset, .forest, .neon: return .white
        }
    }
}

enum TeamAvatar: String, CaseIterable, Identifiable {
    case star = "star.fill"
    case bolt = "bolt.fill"
    case flame = "flame.fill"
    case heart = "heart.fill"
    case crown = "crown.fill"
    case diamond = "diamond.fill"
    case leaf = "leaf.fill"
    case moon = "moon.fill"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .star: return .yellow
        case .bolt: return .orange
        case .flame: return .red
        case .heart: return .pink
        case .crown: return .purple
        case .diamond: return .cyan
        case .leaf: return .green
        case .moon: return .indigo
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .classic
    @Published var teamAvatars: [TeamAvatar] = [.star, .bolt, .flame, .heart]
}
