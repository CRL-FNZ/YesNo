import SwiftUI
import Combine

enum ViewType {
    case language, home, setup, game, result, think, burkard, multipleChoice
}

@main
struct YesNoApp: App {
    @State var currentView: ViewType = .language
    @State var selectedLanguage: Language? = nil
    @StateObject var motionManager = MotionManager()
    @StateObject var gameState = GameState(language: .italian) // Default, will be updated
    @StateObject var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if selectedLanguage != nil {
                    switch currentView {
                    case .language:
                        LanguageSelectionView(selectedLanguage: $selectedLanguage, currentView: $currentView)
                            .transition(.opacity)
                    case .home:
                        HomeView(currentView: $currentView, themeManager: themeManager)
                            .transition(.opacity)
                    case .setup:
                        GameSetupView(currentView: $currentView, gameState: gameState)
                            .transition(.move(edge: .trailing))
                    case .game:
                        GameView(gameState: gameState, motionManager: motionManager, themeManager: themeManager, currentView: $currentView)
                            .transition(.opacity)
                    case .result:
                        ResultView(gameState: gameState, themeManager: themeManager, currentView: $currentView)
                            .transition(.scale.combined(with: .opacity))
                    case .think:
                        ThinkView(language: gameState.language, currentView: $currentView)
                            .transition(.move(edge: .trailing))
                    case .burkard:
                        BurkardView(language: gameState.language, currentView: $currentView)
                            .transition(.move(edge: .trailing))
                    case .multipleChoice:
                        MultipleChoiceView(language: gameState.language, currentView: $currentView)
                            .transition(.move(edge: .trailing))
                    }
                } else {
                    LanguageSelectionView(selectedLanguage: $selectedLanguage, currentView: $currentView)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: currentView)
        }
        .onChange(of: selectedLanguage) { _, newLanguage in
            if let lang = newLanguage {
                gameState.language = lang
                gameState.setup(numberOfTeams: 2, gameMode: .firstTo(points: 10), selectedCategories: Category.allCases)
            }
        }
    }
}
