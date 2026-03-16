import SwiftUI

struct MCSetupView: View {
    @Binding var currentView: ViewType
    @ObservedObject var mcGameState: MCGameState
    var language: Language
    @State private var selectedCategories: Set<Category> = Set(Category.allCases)
    @State private var gameModeType: GameSetupView.GameModeType = .firstTo
    @State private var points: Int = 10
    @State private var seconds: Int = 60
    @State private var numberOfTeams: Int = 2

    var body: some View {
        VStack(spacing: 20) {
            Text("Multiple Choice")
                .font(.largeTitle)

            Text(language.categoriesText)
                .font(.headline)
            ForEach(Category.allCases, id: \.self) { category in
                Toggle(category.displayName(for: language), isOn: Binding(
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

            Text(language.modeText)
                .font(.headline)
            HStack(spacing: 12) {
                Button(action: { gameModeType = .firstTo }) {
                    Text(language.firstToText)
                        .font(.body)
                        .fontWeight(gameModeType == .firstTo ? .bold : .regular)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(gameModeType == .firstTo ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(gameModeType == .firstTo ? .white : .primary)
                        .cornerRadius(10)
                }
                Button(action: { gameModeType = .timedMode }) {
                    Text(language.timedText)
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
                Stepper("\(language.pointsText): \(points)", value: $points, in: 1...50)
            } else {
                Stepper("\(language.secondsText): \(seconds)", value: $seconds, in: 10...300, step: 10)
            }

            Text(language.teamsTitle)
                .font(.headline)
            Picker("Squadre", selection: $numberOfTeams) {
                ForEach(1...4, id: \.self) { num in
                    Text("\(num)").tag(num)
                }
            }

            Button(action: startGame) {
                Text(language.startGameText)
                    .font(.title)
                    .padding()
                    .background(selectedCategories.isEmpty ? Color.gray : Color.teal)
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
        mcGameState.setup(numberOfTeams: numberOfTeams, gameMode: mode, selectedCategories: Array(selectedCategories), language: language)
        currentView = .multipleChoice
    }
}
