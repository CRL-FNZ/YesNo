import SwiftUI

struct GameSetupView: View {
    @Binding var currentView: ViewType
    @ObservedObject var gameState: GameState
    @State private var selectedCategories: Set<Category> = Set(Category.allCases)
    @State private var gameModeType: GameModeType = .firstTo
    @State private var points: Int = 10
    @State private var seconds: Int = 60
    @State private var numberOfTeams: Int = 2

    enum GameModeType {
        case firstTo, timedMode
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(gameState.language.setupTitle)
                .font(.largeTitle)

            Text(gameState.language.categoriesText)
                .font(.headline)
            ForEach(Category.allCases, id: \.self) { category in
                Toggle(category.displayName(for: gameState.language), isOn: Binding(
                    get: { selectedCategories.contains(category) },
                    set: { isSelected in
                        if isSelected {
                            selectedCategories.insert(category)
                        } else {
                            selectedCategories.remove(category)
                        }
                    }
                ))
            }

            Text(gameState.language.modeText)
                .font(.headline)
            Picker("Tipo", selection: $gameModeType) {
                Text(gameState.language.firstToText).tag(GameModeType.firstTo)
                Text(gameState.language.timedText).tag(GameModeType.timedMode)
            }
            .pickerStyle(SegmentedPickerStyle())

            if gameModeType == .firstTo {
                Stepper("\(gameState.language.pointsText): \(points)", value: $points, in: 1...50)
            } else {
                Stepper("\(gameState.language.secondsText): \(seconds)", value: $seconds, in: 10...300, step: 10)
            }

            Text(gameState.language.teamsTitle)
                .font(.headline)
            Picker("Squadre", selection: $numberOfTeams) {
                ForEach(1...4, id: \.self) { num in
                    Text("\(num)").tag(num)
                }
            }

            Button(action: startGame) {
                Text(gameState.language.startGameText)
                    .font(.title)
                    .padding()
                    .background(selectedCategories.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(selectedCategories.isEmpty)
        }
        .padding()
    }

    private func startGame() {
        guard !selectedCategories.isEmpty else { return }
        let mode: GameMode = gameModeType == .firstTo ? .firstTo(points: points) : .timedMode(seconds: seconds)
        gameState.setup(numberOfTeams: numberOfTeams, gameMode: mode, selectedCategories: Array(selectedCategories))
        currentView = .game
    }
}