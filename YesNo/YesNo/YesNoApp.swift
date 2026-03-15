import SwiftUI
import Combine

enum ViewType {
    case language, home, setup, game, result
}

@main
struct YesNoApp: App {
    @State var currentView: ViewType = .language
    @State var selectedLanguage: Language? = nil
    @StateObject var motionManager = MotionManager()
    @StateObject var gameState = GameState(language: .italian) // Default, will be updated

    var body: some Scene {
        WindowGroup {
            ZStack {
                if let language = selectedLanguage {
                    switch currentView {
                    case .language:
                        LanguageSelectionView(selectedLanguage: $selectedLanguage, currentView: $currentView)
                    case .home:
                        HomeView(currentView: $currentView)
                    case .setup:
                        GameSetupView(currentView: $currentView, gameState: gameState)
                    case .game:
                        GameView(gameState: gameState, motionManager: motionManager, currentView: $currentView)
                    case .result:
                        ResultView(gameState: gameState, currentView: $currentView)
                    }
                } else {
                    LanguageSelectionView(selectedLanguage: $selectedLanguage, currentView: $currentView)
                }
            }
        }
        .onChange(of: selectedLanguage) { _, newLanguage in
            if let lang = newLanguage {
                gameState.language = lang
                gameState.setup(numberOfTeams: 2, gameMode: .firstTo(points: 10), selectedCategories: Category.allCases) // Reload questions
            }
        }
    }
}