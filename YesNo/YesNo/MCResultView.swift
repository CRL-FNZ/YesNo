import SwiftUI

struct MCResultView: View {
    @ObservedObject var mcGameState: MCGameState
    @ObservedObject var themeManager: ThemeManager
    @Binding var currentView: ViewType
    @State private var showConfetti = false
    @State private var scoresVisible: [Bool] = []
    @State private var trophyScale: CGFloat = 0.0

    private var theme: AppTheme { themeManager.currentTheme }
    private var language: Language { mcGameState.language }

    private var winnerIndex: Int? {
        guard let maxScore = mcGameState.scores.max(), maxScore > 0 else { return nil }
        return mcGameState.scores.firstIndex(of: maxScore)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.backgroundColor, startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                Spacer()

                if let winner = winnerIndex {
                    let avatar = themeManager.teamAvatars[winner % themeManager.teamAvatars.count]
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .scaleEffect(trophyScale)
                        Image(systemName: avatar.rawValue)
                            .font(.title)
                            .foregroundColor(avatar.color)
                        Text("\(language.teamText) \(winner + 1)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(theme.textColor)
                    }
                }

                Text(language.resultsTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)

                VStack(spacing: 12) {
                    ForEach(0..<mcGameState.scores.count, id: \.self) { index in
                        let avatar = themeManager.teamAvatars[index % themeManager.teamAvatars.count]
                        let isWinner = index == winnerIndex
                        HStack {
                            Image(systemName: avatar.rawValue)
                                .foregroundColor(avatar.color)
                                .font(.title2)
                            Text("\(language.teamText) \(index + 1)")
                                .fontWeight(isWinner ? .bold : .regular)
                            Spacer()
                            Text("\(mcGameState.scores[index]) \(language.pointsSuffix)")
                                .fontWeight(.bold)
                        }
                        .font(.title2)
                        .foregroundColor(theme.textColor)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isWinner ? theme.primaryColor.opacity(0.3) : Color.white.opacity(0.1))
                        )
                        .scaleEffect(scoresVisible.indices.contains(index) && scoresVisible[index] ? 1 : 0.8)
                        .opacity(scoresVisible.indices.contains(index) && scoresVisible[index] ? 1 : 0)
                    }
                }
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    currentView = .home
                }) {
                    Text(language.newGameText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(theme.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
            .padding()

            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            SoundManager.shared.playVictory()
            scoresVisible = Array(repeating: false, count: mcGameState.scores.count)

            withAnimation(.spring(response: 0.5, dampingFraction: 0.4).delay(0.2)) {
                trophyScale = 1.0
            }

            for i in 0..<mcGameState.scores.count {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.5 + Double(i) * 0.2)) {
                    scoresVisible[i] = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}
