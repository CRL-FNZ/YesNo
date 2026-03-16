import SwiftUI

struct MCQuestion: Codable {
    let text: String
    let options: [String]
    let correctIndex: Int
    let category: String
}

struct MultipleChoiceView: View {
    @ObservedObject var mcGameState: MCGameState
    @ObservedObject var themeManager: ThemeManager
    @Binding var currentView: ViewType
    @State private var selectedIndex: Int? = nil
    @State private var showResult = false
    @State private var showQuestion = false

    private var theme: AppTheme { themeManager.currentTheme }
    private var language: Language { mcGameState.language }

    var body: some View {
        ZStack {
            LinearGradient(colors: theme.backgroundColor, startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: {
                        mcGameState.stopTimer()
                        currentView = .home
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(language.backText)
                        }
                        .foregroundColor(theme.textColor)
                    }
                    Spacer()
                    Text("Multiple Choice")
                        .font(.headline)
                        .foregroundColor(theme.textColor)
                    Spacer()
                    Color.clear.frame(width: 70)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)

                if let question = mcGameState.currentQuestion {
                    // Current team indicator
                    if mcGameState.scores.count > 1 {
                        HStack {
                            let avatar = themeManager.teamAvatars[mcGameState.currentTurn % themeManager.teamAvatars.count]
                            Image(systemName: avatar.rawValue)
                                .foregroundColor(avatar.color)
                                .font(.title2)
                            Text("\(language.turnText) \(mcGameState.currentTurn + 1)")
                                .font(.headline)
                                .foregroundColor(theme.textColor)
                        }
                        .padding(.bottom, 4)
                    }

                    // Timer
                    if case .timedMode = mcGameState.gameMode, let t = mcGameState.timeRemaining {
                        Text("\(language.timeText) \(t)s")
                            .font(.title2)
                            .foregroundColor(t <= 10 ? theme.wrongColor : theme.textColor)
                            .scaleEffect(t <= 5 ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: t)
                            .padding(.bottom, 4)
                    }

                    Spacer()

                    // Category
                    Text(question.category.uppercased())
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(theme.textColor.opacity(0.6))
                        .padding(.bottom, 8)

                    // Question
                    Text(question.text)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                        .foregroundColor(theme.textColor)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 20)
                        .animation(.easeOut(duration: 0.4), value: showQuestion)

                    Spacer()

                    // Options
                    VStack(spacing: 10) {
                        ForEach(0..<question.options.count, id: \.self) { index in
                            Button(action: {
                                guard !showResult else { return }
                                selectedIndex = index
                                showResult = true
                                let correct = index == question.correctIndex
                                if correct {
                                    SoundManager.shared.playCorrect()
                                } else {
                                    SoundManager.shared.playWrong()
                                }
                                mcGameState.submitAnswer(isCorrect: correct)
                            }) {
                                HStack {
                                    Text(optionLabel(index))
                                        .fontWeight(.bold)
                                        .frame(width: 28)
                                    Text(question.options[index])
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if showResult {
                                        if index == question.correctIndex {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if index == selectedIndex {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .font(.body)
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                                .background(optionBackground(index, correctIndex: question.correctIndex))
                                .foregroundColor(optionTextColor(index, correctIndex: question.correctIndex))
                                .cornerRadius(12)
                            }
                            .disabled(showResult)
                        }
                    }
                    .padding(.horizontal, 20)
                    .opacity(showQuestion ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: showQuestion)

                    Spacer().frame(height: 12)

                    // Team scores
                    if mcGameState.scores.count > 1 {
                        HStack {
                            ForEach(0..<mcGameState.scores.count, id: \.self) { i in
                                let avatar = themeManager.teamAvatars[i % themeManager.teamAvatars.count]
                                VStack(spacing: 2) {
                                    Image(systemName: avatar.rawValue)
                                        .foregroundColor(avatar.color)
                                        .font(.caption)
                                    Text("\(mcGameState.scores[i])")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(i == mcGameState.currentTurn ? theme.primaryColor.opacity(0.3) : Color.clear)
                                )
                                .foregroundColor(theme.textColor)
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    // Next button
                    if showResult && !mcGameState.isGameOver {
                        Button(action: nextQuestion) {
                            HStack {
                                Text(language.nextQuestionText)
                                Image(systemName: "arrow.right")
                            }
                            .font(.title3)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.teal.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer().frame(height: 16)
                }
            }
        }
        .onAppear {
            mcGameState.startTimer()
            showQuestion = true
        }
        .onChange(of: mcGameState.isGameOver) { _, newValue in
            if newValue {
                currentView = .mcResult
            }
        }
    }

    private func optionLabel(_ index: Int) -> String {
        ["A", "B", "C", "D"][index]
    }

    private func optionBackground(_ index: Int, correctIndex: Int) -> Color {
        guard showResult else {
            return Color(.systemBackground).opacity(0.8)
        }
        if index == correctIndex {
            return Color.green.opacity(0.3)
        }
        if index == selectedIndex {
            return Color.red.opacity(0.3)
        }
        return Color(.systemBackground).opacity(0.4)
    }

    private func optionTextColor(_ index: Int, correctIndex: Int) -> Color {
        guard showResult else { return .primary }
        if index == correctIndex { return .green }
        if index == selectedIndex { return .red }
        return .secondary
    }

    private func nextQuestion() {
        showQuestion = false
        selectedIndex = nil
        showResult = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showQuestion = true
        }
    }
}
