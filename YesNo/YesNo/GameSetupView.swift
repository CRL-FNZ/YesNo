import SwiftUI

struct GameSetupView: View {
    @Binding var currentView: ViewType
    @ObservedObject var gameState: GameState
    @State private var selectedCategories: Set<Category> = Set(Category.allCases)
    @State private var gameModeType: GameModeType = .firstTo
    @State private var points: Int = 10
    @State private var seconds: Int = 60
    @State private var numberOfTeams: Int = 2
    @State private var soundEnabled: Bool = true

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
            HStack(spacing: 12) {
                Button(action: { gameModeType = .firstTo }) {
                    Text(gameState.language.firstToText)
                        .font(.body)
                        .fontWeight(gameModeType == .firstTo ? .bold : .regular)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(gameModeType == .firstTo ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(gameModeType == .firstTo ? .white : .primary)
                        .cornerRadius(10)
                }
                Button(action: { gameModeType = .timedMode }) {
                    Text(gameState.language.timedText)
                        .font(.body)
                        .fontWeight(gameModeType == .timedMode ? .bold : .regular)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(gameModeType == .timedMode ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(gameModeType == .timedMode ? .white : .primary)
                        .cornerRadius(10)
                }
            }

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

            Toggle(gameState.language.soundText, isOn: $soundEnabled)
                .onChange(of: soundEnabled) { _, newValue in
                    SoundManager.shared.soundEnabled = newValue
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