import SwiftUI

struct ResultView: View {
    @ObservedObject var gameState: GameState
    @Binding var currentView: ViewType

    var body: some View {
        VStack(spacing: 20) {
            Text(gameState.language.resultsTitle)
                .font(.largeTitle)

            ForEach(0..<gameState.scores.count, id: \.self) { index in
                HStack {
                    Text("\(gameState.language.teamText) \(index + 1)")
                    Spacer()
                    Text("\(gameState.scores[index]) \(gameState.language.pointsSuffix)")
                }
                .font(.title)
            }

            Button(action: {
                currentView = .home
            }) {
                Text(gameState.language.newGameText)
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}